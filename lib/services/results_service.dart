import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projectmercury/models/moca_result.dart';
import 'package:projectmercury/resources/auth_methods.dart';
import 'package:projectmercury/resources/firestore_path.dart';
import 'package:projectmercury/resources/locator.dart';

class ResultsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> hasCurrentUserResults() async {
    final userDoc = await _firestore.doc(FirestorePath.user()).get();
    final userData = userDoc.data() ?? <String, dynamic>{};

    final String? currDataId = userData['currDataId']?.toString();
    final int score = _toInt(userData['score']);
    final int txnCount = _toInt(userData['TXN_CNT'] ?? userData['txnCnt']);
    final int eventCount = _toInt(userData['EVNT_CNT'] ?? userData['evntCnt']);

    if (score > 0 || txnCount > 0 || eventCount > 0) {
      return true;
    }

    if (currDataId == null || currDataId.isEmpty) {
      return false;
    }

    final newDataDoc =
        await _firestore.doc(FirestorePath.newDataRow(currDataId)).get();

    if (!newDataDoc.exists) {
      return false;
    }

    final data = newDataDoc.data() ?? <String, dynamic>{};
    final latest = _extractLatestMocaFields(data);

    if (latest == null) {
      return false;
    }

    final int total = _toInt(latest['total']);
    return total > 0 || latest.isNotEmpty;
  }

  Future<VestaAssessmentResult> getCurrentUserResults() async {
    final auth = locator.get<AuthMethods>();

    final userDoc = await _firestore.doc(FirestorePath.user()).get();
    final userData = userDoc.data() ?? <String, dynamic>{};

    final String email =
        (userData['email'] ?? auth.currentUser.email ?? '').toString().trim();
    final String patientName = _nameFromEmail(email);

    final String? currDataId = userData['currDataId']?.toString();

    Map<String, dynamic>? latestMoca;
    if (currDataId != null && currDataId.isNotEmpty) {
      final newDataDoc =
          await _firestore.doc(FirestorePath.newDataRow(currDataId)).get();
      final newData = newDataDoc.data() ?? <String, dynamic>{};
      latestMoca = _extractLatestMocaFields(newData);
    }

    final DateTime assessmentDate =
        _readTimestamp(latestMoca?['time']) ??
            _readTimestamp(userData['updatedAt']) ??
            DateTime.now();

    final int mocaTotal = _toInt(latestMoca?['total']);
    final int mocaMax =
        _toInt(latestMoca?['max']) == 0 ? 12 : _toInt(latestMoca?['max']);

    final int fluency = _toInt(latestMoca?['fluency']);
    final int recall = _toInt(latestMoca?['recall']);
    final int orientation = _toInt(latestMoca?['orientation']);

    final mocaSections = <MocaSectionResult>[
      MocaSectionResult(
        sectionName: 'Fluency',
        friendlyName: 'Verbal Fluency',
        pointsScored: _clamp(fluency, 0, 1),
        maxPoints: 1,
        description:
            'How many words you generated beginning with the required letter.',
      ),
      MocaSectionResult(
        sectionName: 'Delayed Recall',
        friendlyName: 'Delayed Recall',
        pointsScored: _clamp(recall, 0, 5),
        maxPoints: 5,
        description: 'How many target words you recalled without cues.',
      ),
      MocaSectionResult(
        sectionName: 'Orientation',
        friendlyName: 'Orientation',
        pointsScored: _clamp(orientation, 0, 6),
        maxPoints: 6,
        description:
            'How accurately you identified the date, day, place, and city.',
      ),
    ];

    final int simScore = _toInt(userData['score']);
    final double balance = _toDouble(userData['balance']);
    final int txnCount = _toInt(userData['TXN_CNT'] ?? userData['txnCnt']);
    final int eventCount = _toInt(userData['EVNT_CNT'] ?? userData['evntCnt']);

    final simsSections = _buildSimulationSections(
      score: simScore,
      balance: balance,
      txnCount: txnCount,
      eventCount: eventCount,
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

  Map<String, dynamic>? _extractLatestMocaFields(Map<String, dynamic> row) {
    final RegExp keyPattern = RegExp(r'^(\d+)_MOCA_M(\d+)_(.+)$');

    int latestAttempt = -1;
    int latestSession = -1;
    final Map<String, dynamic> latestFields = {};

    row.forEach((key, value) {
      final match = keyPattern.firstMatch(key);
      if (match == null) return;

      final int session = int.tryParse(match.group(1) ?? '') ?? -1;
      final int attempt = int.tryParse(match.group(2) ?? '') ?? -1;
      final String field = match.group(3) ?? '';

      if (attempt > latestAttempt ||
          (attempt == latestAttempt && session > latestSession)) {
        latestAttempt = attempt;
        latestSession = session;
        latestFields.clear();
      }

      if (attempt == latestAttempt && session == latestSession) {
        latestFields[field] = value;
      }
    });

    if (latestAttempt < 0 || latestSession < 0) {
      return null;
    }

    return latestFields;
  }

  List<SimsSectionResult> _buildSimulationSections({
    required int score,
    required double balance,
    required int txnCount,
    required int eventCount,
  }) {
    final int budgetPoints = _clamp((balance / 1600).round(), 0, 10);
    final int scamPoints = _clamp(eventCount, 0, 10);
    final int financialPoints = _clamp(txnCount * 2, 0, 10);
    final int decisionPoints = _clamp((score / 5).round(), 0, 10);

    return [
      SimsSectionResult(
        sectionName: 'Budget Management',
        friendlyName: 'Managing a Budget',
        pointsScored: budgetPoints,
        maxPoints: 10,
        description:
            'Based on how well you preserved and managed your balance.',
      ),
      SimsSectionResult(
        sectionName: 'Scam Detection',
        friendlyName: 'Scam Awareness',
        pointsScored: scamPoints,
        maxPoints: 10,
        description:
            'Based on your event interactions and scam-related responses.',
      ),
      SimsSectionResult(
        sectionName: 'Financial Awareness',
        friendlyName: 'Financial Decisions',
        pointsScored: financialPoints,
        maxPoints: 10,
        description:
            'Based on your transaction activity and financial task participation.',
      ),
      SimsSectionResult(
        sectionName: 'Decision Making',
        friendlyName: 'Making Choices',
        pointsScored: decisionPoints,
        maxPoints: 10,
        description:
            'Based on your overall simulation performance score.',
      ),
    ];
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return 0;
  }

  double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return 0.0;
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