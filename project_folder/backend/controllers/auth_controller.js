// Initialise express router
const { model } = require("../models/user");
const { model: UserProfile } = require("../models/user_profile");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const { createDefaultUserLog } = require("./user_log_controller");
const nodemailer = require("nodemailer");
const crypto = require("crypto");

// Store verification codes in memory with expiration times
const verificationCodes = new Map();

// Store password reset codes in memory with expiration times
const passwordResetCodes = new Map();

// Configure SMTP Transport
const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST,
  port: process.env.SMTP_PORT,
  secure: process.env.SMTP_SECURE === "true", // True for 465 (SSL), False for 587 (TLS)
  auth: {
    user: process.env.SMTP_EMAIL,
    pass: process.env.SMTP_PASSWORD,
  },
});

// Function to send welcome email to newly registered users
const sendWelcomeEmail = async (username, email) => {
  try {
    const sender = `"FitLife Support" <${process.env.SMTP_EMAIL}>`;

    await transporter.sendMail({
      from: sender,
      to: email,
      subject: "Welcome to FitLife - Your Journey to Better Health Begins!",
      text: `Hello ${username},

Welcome to FitLife! We're thrilled to have you join our community of fitness enthusiasts.

ABOUT FITLIFE:
FitLife is a comprehensive fitness tracking application designed to help you achieve your health and fitness goals. Whether you're looking to lose weight, build strength, or simply maintain a healthier lifestyle, FitLife provides the tools you need to succeed.

KEY FEATURES:
• Personalized workout tracking
• Daily activity monitoring
• Progress visualization
• Goal setting and achievement tracking
• Fitness community support

DEVELOPER NOTE:
FitLife was developed by Mandeep Pandya as part of a university project at Coventry University. As this is a new application, you may encounter occasional bugs or have suggestions for improvements. We greatly value your feedback and encourage you to report any issues through the Contact Us page in the app.

GETTING STARTED:
1. Set up your profile
2. Define your fitness goals
3. Start tracking your workouts
4. Monitor your progress
5. Stay consistent and motivated!

Thank you for choosing FitLife to support your fitness journey. We're committed to helping you lead a healthier, more active life.

Best Regards,
The FitLife Team`,
      html: `
<!DOCTYPE html>
<html>
<head>
  <style>
    body {
      font-family: Arial, sans-serif;
      line-height: 1.6;
      color: #333;
    }
    .container {
      max-width: 600px;
      margin: 0 auto;
      padding: 20px;
      border: 1px solid #ddd;
      border-radius: 5px;
    }
    .header {
      background-color: #6200EE;
      color: white;
      padding: 20px;
      text-align: center;
      border-radius: 5px 5px 0 0;
    }
    .content {
      padding: 20px;
    }
    .footer {
      background-color: #f5f5f5;
      padding: 15px;
      text-align: center;
      border-radius: 0 0 5px 5px;
      font-size: 12px;
      color: #666;
    }
    h1 {
      color: white;
      margin: 0;
    }
    h2 {
      color: #6200EE;
      border-bottom: 1px solid #eee;
      padding-bottom: 10px;
    }
    .feature {
      margin-bottom: 5px;
    }
    .button {
      display: inline-block;
      background-color: #6200EE;
      color: white;
      padding: 10px 20px;
      text-decoration: none;
      border-radius: 5px;
      margin-top: 15px;
    }
    .note {
      background-color: #f9f9f9;
      padding: 15px;
      border-left: 4px solid #6200EE;
      margin: 20px 0;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>Welcome to FitLife!</h1>
    </div>
    <div class="content">
      <p>Hello <strong>${username}</strong>,</p>
      
      <p>We're thrilled to have you join our community of fitness enthusiasts!</p>
      
      <h2>About FitLife</h2>
      <p>FitLife is a comprehensive fitness tracking application designed to help you achieve your health and fitness goals. Whether you're looking to lose weight, build strength, or simply maintain a healthier lifestyle, FitLife provides the tools you need to succeed.</p>
      
      <h2>Key Features</h2>
      <ul>
        <li class="feature">📊 <strong>Personalized workout tracking</strong> - Create and monitor custom workout routines</li>
        <li class="feature">📈 <strong>Daily activity monitoring</strong> - Track steps, water intake, and more</li>
        <li class="feature">📱 <strong>Progress visualization</strong> - See your improvements over time</li>
        <li class="feature">🎯 <strong>Goal setting</strong> - Set achievable targets and celebrate milestones</li>
        <li class="feature">👥 <strong>Fitness community</strong> - Stay motivated with support</li>
      </ul>
      
      <div class="note">
        <h3>Developer Note</h3>
        <p>FitLife was developed by <strong>Mandeep Pandya</strong> as part of a university project at Coventry University. As this is a new application, you may encounter occasional bugs or have suggestions for improvements. We greatly value your feedback and encourage you to report any issues through the Contact Us page in the app.</p>
      </div>
      
      <h2>Getting Started</h2>
      <ol>
        <li>Set up your profile</li>
        <li>Define your fitness goals</li>
        <li>Start tracking your workouts</li>
        <li>Monitor your progress</li>
        <li>Stay consistent and motivated!</li>
      </ol>
      
      <p>Thank you for choosing FitLife to support your fitness journey. We're committed to helping you lead a healthier, more active life.</p>
      
      <p>Best Regards,<br>The FitLife Team</p>
    </div>
    <div class="footer">
      <p>© 2024 FitLife. All rights reserved.</p>
      <p>This email was sent to ${email}</p>
    </div>
  </div>
</body>
</html>
      `,
    });

    console.log(`✅ Welcome email sent to ${email}`);
    return true;
  } catch (error) {
    console.error("❌ Error sending welcome email:", error);
    return false;
  }
};

