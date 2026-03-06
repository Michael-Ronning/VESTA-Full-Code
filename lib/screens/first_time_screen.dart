import 'package:flutter/material.dart';
import 'package:projectmercury/screens/navigation_screen.dart';
import 'package:projectmercury/screens/interactive_moca_exam_widget_screen.dart';
import 'package:projectmercury/screens/results_screen.dart';

class FirstTimeScreen extends StatelessWidget {
  static const routeName = '/first-time';

  const FirstTimeScreen({Key? key}) : super(key: key);

void _navigateTo(BuildContext context, String route) {
  print('_navigateTo called with route: $route'); // Add this
  
  if (route == '/moca') {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InteractiveMoCAExamWidget()),
    );
  } else if (route == '/navigation') {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NavigationScreen()),
    );
  } else if (route == '/results') {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ResultsScreen(),
      ),
    );
  }

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
              onPressed: () => _navigateTo(context, '/moca'),
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
              onPressed: () => _navigateTo(context, '/navigation'),
            ),
          ),
          const SizedBox(height: 12.0),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.bar_chart),
              label: const Text('Results'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              onPressed: () => _navigateTo(context, '/results'),
            ),
          ),
        ],
      ),
    ),
  );
}
}