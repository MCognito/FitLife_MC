// Code to create a user schema and export it as a model
const mongoose = require("mongoose");

// Create a user schema
const UserSchema = new mongoose.Schema({
  username: { type: String, required: true },
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true, // Always store email in lowercase
    trim: true, // Remove whitespace
    validate: {
      validator: function (v) {
        return /^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/.test(v);
      },
      message: (props) => `${props.value} is not a valid email address!`,
    },
  },
  password: {
    type: String,
    required: true,
  },
  // Additional fields for fitness tracking
  age: Number,
  weight: Number,
  height: Number,
  created_at: { type: Date, default: Date.now },
});

// Pre-save middleware to ensure email is lowercase
UserSchema.pre("save", function (next) {
  if (this.email) {
    this.email = this.email.toLowerCase();
  }
  next();
});

// Define the model variable
let UserModel;

// Export the initialization function and model accessor
module.exports = {
  init: (connection) => {
    UserModel = connection.model("User", UserSchema);
    return UserModel;
  },
  model: () => UserModel,
  schema: UserSchema,
};
