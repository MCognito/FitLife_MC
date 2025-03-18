const { model: UserProfile } = require("../models/user_profile");
const { model: Log } = require("../models/log");
const { model: Streak } = require("../models/streak");
const mongoose = require("mongoose");

// Constants
const MINIMUM_STEPS_THRESHOLD = 3000; // Minimum steps required to count for streak
const GRACE_PERIOD_HOURS = 24; // Grace period in hours

// Helper function to validate MongoDB ObjectId
const isValidObjectId = (id) => {
  return mongoose.Types.ObjectId.isValid(id);
};

// Helper function to check if two dates are the same day
const isSameDay = (date1, date2) => {
  if (!date1 || !date2) return false;

  const d1 = new Date(date1);
  const d2 = new Date(date2);

  return (
    d1.getFullYear() === d2.getFullYear() &&
    d1.getMonth() === d2.getMonth() &&
    d1.getDate() === d2.getDate()
  );
};

// Helper function to check if a date is yesterday
const isYesterday = (date) => {
  if (!date) return false;

  const yesterday = new Date();
  yesterday.setDate(yesterday.getDate() - 1);

  return isSameDay(date, yesterday);
};

// Helper function to check if a date is within the grace period
const isWithinGracePeriod = (date) => {
  if (!date) return false;

  const now = new Date();
  const gracePeriodMs = GRACE_PERIOD_HOURS * 60 * 60 * 1000;
  const dateTime = new Date(date).getTime();

  return now.getTime() - dateTime <= gracePeriodMs;
};

// Check and update user streak
exports.checkAndUpdateStreak = async (userId, activityType, activityValue) => {
  try {
    console.log(
      `[STREAK] Checking streak for user ${userId}: activityType=${activityType}, activityValue=${activityValue}`
    );

    // Validate userId
    if (!isValidObjectId(userId)) {
      console.error(`[STREAK] Invalid user ID format: ${userId}`);
      return {
        updated: false,
        message: "Invalid user ID format",
      };
    }

    // Get or create streak info
    const StreakModel = Streak();
    if (!StreakModel) {
      console.error("[STREAK] Streak model is not initialized");
      return {
        updated: false,
        message: "Database initialization error",
      };
    }

    let streakInfo = await StreakModel.findOne({ user_id: userId });

    if (!streakInfo) {
      // Create new streak info if it doesn't exist
      streakInfo = new StreakModel({
        user_id: userId,
        current_streak: 0,
        longest_streak: 0,
        last_activity_date: null,
        in_grace_period: false,
        grace_period_hours: GRACE_PERIOD_HOURS,
        minimum_steps_threshold: MINIMUM_STEPS_THRESHOLD,
      });
      console.log(`[STREAK] Created new streak info`);
    }

    // Check if activity meets the threshold for streak
    let meetsThreshold = false;
    if (activityType === "workout") {
      meetsThreshold = true;
      console.log(`[STREAK] Workout activity meets threshold`);
    } else if (
      activityType === "steps" &&
      activityValue >= streakInfo.minimum_steps_threshold
    ) {
      meetsThreshold = true;
      console.log(
        `[STREAK] Steps activity meets threshold: ${activityValue} >= ${streakInfo.minimum_steps_threshold}`
      );
    } else {
      console.log(
        `[STREAK] Activity does not meet threshold: ${activityType}, ${activityValue}`
      );
      return {
        updated: false,
        message: "Activity does not meet threshold for streak",
        currentStreak: streakInfo.current_streak,
        longestStreak: streakInfo.longest_streak,
      };
    }

    // Get current date
    const now = new Date();

    // Check if this is the first activity
    if (!streakInfo.last_activity_date) {
      console.log(`[STREAK] First activity recorded`);
      streakInfo.current_streak = 1;
      streakInfo.longest_streak = 1;
      streakInfo.last_activity_date = now;
      streakInfo.in_grace_period = false;

      await streakInfo.save();

      return {
        updated: true,
        message: "First activity recorded, streak started",
        currentStreak: 1,
        longestStreak: 1,
      };
    }

    // Check if activity is on the same day as last activity
    const lastActivityDate = new Date(streakInfo.last_activity_date);
    if (isSameDay(now, lastActivityDate)) {
      console.log(`[STREAK] Activity on same day, no streak change`);
      streakInfo.last_activity_date = now; // Update the timestamp
      streakInfo.in_grace_period = false;

      await streakInfo.save();

      return {
        updated: false,
        message: "Activity on same day, no streak change",
        currentStreak: streakInfo.current_streak,
        longestStreak: streakInfo.longest_streak,
      };
    }

    // Check if activity is on the next day
    const dayDifference = Math.floor(
      (now - lastActivityDate) / (1000 * 60 * 60 * 24)
    );

    // Use calendar day comparison instead of raw time difference
    const lastActivityDay = new Date(lastActivityDate);
    const nowDay = new Date(now);

    // Reset time components to compare calendar days only
    lastActivityDay.setHours(0, 0, 0, 0);
    nowDay.setHours(0, 0, 0, 0);

    // Calculate calendar day difference - this is more accurate for streak tracking
    const calendarDayDiff = Math.round(
      (nowDay - lastActivityDay) / (1000 * 60 * 60 * 24)
    );

    console.log(
      `[STREAK] Raw day difference: ${dayDifference}, Calendar day difference: ${calendarDayDiff}`
    );

    if (calendarDayDiff === 1) {
      // Activity is on the next day, increment streak
      console.log(`[STREAK] Activity on next day, incrementing streak`);
      streakInfo.current_streak += 1;

      // Update longest streak if needed
      if (streakInfo.current_streak > streakInfo.longest_streak) {
        streakInfo.longest_streak = streakInfo.current_streak;
      }

      streakInfo.last_activity_date = now;
      streakInfo.in_grace_period = false;

      await streakInfo.save();

      return {
        updated: true,
        message: "Streak incremented",
        currentStreak: streakInfo.current_streak,
        longestStreak: streakInfo.longest_streak,
      };
    } else if (calendarDayDiff > 1 && calendarDayDiff <= 2) {
      // Activity is after a gap of one day, check if in grace period
      const hoursSinceLastActivity =
        (now - lastActivityDate) / (1000 * 60 * 60);

      if (hoursSinceLastActivity <= streakInfo.grace_period_hours) {
        // Within grace period, maintain streak
        console.log(
          `[STREAK] Activity within grace period, maintaining streak`
        );
        streakInfo.last_activity_date = now;
        streakInfo.in_grace_period = false;

        await streakInfo.save();

        return {
          updated: false,
          message: "Activity within grace period, streak maintained",
          currentStreak: streakInfo.current_streak,
          longestStreak: streakInfo.longest_streak,
        };
      } else {
        // Outside grace period, reset streak
        console.log(`[STREAK] Activity outside grace period, resetting streak`);
        streakInfo.current_streak = 1;
        streakInfo.last_activity_date = now;
        streakInfo.in_grace_period = false;

        await streakInfo.save();

        return {
          updated: true,
          message: "Streak reset due to missed day",
          currentStreak: 1,
          longestStreak: streakInfo.longest_streak,
        };
      }
    } else {
      // Activity after multiple days, reset streak
      console.log(`[STREAK] Activity after multiple days, resetting streak`);
      streakInfo.current_streak = 1;
      streakInfo.last_activity_date = now;
      streakInfo.in_grace_period = false;

      await streakInfo.save();

      return {
        updated: true,
        message: "Streak reset due to multiple missed days",
        currentStreak: 1,
        longestStreak: streakInfo.longest_streak,
      };
    }
  } catch (error) {
    console.error(`[STREAK] Error checking/updating streak: ${error.message}`);
    return {
      updated: false,
      message: `Error: ${error.message}`,
      error: error,
    };
  }
};

