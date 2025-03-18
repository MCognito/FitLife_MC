const { model: UserProfile } = require("../models/user_profile");
const { model: User } = require("../models/user");
const mongoose = require("mongoose");

// Helper function to validate MongoDB ObjectId
const isValidObjectId = (id) => {
  return mongoose.Types.ObjectId.isValid(id);
};

// Get user profile
exports.getUserProfile = async (req, res) => {
  try {
    const userId = req.params.userId;

    // Validate userId
    if (!isValidObjectId(userId)) {
      return res.status(400).json({ message: "Invalid user ID format" });
    }

    // Get user profile
    let profile = await UserProfile().findOne({ user_id: userId });

    // If profile doesn't exist, create a new one
    if (!profile) {
      // Get user data
      const user = await User().findById(userId);
      if (!user) {
        return res.status(404).json({ message: "User not found" });
      }

      // Create new profile
      profile = new (UserProfile())({
        user_id: userId,
        // Initialize with empty objects (defaults will be applied)
      });

      await profile.save();
    }

    res.json(profile);
  } catch (error) {
    console.error("Error in getUserProfile:", error);
    res
      .status(500)
      .json({ message: "Error fetching user profile", error: error.message });
  }
};

// Update user profile
exports.updateUserProfile = async (req, res) => {
  try {
    const userId = req.params.userId;

    // Validate userId
    if (!isValidObjectId(userId)) {
      return res.status(400).json({ message: "Invalid user ID format" });
    }

    // Get profile data from request body
    const { personalInfo, fitnessStats, preferences } = req.body;

    // Find and update profile
    const profile = await UserProfile().findOneAndUpdate(
      { user_id: userId },
      {
        $set: {
          personalInfo: personalInfo || {},
          fitnessStats: fitnessStats || {},
          preferences: preferences || {},
        },
      },
      { new: true, upsert: true }
    );

    res.json(profile);
  } catch (error) {
    console.error("Error in updateUserProfile:", error);
    res
      .status(500)
      .json({ message: "Error updating user profile", error: error.message });
  }
};

// Get user goals
exports.getUserGoals = async (req, res) => {
  try {
    const userId = req.params.userId;

    // Validate userId
    if (!isValidObjectId(userId)) {
      return res.status(400).json({ message: "Invalid user ID format" });
    }

    // Get user profile
    const profile = await UserProfile().findOne({ user_id: userId });

    if (!profile) {
      return res.status(404).json({ message: "User profile not found" });
    }

    res.json(profile.goals || []);
  } catch (error) {
    console.error("Error in getUserGoals:", error);
    res
      .status(500)
      .json({ message: "Error fetching user goals", error: error.message });
  }
};

// Add a goal
exports.addGoal = async (req, res) => {
  try {
    const userId = req.params.userId;

    // Validate userId
    if (!isValidObjectId(userId)) {
      return res.status(400).json({ message: "Invalid user ID format" });
    }

    // Get goal data from request body
    const { title, description, target, current, deadline } = req.body;

    // Validate required fields
    if (!title || !description || !target || !current) {
      return res.status(400).json({ message: "Missing required goal fields" });
    }

    // Create new goal
    const newGoal = {
      title,
      description,
      progress: 0,
      target,
      current,
      deadline: deadline ? new Date(deadline) : undefined,
      isCompleted: false,
      createdAt: new Date(),
    };

    // Add goal to user profile
    const profile = await UserProfile().findOneAndUpdate(
      { user_id: userId },
      { $push: { goals: newGoal } },
      { new: true, upsert: true }
    );

    // Return the newly added goal
    const addedGoal = profile.goals[profile.goals.length - 1];

    res.status(201).json(addedGoal);
  } catch (error) {
    console.error("Error in addGoal:", error);
    res
      .status(500)
      .json({ message: "Error adding goal", error: error.message });
  }
};

// Update a goal
exports.updateGoal = async (req, res) => {
  try {
    const userId = req.params.userId;
    const goalId = req.params.goalId;

    // Validate IDs
    if (!isValidObjectId(userId) || !isValidObjectId(goalId)) {
      return res.status(400).json({ message: "Invalid ID format" });
    }

    // Get goal data from request body
    const {
      title,
      description,
      progress,
      target,
      current,
      deadline,
      isCompleted,
    } = req.body;

    // Find user profile
    const profile = await UserProfile().findOne({ user_id: userId });

    if (!profile) {
      return res.status(404).json({ message: "User profile not found" });
    }

    // Find goal index
    const goalIndex = profile.goals.findIndex(
      (g) => g._id.toString() === goalId
    );

    if (goalIndex === -1) {
      return res.status(404).json({ message: "Goal not found" });
    }

    // Update goal fields
    if (title) profile.goals[goalIndex].title = title;
    if (description) profile.goals[goalIndex].description = description;
    if (progress !== undefined) profile.goals[goalIndex].progress = progress;
    if (target) profile.goals[goalIndex].target = target;
    if (current) profile.goals[goalIndex].current = current;
    if (deadline) profile.goals[goalIndex].deadline = new Date(deadline);
    if (isCompleted !== undefined)
      profile.goals[goalIndex].isCompleted = isCompleted;

    // Save updated profile
    await profile.save();

    res.json(profile.goals[goalIndex]);
  } catch (error) {
    console.error("Error in updateGoal:", error);
    res
      .status(500)
      .json({ message: "Error updating goal", error: error.message });
  }
};

