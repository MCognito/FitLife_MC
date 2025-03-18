const express = require("express");
const router = express.Router();
const {
  getWorkouts,
  addWorkout,
  updateWorkout,
  deleteWorkout,
} = require("../controllers/workout_controller");
const authMiddleware = require("../middleware/auth_middleware");

// Apply auth middleware to all workout routes
router.use(authMiddleware);

// Get all workouts for a user
router.get("/user/:userId", getWorkouts);

// Add a new workout
router.post("/", addWorkout);

// Update a workout
router.put("/:id", updateWorkout);

// Delete a workout
router.delete("/:id", deleteWorkout);

module.exports = router;
