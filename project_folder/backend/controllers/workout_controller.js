const { model: Workout } = require("../models/workout");
const mongoose = require("mongoose");
const { checkAndUpdateStreak } = require("./streak_controller");
const axios = require("axios");

// Helper function to validate MongoDB ObjectId
const isValidObjectId = (id) => {
  return mongoose.Types.ObjectId.isValid(id);
};

// Fetch all workouts for a user
exports.getWorkouts = async (req, res) => {
  try {
    const { userId } = req.params;

    console.log("Fetching workouts for user");

    // Validate userId
    if (!isValidObjectId(userId)) {
      return res.status(400).json({ message: "Invalid user ID format" });
    }

    const workouts = await Workout()
      .find({ user_id: userId })
      .sort({ updated_at: -1 }); // Sort by most recently updated

    console.log(`Found ${workouts.length} workouts`);

    res.json(workouts);
  } catch (error) {
    console.error("Error details:", error);
    res.status(500).json({ message: "Error fetching workouts" });
  }
};

// Add a new workout
exports.addWorkout = async (req, res) => {
  try {
    const { user_id, name, exercises } = req.body;

    // Validate userId
    if (!isValidObjectId(user_id)) {
      return res.status(400).json({ message: "Invalid user ID format" });
    }

    // Validate required fields
    if (!name) {
      return res.status(400).json({ message: "Workout name is required" });
    }

    console.log("Creating new workout:", {
      user_id,
      name,
      exercises: exercises || [],
    });

    const WorkoutModel = Workout();
    if (!WorkoutModel) {
      console.error("Workout model is not initialized");
      return res.status(500).json({ message: "Database initialization error" });
    }

    // Create a new workout with points_awarded set to false initially
    const newWorkout = new WorkoutModel({
      user_id,
      name,
      exercises: exercises || [],
      points_awarded: false, // Initialize as false - points will be awarded on update, not creation
    });

    const savedWorkout = await newWorkout.save();
    console.log(`Workout saved with ID: ${savedWorkout._id}`);
    console.log(
      "No points awarded for workout creation - points are only awarded on workout updates"
    );

    res.status(201).json({
      success: true,
      workout: savedWorkout,
      pointsAdded: false,
    });
  } catch (error) {
    console.error("Error adding workout:", error);
    res.status(500).json({
      success: false,
      message: "Error adding workout",
      error: error.message,
    });
  }
};

