import 'package:projectmercury/models/moca_result.dart';

/// Mock data representing a completed VESTA assessment.
/// This simulates a patient who scored 22/30 on MoCA
/// and did moderately well on the SIMS financial game.
///
/// Replace this with real Firebase data later.

VestaAssessmentResult getMockResult() {
  return VestaAssessmentResult(
    patientName: 'Margaret Johnson',
    assessmentDate: DateTime(2026, 2, 14),
    educationYears: 14,

    mocaSections: [
      MocaSectionResult(
        sectionName: 'Visuospatial/Executive',
        friendlyName: 'Thinking & Planning',
        pointsScored: 3,
        maxPoints: 5,
        description:
            'This measures your ability to plan steps, '
            'copy shapes, and read a clock.',
      ),
      MocaSectionResult(
        sectionName: 'Naming',
        friendlyName: 'Recognizing Objects',
        pointsScored: 3,
        maxPoints: 3,
        description:
            'This measures your ability to identify '
            'familiar animals and objects.',
      ),
      MocaSectionResult(
        sectionName: 'Attention',
        friendlyName: 'Focus & Concentration',
        pointsScored: 4,
        maxPoints: 6,
        description:
            'This measures how well you can stay focused, '
            'remember numbers, and do simple math.',
      ),
      MocaSectionResult(
        sectionName: 'Language',
        friendlyName: 'Language & Speaking',
        pointsScored: 2,
        maxPoints: 3,
        description:
            'This measures your ability to repeat sentences '
            'and think of words quickly.',
      ),
      MocaSectionResult(
        sectionName: 'Abstraction',
        friendlyName: 'Comparing Ideas',
        pointsScored: 2,
        maxPoints: 2,
        description:
            'This measures your ability to see how '
            'two things are related or similar.',
      ),
      MocaSectionResult(
        sectionName: 'Delayed Recall',
        friendlyName: 'Your Memory',
        pointsScored: 2,
        maxPoints: 5,
        description:
            'This measures how well you remember words '
            'that were shown to you earlier.',
      ),
      MocaSectionResult(
        sectionName: 'Orientation',
        friendlyName: 'Awareness of Time & Place',
        pointsScored: 6,
        maxPoints: 6,
        description:
            'This measures whether you know today\'s date, '
            'where you are, and what city you\'re in.',
      ),
    ],

    simsSections: [
      SimsSectionResult(
        sectionName: 'Budget Management',
        friendlyName: 'Managing a Budget',
        pointsScored: 7,
        maxPoints: 10,
        description:
            'How well you planned spending when building '
            'and furnishing your home.',
      ),
      SimsSectionResult(
        sectionName: 'Scam Detection',
        friendlyName: 'Scam Awareness',
        pointsScored: 6,
        maxPoints: 10,
        description:
            'How well you identified suspicious offers, '
            'fake deals, and scam attempts.',
      ),
      SimsSectionResult(
        sectionName: 'Financial Awareness',
        friendlyName: 'Financial Decisions',
        pointsScored: 8,
        maxPoints: 10,
        description:
            'How well you understood costs, compared prices, '
            'and made smart money choices.',
      ),
      SimsSectionResult(
        sectionName: 'Decision Making',
        friendlyName: 'Making Choices',
        pointsScored: 7,
        maxPoints: 10,
        description:
            'How well you weighed your options and made '
            'thoughtful decisions under pressure.',
      ),
    ],
  );
}
