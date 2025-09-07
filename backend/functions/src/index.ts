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
import {defineSecret} from "firebase-functions/params";
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

// Define secrets
const sendgridApiKey = defineSecret("SENDGRID_API_KEY");
const fromEmail = defineSecret("FROM_EMAIL");

export const sendWelcomeEmail = onDocumentCreated(
  {
    document: "users/{userId}",
    secrets: [sendgridApiKey, fromEmail],
  },
  async (event) => {
    const userData = event.data?.data();
    const userId = event.params.userId;
    
    // Initialize SendGrid with the API key
    sgMail.setApiKey(sendgridApiKey.value());
    
    if (!userData || !userData.email) {
      logger.warn("User document created without email address", { userId });
      return;
    }

    const msg = {
      to: userData.email,
      from: fromEmail.value(),
      subject: "Witamy w HummLab!",
      text: `Witaj ${userData.displayName || userData.name || "Użytkowniku"},\n\nWitamy w HummLab! Cieszymy się, że dołączyłeś do nas.\n\nMożesz teraz rozpocząć rezerwację biurek i zarządzanie swoimi rezerwacjami.\n\nPozdrawiamy,\nZespół HummLab`,
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
          <div style="text-align: center; margin-bottom: 30px;">
            <h1 style="color: #3b82f6; margin: 0;">HummLab</h1>
            <p style="color: #64748b; margin: 5px 0;">Inteligentne rozwiązania biurowe</p>
          </div>
          
          <h2 style="color: #1e293b; margin-bottom: 20px;">Witamy w HummLab!</h2>
          
          <p style="color: #374151; line-height: 1.6;">Witaj ${userData.displayName || userData.name || "Użytkowniku"},</p>
          
          <p style="color: #374151; line-height: 1.6;">
            Witamy w HummLab! Cieszymy się, że dołączyłeś do naszej platformy do rezerwacji biurek.
          </p>
          
          <p style="color: #374151; line-height: 1.6;">
            Możesz teraz:
          </p>
          
          <ul style="color: #374151; line-height: 1.8;">
            <li>Rezerwować dostępne biurka w biurze</li>
            <li>Zarządzać swoimi rezerwacjami</li>
            <li>Przeglądać mapę biura w czasie rzeczywistym</li>
            <li>Otrzymywać powiadomienia o rezerwacjach</li>
          </ul>
          
          <div style="text-align: center; margin: 30px 0;">
            <a href="https://spot-booker-client-v2.web.app" 
               style="background-color: #3b82f6; color: white; padding: 12px 24px; text-decoration: none; border-radius: 8px; display: inline-block;">
              Przejdź do aplikacji
            </a>
          </div>
          
          <p style="margin-top: 30px; color: #64748b; border-top: 1px solid #e2e8f0; padding-top: 20px;">
            Pozdrawiamy,<br/>
            <strong>Zespół HummLab</strong><br/>
            <a href="mailto:admin@hummlab.com" style="color: #3b82f6;">admin@hummlab.com</a><br/>
            <a href="https://hummlab.com" style="color: #3b82f6;">hummlab.com</a>
          </p>
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
  }
);

// export const helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
