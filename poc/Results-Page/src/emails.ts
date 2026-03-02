import { EmailPayload, AssessmentResult } from "./models";

export function buildUserEmailPayload(userEmail: string, result: AssessmentResult): EmailPayload {
  const bodyText = `Hello,

Here are your VESTA questionnaire results (POC):
Overall Score: ${result.overallScore ?? ""}

Best regards,
VESTA Team`;

  const bodyHtml = `
    <p>Hello,</p>
    <p>Here are your VESTA questionnaire results (POC):</p>
    <p>Overall Score: <strong>${result.overallScore ?? ""}</strong></p>
    <p>Thank you.</p>`;

  return {
    to: userEmail,
    subject: "Your VESTA Questionnaire Results",
    bodyText,
    bodyHtml,
    pdfAttachmentName: "VESTA_Results_User_POCRun.pdf",
  };
}

export function buildSponsorEmailPayload(sponsorEmail: string, result: AssessmentResult): EmailPayload {
  const bodyText = `Hello Sponsor,

Here is a concise summary of VESTA results (POC).
Overall Score: ${result.overallScore ?? ""}

Best regards,
VESTA Team`;

  const bodyHtml = `
    <p>Hello Sponsor,</p>
    <p>Here is a concise summary of VESTA results (POC).</p>
    <p>Overall Score: <strong>${result.overallScore ?? ""}</strong></p>`;

  return {
    to: sponsorEmail,
    subject: "VESTA Results Summary (Sponsor)",
    bodyText,
    bodyHtml,
  };
}