// Check if user is in grace period and update
exports.checkGracePeriod = async (userId) => {
  try {
    // Get user profile
    const UserProfileModel = UserProfile();
    if (!UserProfileModel) {
      console.error("UserProfile model is not initialized");
      return false;
    }

    // Find user profile
    const userProfile = await UserProfileModel.findOne({ user_id: userId });
    if (!userProfile) {
      console.error(`User profile not found for user: ${userId}`);
      return false;
    }

    const now = new Date();
    const { lastActivityDate, streakGracePeriod } = userProfile.fitnessStats;

    // If no last activity, no grace period needed
    if (!lastActivityDate) return false;

    // If already in grace period, no need to update
    if (streakGracePeriod) return true;

    // Check if last activity was yesterday
    if (isYesterday(lastActivityDate)) {
      // User missed today, set grace period
      userProfile.fitnessStats.streakGracePeriod = true;
      userProfile.fitnessStats.lastStreakUpdate = now;
      await userProfile.save();
      return true;
    }

    return false;
  } catch (error) {
    console.error("Error checking grace period:", error);
    return false;
  }
};

// Get user streak info
exports.getUserStreakInfo = async (req, res) => {
  try {
    const userId = req.params.user_id;
    console.log(`[STREAK] Getting streak info`);

    // Validate userId
    if (!isValidObjectId(userId)) {
      return res.status(400).json({ message: "Invalid user ID format" });
    }

    // Get or create streak info
    const StreakModel = Streak();
    if (!StreakModel) {
      console.error("[STREAK] Streak model is not initialized");
      return res.status(500).json({ message: "Database initialization error" });
    }

    let streakInfo = await StreakModel.findOne({ user_id: userId });

    if (!streakInfo) {
      // Create new streak info if it doesn't exist
      streakInfo = new StreakModel({
        user_id: userId,
        current_streak: 0,
        longest_streak: 0,
        last_activity_date: null,
        in_grace_period: false,
        grace_period_hours: GRACE_PERIOD_HOURS,
        minimum_steps_threshold: MINIMUM_STEPS_THRESHOLD,
      });
      await streakInfo.save();
      console.log(`[STREAK] Created new streak info`);
    }

    // Check if streak is in grace period
    if (streakInfo.last_activity_date) {
      const now = new Date();
      const lastActivity = new Date(streakInfo.last_activity_date);
      const hoursSinceLastActivity = (now - lastActivity) / (1000 * 60 * 60);

      // If it's not the same day and within grace period
      if (
        !isSameDay(now, lastActivity) &&
        hoursSinceLastActivity <= GRACE_PERIOD_HOURS
      ) {
        streakInfo.in_grace_period = true;
      } else if (
        !isSameDay(now, lastActivity) &&
        hoursSinceLastActivity > GRACE_PERIOD_HOURS
      ) {
        // If it's not the same day and beyond grace period, reset streak
        if (streakInfo.current_streak > 0) {
          console.log(`[STREAK] Resetting streak`);
          streakInfo.current_streak = 0;
          streakInfo.in_grace_period = false;
          await streakInfo.save();
        }
      }
    }

    // Return streak info
    return res.status(200).json({
      currentStreak: streakInfo.current_streak,
      longestStreak: streakInfo.longest_streak,
      lastActivityDate: streakInfo.last_activity_date,
      inGracePeriod: streakInfo.in_grace_period,
      gracePeriodHours: streakInfo.grace_period_hours,
      minimumStepsThreshold: streakInfo.minimum_steps_threshold,
    });
  } catch (error) {
    console.error(`[STREAK] Error getting streak info: ${error.message}`);
    return res.status(500).json({ message: "Error getting streak info" });
  }
};
