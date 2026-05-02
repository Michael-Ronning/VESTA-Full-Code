import 'package:flutter/material.dart';
import 'package:projectmercury/models/moca_result.dart';
import 'package:projectmercury/services/results_service.dart';
import 'package:projectmercury/services/pdf_service.dart';
/// -------------------------------------------------------
/// VESTA Results Screen
/// -------------------------------------------------------
/// Displays MoCA + SIMS assessment results to the patient.
/// Designed for users 60+ : large fonts, high contrast,
/// simple language, big tap targets, single scroll page.
/// -------------------------------------------------------

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

@override
Widget build(BuildContext context) {
  final resultsService = ResultsService();

  return FutureBuilder<VestaAssessmentResult>(
    future: resultsService.getCurrentUserResults(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(
          backgroundColor: Color(0xFF1A1A2E),
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (snapshot.hasError) {
        return Scaffold(
          backgroundColor: const Color(0xFF1A1A2E),
          appBar: AppBar(
            backgroundColor: const Color(0xFF16213E),
            title: const Text('Your Results'),
            centerTitle: true,
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Could not load results.\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        );
      }

      if (!snapshot.hasData) {
        return Scaffold(
          backgroundColor: const Color(0xFF1A1A2E),
          appBar: AppBar(
            backgroundColor: const Color(0xFF16213E),
            title: const Text('Your Results'),
            centerTitle: true,
          ),
          body: const Center(
            child: Text(
              'No results found yet.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
        );
      }

      final result = snapshot.data!;

      return Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        appBar: AppBar(
          backgroundColor: const Color(0xFF16213E),
          elevation: 0,
          title: const Text(
            'Your Results',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildGreeting(result),
                const SizedBox(height: 24),
                _buildMocaScoreCard(result),
                const SizedBox(height: 24),
                _buildSectionHeader('Mini MoCA Breakdown'),
                const SizedBox(height: 12),
                ...result.mocaSections.map(
                  (section) => _buildMocaSectionTile(section),
                ),
                const SizedBox(height: 32),
                _buildSimsScoreCard(result),
                const SizedBox(height: 24),
                _buildSectionHeader('Financial & Life Skills Breakdown'),
                const SizedBox(height: 12),
                ...result.simsSections.map(
                  (section) => _buildSimsSectionTile(section),
                ),
                const SizedBox(height: 32),
                const SizedBox(height: 16),
                _buildNextStepsCard(),
                const SizedBox(height: 32),
                _buildDoneButton(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      );
    },
  );
}

  Widget _buildGreeting(VestaAssessmentResult result) {
    String formattedDate =
        '${result.assessmentDate.month}/${result.assessmentDate.day}/${result.assessmentDate.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, ${result.patientName.split(' ').first}!',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Here are your results from $formattedDate.',
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'A detailed report will also be sent to your email.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white54,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildMocaScoreCard(VestaAssessmentResult result) {
    Color statusColor = _getMocaStatusColor(result.mocaStatus);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.5), width: 2),
      ),
      child: Column(
        children: [
          const Text(
            'Cognitive Score',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: statusColor, width: 6),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${result.mocaTotalScore}',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  Text(
                    'out of ${result.mocaMaxScore}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              result.mocaStatus,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _getMocaExplanation(result.mocaStatus),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white60,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimsScoreCard(VestaAssessmentResult result) {
    Color statusColor = _getSimsStatusColor(result.simsStatus);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.5), width: 2),
      ),
      child: Column(
        children: [
          const Text(
            'Life Skills Score',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: statusColor, width: 6),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${result.simsTotalScore}',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  Text(
                    'out of ${result.simsMaxScore}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              result.simsStatus,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _getSimsExplanation(result.simsStatus),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white60,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildMocaSectionTile(MocaSectionResult section) {
    Color barColor = _getBarColor(section.percentage);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2B47),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  section.friendlyName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                '${section.pointsScored} / ${section.maxPoints}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: barColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: section.percentage,
              minHeight: 12,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            section.description,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white54,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimsSectionTile(SimsSectionResult section) {
    Color barColor = _getBarColor(section.percentage);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2B47),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  section.friendlyName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                '${section.pointsScored} / ${section.maxPoints}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: barColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: section.percentage,
              minHeight: 12,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            section.description,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white54,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1F47),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.withOpacity(0.4)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.deepPurpleAccent, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your cognitive score includes a 1-point '
              'adjustment based on your education background. '
              'This is standard practice.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.white60,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextStepsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.mail_outline, color: Colors.blueAccent, size: 28),
              SizedBox(width: 12),
              Text(
                'What Happens Next?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            '• A detailed report will be emailed to you.\n'
            '• Your results are shared with your care provider.\n'
            '• If you have questions, please contact your provider.',
            style: TextStyle(
              fontSize: 17,
              color: Colors.white70,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildDownloadButton(
  BuildContext context,
  VestaAssessmentResult result,
) {
  return SizedBox(
    height: 60,
    child: ElevatedButton(
      onPressed: () async {
        await PdfService.generatePdf(context, result);
      },
      child: const Text(
        'Download PDF',
        style: TextStyle(fontSize: 20),
      ),
    ),
  );
}
  Widget _buildDoneButton(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0F3460),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: const Text(
          'Done',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Color _getMocaStatusColor(String status) {
    switch (status) {
      case 'Normal':
        return const Color(0xFF4CAF50);
      case 'Mild Concern':
        return const Color(0xFFFFC107);
      default:
        return const Color(0xFFFF7043);
    }
  }

  Color _getSimsStatusColor(String status) {
    switch (status) {
      case 'Strong':
        return const Color(0xFF4CAF50);
      case 'Moderate':
        return const Color(0xFFFFC107);
      default:
        return const Color(0xFFFF7043);
    }
  }

  String _getMocaExplanation(String status) {
    switch (status) {
      case 'Normal':
        return 'Your cognitive abilities are within the expected range. '
            'Keep staying active and engaged!';
      case 'Mild Concern':
        return 'Some areas showed room for improvement. '
            'This does not mean anything is wrong — '
            'your provider can discuss this with you.';
      default:
        return 'We recommend discussing these results '
            'with your healthcare provider for guidance.';
    }
  }

  String _getSimsExplanation(String status) {
    switch (status) {
      case 'Strong':
        return 'You showed strong skills in managing finances '
            'and spotting potential scams. Great work!';
      case 'Moderate':
        return 'You did well in some areas. Reviewing tips on '
            'budgeting and scam awareness could be helpful.';
      default:
        return 'We recommend reviewing financial safety resources. '
            'Your provider can help with next steps.';
    }
  }

  Color _getBarColor(double percentage) {
    if (percentage >= 0.80) return const Color(0xFF4CAF50);
    if (percentage >= 0.60) return const Color(0xFFFFC107);
    return const Color(0xFFFF7043);
  }
}
ElevatedButton(
  onPressed: () async {
    await PdfService.generatePdf(context, result);
  },
  child: const Text('Download PDF'),
)
ElevatedButton(
  onPressed: () async {
    await PdfService.emailPdf(context, result);
  },
  child: const Text('Email PDF'),
)
