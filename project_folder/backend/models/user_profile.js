const mongoose = require("mongoose");

// Personal Information Schema
const PersonalInfoSchema = new mongoose.Schema({
  age: Number,
  height: Number, // in cm
  gender: String,
  dateOfBirth: {
    type: Date,
    default: null,
  },
});

// Fitness Stats Schema - Simplified to remove redundant data
const FitnessStatsSchema = new mongoose.Schema({
  level: {
    type: Number,
    default: 1,
  },
  experiencePoints: {
    type: Number,
    default: 0,
  },
});

// User Preferences Schema
const PreferencesSchema = new mongoose.Schema({
  darkMode: {
    type: Boolean,
    default: false,
  },
  notifications: {
    type: Boolean,
    default: true,
  },
  soundEffects: {
    type: Boolean,
    default: true,
  },
  language: {
    type: String,
    default: "English",
  },
  unitSystem: {
    type: String,
    default: "Metric",
    enum: ["Metric", "Imperial"],
  },
  publicProfile: {
    type: Boolean,
    default: false, // Default to private
  },
});

// User Profile Schema
const UserProfileSchema = new mongoose.Schema({
  user_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
    unique: true,
  },
  personalInfo: {
    type: PersonalInfoSchema,
    default: () => ({}),
  },
  fitnessStats: {
    type: FitnessStatsSchema,
    default: () => ({}),
  },
  preferences: {
    type: PreferencesSchema,
    default: () => ({}),
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
  updatedAt: {
    type: Date,
    default: Date.now,
  },
});

// Update the updatedAt field on save
UserProfileSchema.pre("save", function (next) {
  this.updatedAt = Date.now();
  next();
});

// Update the updatedAt field on update
UserProfileSchema.pre("findOneAndUpdate", function (next) {
  this.set({ updatedAt: Date.now() });
  next();
});

let UserProfileModel;

module.exports = {
  init: (connection) => {
    UserProfileModel = connection.model("UserProfile", UserProfileSchema);
    return UserProfileModel;
  },
  model: () => UserProfileModel,
  schema: UserProfileSchema,
};