// Update a workout
exports.updateWorkout = async (req, res) => {
  try {
    const workoutId = req.params.id;

    // Validate workoutId
    if (!isValidObjectId(workoutId)) {
      return res.status(400).json({ message: "Invalid workout ID format" });
    }

    const { name, exercises } = req.body;

    const WorkoutModel = Workout();
    console.log("Attempting to update workout:", workoutId);

    // Find the workout first to ensure it exists
    const existingWorkout = await WorkoutModel.findById(workoutId);
    if (!existingWorkout) {
      return res.status(404).json({ message: "Workout not found" });
    }

    // Create a deep copy of the existing workout exercises to compare with new exercises
    const existingExercises = JSON.parse(
      JSON.stringify(existingWorkout.exercises || [])
    );

    // Calculate points to award
    let totalPointsToAward = 0;
    let exercisePointsAwarded = 0;
    let setPointsAwarded = 0;

    // Track which exercises and sets should be marked as having points awarded
    const exercisesWithPointsAwarded = [];

    // Process each exercise in the updated workout
    if (exercises && exercises.length > 0) {
      exercises.forEach((newExercise, exerciseIndex) => {
        // Find matching exercise in existing workout (by name or index)
        const existingExercise =
          existingExercises.find((e) => e.name === newExercise.name) ||
          existingExercises[exerciseIndex];

        // Check if this is a new exercise or if points haven't been awarded yet
        const isNewExercise = !existingExercise;
        const exerciseNotAwarded =
          existingExercise && !existingExercise.points_awarded;

        // Award points for new exercise or existing exercise without points
        if (isNewExercise || exerciseNotAwarded) {
          totalPointsToAward += 50; // 50 points per exercise
          exercisePointsAwarded += 50;

          // Mark this exercise as having points awarded
          exercisesWithPointsAwarded.push({
            index: exerciseIndex,
            awarded: true,
          });
        } else if (existingExercise && existingExercise.points_awarded) {
          // Keep track of exercises that already have points
          exercisesWithPointsAwarded.push({
            index: exerciseIndex,
            awarded: true,
          });
        }

        // Process sets for this exercise
        if (newExercise.sets && newExercise.sets.length > 0) {
          newExercise.sets.forEach((newSet, setIndex) => {
            // Check if this is a new set or if points haven't been awarded yet
            const existingSets = existingExercise
              ? existingExercise.sets || []
              : [];
            const isNewSet = setIndex >= existingSets.length;
            const setNotAwarded =
              !isNewSet && !existingSets[setIndex].points_awarded;

            // Award points for new set or existing set without points
            if (isNewSet || setNotAwarded) {
              totalPointsToAward += 10; // 10 points per set
              setPointsAwarded += 10;

              // Mark this set as having points awarded
              if (!exercisesWithPointsAwarded[exerciseIndex]) {
                exercisesWithPointsAwarded[exerciseIndex] = {
                  index: exerciseIndex,
                  awarded: false,
                  sets: [],
                };
              }

              if (!exercisesWithPointsAwarded[exerciseIndex].sets) {
                exercisesWithPointsAwarded[exerciseIndex].sets = [];
              }

              exercisesWithPointsAwarded[exerciseIndex].sets.push({
                index: setIndex,
                awarded: true,
              });
            } else if (!isNewSet && existingSets[setIndex].points_awarded) {
              // Keep track of sets that already have points
              if (!exercisesWithPointsAwarded[exerciseIndex]) {
                exercisesWithPointsAwarded[exerciseIndex] = {
                  index: exerciseIndex,
                  awarded: existingExercise.points_awarded,
                  sets: [],
                };
              }

              if (!exercisesWithPointsAwarded[exerciseIndex].sets) {
                exercisesWithPointsAwarded[exerciseIndex].sets = [];
              }

              exercisesWithPointsAwarded[exerciseIndex].sets.push({
                index: setIndex,
                awarded: true,
              });
            }
          });
        }
      });
    }

    // Update the workout with the new data, marking exercises and sets that have been awarded points
    const updatedExercises = exercises.map((exercise, exerciseIndex) => {
      const exerciseInfo = exercisesWithPointsAwarded.find(
        (e) => e.index === exerciseIndex
      );
      const shouldAwardExercise = exerciseInfo && exerciseInfo.awarded;

      return {
        ...exercise,
        points_awarded: shouldAwardExercise,
        sets: exercise.sets
          ? exercise.sets.map((set, setIndex) => {
              const setInfo =
                exerciseInfo && exerciseInfo.sets
                  ? exerciseInfo.sets.find((s) => s.index === setIndex)
                  : null;
              const shouldAwardSet = setInfo && setInfo.awarded;

              return {
                ...set,
                points_awarded: shouldAwardSet,
              };
            })
          : [],
      };
    });

    // Update the workout with the new data
    let workout = await WorkoutModel.findByIdAndUpdate(
      workoutId,
      {
        name,
        exercises: updatedExercises,
        updated_at: Date.now(),
      },
      { new: true }
    );

    let streakResult = null;
    let pointsAdded = false;

    // If there are points to award
    if (totalPointsToAward > 0) {
      const user_id = existingWorkout.user_id;
      console.log(
        `Awarding ${totalPointsToAward} points (${exercisePointsAwarded} for exercises, ${setPointsAwarded} for sets)`
      );

      // Update streak for workout completion (only if this is the first time points are awarded)
      if (exercisePointsAwarded > 0) {
        try {
          streakResult = await checkAndUpdateStreak(user_id, "workout", 1);
          console.log(
            `Streak update for workout: ${JSON.stringify(streakResult)}`
          );
        } catch (streakError) {
          console.error("Error updating streak for workout:", streakError);
          // Continue even if streak update fails
        }
      }

      // Add points to user score
      try {
        // Get the host from the request
        const host = req.get("host");
        const protocol = req.protocol;
        const baseUrl = `${protocol}://${host}`;

        console.log(
          `Sending points request to: ${baseUrl}/api/user-scores/add`
        );

        // Make a request to the user score API
        const scoreResponse = await axios.post(
          `${baseUrl}/api/user-scores/add`,
          {
            user_id,
            action: "add_workout",
            points: totalPointsToAward,
          },
          {
            headers: {
              Authorization: req.headers.authorization,
              "Content-Type": "application/json",
            },
          }
        );

        console.log(`Score API response: ${scoreResponse.status}`);
        console.log(
          `Added ${totalPointsToAward} points for workout update (${exercisePointsAwarded} for exercises, ${setPointsAwarded} for sets)`
        );
        pointsAdded = true;
      } catch (scoreError) {
        console.error("Error adding points for workout:", scoreError.message);
        if (scoreError.response) {
          console.error("Score API error response:", {
            status: scoreError.response.status,
            data: scoreError.response.data,
            headers: scoreError.response.headers,
          });
        } else if (scoreError.request) {
          console.error("Score API no response:", scoreError.request);
        } else {
          console.error("Score API request setup error:", scoreError.message);
        }
        // Continue even if score update fails
      }
    } else {
      console.log("No new exercises or sets to award points for");
    }

    res.json({
      success: true,
      workout,
      streak: streakResult,
      pointsAdded,
      pointsAwarded: totalPointsToAward,
      exercisePointsAwarded,
      setPointsAwarded,
    });
  } catch (error) {
    console.error("Error updating workout:", error);
    res.status(500).json({ message: "Error updating workout" });
  }
};

// Delete a workout
exports.deleteWorkout = async (req, res) => {
  try {
    const workoutId = req.params.id;

    // Validate workoutId
    if (!isValidObjectId(workoutId)) {
      return res.status(400).json({ message: "Invalid workout ID format" });
    }

    const WorkoutModel = Workout();
    console.log("Attempting to delete workout:", workoutId);

    const workout = await WorkoutModel.findByIdAndDelete(workoutId);

    if (!workout) {
      return res.status(404).json({ message: "Workout not found" });
    }

    console.log("Workout deleted successfully:", workoutId);
    res.json({ message: "Workout deleted successfully" });
  } catch (error) {
    console.error("Error deleting workout:", error);
    res.status(500).json({ message: "Error deleting workout" });
  }
};
