import { EmailPayload } from "./models";

export async function sendEmail(payload: EmailPayload): Promise<void> {
  console.log("Mock sending email to:", payload.to);
  console.log("Subject:", payload.subject);
  console.log("Body (HTML):", payload.bodyHtml);
  // In real app: call backend email service
  return Promise.resolve();
}
