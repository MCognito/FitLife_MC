const express = require("express");
const router = express.Router();
const libraryController = require("../controllers/library_controller");
const authMiddleware = require("../middleware/auth_middleware");

// Apply auth middleware to all library routes
router.use(authMiddleware);

// Get all library items
router.get("/", libraryController.getAllLibraryItems);

// Get library items by category
router.get("/category/:category", libraryController.getLibraryItemsByCategory);

module.exports = router;
