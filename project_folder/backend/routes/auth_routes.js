const express = require("express");
const {
  register,
  login,
  deleteAccount,
  getUserInfo,
  sendVerificationCode,
  verifyCode,
  sendPasswordResetCode,
  verifyPasswordResetCode,
  resetPassword,
  changePassword,
  sendPasswordChangeNotification,
} = require("../controllers/auth_controller");
const authMiddleware = require("../middleware/auth_middleware");

const router = express.Router();

router.post("/register", register);
router.post("/login", login);
router.delete("/delete-account", authMiddleware, deleteAccount);
router.get("/user/:userId", authMiddleware, getUserInfo);
router.get("/user", authMiddleware, getUserInfo); // Get current user info
router.post("/send-verification-code", sendVerificationCode); // Send verification code
router.post("/verify-code", verifyCode); // Verify the code

// Password reset routes
router.post("/forgot-password", sendPasswordResetCode);
router.post("/verify-reset-code", verifyPasswordResetCode);
router.post("/reset-password", resetPassword);

// Change password route (requires authentication)
router.post("/change-password", authMiddleware, changePassword);

// Password change notification route
router.post(
  "/password-change-notification",
  authMiddleware,
  sendPasswordChangeNotification
);

module.exports = router;
