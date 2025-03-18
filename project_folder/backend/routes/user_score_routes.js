const express = require("express");
const router = express.Router();
const {
  getUserScore,
  addPoints,
} = require("../controllers/user_score_controller");
const authMiddleware = require("../middleware/auth_middleware");

// Apply auth middleware to all score routes
router.use(authMiddleware);

// Get user score
router.get("/:userId", getUserScore);

// Add points to user score
router.post("/add", addPoints);

module.exports = router;
