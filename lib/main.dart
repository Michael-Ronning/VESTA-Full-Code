import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:projectmercury/firebase_options.dart';
import 'package:projectmercury/resources/analytics_methods.dart';
import 'package:projectmercury/resources/auth_methods.dart';
import 'package:projectmercury/resources/app_state.dart';
import 'package:projectmercury/resources/firestore_methods.dart';
import 'package:projectmercury/resources/locator.dart';
import 'package:projectmercury/resources/task_mapping_validator.dart';
import 'package:projectmercury/screens/welcome_screen.dart';
import 'package:projectmercury/screens/first_time_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // FirebaseFirestore.instance.settings = const Settings(
  //     persistenceEnabled: true, cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
  setupLocator();
  await _runTaskMappingStartupCheck();
  runApp(const MyApp());
}

Future<void> _runTaskMappingStartupCheck() async {
  if (!kDebugMode) {
    return;
  }

  try {
    final expectedTxnTemplateIds = locator
        .get<AppState>()
        .rooms
        .expand((room) => room.distinctSlots)
        .map((slot) => slot.id.trim())
        .where((id) => id.isNotEmpty)
        .toSet();

    final report = await TaskMappingValidator.validateDefaultMapping(
      expectedTxnTemplateIds: expectedTxnTemplateIds,
    );

    debugPrint(
      '[TaskMapping] validation complete: '
      'errors=${report.errors.length}, warnings=${report.warnings.length}, '
      'missingEvents=${report.missingEventTemplateIds.length}, '
      'missingTxns=${report.missingTxnTemplateIds.length}',
    );

    for (final error in report.errors) {
      debugPrint('[TaskMapping][ERROR] $error');
    }
    for (final warning in report.warnings) {
      debugPrint('[TaskMapping][WARN] $warning');
    }
  } catch (e) {
    debugPrint('[TaskMapping][ERROR] startup validation failed: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final AuthMethods auth = locator.get<AuthMethods>();
    final AnalyticsMethods analytics = locator.get<AnalyticsMethods>();
    final FirestoreMethods firestore = locator.get<FirestoreMethods>();
    
    ColorScheme color = ColorScheme.fromSeed(
      seedColor: Colors.red,
    );
    
    return ChangeNotifierProvider.value(
      value: locator.get<AppState>(),
      child: MaterialApp(
        title: 'Project Mercury',
        debugShowCheckedModeBanner: false,
        scrollBehavior: MyCustomScrollBehavior(),
        navigatorObservers: [
          analytics.getAnalyticObserver(),
        ],
        theme: ThemeData(
          colorScheme: color,
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(color.primary),
              foregroundColor: WidgetStateProperty.all(color.onPrimary),
            ),
          ),
          appBarTheme: AppBarTheme(
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontSize: 36,
              color: color.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        home: StreamBuilder(
          // listen to authentication changes
          stream: auth.userStream,
          builder: (context, snapshot) {
            // return nav screen if user logged in
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                // Move these to a post-frame callback to avoid issues
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  firestore.initializeData(auth.currentUser);
                  analytics.setCurrentScreen('/first-time');
                });
                return const FirstTimeScreen();
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('${snapshot.error}'),
                );
              }
            }
            // return indicator if loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            // return login screen if user not logged in
            print("login failed");
            analytics.setCurrentScreen('/login');
            return const WelcomeScreen();
          },
        ),
      ),
    );
  }
}

// enable mouse scroll on web
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
