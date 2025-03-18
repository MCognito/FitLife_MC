const { model: Log } = require("../models/log");
const { model: UserLog } = require("../models/user_log");
const { checkAndUpdateStreak } = require("./streak_controller");
const mongoose = require("mongoose");
const axios = require("axios");

exports.addLog = async (req, res) => {
  const { user_id, type, value, unit } = req.body;

  try {
    console.log(
      `Adding log: type=${type}, value=${value}, unit=${unit} for user=${user_id}`
    );

    // Get the Log model
    const LogModel = Log();
    if (!LogModel) {
      console.error("Log model is not initialized");
      return res.status(500).json({ message: "Database initialization error" });
    }

    // Validate log type
    const validTypes = ["water_intake", "sleep", "weight", "steps"];
    if (!validTypes.includes(type)) {
      return res.status(400).json({ message: "Invalid log type" });
    }

    // Get today's date with time set to midnight for comparison
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // Check if a log for this type already exists today
    const existingLog = await LogModel.findOne({
      user_id,
      type,
      date: {
        $gte: today,
        $lt: new Date(today.getTime() + 24 * 60 * 60 * 1000),
      },
    });

    let log;
    let responseData;

    if (existingLog) {
      // Update existing log
      console.log(`Updating existing log: ${existingLog._id}`);
      existingLog.value = value;
      existingLog.unit = unit;
      log = await existingLog.save();
      responseData = log;
    } else {
      // Check if we have a consolidated log for this user
      const userLog = await getOrCreateUserLog(user_id);

      // Just update the consolidated log and return success
      if (userLog) {
        console.log(`Updating consolidated log`);
        await updateUserLogArray(user_id, type, value);
        responseData = {
          message: "Log updated in consolidated format",
          type,
          value,
          unit,
          date: new Date(),
        };
      } else {
        // If no consolidated log exists, create a new individual log
        console.log(`Creating new individual log`);
        log = await LogModel.create({ user_id, type, value, unit });
        responseData = log;
      }
    }

    // Update streak if this is a steps log
    if (type === "steps") {
      console.log(
        `[LOG] Processing step log for streak: user_id=${user_id}, value=${value}`
      );
      try {
        // Update streak based on steps
        const streakResult = await checkAndUpdateStreak(
          user_id,
          "steps",
          value
        );
        console.log(
          `[LOG] Streak update for steps: ${JSON.stringify(streakResult)}`
        );

        // Add streak info to response
        responseData.streak = streakResult;
      } catch (streakError) {
        console.error(
          `[LOG] Error updating streak for steps: ${streakError.message}`
        );
        console.error(streakError.stack);
      }
    }

    // Add points to user score based on log type
    try {
      // Get the host from the request
      const host = req.get("host");
      const protocol = req.protocol;
      const baseUrl = `${protocol}://${host}`;

      // Points based on log type
      let points = 0;
      let action = "";

      switch (type) {
        case "weight":
          points = 20;
          action = "log_weight";
          break;
        case "water_intake":
          points = 15;
          action = "log_water";
          break;
        case "steps":
          // 10 points for every 1000 steps, up to 50 points
          points = Math.min(Math.floor(value / 1000) * 10, 50);
          action = "log_steps";
          break;
        default:
          points = 10;
          action = "log_other";
      }

      // Make a request to the user score API
      if (points > 0) {
        console.log(
          `Sending points request to: ${baseUrl}/api/user-scores/add for ${action} (${points} points)`
        );

        const scoreResponse = await axios.post(
          `${baseUrl}/api/user-scores/add`,
          {
            user_id,
            action,
            points,
          },
          {
            headers: {
              Authorization: req.headers.authorization,
              "Content-Type": "application/json",
            },
          }
        );

        console.log(`Score API response: ${scoreResponse.status}`);
        console.log(`Added ${points} points for ${type} log`);
      }
    } catch (scoreError) {
      console.error("Error adding points for log:", scoreError.message);
      if (scoreError.response) {
        // The request was made and the server responded with a status code
        // that falls out of the range of 2xx
        console.error("Score API error response:", {
          status: scoreError.response.status,
          data: scoreError.response.data,
          headers: scoreError.response.headers,
        });
      } else if (scoreError.request) {
        // The request was made but no response was received
        console.error("Score API no response:", scoreError.request);
      } else {
        // Something happened in setting up the request that triggered an Error
        console.error("Score API request setup error:", scoreError.message);
      }
      // Continue even if score update fails
    }

    // Send the response
    res.status(existingLog ? 200 : 201).json(responseData);
  } catch (error) {
    console.error("Error adding log:", error);
    res.status(500).json({
      success: false,
      message: "Error adding log",
      error: error.message,
    });
  }
};

