const express = require("express");
const router = express.Router();
const { getUserStreakInfo } = require("../controllers/streak_controller");
const authMiddleware = require("../middleware/auth_middleware");

// Get user streak info
router.get("/:user_id", authMiddleware, getUserStreakInfo);

module.exports = router;
