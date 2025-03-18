const { model: UserScore } = require("../models/user_score");
const { model: UserProfile } = require("../models/user_profile");
const mongoose = require("mongoose");

// Helper function to validate MongoDB ObjectId
const isValidObjectId = (id) => {
  if (!id) return false;

  // If it's already an ObjectId, it's valid
  if (id instanceof mongoose.Types.ObjectId) return true;

  // If it's a string that looks like an ObjectId (24 hex chars)
  if (typeof id === "string" && /^[0-9a-fA-F]{24}$/.test(id)) return true;

  // Otherwise, use mongoose's built-in validation
  try {
    return mongoose.Types.ObjectId.isValid(id);
  } catch (e) {
    console.error(`[DEBUG] Error validating ObjectId: ${e.message}`);
    return false;
  }
};

// Calculate level based on total score
// Level formula: Level = 1 + floor(sqrt(total_score / 100))
// This creates a progressively harder level curve
const calculateLevel = (totalScore) => {
  return Math.floor(1 + Math.sqrt(totalScore / 100));
};

// Helper function to sync level with user profile
const syncLevelWithUserProfile = async (userId, level) => {
  try {
    if (!isValidObjectId(userId)) {
      console.error("Invalid user ID format for syncing level");
      return false;
    }

    // Get user profile
    const UserProfileModel = UserProfile();
    if (!UserProfileModel) {
      console.error("UserProfile model is not initialized");
      return false;
    }

    // Update the level in the user profile
    await UserProfileModel.findOneAndUpdate(
      { user_id: userId },
      {
        $set: {
          "fitnessStats.level": level,
          "fitnessStats.experiencePoints": level * 100, // Simple approximation
        },
      },
      { new: true, upsert: true }
    );

    console.log(`Synced level ${level} to user profile`);
    return true;
  } catch (error) {
    console.error("Error syncing level with user profile:", error);
    return false;
  }
};

// Get user score and level
exports.getUserScore = async (req, res) => {
  try {
    const userId = req.params.userId;
    console.log("Fetching score");

    // Validate userId
    if (!isValidObjectId(userId)) {
      return res.status(400).json({ message: "Invalid user ID format" });
    }

    // Get or create user score
    let userScore = await UserScore().findOne({ user_id: userId });

    if (!userScore) {
      // Create new user score if it doesn't exist
      const UserScoreModel = UserScore();
      userScore = new UserScoreModel({
        user_id: userId,
        total_score: 0,
        level: 1,
        daily_points: 0,
        last_reset_date: new Date(),
        score_history: [],
      });
      await userScore.save();
    }

    // Check if daily points need to be reset
    const today = new Date();
    const lastResetDate = new Date(userScore.last_reset_date);
    if (
      today.getDate() !== lastResetDate.getDate() ||
      today.getMonth() !== lastResetDate.getMonth() ||
      today.getFullYear() !== lastResetDate.getFullYear()
    ) {
      // Reset daily points if it's a new day
      userScore.daily_points = 0;
      userScore.last_reset_date = today;
      await userScore.save();
    }

    // Sync level with user profile
    await syncLevelWithUserProfile(userId, userScore.level);

    res.json({
      total_score: userScore.total_score,
      level: userScore.level,
      daily_points: userScore.daily_points,
      score_history: userScore.score_history,
    });
  } catch (error) {
    console.error("Error details:", error);
    res.status(500).json({ message: "Error fetching user score" });
  }
};

// Add points to user score
exports.addPoints = async (req, res) => {
  try {
    const { user_id, action, points } = req.body;
    console.log(`[DEBUG] Adding points: action=${action}, points=${points}`);

    // Validate userId
    if (!isValidObjectId(user_id)) {
      console.log(`[DEBUG] Invalid user ID format`);
      return res.status(400).json({ message: "Invalid user ID format" });
    }

    // Validate required fields
    if (!action) {
      console.log(`[DEBUG] Action is required but was not provided`);
      return res.status(400).json({ message: "Action is required" });
    }

    if (!points || isNaN(points) || points <= 0) {
      console.log(`[DEBUG] Invalid points value`);
      return res
        .status(400)
        .json({ message: "Valid points value is required" });
    }

    // Get or create user score
    let userScore = await UserScore().findOne({ user_id });
    console.log(`[DEBUG] Found user score: ${userScore ? "Yes" : "No"}`);

    if (!userScore) {
      // Create new user score if it doesn't exist
      console.log(`[DEBUG] Creating new user score`);
      const UserScoreModel = UserScore();
      userScore = new UserScoreModel({
        user_id,
        total_score: 0,
        level: 1,
        daily_points: 0,
        last_reset_date: new Date(),
        score_history: [],
      });
    }

    // Check if daily points need to be reset
    const today = new Date();
    const lastResetDate = new Date(userScore.last_reset_date);
    console.log(`[DEBUG] Last reset date: ${lastResetDate.toISOString()}`);
    console.log(`[DEBUG] Today: ${today.toISOString()}`);

    if (
      today.getDate() !== lastResetDate.getDate() ||
      today.getMonth() !== lastResetDate.getMonth() ||
      today.getFullYear() !== lastResetDate.getFullYear()
    ) {
      // Reset daily points if it's a new day
      console.log(`[DEBUG] Resetting daily points (new day)`);
      userScore.daily_points = 0;
      userScore.last_reset_date = today;
    }

    // Check if daily points cap (300) has been reached
    console.log(`[DEBUG] Current daily points: ${userScore.daily_points}/300`);
    if (userScore.daily_points >= 300) {
      console.log(`[DEBUG] Daily points cap reached`);
      return res.status(200).json({
        success: false,
        message: "Daily points cap reached",
        total_score: userScore.total_score,
        level: userScore.level,
        daily_points: userScore.daily_points,
      });
    }

    // Calculate points to add (respect the daily cap)
    const pointsToAdd = Math.min(points, 300 - userScore.daily_points);
    console.log(
      `[DEBUG] Adding ${pointsToAdd} points (daily cap: ${userScore.daily_points}/300)`
    );

    // Add points to user score
    userScore.total_score += pointsToAdd;
    userScore.daily_points += pointsToAdd;

    // Add to score history
    userScore.score_history.push({
      date: new Date(),
      action,
      points: pointsToAdd,
    });

    // Calculate new level
    const newLevel = calculateLevel(userScore.total_score);
    const leveledUp = newLevel > userScore.level;
    userScore.level = newLevel;
    console.log(`[DEBUG] New level: ${newLevel}, leveled up: ${leveledUp}`);

    // Save user score
    await userScore.save();
    console.log(`[DEBUG] User score saved successfully`);

    // Sync level with user profile
    await syncLevelWithUserProfile(user_id, newLevel);

    res.status(200).json({
      success: true,
      message: leveledUp ? "Level up!" : "Points added",
      points_added: pointsToAdd,
      total_score: userScore.total_score,
      level: userScore.level,
      daily_points: userScore.daily_points,
      leveled_up: leveledUp,
    });
  } catch (error) {
    console.error("[DEBUG] Error adding points:", error);
    res.status(500).json({
      success: false,
      message: "Error adding points",
      error: error.message,
    });
  }
};
