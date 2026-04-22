import 'package:flutter/material.dart';
import 'package:projectmercury/screens/interactive_moca_exam_widget_screen.dart';
import 'package:projectmercury/screens/navigation_screen.dart';
import 'package:projectmercury/screens/results_screen.dart';
import 'package:projectmercury/services/results_service.dart';

class FirstTimeScreen extends StatelessWidget {
  const FirstTimeScreen({super.key});

  void _navigateToMoca(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const InteractiveMoCAExamWidget(),
      ),
    );
  }

  void _navigateToMainApp(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NavigationScreen(),
      ),
    );
  }

  void _navigateToResults(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ResultsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Choose an option to continue',
              style: TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 24.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.assessment),
                label: const Text('MoCA Assessment'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                onPressed: () => _navigateToMoca(context),
              ),
            ),
            const SizedBox(height: 12.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.home),
                label: const Text('Main App'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                onPressed: () => _navigateToMainApp(context),
              ),
            ),
            const SizedBox(height: 12.0),
            FutureBuilder<bool>(
              future: ResultsService().hasCurrentUserResults(),
              builder: (context, snapshot) {
                final hasResults = snapshot.data ?? false;

                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.bar_chart),
                    label: Text(
                      hasResults ? 'Results' : 'Results (Not Ready Yet)',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    onPressed: hasResults
                        ? () => _navigateToResults(context)
                        : null,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}