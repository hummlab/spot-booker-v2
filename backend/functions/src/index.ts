/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import {setGlobalOptions} from "firebase-functions";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import {onDocumentCreated} from "firebase-functions/v2/firestore";
import * as sgMail from "@sendgrid/mail";

// Start writing functions
// https://firebase.google.com/docs/functions/typescript

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({ maxInstances: 10 });

admin.initializeApp();

const SENDGRID_API_KEY = process.env.SENDGRID_API_KEY;
if (SENDGRID_API_KEY) {
  sgMail.setApiKey(SENDGRID_API_KEY);
}

export const sendWelcomeEmail = onDocumentCreated("users/{userId}", async (event) => {
  const userData = event.data?.data();
  const userId = event.params.userId;
  
  if (!SENDGRID_API_KEY) {
    logger.error("SENDGRID_API_KEY is not set");
    return;
  }
  
  if (!userData || !userData.email) {
    logger.warn("User document created without email address", { userId });
    return;
  }

  const msg = {
    to: userData.email,
    from: process.env.FROM_EMAIL || "noreply@example.com",
    subject: "Welcome to Spot Booker!",
    text: `Hello ${userData.displayName || userData.name || "User"},\n\nWelcome to Spot Booker! We're excited to have you on board.\n\nBest regards,\nSpot Booker Team`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #333;">Welcome to Spot Booker!</h2>
        <p>Hello ${userData.displayName || userData.name || "User"},</p>
        <p>Welcome to Spot Booker! We're excited to have you on board.</p>
        <p>You can now start booking your favorite spots and managing your reservations.</p>
        <p style="margin-top: 30px;">Best regards,<br/>The Spot Booker Team</p>
      </div>
    `,
  };

  try {
    await sgMail.send(msg);
    logger.info(`Welcome email sent to ${userData.email}`, {
      userId: userId,
      email: userData.email,
    });
  } catch (error) {
    logger.error("Error sending welcome email", {
      userId: userId,
      email: userData.email,
      error: error,
    });
  }
});

// export const helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
