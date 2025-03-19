const mongoose = require("mongoose");

const goalSchema = new mongoose.Schema(
  {
    user_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    type: {
      type: String,
      required: true,
      enum: [
        "LOSE_WEIGHT",
        "GAIN_WEIGHT",
        "BUILD_STRENGTH",
        "BUILD_STAMINA",
        "MAINTAIN_WEIGHT",
        "Lose Weight",
        "Gain Weight",
        "Build Strength",
        "Build Stamina",
        "Maintain Weight",
      ],
    },
    status: {
      type: String,
      required: true,
      enum: [
        "IN_PROGRESS",
        "COMPLETED",
        "ABANDONED",
        "In Progress",
        "Completed",
        "Abandoned",
      ],
      default: "IN_PROGRESS",
    },
    startDate: {
      type: Date,
      required: true,
      default: Date.now,
    },
    targetDate: {
      type: Date,
      required: true,
    },
    startValue: {
      type: Number,
      required: true,
    },
    currentValue: {
      type: Number,
      required: true,
    },
    targetValue: {
      type: Number,
      required: true,
    },
    unit: {
      type: String,
      required: true,
    },
    milestones: [
      {
        value: Number,
        achieved: {
          type: Boolean,
          default: false,
        },
        achievedDate: Date,
        reward: String,
      },
    ],
    notes: [
      {
        date: {
          type: Date,
          default: Date.now,
        },
        content: String,
      },
    ],
    weeklyProgress: [
      {
        week: Number,
        value: Number,
        date: Date,
      },
    ],
    motivation: {
      quote: String,
      reminder: {
        enabled: {
          type: Boolean,
          default: true,
        },
        frequency: {
          type: String,
          enum: ["DAILY", "WEEKLY"],
          default: "DAILY",
        },
        time: String,
      },
    },
  },
  {
    timestamps: true,
  }
);

// Calculate progress percentage
goalSchema.methods.getProgressPercentage = function () {
  const totalChange = this.targetValue - this.startValue;
  const currentChange = this.currentValue - this.startValue;

  // For goals where target is less than start (weight loss, etc.)
  if (totalChange < 0) {
    // For decreasing goals, progress increases as value decreases
    // If currentValue <= targetValue, progress is 100%
    if (this.currentValue <= this.targetValue) {
      return 100;
    }

    // Calculate how much progress has been made toward the target
    const remainingChange = this.currentValue - this.targetValue;
    const totalAbsChange = Math.abs(totalChange);
    return Math.min(
      100,
      Math.max(0, ((totalAbsChange - remainingChange) / totalAbsChange) * 100)
    );
  }
  // For goals where target is greater than start (weight gain, steps, etc.)
  else {
    // If currentValue >= targetValue, progress is 100%
    if (this.currentValue >= this.targetValue) {
      return 100;
    }

    return Math.min(100, Math.max(0, (currentChange / totalChange) * 100));
  }
};

// Check if goal is on track
goalSchema.methods.isOnTrack = function () {
  const totalDays =
    (new Date(this.targetDate) - new Date(this.startDate)) /
    (1000 * 60 * 60 * 24);
  const daysPassed =
    (new Date() - new Date(this.startDate)) / (1000 * 60 * 60 * 24);
  const expectedProgress = (daysPassed / totalDays) * 100;
  const actualProgress = this.getProgressPercentage();

  return actualProgress >= expectedProgress;
};

// Define the model variable
let GoalModel;

// Export the initialization function and model accessor
module.exports = {
  init: (connection) => {
    // Initialize the model with the correct collection name
    GoalModel = connection.model("Goal", goalSchema, "goals");
    return GoalModel;
  },
  model: () => GoalModel,
  schema: goalSchema,
};
