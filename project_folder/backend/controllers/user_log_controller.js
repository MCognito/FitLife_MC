const { model: UserLog } = require("../models/user_log");
const { checkAndUpdateStreak } = require("./streak_controller");

/**
 * Gets or creates a user log document for a specific user
 * 
 * This function first tries to find an existing log document for the user.
 * If none exists, it creates a new one with empty arrays for each log type.
 * 
 * @param {string} userId - The ID of the user to get/create logs for
 * @returns {Object} The user log document
 */
const getOrCreateUserLog = async (userId) => {
  try {
    const UserLogModel = UserLog();
    if (!UserLogModel) {
      throw new Error("Database initialization error");
    }

    let userLog = await UserLogModel.findOne({ user_id: userId });
    if (!userLog) {
      // Create a new log document if none exists
      userLog = await UserLogModel.create({
        user_id: userId,
        weight_logs: [],
        water_logs: [],
        step_logs: [],
      });
    }
    return userLog;
  } catch (error) {
    console.error("Error in getOrCreateUserLog:", error);
    throw error;
  }
};

/**
 * Checks if two dates are on the same day
 * 
 * Compares year, month, and day values to determine if two dates
 * fall on the same calendar day, ignoring time components.
 * 
 * @param {Date} date1 - First date to compare
 * @param {Date} date2 - Second date to compare
 * @returns {boolean} True if dates are on the same day
 */
const isSameDay = (date1, date2) => {
  return (
    date1.getFullYear() === date2.getFullYear() &&
    date1.getMonth() === date2.getMonth() &&
    date1.getDate() === date2.getDate()
  );
};

/**
 * Adds a new log entry for a user
 * 
 * This endpoint handles adding weight, water, and step logs.
 * It also triggers streak updates when step logs meet the threshold.
 * 
 * @route POST /api/logs/add
 */
exports.addLogEntry = async (req, res) => {
  try {
    const { user_id, type, value } = req.body;

    // Make sure we have all required fields
    if (!user_id || !type || value === undefined) {
      return res.status(400).json({
        success: false,
        message: "Missing required fields",
      });
    }

    // Make sure value is a number
    const numericValue = parseFloat(value);
    if (isNaN(numericValue)) {
      return res.status(400).json({
        success: false,
        message: "Value must be a number",
      });
    }

    // Get the log model
    const LogModel = UserLog();
    if (!LogModel) {
      return res.status(500).json({
        success: false,
        message: "Database initialization error",
      });
    }

    // Current date for the new log
    const now = new Date();

    // Find existing log document for this user or create a new one
    let userLog = await LogModel.findOne({ user_id });
    if (!userLog) {
      // First time logging - create a new document with empty arrays
      userLog = new LogModel({
        user_id,
        weight_logs: [],
        water_logs: [],
        step_logs: [],
      });
    }

    // Determine which log array to use based on type
    let logArray;
    if (type === "weight") {
      logArray = userLog.weight_logs;
    } else if (type === "water") {
      logArray = userLog.water_logs;
    } else if (type === "steps") {
      logArray = userLog.step_logs;
    } else {
      return res.status(400).json({
        success: false,
        message: "Invalid log type",
      });
    }

    // Check if there's already a log entry for today
    const todayIndex = logArray.findIndex((log) =>
      isSameDay(new Date(log.date), now)
    );

    let logEntry;
    let isNewEntry = false;

    if (todayIndex !== -1) {
      // Update existing log for today
      logEntry = logArray[todayIndex];
      logEntry.value = numericValue;
      logEntry.date = now; // Update timestamp
      console.log(`Updated existing log for today:`);
    } else {
      // Create new log entry
      logEntry = {
        value: numericValue,
        date: now,
      };
      logArray.push(logEntry);
      isNewEntry = true;
      console.log(`Created new log:`);
    }

    // Save the updated log document
    await userLog.save();

    // For steps logs, check if they meet the threshold for streak
    let streakResult = null;
    if (type === "steps") {
      try {
        const streakController = require("./streak_controller");
        streakResult = await streakController.checkAndUpdateStreak(
          user_id,
          "steps",
          numericValue
        );
        console.log("[STREAK] Streak update result:", streakResult);
      } catch (streakError) {
        console.error("Error updating streak:", streakError);
        // Continue with saving the log even if streak update fails
      }
    }

    // Return success with appropriate message
    return res.status(200).json({
      success: true,
      message: isNewEntry
        ? "Log entry added successfully"
        : "Log entry updated successfully",
      data: logEntry,
      streak: streakResult,
    });
  } catch (error) {
    console.error("Error adding/updating log entry:", error);
    return res.status(500).json({
      success: false,
      message: "Error adding/updating log entry",
      error: error.message,
    });
  }
};

// Get user logs
exports.getUserLogs = async (req, res) => {
  try {
    const userId = req.params.user_id;
    const userLog = await getOrCreateUserLog(userId);

    res.status(200).json({
      success: true,
      data: {
        weight_logs: userLog.weight_logs.sort((a, b) => b.date - a.date),
        water_logs: userLog.water_logs.sort((a, b) => b.date - a.date),
        step_logs: userLog.step_logs.sort((a, b) => b.date - a.date),
      },
    });
  } catch (error) {
    console.error("Error getting user logs:", error);
    res.status(500).json({
      success: false,
      message: "Error getting user logs",
      error: error.message,
    });
  }
};

// Get logs by type and date range
exports.getLogsByDateRange = async (req, res) => {
  try {
    const { user_id, type, start_date, end_date } = req.query;

    if (!user_id || !type) {
      return res.status(400).json({
        success: false,
        message: "Missing required fields",
      });
    }

    const userLog = await getOrCreateUserLog(user_id);
    let logs;

    switch (type) {
      case "weight":
        logs = userLog.weight_logs;
        break;
      case "water_intake":
        logs = userLog.water_logs;
        break;
      case "steps":
        logs = userLog.step_logs;
        break;
      default:
        return res.status(400).json({
          success: false,
          message: "Invalid log type",
        });
    }

    // Filter by date range if provided
    if (start_date && end_date) {
      const startDate = new Date(start_date);
      const endDate = new Date(end_date);
      logs = logs.filter((log) => log.date >= startDate && log.date <= endDate);
    }

    // Sort by date
    logs = logs.sort((a, b) => a.date - b.date);

    res.status(200).json({
      success: true,
      data: logs,
    });
  } catch (error) {
    console.error("Error getting logs by date range:", error);
    res.status(500).json({
      success: false,
      message: "Error getting logs",
      error: error.message,
    });
  }
};

// Create default logs for a new user
exports.createDefaultUserLog = async (userId) => {
  try {
    await getOrCreateUserLog(userId);
    return true;
  } catch (error) {
    console.error("Error creating default user log:", error);
    return false;
  }
};
