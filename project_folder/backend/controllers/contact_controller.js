const nodemailer = require("nodemailer");

// Function to generate a reference number
const generateReference = (email, name) => {
  const emailPart = email.split("@")[0].substring(0, 3).toUpperCase();
  const namePart = name.replace(/\s+/g, "").substring(0, 3).toUpperCase();
  const randomNumber = String(Math.floor(Math.random() * 1000) + 1).padStart(
    3,
    "0"
  );
  return `FTL-SP${emailPart}${namePart}${randomNumber}`;
};

// Configure SMTP Transport with Logs
const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST,
  port: process.env.SMTP_PORT,
  secure: process.env.SMTP_SECURE === "true", // True for 465 (SSL), False for 587 (TLS)
  auth: {
    user: process.env.SMTP_EMAIL,
    pass: process.env.SMTP_PASSWORD,
  },
});

// Function to Handle Contact Form Emails
const sendContactEmail = async (req, res) => {
  const { name, email, subject, message, category } = req.body;

  if (!email || !name || !subject || !message) {
    console.log("❌ Missing fields in request:", req.body);
    return res.status(400).json({ error: "All fields are required!" });
  }

  // Generate the reference number
  const reference = generateReference(email, name);

  try {
    console.log("📩 Sending confirmation email");

    // Define sender with custom display name
    const sender = `"FitLife Support" <${process.env.SMTP_EMAIL}>`;

    // 1️⃣ Send Confirmation Email to the User
    let userMailInfo = await transporter.sendMail({
      from: sender,
      to: email,
      subject: `Confirmation: ${subject} - Ref: ${reference}`,
      text: `Hello ${name},

Thank you for reaching out to us. Your inquiry under "${category}" has been received.
Your reference number is ${reference}.
We will try to respond to your enquiry within 48 hours.

Best Regards,
FitLife Team`,
      html: `
<!DOCTYPE html>
<html>
<head>
  <style>
    body {
      font-family: Arial, sans-serif;
      line-height: 1.6;
      color: #333;
    }
    .container {
      max-width: 600px;
      margin: 0 auto;
      padding: 20px;
      border: 1px solid #ddd;
      border-radius: 5px;
    }
    .header {
      background-color: #6200EE;
      color: white;
      padding: 20px;
      text-align: center;
      border-radius: 5px 5px 0 0;
    }
    .content {
      padding: 20px;
    }
    .footer {
      background-color: #f5f5f5;
      padding: 15px;
      text-align: center;
      border-radius: 0 0 5px 5px;
      font-size: 12px;
      color: #666;
    }
    h1 {
      color: white;
      margin: 0;
    }
    .reference {
      background-color: #f9f9f9;
      padding: 15px;
      border-left: 4px solid #6200EE;
      margin: 20px 0;
      font-size: 18px;
      text-align: center;
    }
    .details {
      margin: 20px 0;
      padding: 15px;
      background-color: #f9f9f9;
      border-radius: 5px;
    }
    .detail-row {
      margin-bottom: 10px;
    }
    .detail-label {
      font-weight: bold;
      color: #6200EE;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>Inquiry Confirmation</h1>
    </div>
    <div class="content">
      <p>Hello <strong>${name}</strong>,</p>
      
      <p>Thank you for reaching out to us. Your inquiry has been received and will be addressed by our team.</p>
      
      <div class="reference">
        <p>Your Reference Number:</p>
        <h2>${reference}</h2>
        <p>Please keep this reference number for future correspondence.</p>
      </div>
      
      <div class="details">
        <div class="detail-row">
          <span class="detail-label">Category:</span> ${category}
        </div>
        <div class="detail-row">
          <span class="detail-label">Subject:</span> ${subject}
        </div>
        <div class="detail-row">
          <span class="detail-label">Date Submitted:</span> ${new Date().toLocaleString()}
        </div>
      </div>
      
      <p>We will try to respond to your inquiry within <strong>48 hours</strong>.</p>
      
      <p>Best Regards,<br>FitLife Team</p>
    </div>
    <div class="footer">
      <p>© 2024 FitLife. All rights reserved.</p>
      <p>This is an automated email. Please do not reply to this message.</p>
    </div>
  </div>
</body>
</html>
      `,
    });

    console.log("✅ Confirmation email sent successfully");

    // 2️⃣ Send Inquiry to Admin (Service Email)
    console.log(
      "📩 Sending inquiry email to admin:",
      process.env.SERVICE_EMAIL
    );
    let adminMailInfo = await transporter.sendMail({
      from: sender,
      to: process.env.SERVICE_EMAIL,
      subject: `New Inquiry from ${name}: ${subject} - Ref: ${reference}`,
      text: `New inquiry:

Reference: ${reference}
Name: ${name}
Email: ${email}
Category: ${category}
Subject: ${subject}
Message: ${message}

Please refer to the reference number when responding.`,
      html: `
<!DOCTYPE html>
<html>
<head>
  <style>
    body {
      font-family: Arial, sans-serif;
      line-height: 1.6;
      color: #333;
    }
    .container {
      max-width: 600px;
      margin: 0 auto;
      padding: 20px;
      border: 1px solid #ddd;
      border-radius: 5px;
    }
    .header {
      background-color: #6200EE;
      color: white;
      padding: 20px;
      text-align: center;
      border-radius: 5px 5px 0 0;
    }
    .content {
      padding: 20px;
    }
    .footer {
      background-color: #f5f5f5;
      padding: 15px;
      text-align: center;
      border-radius: 0 0 5px 5px;
      font-size: 12px;
      color: #666;
    }
    h1 {
      color: white;
      margin: 0;
    }
    .reference {
      background-color: #f9f9f9;
      padding: 10px;
      border-left: 4px solid #6200EE;
      margin: 20px 0;
      font-size: 16px;
    }
    .user-info {
      margin: 20px 0;
      padding: 15px;
      background-color: #f9f9f9;
      border-radius: 5px;
    }
    .info-row {
      margin-bottom: 10px;
    }
    .info-label {
      font-weight: bold;
      color: #6200EE;
      width: 100px;
      display: inline-block;
    }
    .message-box {
      margin: 20px 0;
      padding: 15px;
      background-color: #f9f9f9;
      border-radius: 5px;
      border: 1px solid #ddd;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>New User Inquiry</h1>
    </div>
    <div class="content">
      <div class="reference">
        <p><strong>Reference Number:</strong> ${reference}</p>
      </div>
      
      <div class="user-info">
        <div class="info-row">
          <span class="info-label">Name:</span> ${name}
        </div>
        <div class="info-row">
          <span class="info-label">Email:</span> <a href="mailto:${email}">${email}</a>
        </div>
        <div class="info-row">
          <span class="info-label">Category:</span> ${category}
        </div>
        <div class="info-row">
          <span class="info-label">Subject:</span> ${subject}
        </div>
        <div class="info-row">
          <span class="info-label">Date:</span> ${new Date().toLocaleString()}
        </div>
      </div>
      
      <h3>Message:</h3>
      <div class="message-box">
        ${message.replace(/\n/g, "<br>")}
      </div>
      
      <p>Please refer to the reference number when responding to this inquiry.</p>
    </div>
    <div class="footer">
      <p>© 2024 FitLife. All rights reserved.</p>
      <p>This is an automated email from the FitLife contact system.</p>
    </div>
  </div>
</body>
</html>
      `,
    });

    console.log("✅ Inquiry email sent to admin successfully");

    res.json({ success: true, message: "Emails sent successfully!" });
  } catch (error) {
    console.error("❌ Error sending email:", error);
    res.status(500).json({ error: "Error sending email. Check server logs." });
  }
};

module.exports = { sendContactEmail };
