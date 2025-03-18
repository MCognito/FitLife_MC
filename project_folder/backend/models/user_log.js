const mongoose = require("mongoose");

const userLogSchema = new mongoose.Schema({
  user_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
    unique: true,
  },
  weight_logs: [
    {
      value: Number,
      date: { type: Date, default: Date.now },
    },
  ],
  water_logs: [
    {
      value: Number,
      date: { type: Date, default: Date.now },
    },
  ],
  step_logs: [
    {
      value: Number,
      date: { type: Date, default: Date.now },
    },
  ],
});

let UserLog;

module.exports = {
  init: (connection) => {
    UserLog = connection.model("logs", userLogSchema, "logs");
    return UserLog;
  },
  model: () => UserLog,
  schema: userLogSchema,
};
