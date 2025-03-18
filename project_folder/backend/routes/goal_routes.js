const express = require("express");
const router = express.Router();
const goalController = require("../controllers/goal_controller");
const authMiddleware = require("../middleware/auth_middleware");

// Apply authentication middleware to all routes
router.use(authMiddleware);

// Create a new goal
router.post("/:user_id/create", goalController.createGoal);

// Get all goals for a user
router.get("/:user_id", goalController.getUserGoals);

// Update goal progress
router.put("/:goal_id/progress", goalController.updateGoalProgress);

// Delete a goal
router.delete("/:goal_id", goalController.deleteGoal);

// Abandon a goal
router.put("/:goal_id/abandon", goalController.abandonGoal);

module.exports = router;
