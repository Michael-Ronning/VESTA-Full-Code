import 'package:flutter/services.dart' show rootBundle;
import 'package:projectmercury/data/event_data.dart';

class TaskMappingRow {
  final String templateId;
  final String entityType;
  final String difficulty;
  final String successDecision;
  final bool countAsTask;
  final String notes;

  const TaskMappingRow({
    required this.templateId,
    required this.entityType,
    required this.difficulty,
    required this.successDecision,
    required this.countAsTask,
    required this.notes,
  });
}

class TaskMappingValidationReport {
  final List<String> errors;
  final List<String> warnings;
  final List<String> missingEventTemplateIds;
  final List<String> missingTxnTemplateIds;

  const TaskMappingValidationReport({
    required this.errors,
    required this.warnings,
    required this.missingEventTemplateIds,
    required this.missingTxnTemplateIds,
  });

  bool get isValid => errors.isEmpty;
}

class TaskMappingValidator {
  static const String defaultAssetPath =
      'lib/data/analytics/task_mapping_v1.csv';

  static Future<List<TaskMappingRow>> loadMappingRows({
    String assetPath = defaultAssetPath,
  }) async {
    final csv = await rootBundle.loadString(assetPath);
    return _parseCsv(csv);
  }

  static Future<TaskMappingValidationReport> validateDefaultMapping({
    String assetPath = defaultAssetPath,
    Set<String> expectedTxnTemplateIds = const {},
  }) async {
    final rows = await loadMappingRows(assetPath: assetPath);

    // NOTE: Event currently exposes stable `id` values in seed data.
    // If/when explicit templateId is added, switch this to those values.
    final expectedEventTemplateIds =
        events.map((e) => e.id.trim()).where((id) => id.isNotEmpty).toSet();

    return validateRows(
      rows,
      expectedEventTemplateIds: expectedEventTemplateIds,
      expectedTxnTemplateIds: expectedTxnTemplateIds,
    );
  }

  static TaskMappingValidationReport validateRows(
    List<TaskMappingRow> rows, {
    required Set<String> expectedEventTemplateIds,
    required Set<String> expectedTxnTemplateIds,
  }) {
    final errors = <String>[];
    final warnings = <String>[];

    final seen = <String>{};

    for (final row in rows) {
      if (row.templateId.isEmpty) {
        errors.add('Row has empty templateId.');
        continue;
      }

      if (!seen.add(row.templateId)) {
        errors.add('Duplicate templateId found: ${row.templateId}');
      }

      if (row.entityType != 'EVNT' && row.entityType != 'TXN') {
        errors.add(
            'templateId ${row.templateId} has invalid entityType ${row.entityType}. Expected EVNT or TXN.');
      }

      if (row.difficulty != 'easy' && row.difficulty != 'hard') {
        errors.add(
            'templateId ${row.templateId} has invalid difficulty ${row.difficulty}. Expected easy or hard.');
      }

      if (row.countAsTask) {
        if (row.entityType == 'EVNT' &&
            row.successDecision != 'yes' &&
            row.successDecision != 'no') {
          errors.add(
              'templateId ${row.templateId} must have successDecision yes/no for EVNT when countAsTask=true.');
        }
        if (row.entityType == 'TXN' &&
            row.successDecision != 'approve' &&
            row.successDecision != 'dispute') {
          errors.add(
              'templateId ${row.templateId} must have successDecision approve/dispute for TXN when countAsTask=true.');
        }
      }
    }

    final mappedEventIds = rows
        .where((r) => r.entityType == 'EVNT')
        .map((r) => r.templateId)
        .toSet();
    final mappedTxnIds = rows
        .where((r) => r.entityType == 'TXN')
        .map((r) => r.templateId)
        .toSet();

    final missingEventTemplateIds =
        expectedEventTemplateIds.difference(mappedEventIds).toList()..sort();
    final missingTxnTemplateIds =
        expectedTxnTemplateIds.difference(mappedTxnIds).toList()..sort();

    if (missingEventTemplateIds.isNotEmpty) {
      warnings.add(
          'Missing event templateIds in mapping: ${missingEventTemplateIds.join(', ')}');
    }
    if (missingTxnTemplateIds.isNotEmpty) {
      warnings.add(
          'Missing transaction templateIds in mapping: ${missingTxnTemplateIds.join(', ')}');
    }

    if (expectedTxnTemplateIds.isEmpty) {
      warnings.add(
          'No expected transaction templateIds were provided to validator; transaction coverage check is skipped.');
    }

    return TaskMappingValidationReport(
      errors: errors,
      warnings: warnings,
      missingEventTemplateIds: missingEventTemplateIds,
      missingTxnTemplateIds: missingTxnTemplateIds,
    );
  }

  static List<TaskMappingRow> _parseCsv(String csv) {
    final lines = csv
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return const [];
    }

    final header = lines.first.split(',').map((e) => e.trim()).toList();
    const expectedHeader = [
      'templateId',
      'entityType',
      'difficulty',
      'successDecision',
      'countAsTask',
      'notes',
    ];

    if (header.length != expectedHeader.length ||
        !_listEquals(header, expectedHeader)) {
      throw FormatException(
          'Invalid CSV header. Expected: ${expectedHeader.join(',')}');
    }

    final rows = <TaskMappingRow>[];

    for (int i = 1; i < lines.length; i++) {
      final cols = lines[i].split(',');
      if (cols.length < 6) {
        throw FormatException('Invalid CSV row at line ${i + 1}: ${lines[i]}');
      }

      rows.add(TaskMappingRow(
        templateId: cols[0].trim(),
        entityType: cols[1].trim(),
        difficulty: cols[2].trim(),
        successDecision: cols[3].trim(),
        countAsTask: cols[4].trim().toLowerCase() == 'true',
        notes: cols.sublist(5).join(',').trim(),
      ));
    }

    return rows;
  }

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) {
      return false;
    }
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }
}
