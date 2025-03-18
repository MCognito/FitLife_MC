const express = require("express");
const router = express.Router();
const userProfileController = require("../controllers/user_profile_controller");
const authMiddleware = require("../middleware/auth_middleware");

// Apply auth middleware to all routes
router.use(authMiddleware);

// User profile routes
router.get("/:userId", userProfileController.getUserProfile);
router.put("/:userId", userProfileController.updateUserProfile);
router.delete("/:userId", userProfileController.deleteUserProfile);

// User goals routes
router.get("/:userId/goals", userProfileController.getUserGoals);
router.post("/:userId/goals", userProfileController.addGoal);
router.put("/:userId/goals/:goalId", userProfileController.updateGoal);
router.delete("/:userId/goals/:goalId", userProfileController.deleteGoal);

// Leaderboard routes
router.get("/leaderboard/:type", userProfileController.getLeaderboard);

// User preferences routes
router.put("/:userId/preferences", userProfileController.updatePreferences);

module.exports = router;
