/// Data model for a complete VESTA assessment result.
/// Includes both MoCA cognitive scores and SIMS game scores.

class MocaSectionResult {
  final String sectionName;       // e.g., "Memory"
  final String friendlyName;      // e.g., "Your Memory Score"
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
  final int educationYears;       // For MoCA +1 adjustment

  // --- MoCA Sections ---
  final List<MocaSectionResult> mocaSections;

  // --- SIMS Game Sections ---
  final List<SimsSectionResult> simsSections;

  VestaAssessmentResult({
    required this.patientName,
    required this.assessmentDate,
    required this.educationYears,
    required this.mocaSections,
    required this.simsSections,
  });

  // ---- MoCA Calculations ----

  /// Raw MoCA score before education adjustment
  int get mocaRawScore =>
      mocaSections.fold(0, (sum, s) => sum + s.pointsScored);

  /// +1 point if patient has 12 or fewer years of education
  int get educationAdjustment => educationYears <= 12 ? 1 : 0;

  /// Final MoCA score (capped at 30)
  int get mocaTotalScore {
    int total = mocaRawScore + educationAdjustment;
    return total > 30 ? 30 : total;
  }

  /// Maximum possible MoCA score
  int get mocaMaxScore => 30;

  /// MoCA is generally "normal" at 26+
  String get mocaStatus {
    if (mocaTotalScore >= 26) return 'Normal';
    if (mocaTotalScore >= 18) return 'Mild Concern';
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
