/// Data model for a complete VESTA assessment result.
/// Includes both Mini MoCA cognitive scores and SIMS game scores.

class MocaSectionResult {
  final String sectionName;       // e.g., "Fluency"
  final String friendlyName;      // e.g., "Verbal Fluency"
  final int pointsScored;
  final int maxPoints;
  final String description;       // Simple explanation for the patient

  MocaSectionResult({
    required this.sectionName,
    required this.friendlyName,
    required this.pointsScored,
    required this.maxPoints,
    required this.description,
  });

  /// Returns a percentage (0.0 to 1.0) for progress bar display
  double get percentage =>
      maxPoints > 0 ? pointsScored / maxPoints : 0.0;
}

class SimsSectionResult {
  final String sectionName;       // e.g., "Scam Detection"
  final String friendlyName;      // e.g., "Scam Awareness"
  final int pointsScored;
  final int maxPoints;
  final String description;

  SimsSectionResult({
    required this.sectionName,
    required this.friendlyName,
    required this.pointsScored,
    required this.maxPoints,
    required this.description,
  });

  double get percentage =>
      maxPoints > 0 ? pointsScored / maxPoints : 0.0;
}

class VestaAssessmentResult {
  // --- Patient Info ---
  final String patientName;
  final DateTime assessmentDate;
  final int educationYears;       // Kept for compatibility with existing UI

  // --- MoCA Sections ---
  final List<MocaSectionResult> mocaSections;

  // --- SIMS Game Sections ---
  final List<SimsSectionResult> simsSections;

  // --- Optional Firebase Summary Overrides ---
  final int? mocaTotalOverride;
  final int? mocaMaxOverride;

  VestaAssessmentResult({
    required this.patientName,
    required this.assessmentDate,
    required this.educationYears,
    required this.mocaSections,
    required this.simsSections,
    this.mocaTotalOverride,
    this.mocaMaxOverride,
  });

  // ---- MoCA Calculations ----

  /// Raw Mini MoCA score before any override
  int get mocaRawScore =>
      mocaSections.fold(0, (sum, s) => sum + s.pointsScored);

  /// Kept for compatibility with the existing screen.
  /// Mini MoCA does not use this the same way the old full MoCA did.
  int get educationAdjustment => educationYears <= 12 ? 1 : 0;

  /// Final Mini MoCA score.
  /// If Firebase summary provides a stored total, prefer that.
  int get mocaTotalScore {
    if (mocaTotalOverride != null) return mocaTotalOverride!;

    int total = mocaRawScore;
    final max = mocaMaxScore;
    return total > max ? max : total;
  }

  /// Maximum possible Mini MoCA score
  int get mocaMaxScore => mocaMaxOverride ?? 15;

  /// Mini MoCA is generally considered "normal" at 12+
  String get mocaStatus {
    if (mocaTotalScore >= 12) return 'Normal';
    if (mocaTotalScore >= 8) return 'Mild Concern';
    return 'Needs Review';
  }

  // ---- SIMS Calculations ----

  int get simsTotalScore =>
      simsSections.fold(0, (sum, s) => sum + s.pointsScored);

  int get simsMaxScore =>
      simsSections.fold(0, (sum, s) => sum + s.maxPoints);

  double get simsPercentage =>
      simsMaxScore > 0 ? simsTotalScore / simsMaxScore : 0.0;

  String get simsStatus {
    double pct = simsPercentage;
    if (pct >= 0.80) return 'Strong';
    if (pct >= 0.60) return 'Moderate';
    return 'Needs Review';
  }
}