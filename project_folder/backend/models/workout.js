const mongoose = require("mongoose");

// Define the Set schema
const SetSchema = new mongoose.Schema(
  {
    reps: { type: Number, required: true },
    weight: { type: Number, required: true },
    points_awarded: { type: Boolean, default: false },
  },
  { _id: false }
);

const workoutSchema = new mongoose.Schema({
  user_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
  },
  name: { type: String, required: true },
  exercises: [
    {
      name: { type: String, required: true },
      sets: [SetSchema],
      notes: String,
      points_awarded: { type: Boolean, default: false },
    },
  ],
  date: { type: Date, default: Date.now },
  duration: Number,
  notes: String,
  points_awarded: { type: Boolean, default: false },
  created_at: { type: Date, default: Date.now },
  updated_at: { type: Date, default: Date.now },
});

// Add pre-save middleware to update the updated_at field
workoutSchema.pre("save", function (next) {
  this.updated_at = Date.now();
  next();
});

// Add pre-findOneAndUpdate middleware to update the updated_at field
workoutSchema.pre("findOneAndUpdate", function (next) {
  this.set({ updated_at: Date.now() });
  next();
});

let WorkoutModel;

module.exports = {
  init: (connection) => {
    WorkoutModel = connection.model("Workout", workoutSchema);
    return WorkoutModel;
  },
  model: () => WorkoutModel,
  schema: workoutSchema,
};
