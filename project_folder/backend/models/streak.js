const mongoose = require("mongoose");

const streakSchema = new mongoose.Schema({
  user_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
    unique: true,
  },
  current_streak: {
    type: Number,
    default: 0,
  },
  longest_streak: {
    type: Number,
    default: 0,
  },
  last_activity_date: {
    type: Date,
    default: null,
  },
  in_grace_period: {
    type: Boolean,
    default: false,
  },
  grace_period_hours: {
    type: Number,
    default: 24,
  },
  minimum_steps_threshold: {
    type: Number,
    default: 3000,
  },
  created_at: { type: Date, default: Date.now },
  updated_at: { type: Date, default: Date.now },
});

// Add pre-save middleware to update the updated_at field
streakSchema.pre("save", function (next) {
  this.updated_at = Date.now();
  next();
});

// Add pre-findOneAndUpdate middleware to update the updated_at field
streakSchema.pre("findOneAndUpdate", function (next) {
  this.set({ updated_at: Date.now() });
  next();
});

let StreakModel;

module.exports = {
  init: (connection) => {
    StreakModel = connection.model("Streak", streakSchema);
    return StreakModel;
  },
  model: () => StreakModel,
  schema: streakSchema,
};
