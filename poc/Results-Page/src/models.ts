export type SessionResponse = {
  id: string;          // Q1..Q10
  category: string;      // orientation, attention, memory, abstraction, executive
  prompt: string;
  chosenOption: string;
  timestamp?: string;
};

export type MOCAResult = {
  moCAraw?: string;
  moCAscore?: number;
  notes?: string;
};

export type CategoryDetail = {
  item: string;
  chosen?: string;
  score?: number;
  note?: string;
};

export type CategoryScore = {
  id: string;
  name: string;
  score?: number;
  details: CategoryDetail[];
};

export type AssessmentResult = {
  assessmentId: string;
  timestamp?: string;
  overallScore?: number;
  moCA?: MOCAResult;
  categories: CategoryScore[];
  responses?: SessionResponse[];
};

export type EmailPayload = {
  to: string;
  subject: string;
  bodyHtml: string;
  bodyText: string;
  pdfAttachmentName?: string;
};

export type SponsorReport = {
  title: string;
  generatedAt: string;
  summary: string;
  categories: { id: string; name: string; score?: number }[];
  details?: any;
};
