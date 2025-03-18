// Initiate the server and connect to MongoDB

// Import the required packages and routes
require("dotenv").config();
const express = require("express");
const cors = require("cors");
const connectDB = require("./config/db");
const authRoutes = require("./routes/auth_routes");
const workoutRoutes = require("./routes/workout_routes");
const libraryRoutes = require("./routes/library_routes");
const logRoutes = require("./routes/log_routes");
const userProfileRoutes = require("./routes/user_profile_routes");
const streakRoutes = require("./routes/streak_routes");
const userScoreRoutes = require("./routes/user_score_routes");
const goalRoutes = require("./routes/goal_routes");
const contactRoutes = require("./routes/contact_routes");
const mongoose = require("mongoose");
const axios = require("axios");

const app = express();

// Connect to MongoDB
connectDB();

// For Middleware
app.use(express.json());
app.use(cors({ origin: "*" }));

// For Routes
app.use("/api/auth", authRoutes);
app.use("/api/workouts", workoutRoutes);
app.use("/api/library", libraryRoutes);
app.use("/api/logs", logRoutes); // Use only this for logs
app.use("/api/users", userProfileRoutes); // User profile routes
app.use("/api/streaks", streakRoutes);
app.use("/api/user-scores", userScoreRoutes);
app.use("/api/goals", goalRoutes);
app.use("/api", contactRoutes);

app.get("/", (req, res) => res.send("Welcome to the FitLife API!"));

// Start the server
const PORT = process.env.PORT || 5000;
app.listen(PORT, "0.0.0.0", () =>
  console.log(`Server running on port ${PORT}`)
);
