import { AssessmentResult, SponsorReport } from "./models";

export function buildSponsorReport(result: AssessmentResult): SponsorReport {
  const categories = result.categories.map((c) => ({
    id: c.id,
    name: c.name,
    score: c.score
  }));

  return {
    title: "VESTA Sponsor Report (POC)",
    generatedAt: new Date().toISOString(),
    summary: `Overall Score: ${result.overallScore ?? ""}. See category-level breakdown for details.`,
    categories
  };
}
