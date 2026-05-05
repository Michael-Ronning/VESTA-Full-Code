import 'package:flutter/material.dart';
import 'package:projectmercury/models/moca_result.dart';
import 'package:projectmercury/services/results_service.dart';
/// -------------------------------------------------------
/// VESTA Results Screen
/// -------------------------------------------------------
/// Displays MoCA + SIMS assessment results to the patient.
/// Designed for users 60+ : large fonts, high contrast,
/// simple language, big tap targets, single scroll page.
/// -------------------------------------------------------

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});
 
 
 static const Color _appPrimary = Color(0xFFFF5A5A);
static const Color _appPrimaryDark = Color(0xFFE14B4B);
static const Color _appPrimaryLight = Color(0xFFFFECEC);
static const Color _pageBg = Color(0xFFFFF7F7);
static const Color _cardBg = Color(0xFFFFFCFC);
static const Color _textDark = Color(0xFF222222);
static const Color _textMuted = Color(0xFF666666);
static const Color _softBorder = Color(0xFFFFD6D6);

static const Color _goodColor = Color(0xFF43A047);
static const Color _warningColor = Color(0xFFE0A13B);
static const Color _criticalColor = Color(0xFFD96C6C);

static const Color _goodBg = Color(0xFFE8F5E9);
static const Color _warningBg = Color(0xFFFFF8E1);
static const Color _criticalBg = Color(0xFFFFEBEE);

static const Color _barTrack = Color(0xFFF1E3E3);


@override
Widget build(BuildContext context) {
  final resultsService = ResultsService();

  return FutureBuilder<VestaAssessmentResult>(
    future: resultsService.getCurrentUserResults(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(
         backgroundColor: _pageBg,
         body: Center(
           child: CircularProgressIndicator(
              color: _appPrimary,
            ),
         ),
        );
      }

      if (snapshot.hasError) {
        return Scaffold(
          backgroundColor: _pageBg,
          appBar: AppBar(
            backgroundColor: _appPrimary,
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
                  color: _textDark,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        );
      }

      if (!snapshot.hasData) {
         return Scaffold(
           backgroundColor: _pageBg,
           appBar: AppBar(
              backgroundColor: _appPrimary,
              foregroundColor: Colors.white,
             iconTheme: const IconThemeData(color: Colors.white),
             title: const Text('Your Results'),
              centerTitle: true,
           ),
           body: const Center(
             child: Text(
               'No results found yet.',
                style: TextStyle(
                 color: _textDark,
                 fontSize: 18,
                ),
             ),
           ),
         );
        }

      final result = snapshot.data!;

      return Scaffold(
            backgroundColor: _pageBg,
           appBar: AppBar(
      backgroundColor: _appPrimary,
     foregroundColor: Colors.white,
     iconTheme: const IconThemeData(color: Colors.white),
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
            color: _textDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Here are your results from $formattedDate.',
          style: const TextStyle(
            fontSize: 18,
            color: _textMuted,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'A detailed report will also be sent to your email.',
          style: TextStyle(
            fontSize: 16,
            color: _textMuted,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildMocaScoreCard(VestaAssessmentResult result) {
    Color statusColor = _getMocaStatusColor(result.mocaStatus);
    Color statusBg = _getMocaStatusBg(result.mocaStatus);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _softBorder, width: 2),
       boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
       ],
      ),
      child: Column(
        children: [
          const Text(
            'Cognitive Score',
            style: TextStyle(
              fontSize: 20,
              color: _textMuted,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: statusColor, width: 5),
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
                      color: _textMuted,
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
            color: statusBg,
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
              color: _textMuted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimsScoreCard(VestaAssessmentResult result) {
    Color statusColor = _getSimsStatusColor(result.simsStatus);
  Color statusBg = _getSimsStatusBg(result.simsStatus);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
       color: _cardBg,
       borderRadius: BorderRadius.circular(16),
       border: Border.all(color: _softBorder, width: 2),
        boxShadow: [
         BoxShadow(
           color: Colors.black.withOpacity(0.05),
           blurRadius: 10,
            offset: const Offset(0, 4),
         ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Life Skills Score',
            style: TextStyle(
              fontSize: 20,
              color: _textMuted,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: statusColor, width: 5),
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
                      color: _textMuted,
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
             color: statusBg,
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
              color: _textMuted,
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
        color: _textDark,
      ),
    );
  }

  Widget _buildMocaSectionTile(MocaSectionResult section) {
    Color barColor = _getBarColor(section.percentage);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
         color: _cardBg,
         borderRadius: BorderRadius.circular(12),
         border: Border.all(color: _softBorder),
         boxShadow: [
           BoxShadow(
             color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
         ],
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
                    color: _textDark,
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
              backgroundColor: _barTrack,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            section.description,
            style: const TextStyle(
              fontSize: 15,
              color: _textMuted,
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
        color: _cardBg,
       borderRadius: BorderRadius.circular(12),
       border: Border.all(color: _softBorder),
       boxShadow: [
         BoxShadow(
           color: Colors.black.withOpacity(0.03),
           blurRadius: 6,
           offset: const Offset(0, 2),
          ),
       ],
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
                    color: _textDark,
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
              backgroundColor: _barTrack,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            section.description,
            style: const TextStyle(
              fontSize: 15,
              color: _textMuted,
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
      color: _cardBg,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _softBorder),
    ),
    child: const Row(
      children: [
        Icon(Icons.info_outline, color: _appPrimary, size: 28),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            'Your cognitive score includes a 1-point '
            'adjustment based on your education background. '
            'This is standard practice.',
            style: TextStyle(
              fontSize: 15,
              color: _textMuted,
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
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _softBorder),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.mail_outline, color: _appPrimary, size: 28),
              SizedBox(width: 12),
              Text(
                'What Happens Next?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _textDark,
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
              color: _textMuted,
              height: 1.6,
            ),
          ),
        ],
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
          backgroundColor: _appPrimary,
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
      case 'Within Expected Range':
        return _goodColor;
      case 'Follow-Up Recommended':
        return _warningColor;
      case 'Additional Review Recommended':
        return _criticalColor;
      default:
        return _warningColor;
    }
  }

  Color _getMocaStatusBg(String status) {
    switch (status) {
      case 'Within Expected Range':
        return _goodBg;
      case 'Follow-Up Recommended':
        return _warningBg;
      case 'Additional Review Recommended':
        return _criticalBg;
      default:
        return _warningBg;
    }
  }

  Color _getSimsStatusColor(String status) {
    switch (status) {
      case 'Strong':
        return _goodColor;
      case 'Moderate':
        return _warningColor;
      case 'Needs Support':
        return _criticalColor;
      default:
        return _warningColor;
    }
  }

  Color _getSimsStatusBg(String status) {
    switch (status) {
      case 'Strong':
        return _goodBg;
      case 'Moderate':
        return _warningBg;
      case 'Needs Support':
        return _criticalBg;
      default:
        return _warningBg;
    }
  }

  String _getMocaExplanation(String status) {
    switch (status) {
      case 'Within Expected Range':
        return 'Your screening result was within the expected range.';
      case 'Follow-Up Recommended':
        return 'This screening suggests that additional follow-up may be helpful. '
            'This is a screening result and not a diagnosis.';
      case 'Additional Review Recommended':
        return 'This screening suggests that further review is recommended. '
            'Please discuss these results with your healthcare provider.';
      default:
        return 'Your provider can help explain these results and next steps.';
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
    if (percentage >= 0.85) return _goodColor;
    if (percentage >= 0.60) return _warningColor;
    return _criticalColor;
  }
}