// Register user
const register = async (req, res) => {
  const { username, email, password, code } = req.body;

  try {
    // Get the User model
    const User = model();
    if (!User) {
      console.error("User model is not initialized");
      return res.status(500).json({ error: "Database initialization error" });
    }

    // Sanitize email (convert to lowercase and trim)
    const sanitizedEmail = email.toLowerCase().trim();

    console.log(
      `Attempting to register user with email: code: ${code}`
    );

    // Validate password strength before checking verification code
    const passwordRegex =
      /^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/;
    if (!passwordRegex.test(password)) {
      return res.status(400).json({
        success: false,
        message:
          "Password must contain at least 8 characters, including uppercase, lowercase, number, and special character",
      });
    }

    // Check if verification code exists and is valid
    if (!verificationCodes.has(sanitizedEmail)) {
      console.log(
        `No verification code found during registration`
      );

      // Log all current verification codes for debugging
      console.log("Current verification codes during registration");
      for (const [key, value] of verificationCodes) {
        console.log(
          `${key}: ${value.code} (expires: ${new Date(
            value.expiresAt
          ).toISOString()})`
        );
      }

      return res.status(400).json({
        success: false,
        message:
          "Verification code not found or expired. Please request a new code.",
      });
    }

    const storedData = verificationCodes.get(sanitizedEmail);
    console.log(
      `Stored code during registration: ${
        storedData.code
      }, expires at: ${new Date(storedData.expiresAt).toISOString()}`
    );

    // Check if the code has expired
    if (Date.now() > storedData.expiresAt) {
      console.log(
        `Verification code has expired during registration`
      );
      verificationCodes.delete(sanitizedEmail); // Clean up expired code
      return res.status(400).json({
        success: false,
        message: "Verification code has expired. Please request a new code.",
      });
    }

    // Check if the code matches
    if (storedData.code !== code) {
      console.log(
        `Invalid code for ${sanitizedEmail} during registration: expected=${storedData.code}, received=${code}`
      );
      return res.status(400).json({
        success: false,
        message: "Invalid verification code. Please try again.",
      });
    }

    // Code is valid, now we can remove it
    console.log(
      `Verification code valid for ${sanitizedEmail} during registration, removing code`
    );
    verificationCodes.delete(sanitizedEmail);

    // Check if user already exists
    let user = await User.findOne({ email: sanitizedEmail });
    if (user) {
      return res.status(400).json({
        success: false,
        message: "User already exists",
      });
    }

    // Hash the password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Create new user
    user = new User({
      username,
      email: sanitizedEmail,
      password: hashedPassword,
    });
    await user.save();

    // Create a user profile for the new user
    try {
      const userProfileModel = UserProfile();
      if (userProfileModel) {
        const newProfile = new userProfileModel({
          user_id: user._id,
          // Initialize with default values
          personalInfo: {
            // Empty by default
          },
          fitnessStats: {
            currentStreak: 0,
            longestStreak: 0,
            level: 1,
            experiencePoints: 0,
          },
          preferences: {
            darkMode: false,
            notifications: true,
            soundEffects: true,
            language: "English",
            unitSystem: "Metric",
          },
        });

        await newProfile.save();
        console.log(`User profile created`);
      } else {
        console.error("UserProfile model is not initialized");
      }
    } catch (profileErr) {
      console.error("Error creating user profile:", profileErr);
      // Continue with registration even if profile creation fails
    }

    // Create default logs for the new user
    try {
      await createDefaultUserLog(user._id);
      console.log(`Default logs created`);
    } catch (logErr) {
      console.error("Error creating default logs:", logErr);
      // Continue with registration even if log creation fails
    }

    // Send welcome email to the user
    await sendWelcomeEmail(username, email);

    console.log(`User registered successfully: ${sanitizedEmail}`);
    res
      .status(201)
      .json({ success: true, message: "User registered successfully!" });
  } catch (err) {
    console.error("Registration error:", err);
    res.status(500).json({ error: err.message });
  }
};

