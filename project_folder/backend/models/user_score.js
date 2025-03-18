const mongoose = require("mongoose");

const userScoreSchema = new mongoose.Schema({
  user_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
    unique: true,
  },
  total_score: {
    type: Number,
    default: 0,
  },
  level: {
    type: Number,
    default: 1,
  },
  daily_points: {
    type: Number,
    default: 0,
  },
  last_reset_date: {
    type: Date,
    default: Date.now,
  },
  score_history: [
    {
      date: { type: Date, default: Date.now },
      action: { type: String, required: true },
      points: { type: Number, required: true },
    },
  ],
  created_at: { type: Date, default: Date.now },
  updated_at: { type: Date, default: Date.now },
});

// Add pre-save middleware to update the updated_at field
userScoreSchema.pre("save", function (next) {
  this.updated_at = Date.now();
  next();
});

// Add pre-findOneAndUpdate middleware to update the updated_at field
userScoreSchema.pre("findOneAndUpdate", function (next) {
  this.set({ updated_at: Date.now() });
  next();
});

let UserScoreModel;

module.exports = {
  init: (connection) => {
    UserScoreModel = connection.model("UserScore", userScoreSchema);
    return UserScoreModel;
  },
  model: () => UserScoreModel,
  schema: userScoreSchema,
};
