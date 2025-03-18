const jwt = require("jsonwebtoken");

const authMiddleware = (req, res, next) => {
  // Get token from header
  const authHeader = req.header("Authorization");

  // Check if auth header exists
  if (!authHeader) {
    return res.status(401).json({ message: "No token, authorization denied" });
  }

  try {
    // Extract token (remove "Bearer " prefix if present)
    const token = authHeader.startsWith("Bearer ")
      ? authHeader.slice(7)
      : authHeader;

    // Verify the token
    const decoded = jwt.verify(
      token,
      process.env.JWT_SECRET || "fitlife_jwt_secret_key_2024"
    );

    // Set user ID in request
    req.userId = decoded.userId;

    // Check if the logged-in user matches the token's user ID
    if (req.params.user_id && req.userId !== req.params.user_id) {
      return res.status(403).json({ message: "Not authorized" });
    }

    next(); // Pass control to the next middleware
  } catch (error) {
    console.error("Token verification error:", error);
    res.status(401).json({ message: "Token is not valid" });
  }
};

module.exports = authMiddleware;
