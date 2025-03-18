const express = require("express");
const { sendContactEmail } = require("../controllers/contact_controller");

const router = express.Router();

// Contact Form Route
router.post("/contact", sendContactEmail);

module.exports = router;
