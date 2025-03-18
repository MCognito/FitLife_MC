const express = require("express");
const router = express.Router();
const userLogController = require("../controllers/user_log_controller");
const authMiddleware = require("../middleware/auth_middleware");

// Apply authentication middleware to all routes
router.use(authMiddleware);

// Get all logs for a user
router.get("/:user_id", userLogController.getUserLogs);

// Get logs by type and date range
router.get("/range/:user_id", userLogController.getLogsByDateRange);

// Add a new log entry
router.post("/add", userLogController.addLogEntry);

module.exports = router;