exports.getLogs = async (req, res) => {
  try {
    const userId = req.params.user_id;

    // First, try to get the consolidated log
    const userLog = await getOrCreateUserLog(userId);

    if (userLog) {
      // Convert the consolidated log to the format expected by the client
      const formattedLogs = [];

      // Add the latest weight log
      if (userLog.weight_log && userLog.weight_log.length > 0) {
        formattedLogs.push({
          user_id: userId,
          type: "weight",
          value: userLog.weight_log[userLog.weight_log.length - 1],
          unit: "kg",
          date: userLog.last_update_weight,
        });
      }

      // Add the latest water intake log
      if (userLog.water_log && userLog.water_log.length > 0) {
        formattedLogs.push({
          user_id: userId,
          type: "water_intake",
          value: userLog.water_log[userLog.water_log.length - 1],
          unit: "ml",
          date: userLog.last_update_water,
        });
      }

      // Add the latest steps log
      if (userLog.step_log && userLog.step_log.length > 0) {
        formattedLogs.push({
          user_id: userId,
          type: "steps",
          value: userLog.step_log[userLog.step_log.length - 1],
          unit: "steps",
          date: userLog.last_update_step,
        });
      }

      return res.json(formattedLogs);
    }

    // If no consolidated log exists, fall back to the old method
    // Get the Log model
    const LogModel = Log();
    if (!LogModel) {
      console.error("Log model is not initialized");
      return res.status(500).json({ message: "Database initialization error" });
    }

    // Get today's date with time set to midnight for comparison
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // Check if logs exist for today
    const todayLogs = await LogModel.find({
      user_id: userId,
      date: {
        $gte: today,
        $lt: new Date(today.getTime() + 24 * 60 * 60 * 1000),
      },
    });

    // Create default logs for today if they don't exist
    if (todayLogs.length < 3) {
      // We expect 3 log types: weight, water_intake, steps
      await createDailyLogs(userId, todayLogs);
    }

    // Get all logs for the user
    const logs = await LogModel.find({ user_id: userId });
    res.json(logs);
  } catch (error) {
    console.error("Error getting logs:", error);
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

// Create default logs for a new user
exports.createDefaultLogs = async (userId) => {
  try {
    // First, check if a consolidated log already exists
    const userLog = await getOrCreateUserLog(userId);

    // If we already have a consolidated log, we don't need to create individual logs
    if (userLog) {
      console.log(`Consolidated log already exists`);
      return true;
    }

    // If no consolidated log exists, create one
    await getOrCreateUserLog(userId);
    console.log(`Default logs created`);

    return true;
  } catch (error) {
    console.error("Error creating default logs:", error);
    return false;
  }
};

// Create daily logs for a user
const createDailyLogs = async (userId, existingLogs = []) => {
  try {
    // First, check if a consolidated log exists
    const userLog = await getOrCreateUserLog(userId);

    if (userLog) {
      console.log(`Using consolidated log`);
      return true;
    }

    // If no consolidated log exists, fall back to the old method
    // Get the Log model
    const LogModel = Log();
    if (!LogModel) {
      console.error("Log model is not initialized");
      return false;
    }

    // Check which log types already exist for today
    const existingTypes = existingLogs.map((log) => log.type);

    // Create an array to hold new logs
    const newLogs = [];

    // For weight, get the most recent value to carry over
    if (!existingTypes.includes("weight")) {
      let weightValue = 0;
      const lastWeightLog = await LogModel.findOne({
        user_id: userId,
        type: "weight",
      }).sort({ date: -1 });

      if (lastWeightLog) {
        weightValue = lastWeightLog.value;
      }

      newLogs.push({
        user_id: userId,
        type: "weight",
        value: weightValue,
        unit: "kg",
      });
    }

    // For water_intake, always start at 0 for a new day
    if (!existingTypes.includes("water_intake")) {
      newLogs.push({
        user_id: userId,
        type: "water_intake",
        value: 0,
        unit: "ml",
      });
    }

    // For steps, always start at 0 for a new day
    if (!existingTypes.includes("steps")) {
      newLogs.push({
        user_id: userId,
        type: "steps",
        value: 0,
        unit: "steps",
      });
    }

    // Create the new logs if there are any
    if (newLogs.length > 0) {
      await LogModel.insertMany(newLogs);
      console.log(`Daily logs created`);
    }

    return true;
  } catch (error) {
    console.error("Error creating daily logs:", error);
    return false;
  }
};

// New consolidated user log functions

// Get or create user log document
const getOrCreateUserLog = async (userId) => {
  try {
    const UserLogModel = UserLog();
    if (!UserLogModel) {
      console.error("UserLog model is not initialized");
      throw new Error("Database initialization error");
    }

    // Try to find existing user log
    let userLog = await UserLogModel.findOne({ user_id: userId });

    // If no user log exists, create one
    if (!userLog) {
      console.log(`Creating new consolidated log`);

      // Create a document with the correct structure
      const newUserLog = {
        user_id: userId,
        water_log: [0],
        weight_log: [0],
        step_log: [0],
        last_update_water: new Date(),
        last_update_weight: new Date(),
        last_update_step: new Date(),
      };

      // Use findOneAndUpdate with upsert to avoid race conditions
      userLog = await UserLogModel.findOneAndUpdate(
        { user_id: userId },
        newUserLog,
        {
          upsert: true,
          new: true,
          setDefaultsOnInsert: true,
        }
      );

      console.log(`Created consolidated log`);
    }

    return userLog;
  } catch (error) {
    console.error("Error in getOrCreateUserLog:", error);
    throw error;
  }
};

// Update user log array
const updateUserLogArray = async (userId, type, value) => {
  try {
    const userLog = await getOrCreateUserLog(userId);
    const now = new Date();

    // Helper function to check if two dates are the same day
    const isSameDay = (date1, date2) => {
      return (
        date1.getFullYear() === date2.getFullYear() &&
        date1.getMonth() === date2.getMonth() &&
        date1.getDate() === date2.getDate()
      );
    };

    if (type === "water_intake") {
      // Check if we already have an update today
      if (
        userLog.last_update_water &&
        isSameDay(userLog.last_update_water, now)
      ) {
        // Update the last value if it's the same day
        if (userLog.water_log.length > 0) {
          userLog.water_log[userLog.water_log.length - 1] = value;
        } else {
          userLog.water_log.push(value);
        }
      } else {
        // Add a new value for a new day
        userLog.water_log.push(value);
      }
      userLog.last_update_water = now;
    } else if (type === "weight") {
      // Check if we already have an update today
      if (
        userLog.last_update_weight &&
        isSameDay(userLog.last_update_weight, now)
      ) {
        // Update the last value if it's the same day
        if (userLog.weight_log.length > 0) {
          userLog.weight_log[userLog.weight_log.length - 1] = value;
        } else {
          userLog.weight_log.push(value);
        }
      } else {
        // For a new day, copy the last weight value and then update it
        if (userLog.weight_log.length > 0) {
          const lastWeight = userLog.weight_log[userLog.weight_log.length - 1];
          userLog.weight_log.push(value);
        } else {
          userLog.weight_log.push(value);
        }
      }
      userLog.last_update_weight = now;
    } else if (type === "steps") {
      // Check if we already have an update today
      if (
        userLog.last_update_step &&
        isSameDay(userLog.last_update_step, now)
      ) {
        // Update the last value if it's the same day
        if (userLog.step_log.length > 0) {
          userLog.step_log[userLog.step_log.length - 1] = value;
        } else {
          userLog.step_log.push(value);
        }
      } else {
        // Add a new value for a new day (steps reset to 0 each day)
        userLog.step_log.push(value);
      }
      userLog.last_update_step = now;
    }

    await userLog.save();
    return true;
  } catch (error) {
    console.error("Error updating user log array:", error);
    throw error;
  }
};

// Get consolidated user logs
exports.getConsolidatedLogs = async (req, res) => {
  try {
    const UserLogModel = UserLog();
    if (!UserLogModel) {
      console.error("UserLog model is not initialized");
      return res.status(500).json({ message: "Database initialization error" });
    }

    const userId = req.params.user_id;

    // Get or create user log
    const userLog = await getOrCreateUserLog(userId);

    // Format response
    const response = {
      user_id: userLog.user_id,
      logs: {
        water_intake: {
          values: userLog.water_log || [],
          last_update: userLog.last_update_water,
        },
        weight: {
          values: userLog.weight_log || [],
          last_update: userLog.last_update_weight,
        },
        steps: {
          values: userLog.step_log || [],
          last_update: userLog.last_update_step,
        },
      },
    };

    res.json(response);
  } catch (error) {
    console.error("Error getting consolidated logs:", error);
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

// Update consolidated user log
exports.updateConsolidatedLog = async (req, res) => {
  try {
    const { user_id, type, value } = req.body;

    // Validate log type
    const validTypes = ["water_intake", "weight", "steps"];
    if (!validTypes.includes(type)) {
      return res.status(400).json({ message: "Invalid log type" });
    }

    // Update the user log array
    await updateUserLogArray(user_id, type, value);

    // Create response data
    const responseData = {
      success: true,
      message: `${type} log updated successfully`,
      type,
      value,
      date: new Date(),
    };

    // Update streak if this is a steps log
    if (type === "steps") {
      console.log(
        `[LOG] Processing step log for streak: user_id=${user_id}, value=${value}`
      );
      try {
        // Update streak based on steps
        const streakResult = await checkAndUpdateStreak(
          user_id,
          "steps",
          value
        );
        console.log(
          `[LOG] Streak update for steps: ${JSON.stringify(streakResult)}`
        );

        // Add streak info to response
        responseData.streak = streakResult;
      } catch (streakError) {
        console.error(
          `[LOG] Error updating streak for steps: ${streakError.message}`
        );
        console.error(streakError.stack);
      }
    }

    // Return success response
    res.status(200).json(responseData);
  } catch (error) {
    console.error("Error updating consolidated log:", error);
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

// Migrate existing logs to consolidated format
const migrateLogsToConsolidated = async (userId) => {
  try {
    // Get the Log model
    const LogModel = Log();
    if (!LogModel) {
      console.error("Log model is not initialized");
      return false;
    }

    // Get all logs for the user
    const logs = await LogModel.find({ user_id: userId }).sort({ date: 1 });

    if (logs.length === 0) {
      console.log(`No logs to migrate`);
      return true;
    }

    // Get or create the consolidated log
    const userLog = await getOrCreateUserLog(userId);

    // Group logs by type
    const weightLogs = logs.filter((log) => log.type === "weight");
    const waterLogs = logs.filter((log) => log.type === "water_intake");
    const stepsLogs = logs.filter((log) => log.type === "steps");

    // Helper function to check if two dates are the same day
    const isSameDay = (date1, date2) => {
      return (
        date1.getFullYear() === date2.getFullYear() &&
        date1.getMonth() === date2.getMonth() &&
        date1.getDate() === date2.getDate()
      );
    };

    // Process weight logs
    if (weightLogs.length > 0) {
      // Reset the weight log
      userLog.weight_log = [0];
      userLog.last_update_weight = new Date(0);

      // Add each weight log, avoiding duplicates for the same day
      for (const log of weightLogs) {
        if (
          !userLog.last_update_weight ||
          !isSameDay(userLog.last_update_weight, log.date)
        ) {
          // New day, add a new entry
          userLog.weight_log.push(log.value);
        } else {
          // Same day, update the last entry
          userLog.weight_log[userLog.weight_log.length - 1] = log.value;
        }
        userLog.last_update_weight = log.date;
      }
    }

    // Process water logs
    if (waterLogs.length > 0) {
      // Reset the water log
      userLog.water_log = [0];
      userLog.last_update_water = new Date(0);

      // Add each water log, avoiding duplicates for the same day
      for (const log of waterLogs) {
        if (
          !userLog.last_update_water ||
          !isSameDay(userLog.last_update_water, log.date)
        ) {
          // New day, add a new entry
          userLog.water_log.push(log.value);
        } else {
          // Same day, update the last entry
          userLog.water_log[userLog.water_log.length - 1] = log.value;
        }
        userLog.last_update_water = log.date;
      }
    }

    // Process steps logs
    if (stepsLogs.length > 0) {
      // Reset the steps log
      userLog.step_log = [0];
      userLog.last_update_step = new Date(0);

      // Add each steps log, avoiding duplicates for the same day
      for (const log of stepsLogs) {
        if (
          !userLog.last_update_step ||
          !isSameDay(userLog.last_update_step, log.date)
        ) {
          // New day, add a new entry
          userLog.step_log.push(log.value);
        } else {
          // Same day, update the last entry
          userLog.step_log[userLog.step_log.length - 1] = log.value;
        }
        userLog.last_update_step = log.date;
      }
    }

    // Save the consolidated log
    await userLog.save();
    console.log(
      `Migrated ${logs.length} logs to consolidated format for user: ${userId}`
    );

    return true;
  } catch (error) {
    console.error("Error migrating logs to consolidated format:", error);
    return false;
  }
};

// Add a route to migrate logs
exports.migrateUserLogs = async (req, res) => {
  try {
    const userId = req.params.user_id;

    // Migrate logs
    const success = await migrateLogsToConsolidated(userId);

    if (success) {
      res.status(200).json({ message: "Logs migrated successfully" });
    } else {
      res.status(500).json({ message: "Failed to migrate logs" });
    }
  } catch (error) {
    console.error("Error in migrateUserLogs:", error);
    res.status(500).json({ message: "Server error", error: error.message });
  }
};
