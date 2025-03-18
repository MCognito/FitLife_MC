// Initiate connection to MongoDB database
// Import Mongoose and User model
const mongoose = require("mongoose");
const user = require("../models/user");
require("dotenv").config();

const connectDB = async () => {
  try {
    // Connect to users database (contains users, logs, and workouts)
    const usersConnection = await mongoose.createConnection(
      process.env.MONGO_URI,
      {
        dbName: "users_db",
        useNewUrlParser: true,
        useUnifiedTopology: true,
      }
    );
    console.log("Users DB Connected...");

    // Connect to library database
    const libraryConnection = await mongoose.createConnection(
      process.env.MONGO_URI,
      {
        dbName: "library_db",
        useNewUrlParser: true,
        useUnifiedTopology: true,
      }
    );
    console.log("Library DB Connected...");

    // Initialize models for users_db
    require("../models/user").init(usersConnection);
    require("../models/log").init(usersConnection);
    require("../models/workout").init(usersConnection);
    require("../models/user_profile").init(usersConnection);
    require("../models/user_log").init(usersConnection);
    require("../models/user_score").init(usersConnection);
    require("../models/streak").init(usersConnection);
    require("../models/goal").init(usersConnection);

    // Initialize model for library_db
    require("../models/LibraryItem").init(libraryConnection);

    // Set default connection for mongoose (optional, but helpful for backward compatibility)
    mongoose.connect(process.env.MONGO_URI, {
      dbName: "users_db",
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
  } catch (err) {
    console.error(err.message);
    process.exit(1);
  }
};

// Export connectDB function
module.exports = connectDB;