// Delete a goal
exports.deleteGoal = async (req, res) => {
  try {
    const userId = req.params.userId;
    const goalId = req.params.goalId;

    // Validate IDs
    if (!isValidObjectId(userId) || !isValidObjectId(goalId)) {
      return res.status(400).json({ message: "Invalid ID format" });
    }

    // Remove goal from user profile
    const profile = await UserProfile().findOneAndUpdate(
      { user_id: userId },
      { $pull: { goals: { _id: goalId } } },
      { new: true }
    );

    if (!profile) {
      return res.status(404).json({ message: "User profile not found" });
    }

    res.json({ message: "Goal deleted successfully" });
  } catch (error) {
    console.error("Error in deleteGoal:", error);
    res
      .status(500)
      .json({ message: "Error deleting goal", error: error.message });
  }
};

// Get leaderboard
exports.getLeaderboard = async (req, res) => {
  try {
    const type = req.params.type;
    const userId = req.userId; // From auth middleware

    // Validate type
    if (type !== "global") {
      return res.status(400).json({ message: "Invalid leaderboard type" });
    }

    // Get all user profiles with fitness stats
    const profiles = await UserProfile()
      .find({
        "preferences.publicProfile": true, // Only include users with publicProfile set to true
      })
      .populate("user_id", "username");

    // Get all streaks
    const Streak = require("../models/streak").model();
    const streaks = await Streak.find({});

    // Create a map of user IDs to their streak values
    const streakMap = {};
    streaks.forEach((streak) => {
      streakMap[streak.user_id.toString()] = streak.current_streak;
    });

    // Transform profiles to leaderboard format
    const leaderboard = profiles.map((profile) => {
      const userIdStr = profile.user_id._id.toString();
      return {
        userId: profile.user_id._id,
        name: profile.user_id.username,
        level: profile.fitnessStats.level || 1,
        experiencePoints: profile.fitnessStats.experiencePoints || 0,
        streak: streakMap[userIdStr] || 0, // Get streak from the streaks collection
        publicProfile: profile.preferences.publicProfile || false,
        isCurrentUser: userIdStr === userId,
      };
    });

    // Sort by level (default)
    leaderboard.sort((a, b) => b.level - a.level);

    // Add rank
    leaderboard.forEach((user, index) => {
      user.rank = index + 1;
    });

    res.json(leaderboard);
  } catch (error) {
    console.error("Error in getLeaderboard:", error);
    res
      .status(500)
      .json({ message: "Error fetching leaderboard", error: error.message });
  }
};

// Update user preferences
exports.updatePreferences = async (req, res) => {
  try {
    const userId = req.params.userId;

    // Validate userId
    if (!isValidObjectId(userId)) {
      return res.status(400).json({ message: "Invalid user ID format" });
    }

    // Get preferences from request body
    const preferences = req.body;

    // Update preferences
    const profile = await UserProfile().findOneAndUpdate(
      { user_id: userId },
      { $set: { preferences } },
      { new: true, upsert: true }
    );

    res.json(profile.preferences);
  } catch (error) {
    console.error("Error in updatePreferences:", error);
    res
      .status(500)
      .json({ message: "Error updating preferences", error: error.message });
  }
};

// Delete user profile
exports.deleteUserProfile = async (req, res) => {
  try {
    const userId = req.params.userId;

    // Validate userId
    if (!isValidObjectId(userId)) {
      return res.status(400).json({ message: "Invalid user ID format" });
    }

    // Delete user profile
    const result = await UserProfile().findOneAndDelete({ user_id: userId });

    if (!result) {
      return res.status(404).json({ message: "User profile not found" });
    }

    res.json({ message: "User profile deleted successfully" });
  } catch (error) {
    console.error("Error in deleteUserProfile:", error);
    res
      .status(500)
      .json({ message: "Error deleting user profile", error: error.message });
  }
};
