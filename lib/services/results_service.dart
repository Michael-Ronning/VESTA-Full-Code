import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projectmercury/models/moca_result.dart';
import 'package:projectmercury/resources/auth_methods.dart';
import 'package:projectmercury/resources/firestore_path.dart';
import 'package:projectmercury/resources/locator.dart';

class ResultsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> hasCurrentUserResults() async {
    final auth = locator.get<AuthMethods>();
    final uid = auth.uid;

    final userDoc = await _firestore.doc(FirestorePath.user()).get();
    final userData = userDoc.data() ?? <String, dynamic>{};
    final int currentSession =
        _toInt(userData['session']) == 0 ? 1 : _toInt(userData['session']);

    final summaryDoc = await _firestore
        .doc(FirestorePath.sessionSummary(uid, currentSession))
        .get();

    if (!summaryDoc.exists) return false;

    final summary = summaryDoc.data() ?? <String, dynamic>{};

    final bool mocaCompleted = summary['mocaCompleted'] == true;
    final int tasksTotal = _toInt(summary['tasksTotal']);
    final int approvedTxns = _toInt(summary['approvedTxns']);
    final int disputedTxns = _toInt(summary['disputedTxns']);
    final int eventYes = _toInt(summary['eventYes']);
    final int eventNo = _toInt(summary['eventNo']);

    return mocaCompleted ||
        tasksTotal > 0 ||
        approvedTxns > 0 ||
        disputedTxns > 0 ||
        eventYes > 0 ||
        eventNo > 0;
  }

  Future<VestaAssessmentResult> getCurrentUserResults() async {
    final auth = locator.get<AuthMethods>();
    final uid = auth.uid;

    final userDoc = await _firestore.doc(FirestorePath.user()).get();
    final userData = userDoc.data() ?? <String, dynamic>{};
    final int currentSession =
        _toInt(userData['session']) == 0 ? 1 : _toInt(userData['session']);

    final summaryDoc = await _firestore
        .doc(FirestorePath.sessionSummary(uid, currentSession))
        .get();
    final summary = summaryDoc.data() ?? <String, dynamic>{};

    final String email =
        (summary['email'] ?? userData['email'] ?? auth.currentUser.email ?? '')
            .toString()
            .trim();

    final String patientName = _nameFromEmail(email);

    final DateTime assessmentDate =
            _readTimestamp(summary['updatedAt']) ??
            _readTimestamp(summary['sessionStartTs']) ??
            DateTime.now();

    final int mocaTotal = _toInt(summary['mocaTotal']);
    final int mocaMax =
        _toInt(summary['mocaMaxScore']) == 0 ? 15 : _toInt(summary['mocaMaxScore']);

    final int miniFluency = _toInt(summary['miniFluency']);
    final int miniRecall = _toInt(summary['miniRecall']);
    final int miniOrientation = _toInt(summary['miniOrientation']);

    final int approvedTxns = _toInt(summary['approvedTxns']);
    final int disputedTxns = _toInt(summary['disputedTxns']);
    final int easyCompleted = _toInt(summary['easyCompleted']);
    final int easyFailed = _toInt(summary['easyFailed']);
    final int hardCompleted = _toInt(summary['hardCompleted']);
    final int hardFailed = _toInt(summary['hardFailed']);
    final int tasksCompleted = _toInt(summary['tasksCompleted']);
    final int tasksFailed = _toInt(summary['tasksFailed']);
    final int tasksTotal = _toInt(summary['tasksTotal']);
    final int eventYes = _toInt(summary['eventYes']);
    final int eventNo = _toInt(summary['eventNo']);

    final mocaSections = <MocaSectionResult>[
      MocaSectionResult(
        sectionName: 'Fluency',
        friendlyName: 'Verbal Fluency',
        pointsScored: _clamp(miniFluency, 0, 4),
        maxPoints: 4,
        description:
            'How many words you generated beginning with the required letter.',
      ),
      MocaSectionResult(
        sectionName: 'Delayed Recall',
        friendlyName: 'Delayed Recall',
        pointsScored: _clamp(miniRecall, 0, 5),
        maxPoints: 5,
        description: 'How many target words you recalled without cues.',
      ),
      MocaSectionResult(
        sectionName: 'Orientation',
        friendlyName: 'Orientation',
        pointsScored: _clamp(miniOrientation, 0, 6),
        maxPoints: 6,
        description:
            'How accurately you identified the date, day, place, and city.',
      ),
    ];

    final simsSections = _buildSimulationSections(
      approvedTxns: approvedTxns,
      disputedTxns: disputedTxns,
      easyCompleted: easyCompleted,
      easyFailed: easyFailed,
      hardCompleted: hardCompleted,
      hardFailed: hardFailed,
      tasksCompleted: tasksCompleted,
      tasksFailed: tasksFailed,
      tasksTotal: tasksTotal,
      eventYes: eventYes,
      eventNo: eventNo,
    );

    return VestaAssessmentResult(
      patientName: patientName,
      assessmentDate: assessmentDate,
      educationYears: 13,
      mocaSections: mocaSections,
      simsSections: simsSections,
      mocaTotalOverride: mocaTotal,
      mocaMaxOverride: mocaMax,
    );
  }

  List<SimsSectionResult> _buildSimulationSections({
    required int approvedTxns,
    required int disputedTxns,
    required int easyCompleted,
    required int easyFailed,
    required int hardCompleted,
    required int hardFailed,
    required int tasksCompleted,
    required int tasksFailed,
    required int tasksTotal,
    required int eventYes,
    required int eventNo,
  }) {
    final int budgetPoints = _clamp(tasksCompleted, 0, 10);
    final int scamPoints =
        _clamp(eventYes + eventNo + approvedTxns + disputedTxns, 0, 10);
    final int financialPoints = _clamp(easyCompleted + hardCompleted, 0, 10);
    final int decisionPoints = _clamp(tasksTotal - tasksFailed, 0, 10);

    return [
      SimsSectionResult(
        sectionName: 'Budget Management',
        friendlyName: 'Managing a Budget',
        pointsScored: budgetPoints,
        maxPoints: 10,
        description:
            'How well you completed practical budgeting and purchase tasks.',
      ),
      SimsSectionResult(
        sectionName: 'Scam Detection',
        friendlyName: 'Scam Awareness',
        pointsScored: scamPoints,
        maxPoints: 10,
        description:
            'How often you responded to suspicious financial events and transactions.',
      ),
      SimsSectionResult(
        sectionName: 'Financial Awareness',
        friendlyName: 'Financial Decisions',
        pointsScored: financialPoints,
        maxPoints: 10,
        description: 'How well you handled easy and hard financial tasks.',
      ),
      SimsSectionResult(
        sectionName: 'Decision Making',
        friendlyName: 'Making Choices',
        pointsScored: decisionPoints,
        maxPoints: 10,
        description:
            'How consistently you completed tasks successfully during the session.',
      ),
    ];
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return 0;
  }

  int _clamp(int value, int min, int max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  DateTime? _readTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  String _nameFromEmail(String email) {
    if (email.isEmpty) return 'Participant';

    final local = email.split('@').first.trim();
    final cleaned = local.replaceAll(RegExp(r'[._\-0-9]+'), ' ').trim();
    if (cleaned.isEmpty) return 'Participant';

    final words = cleaned
        .split(' ')
        .where((w) => w.trim().isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .toList();

    return words.isEmpty ? 'Participant' : words.join(' ');
  }
}