// Login user
const login = async (req, res) => {
  const { email: loginEmail, password: loginPassword } = req.body;
  try {
    // Get the User model
    const User = model();
    if (!User) {
      console.error("User model is not initialized");
      return res.status(500).json({ error: "Database initialization error" });
    }

    // Convert email to lowercase for comparison
    const sanitizedEmail = loginEmail.toLowerCase().trim();

    const user = await User.findOne({ email: sanitizedEmail });
    if (!user) {
      return res.status(400).json({
        success: false,
        message: "Invalid credentials",
      });
    }

    // Compare password
    const isMatch = await bcrypt.compare(loginPassword, user.password);
    if (!isMatch) {
      return res.status(400).json({
        success: false,
        message: "Invalid credentials",
      });
    }

    // Generate JWT token
    const token = jwt.sign(
      { userId: user._id },
      process.env.JWT_SECRET || "fitlife_jwt_secret_key_2024",
      { expiresIn: "7d" }
    );

    // Return user data without password
    const userData = {
      _id: user._id,
      username: user.username,
      email: user.email,
    };

    res.status(200).json({
      success: true,
      message: "User logged in successfully!",
      user: userData,
      token,
    });
  } catch (err) {
    console.error("Login error:", err);
    res.status(500).json({
      success: false,
      error: err.message,
    });
  }
};

