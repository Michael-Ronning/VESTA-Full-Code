import { AssessmentResult, CategoryScore } from "./models";

export function mockAssessment(): AssessmentResult {
  const categories: CategoryScore[] = [
    {
      id: "orientation",
      name: "Orientation",
      score: 2,
      details: [
        { item: "Q1: What is today's date?", chosen: "June 5", score: 1 },
        { item: "Q2: Which season are we currently in?", chosen: "Summer", score: 1 }
      ]
    },
    {
      id: "attention",
      name: "Attention",
      score: 2,
      details: [
        { item: "Q3: Tap numbers in order 1-4", chosen: "2,4,7", score: 1 },
        { item: "Q4: After D", chosen: "E", score: 1 }
      ]
    },
    {
      id: "memory",
      name: "Memory",
      score: 2,
      details: [
        { item: "Q5: Remember words", chosen: "Face, Velvet, Church", score: 1 },
        { item: "Q6: Which word shown earlier?", chosen: "Velvet", score: 1 }
      ]
    },
    {
      id: "abstraction",
      name: "Abstraction",
      score: 2,
      details: [
        { item: "Q8: Train vs bicycle similarity", chosen: "Both are forms of transportation", score: 2 }
      ]
    },
    {
      id: "executive",
      name: "Executive",
      score: 2,
      details: [
        { item: "Q9: Next in sequence 2,4,6,?", chosen: "8", score: 1 },
        { item: "Q10: Change calculation", chosen: "75 cents", score: 1 }
      ]
    }
  ];

  return {
    assessmentId: "sess-001",
    timestamp: new Date().toISOString(),
    overallScore: 10,
    moCA: { moCAraw: "MOCA-like items", moCAscore: 28, notes: "" },
    categories
  };
}
