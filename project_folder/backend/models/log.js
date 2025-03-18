const mongoose = require("mongoose");

const logSchema = new mongoose.Schema({
  user_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
  },
  type: {
    type: String,
    enum: ["water_intake", "sleep", "weight", "steps"],
    required: true,
  },
  value: Number,
  unit: String,
  date: { type: Date, default: Date.now },
});

// Add compound index for faster queries
logSchema.index({ user_id: 1, type: 1, date: -1 });

// Define the model variable
let LogModel;

// Export the initialization function and model accessor
module.exports = {
  init: (connection) => {
    LogModel = connection.model("Log", logSchema);
    return LogModel;
  },
  model: () => LogModel,
  schema: logSchema,
};
