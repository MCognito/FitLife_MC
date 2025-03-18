const { model: Goal } = require("../models/goal");
const mongoose = require("mongoose");

// Helper function to validate MongoDB ObjectId
const isValidObjectId = (id) => {
  if (!id) return false;
  return mongoose.Types.ObjectId.isValid(id);
};

// Create a new goal
exports.createGoal = async (req, res) => {
  try {
    const GoalModel = Goal();
    if (!GoalModel) {
      return res.status(500).json({ message: "Database initialization error" });
    }

    const { type, targetDate, startValue, targetValue, unit, motivation } =
      req.body;

    const user_id = req.params.user_id;

    console.log("Creating goal with data:", {
      type,
      targetDate,
      startValue,
      targetValue,
      unit,
      user_id,
    });

    // Validate required fields
    if (
      !type ||
      !targetDate ||
      startValue == null ||
      targetValue == null ||
      !unit
    ) {
      return res.status(400).json({ message: "Missing required fields" });
    }

    // Map frontend goal types to backend enum types
    const typeMap = {
      "Weight Loss": "Lose Weight",
      "Weight Gain": "Gain Weight",
      Steps: "Build Stamina",
      "Water Intake": "Maintain Weight",
      "Exercise Minutes": "Build Strength",
      "Sleep Hours": "Maintain Weight",
    };

    // Convert frontend type to backend enum type
    const backendType = typeMap[type] || type;

    // Create milestones based on goal type
    const milestones = generateMilestones(startValue, targetValue, type);

    const goal = new GoalModel({
      user_id,
      type: backendType, // Use the mapped backend type
      targetDate,
      startValue,
      currentValue: startValue,
      targetValue,
      unit,
      milestones,
      motivation: {
        quote: motivation?.quote || getMotivationalQuote(type),
        reminder: motivation?.reminder || {
          enabled: true,
          frequency: "DAILY",
          time: "09:00",
        },
      },
    });

    await goal.save();
    res.status(201).json(goal);
  } catch (error) {
    console.error("Error creating goal:", error);
    res
      .status(500)
      .json({ message: "Error creating goal", error: error.message });
  }
};

// Get all goals for a user
exports.getUserGoals = async (req, res) => {
  try {
    const GoalModel = Goal();
    if (!GoalModel) {
      return res.status(500).json({ message: "Database initialization error" });
    }

    const user_id = req.params.user_id;
    const goals = await GoalModel.find({ user_id }).sort({ createdAt: -1 });

    // Add progress calculations for each goal
    const goalsWithProgress = goals.map((goal) => {
      const progress = goal.getProgressPercentage();
      const isOnTrack = goal.isOnTrack();
      return {
        ...goal.toObject(),
        progress,
        isOnTrack,
      };
    });

    res.json(goalsWithProgress);
  } catch (error) {
    console.error("Error getting goals:", error);
    res
      .status(500)
      .json({ message: "Error getting goals", error: error.message });
  }
};

// Update goal progress
exports.updateGoalProgress = async (req, res) => {
  try {
    const GoalModel = Goal();
    if (!GoalModel) {
      return res.status(500).json({ message: "Database initialization error" });
    }

    const { goal_id } = req.params;
    const { currentValue, note } = req.body;

    if (!isValidObjectId(goal_id)) {
      return res.status(400).json({ message: "Invalid goal ID" });
    }

    const goal = await GoalModel.findById(goal_id);
    if (!goal) {
      return res.status(404).json({ message: "Goal not found" });
    }

    // Update current value
    goal.currentValue = currentValue;

    // Add note if provided
    if (note) {
      goal.notes.push({ content: note });
    }

    // Update weekly progress
    const currentWeek = Math.ceil(
      (new Date() - goal.startDate) / (1000 * 60 * 60 * 24 * 7)
    );
    goal.weeklyProgress.push({
      week: currentWeek,
      value: currentValue,
      date: new Date(),
    });

    // Check and update milestones
    goal.milestones = goal.milestones.map((milestone) => {
      if (
        !milestone.achieved &&
        ((goal.targetValue > goal.startValue &&
          currentValue >= milestone.value) ||
          (goal.targetValue < goal.startValue &&
            currentValue <= milestone.value))
      ) {
        milestone.achieved = true;
        milestone.achievedDate = new Date();
      }
      return milestone;
    });

    // Check if goal is completed
    if (
      (goal.targetValue > goal.startValue &&
        currentValue >= goal.targetValue) ||
      (goal.targetValue < goal.startValue && currentValue <= goal.targetValue)
    ) {
      goal.status = "Completed";
    }

    await goal.save();

    // Return updated goal with progress calculations
    const progress = goal.getProgressPercentage();
    const isOnTrack = goal.isOnTrack();

    res.json({
      ...goal.toObject(),
      progress,
      isOnTrack,
    });
  } catch (error) {
    console.error("Error updating goal progress:", error);
    res
      .status(500)
      .json({ message: "Error updating goal progress", error: error.message });
  }
};