// Send verification code to user's email
const sendVerificationCode = async (req, res) => {
  const { email } = req.body;

  try {
    // Check if email is valid
    if (!email || !email.match(/^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/)) {
      return res.status(400).json({
        success: false,
        message: "Please provide a valid email address",
      });
    }

    // Convert email to lowercase and trim
    const sanitizedEmail = email.toLowerCase().trim();
    console.log(`Sending verification code for email: ${sanitizedEmail}`);

    // Check if user already exists
    const User = model();
    if (User) {
      const existingUser = await User.findOne({ email: sanitizedEmail });
      if (existingUser) {
        console.log(`User with email ${sanitizedEmail} already exists`);
        return res.status(400).json({
          success: false,
          message: "User with this email already exists",
        });
      }
    }

    // Generate a 6-digit verification code
    const verificationCode = crypto.randomInt(100000, 999999).toString();

    // Store the code with expiration time (1 minute)
    const expirationTime = Date.now() + 60000; // Current time + 1 minute
    verificationCodes.set(sanitizedEmail, {
      code: verificationCode,
      expiresAt: expirationTime,
    });

    console.log(
      `Verification code generated for ${sanitizedEmail}`
    );
    console.log(
      `Verification code will expire at: ${new Date(
        expirationTime
      ).toISOString()}`
    );

    // Log all current verification codes for debugging
    console.log("Current verification codes after adding new code");
    for (const [key, value] of verificationCodes) {
      console.log(
        `${key}: ${value.code} (expires: ${new Date(
          value.expiresAt
        ).toISOString()})`
      );
    }

    // Send the verification code via email
    const sender = `"FitLife Support" <${process.env.SMTP_EMAIL}>`;

    await transporter.sendMail({
      from: sender,
      to: sanitizedEmail,
      subject: "FitLife Email Verification Code",
      text: `Hello,\n\nYour verification code for FitLife account registration is: ${verificationCode}\n\nThis code will expire in 1 minute.\n\nBest Regards,\nFitLife Team`,
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #6200EE;">FitLife Email Verification</h2>
          <p>Hello,</p>
          <p>Your verification code for FitLife account registration is:</p>
          <div style="background-color: #f0f0f0; padding: 15px; text-align: center; font-size: 24px; font-weight: bold; letter-spacing: 5px; margin: 20px 0;">
            ${verificationCode}
          </div>
          <p>This code will expire in <strong>1 minute</strong>.</p>
          <p>If you did not request this code, please ignore this email.</p>
          <p>Best Regards,<br>FitLife Team</p>
        </div>
      `,
    });

    // Set a timeout to delete the verification code after it expires
    setTimeout(() => {
      verificationCodes.delete(sanitizedEmail);
      console.log(
        `Verification code for ${sanitizedEmail} expired and removed`
      );
    }, 60000); // 1 minute

    res.status(200).json({
      success: true,
      message: "Verification code sent successfully",
    });
  } catch (error) {
    console.error("Error sending verification code:", error);
    res.status(500).json({
      success: false,
      message: "Failed to send verification code",
      error: error.message,
    });
  }
};

// Verify the code entered by the user
const verifyCode = async (req, res) => {
  const { email, code } = req.body;

  try {
    // Convert email to lowercase for comparison
    const sanitizedEmail = email.toLowerCase().trim();

    // Check if there's a verification code for this email
    if (!verificationCodes.has(sanitizedEmail)) {
      console.log("Current verification codes");
      for (const [key, value] of verificationCodes) {
        console.log(
          `${key}: ${value.code} (expires: ${new Date(
            value.expiresAt
          ).toISOString()})`
        );
      }

      return res.status(400).json({
        success: false,
        message:
          "Verification code not found or expired. Please request a new code.",
      });
    }

    const storedData = verificationCodes.get(sanitizedEmail);
    console.log(
      `Stored code for ${sanitizedEmail}: ${
        storedData.code
      }, expires at: ${new Date(storedData.expiresAt).toISOString()}`
    );

    // Check if the code has expired
    if (Date.now() > storedData.expiresAt) {
      console.log(`Verification code for ${sanitizedEmail} has expired`);
      verificationCodes.delete(sanitizedEmail); // Clean up expired code
      return res.status(400).json({
        success: false,
        message: "Verification code has expired. Please request a new code.",
      });
    }

    // Check if the code matches
    if (storedData.code !== code) {
      console.log(
        `Invalid code for ${sanitizedEmail}: expected=${storedData.code}, received=${code}`
      );
      return res.status(400).json({
        success: false,
        message: "Invalid verification code. Please try again.",
      });
    }

    console.log(`Verification successful for ${sanitizedEmail}`);

    // This line clears the verification code but is temporarily commented out
    // We'll need it for the complete registration flow later
    // verificationCodes.delete(email);

    res.status(200).json({
      success: true,
      message: "Email verified successfully",
    });
  } catch (error) {
    console.error("Error verifying code:", error);
    res.status(500).json({
      success: false,
      message: "Failed to verify code",
      error: error.message,
    });
  }
};

// Delete user account
const deleteAccount = async (req, res) => {
  try {
    const userId = req.user.id; // From auth middleware

    // Get the User model
    const User = model();
    if (!User) {
      console.error("User model is not initialized");
      return res.status(500).json({ error: "Database initialization error" });
    }

    console.log(`Attempting to delete account`);

    // Delete user account
    const deletedUser = await User.findByIdAndDelete(userId);
    if (!deletedUser) {
      return res.status(404).json({ message: "User not found" });
    }
    console.log(`User document deleted from 'users' collection`);

    // Delete user profile
    try {
      const userProfileModel = UserProfile();
      if (userProfileModel) {
        const deletedProfile = await userProfileModel.findOneAndDelete({
          user_id: userId,
        });
        console.log(
          `User profile ${
            deletedProfile ? "deleted" : "not found"
          } in 'userprofiles' collection`
        );
      }
    } catch (profileErr) {
      console.error("Error deleting user profile:", profileErr);
      // Continue with account deletion even if profile deletion fails
    }

    // Delete user workouts
    try {
      const WorkoutModel = require("../models/workout").model();
      if (WorkoutModel) {
        const result = await WorkoutModel.deleteMany({ user_id: userId });
        console.log(
          `Deleted ${result.deletedCount} workouts from 'workouts' collection`
        );
      }
    } catch (workoutErr) {
      console.error("Error deleting user workouts:", workoutErr);
      // Continue with account deletion
    }

    // Delete user logs
    try {
      const UserLogModel = require("../models/user_log").model();
      if (UserLogModel) {
        const result = await UserLogModel.deleteMany({ user_id: userId });
        console.log(
          `Deleted user logs from 'logs' collection: ${result.deletedCount} documents`
        );
      }
    } catch (logErr) {
      console.error("Error deleting user logs:", logErr);
      // Continue with account deletion
    }

    // Delete user streaks
    try {
      const StreakModel = require("../models/streak").model();
      if (StreakModel) {
        const result = await StreakModel.deleteMany({ user_id: userId });
        console.log(
          `Deleted user streaks from 'streaks' collection: ${result.deletedCount} documents`
        );
      }
    } catch (streakErr) {
      console.error("Error deleting user streaks:", streakErr);
      // Continue with account deletion
    }

    // Delete user scores
    try {
      const UserScoreModel = require("../models/user_score").model();
      if (UserScoreModel) {
        const result = await UserScoreModel.deleteMany({ user_id: userId });
        console.log(
          `Deleted user scores from 'userscores' collection: ${result.deletedCount} documents`
        );
      }
    } catch (scoreErr) {
      console.error("Error deleting user scores:", scoreErr);
      // Continue with account deletion
    }

    // Goals are typically stored within the user profile, but if they're in a separate collection:
    try {
      const GoalModel = require("../models/goal").model();
      if (GoalModel) {
        const result = await GoalModel.deleteMany({ user_id: userId });
        console.log(
          `Deleted user goals from 'goals' collection: ${result.deletedCount} documents`
        );
      }
    } catch (goalErr) {
      // If goals model doesn't exist or other error
      console.log(
        "Note: Goals may be embedded in user profile or goals model not found"
      );
    }

    console.log(
      `Account deletion completed successfully for user ID: ${userId}`
    );
    res.status(200).json({ message: "Account deleted successfully" });
  } catch (err) {
    console.error("Delete account error:", err);
    res.status(500).json({ error: err.message });
  }
};

// Get user information
const getUserInfo = async (req, res) => {
  try {
    const userId = req.params.userId || req.userId;

    // Get the User model
    const User = model();
    if (!User) {
      console.error("User model is not initialized");
      return res.status(500).json({ error: "Database initialization error" });
    }

    // Find user by ID
    const user = await User.findById(userId).select("-password");
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    // Return user data
    res.status(200).json(user);
  } catch (err) {
    console.error("Get user info error:", err);
    res.status(500).json({ error: err.message });
  }
};

// Send password reset code to user's email
const sendPasswordResetCode = async (req, res) => {
  const { email } = req.body;

  try {
    // Check if email is valid
    if (!email || !email.match(/^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/)) {
      return res.status(400).json({
        success: false,
        message: "Please provide a valid email address",
      });
    }

    // Convert email to lowercase for comparison
    const sanitizedEmail = email.toLowerCase().trim();

    // Check if user exists
    const User = model();
    if (!User) {
      console.error("User model is not initialized");
      return res.status(500).json({ error: "Database initialization error" });
    }

    const user = await User.findOne({ email: sanitizedEmail });
    if (!user) {
      return res.status(400).json({
        success: false,
        message: "No account found with this email address",
      });
    }

    // Generate a 6-digit reset code
    const resetCode = crypto.randomInt(100000, 999999).toString();

    // Store the code with expiration time (1 minute)
    const expirationTime = Date.now() + 60000; // Current time + 1 minute
    passwordResetCodes.set(sanitizedEmail, {
      code: resetCode,
      expiresAt: expirationTime,
      userId: user._id,
    });

    console.log(`Password reset code generated for ${sanitizedEmail}`);

    // Send the reset code via email
    const sender = `"FitLife Support" <${process.env.SMTP_EMAIL}>`;

    await transporter.sendMail({
      from: sender,
      to: sanitizedEmail,
      subject: "FitLife Password Reset Code",
      text: `Hello ${user.username},

You have requested to reset your password for your FitLife account.

Your password reset code is: ${resetCode}

This code will expire in 1 minute.

If you did not request this code, please ignore this email or contact support if you believe this is an error.

Best Regards,
FitLife Team`,
      html: `
<!DOCTYPE html>
<html>
<head>
  <style>
    body {
      font-family: Arial, sans-serif;
      line-height: 1.6;
      color: #333;
    }
    .container {
      max-width: 600px;
      margin: 0 auto;
      padding: 20px;
      border: 1px solid #ddd;
      border-radius: 5px;
    }
    .header {
      background-color: #6200EE;
      color: white;
      padding: 20px;
      text-align: center;
      border-radius: 5px 5px 0 0;
    }
    .content {
      padding: 20px;
    }
    .footer {
      background-color: #f5f5f5;
      padding: 15px;
      text-align: center;
      border-radius: 0 0 5px 5px;
      font-size: 12px;
      color: #666;
    }
    h1 {
      color: white;
      margin: 0;
    }
    .code-box {
      background-color: #f0f0f0;
      padding: 15px;
      text-align: center;
      font-size: 24px;
      font-weight: bold;
      letter-spacing: 5px;
      margin: 20px 0;
      border-radius: 5px;
    }
    .warning {
      color: #e74c3c;
      font-weight: bold;
    }
    .note {
      background-color: #f9f9f9;
      padding: 15px;
      border-left: 4px solid #6200EE;
      margin: 20px 0;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>Password Reset Request</h1>
    </div>
    <div class="content">
      <p>Hello <strong>${user.username}</strong>,</p>
      
      <p>You have requested to reset your password for your FitLife account.</p>
      
      <p>Your password reset code is:</p>
      <div class="code-box">
        ${resetCode}
      </div>
      
      <p class="warning">This code will expire in 1 minute.</p>
      
      <div class="note">
        <p>If you did not request this code, please ignore this email or contact support if you believe this is an error.</p>
      </div>
      
      <p>Best Regards,<br>FitLife Team</p>
    </div>
    <div class="footer">
      <p>© 2024 FitLife. All rights reserved.</p>
      <p>This is an automated email. Please do not reply to this message.</p>
    </div>
  </div>
</body>
</html>
      `,
    });

    // Set a timeout to delete the reset code after it expires
    setTimeout(() => {
      passwordResetCodes.delete(sanitizedEmail);
      console.log(
        `Password reset code for ${sanitizedEmail} expired and removed`
      );
    }, 60000); // 1 minute

    res.status(200).json({
      success: true,
      message: "Password reset code sent successfully",
    });
  } catch (error) {
    console.error("Error sending password reset code:", error);
    res.status(500).json({
      success: false,
      message: "Failed to send password reset code",
      error: error.message,
    });
  }
};

// Verify password reset code
const verifyPasswordResetCode = async (req, res) => {
  const { email, code } = req.body;

  try {
    // Convert email to lowercase for comparison
    const sanitizedEmail = email.toLowerCase().trim();

    // Check if there's a reset code for this email
    if (!passwordResetCodes.has(sanitizedEmail)) {
      return res.status(400).json({
        success: false,
        message: "Reset code not found or expired. Please request a new code.",
      });
    }

    const storedData = passwordResetCodes.get(sanitizedEmail);

    // Check if the code has expired
    if (Date.now() > storedData.expiresAt) {
      passwordResetCodes.delete(sanitizedEmail); // Clean up expired code
      return res.status(400).json({
        success: false,
        message: "Reset code has expired. Please request a new code.",
      });
    }

    // Check if the code matches
    if (storedData.code !== code) {
      return res.status(400).json({
        success: false,
        message: "Invalid reset code. Please try again.",
      });
    }

    // Code is valid, return success
    // It will be used in resetPassword function
    res.status(200).json({
      success: true,
      message: "Reset code verified successfully",
      userId: storedData.userId,
    });
  } catch (error) {
    console.error("Error verifying reset code:", error);
    res.status(500).json({
      success: false,
      message: "Failed to verify reset code",
      error: error.message,
    });
  }
};

// Reset password with verified code
const resetPassword = async (req, res) => {
  const { email, code, newPassword } = req.body;

  try {
    // Convert email to lowercase for comparison
    const sanitizedEmail = email.toLowerCase().trim();

    // Check if there's a reset code for this email
    if (!passwordResetCodes.has(sanitizedEmail)) {
      return res.status(400).json({
        success: false,
        message: "Reset code not found or expired. Please request a new code.",
      });
    }

    const storedData = passwordResetCodes.get(sanitizedEmail);

    // Check if the code has expired
    if (Date.now() > storedData.expiresAt) {
      passwordResetCodes.delete(sanitizedEmail); // Clean up expired code
      return res.status(400).json({
        success: false,
        message: "Reset code has expired. Please request a new code.",
      });
    }

    // Check if the code matches
    if (storedData.code !== code) {
      return res.status(400).json({
        success: false,
        message: "Invalid reset code. Please try again.",
      });
    }

    // Validate password strength
    const passwordRegex =
      /^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/;
    if (!passwordRegex.test(newPassword)) {
      return res.status(400).json({
        success: false,
        message:
          "Password must contain at least 8 characters, including uppercase, lowercase, number, and special character",
      });
    }

    // Get the User model
    const User = model();
    if (!User) {
      console.error("User model is not initialized");
      return res.status(500).json({ error: "Database initialization error" });
    }

    // Hash the new password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(newPassword, salt);

    // Update the user's password
    const user = await User.findByIdAndUpdate(
      storedData.userId,
      { password: hashedPassword },
      { new: true }
    );

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    // Delete the reset code
    passwordResetCodes.delete(sanitizedEmail);

    // Send confirmation email
    const sender = `"FitLife Support" <${process.env.SMTP_EMAIL}>`;
    await transporter.sendMail({
      from: sender,
      to: sanitizedEmail,
      subject: "FitLife Password Reset Successful",
      text: `Hello ${user.username},

Your FitLife account password has been successfully reset.

If you did not make this change, please contact our support team immediately.

Best Regards,
FitLife Team`,
      html: `
<!DOCTYPE html>
<html>
<head>
  <style>
    body {
      font-family: Arial, sans-serif;
      line-height: 1.6;
      color: #333;
    }
    .container {
      max-width: 600px;
      margin: 0 auto;
      padding: 20px;
      border: 1px solid #ddd;
      border-radius: 5px;
    }
    .header {
      background-color: #6200EE;
      color: white;
      padding: 20px;
      text-align: center;
      border-radius: 5px 5px 0 0;
    }
    .content {
      padding: 20px;
    }
    .footer {
      background-color: #f5f5f5;
      padding: 15px;
      text-align: center;
      border-radius: 0 0 5px 5px;
      font-size: 12px;
      color: #666;
    }
    h1 {
      color: white;
      margin: 0;
    }
    .success {
      background-color: #d4edda;
      color: #155724;
      padding: 15px;
      border-radius: 5px;
      margin: 20px 0;
      text-align: center;
      font-weight: bold;
    }
    .warning {
      background-color: #f8d7da;
      color: #721c24;
      padding: 15px;
      border-radius: 5px;
      margin: 20px 0;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>Password Reset Successful</h1>
    </div>
    <div class="content">
      <p>Hello <strong>${user.username}</strong>,</p>
      
      <div class="success">
        Your FitLife account password has been successfully reset.
      </div>
      
      <div class="warning">
        <p>If you did not make this change, please contact our support team immediately.</p>
      </div>
      
      <p>Best Regards,<br>FitLife Team</p>
    </div>
    <div class="footer">
      <p>© 2024 FitLife. All rights reserved.</p>
      <p>This is an automated email. Please do not reply to this message.</p>
    </div>
  </div>
</body>
</html>
      `,
    });

    res.status(200).json({
      success: true,
      message: "Password reset successful",
    });
  } catch (error) {
    console.error("Error resetting password:", error);
    res.status(500).json({
      success: false,
      message: "Failed to reset password",
      error: error.message,
    });
  }
};

// Send password change notification email
const sendPasswordChangeNotification = async (req, res) => {
  try {
    const userId = req.userId;

    // Get the User model
    const User = model();
    if (!User) {
      console.error("User model is not initialized");
      return res.status(500).json({ message: "Database initialization error" });
    }

    // Find user by ID
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    // Create email content
    const emailSubject = "Your FitLife Password Has Been Changed";
    const emailContent = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 5px;">
        <div style="text-align: center; margin-bottom: 20px;">
          <h2 style="color: #6200ea;">FitLife Security Alert</h2>
        </div>
        
        <p>Hello ${user.username},</p>
        
        <p>We're sending this email to confirm that your FitLife account password was recently changed.</p>
        
        <p><strong>Time:</strong> ${new Date().toLocaleString()}</p>
        
        <p>If you made this change, you can safely ignore this email.</p>
        
        <p>If you did not change your password, please contact our support team immediately.</p>
        
        <p>For security reasons, we recommend:</p>
        <ul>
          <li>Using a strong, unique password</li>
          <li>Not sharing your password with others</li>
          <li>Changing your password regularly</li>
        </ul>
        
        <p>Thank you for using FitLife!</p>
        
        <div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #e0e0e0; font-size: 12px; color: #757575;">
          <p>This is an automated message, please do not reply to this email.</p>
          <p>If you have any questions, please contact our support team.</p>
        </div>
      </div>
    `;

    // Send the email
    await transporter.sendMail({
      from: process.env.EMAIL_USER,
      to: user.email,
      subject: emailSubject,
      html: emailContent,
    });

    return res
      .status(200)
      .json({ message: "Password change notification sent successfully" });
  } catch (error) {
    console.error("Error sending password change notification:", error);
    return res.status(500).json({ message: "Failed to send notification" });
  }
};

// Change password
const changePassword = async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body;
    const userId = req.userId;

    // Get the User model
    const User = model();
    if (!User) {
      console.error("User model is not initialized");
      return res.status(500).json({ message: "Database initialization error" });
    }

    // Find the user
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    // Verify current password
    const isMatch = await bcrypt.compare(currentPassword, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: "Current password is incorrect" });
    }

    // Hash the new password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(newPassword, salt);

    // Update the password
    user.password = hashedPassword;
    await user.save();

    // Send password change notification email
    try {
      // Create email content
      const emailSubject = "Your FitLife Password Has Been Changed";
      const emailContent = `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 5px;">
          <div style="text-align: center; margin-bottom: 20px;">
            <h2 style="color: #6200ea;">FitLife Security Alert</h2>
          </div>
          
          <p>Hello ${user.username},</p>
          
          <p>We're sending this email to confirm that your FitLife account password was recently changed.</p>
          
          <p><strong>Time:</strong> ${new Date().toLocaleString()}</p>
          
          <p>If you made this change, you can safely ignore this email.</p>
          
          <p>If you did not change your password, please contact our support team immediately.</p>
          
          <p>For security reasons, we recommend:</p>
          <ul>
            <li>Using a strong, unique password</li>
            <li>Not sharing your password with others</li>
            <li>Changing your password regularly</li>
          </ul>
          
          <p>Thank you for using FitLife!</p>
          
          <div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #e0e0e0; font-size: 12px; color: #757575;">
            <p>This is an automated message, please do not reply to this email.</p>
            <p>If you have any questions, please contact our support team.</p>
          </div>
        </div>
      `;

      // Send the email
      await transporter.sendMail({
        from: process.env.EMAIL_USER,
        to: user.email,
        subject: emailSubject,
        html: emailContent,
      });

      console.log(`Password change notification email sent to ${user.email}`);
    } catch (emailError) {
      console.error(
        "Error sending password change notification email:",
        emailError
      );
      // Continue with the response even if email fails
    }

    res.status(200).json({ message: "Password changed successfully" });
  } catch (error) {
    console.error("Error changing password:", error);
    res.status(500).json({ message: "Server error" });
  }
};

module.exports = {
  register,
  login,
  sendVerificationCode,
  verifyCode,
  deleteAccount,
  getUserInfo,
  sendPasswordResetCode,
  verifyPasswordResetCode,
  resetPassword,
  changePassword,
  sendPasswordChangeNotification,
};