// Helper function to generate milestones
function generateMilestones(startValue, targetValue, type) {
  console.log(
    `Generating milestones for type: ${type}, start: ${startValue}, target: ${targetValue}`
  );

  const milestones = [];
  const totalChange = targetValue - startValue;
  const steps = 4; // Number of milestones

  for (let i = 1; i <= steps; i++) {
    const milestone = {
      value: startValue + totalChange * (i / steps),
      achieved: false,
      reward: getMilestoneReward(type, i),
    };
    milestones.push(milestone);
  }

  return milestones;
}

// Helper function to get milestone rewards
function getMilestoneReward(type, milestone) {
  // Map frontend goal types to backend enum types
  const typeMap = {
    "Weight Loss": "Lose Weight",
    "Weight Gain": "Gain Weight",
    Steps: "Build Stamina",
    "Water Intake": "Maintain Weight",
    "Exercise Minutes": "Build Strength",
    "Sleep Hours": "Maintain Weight",
  };

  // Convert frontend type to backend enum type
  const backendType = typeMap[type] || type;

  const rewards = {
    "Lose Weight": [
      "First step towards a healthier you!",
      "You're making great progress!",
      "Almost there, keep pushing!",
      "You're unstoppable!",
    ],
    "Gain Weight": [
      "Building foundations!",
      "Growing stronger!",
      "Impressive gains!",
      "Peak performance achieved!",
    ],
    "Build Strength": [
      "Foundation of strength laid!",
      "Power level increasing!",
      "Strength gains unlocked!",
      "Ultimate strength achieved!",
    ],
    "Build Stamina": [
      "Endurance journey begun!",
      "Stamina increasing!",
      "Energy levels maxing!",
      "Peak endurance reached!",
    ],
    "Maintain Weight": [
      "Consistency is key!",
      "Balance maintained!",
      "Healthy habits formed!",
      "Lifestyle mastered!",
    ],
  };

  // Check if the backend type exists in rewards
  if (!rewards[backendType]) {
    console.log(`Unknown goal type: ${type}, mapped to: ${backendType}`);
    return "Keep going!";
  }

  // Check if the milestone index is valid
  if (milestone < 1 || milestone > rewards[backendType].length) {
    console.log(
      `Invalid milestone index: ${milestone} for type: ${backendType}`
    );
    return "Keep going!";
  }

  return rewards[backendType][milestone - 1] || "Keep going!";
}

// Helper function to get motivational quotes
function getMotivationalQuote(type) {
  // Map frontend goal types to backend enum types
  const typeMap = {
    "Weight Loss": "Lose Weight",
    "Weight Gain": "Gain Weight",
    Steps: "Build Stamina",
    "Water Intake": "Maintain Weight",
    "Exercise Minutes": "Build Strength",
    "Sleep Hours": "Maintain Weight",
  };

  // Convert frontend type to backend enum type
  const backendType = typeMap[type] || type;

  const quotes = {
    "Lose Weight":
      "Every step forward is a step towards your goal. You've got this!",
    "Gain Weight": "Building strength takes time. Trust the process!",
    "Build Strength": "Your only limit is you. Push through it!",
    "Build Stamina": "Energy and persistence conquer all things!",
    "Maintain Weight":
      "Balance is not something you find, it's something you create.",
  };

  return quotes[backendType] || "Your journey to better health starts here!";
}

// Delete a goal
exports.deleteGoal = async (req, res) => {
  try {
    const GoalModel = Goal();
    if (!GoalModel) {
      return res.status(500).json({ message: "Database initialization error" });
    }

    const { goal_id } = req.params;

    if (!isValidObjectId(goal_id)) {
      return res.status(400).json({ message: "Invalid goal ID" });
    }

    const goal = await GoalModel.findByIdAndDelete(goal_id);
    if (!goal) {
      return res.status(404).json({ message: "Goal not found" });
    }

    res.json({ message: "Goal deleted successfully" });
  } catch (error) {
    console.error("Error deleting goal:", error);
    res
      .status(500)
      .json({ message: "Error deleting goal", error: error.message });
  }
};

// Abandon a goal
exports.abandonGoal = async (req, res) => {
  try {
    const GoalModel = Goal();
    if (!GoalModel) {
      return res.status(500).json({ message: "Database initialization error" });
    }

    const { goal_id } = req.params;
    const { reason } = req.body;

    if (!isValidObjectId(goal_id)) {
      return res.status(400).json({ message: "Invalid goal ID" });
    }

    const goal = await GoalModel.findById(goal_id);
    if (!goal) {
      return res.status(404).json({ message: "Goal not found" });
    }

    goal.status = "Abandoned";
    if (reason) {
      goal.notes.push({
        content: `Goal abandoned: ${reason}`,
      });
    }

    await goal.save();
    res.json(goal);
  } catch (error) {
    console.error("Error abandoning goal:", error);
    res
      .status(500)
      .json({ message: "Error abandoning goal", error: error.message });
  }
};
