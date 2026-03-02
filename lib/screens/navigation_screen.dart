import 'package:flutter/material.dart';
import 'package:projectmercury/pages/contactPage/contacts_page.dart';
import 'package:projectmercury/pages/eventPage/event_page.dart';
import 'package:projectmercury/resources/analytics_methods.dart';
import 'package:projectmercury/resources/app_state.dart';
import 'package:projectmercury/resources/firestore_methods.dart';
import 'package:projectmercury/resources/locator.dart';
import 'package:projectmercury/resources/time_controller.dart';
import 'package:projectmercury/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:projectmercury/pages/homePage/home_page.dart';
import 'package:projectmercury/pages/infoPage/info_page.dart';
import 'package:projectmercury/pages/moneyPage/money_page.dart';
import 'package:badges/badges.dart' as badges;
import 'package:projectmercury/resources/auth_methods.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({Key? key}) : super(key: key);
  static const routeName = '/navigation';

  @override
  State<NavigationScreen> createState() { 
        print('Creating NavigationScreen state');
        return _NavigationScreenState();

  }
}

class _NavigationScreenState extends State<NavigationScreen> {
  final AnalyticsMethods _analytics = locator.get<AnalyticsMethods>();
  final TimerController _timer = locator.get<TimerController>();
  final AuthMethods auth = locator.get<AuthMethods>();
  final FirestoreMethods firestore = locator.get<FirestoreMethods>();

  List<Widget> pages = const [
    HomePage(),
    MoneyPage(),
    ContactPage(),
    EventPage(),
    InfoPage(),
  ];
  List<String> pageTitles = const [
    'Home',
    'Money',
    'Contacts',
    'Messages',
    'Info',
  ];

  void onNavTapped(int index) {
    setState(() {
      _analytics.setCurrentScreen(pageTitles[index]);
      locator.get<AppState>().currentPage = index;
    });
  }

  @override
  void initState() {
    super.initState();
    print('NavigationScreen initState called');
    locator.get<FirestoreMethods>().initializeSubscriptions();
    _timer.start();
  }

  @override
  void dispose() {
    super.dispose();
    locator.get<FirestoreMethods>().cancelSubscriptions();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    int pageSelected = locator.get<AppState>().currentPage;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Text(pageTitles[pageSelected]),
        actions: [
          pageSelected == 0
              ? IconButton(
                  onPressed: () => setState(() {
                    //_tutorial.showTutorial(context);
                    locator.get<AppState>().toggleTip();
                  }),
                  icon: const Icon(Icons.help_rounded),
                )
              : Container(),
          pageSelected == 4
              ? PopupMenuButton<int>(
                  onSelected: (item) => handleClick(item),
                  itemBuilder: (context) => const [
                    PopupMenuItem<int>(value: 0, child: Text('Logout')),
                    PopupMenuItem<int>(value: 1, child: Text('Reset')),
                    // PopupMenuItem<int>(value: 2, child: Text('Danger!')),
                  ],
                )
              : Container(),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 100),
        child: pages[pageSelected],
      ),
      bottomNavigationBar: Container(
        height: 120,
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.grey,
              width: 1,
            ),
          ),
        ),
        child: Consumer<AppState>(
          builder: (_, event, __) {
            return BottomNavigationBar(
              currentIndex: pageSelected,
              iconSize: 50,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              items: [
                BottomNavigationBarItem(
                  icon: badges.Badge(
                    showBadge: event.showBadge[0],
                    badgeContent: Icon(
                      Icons.notification_important,
                      size: 28,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: const Icon(Icons.home),
                  ),
                  label: pageTitles[0],
                ),
                BottomNavigationBarItem(
                  icon: badges.Badge(
                    showBadge: event.showBadge[1],
                    badgeContent: Icon(
                      Icons.notification_important,
                      size: 28,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: const Icon(Icons.attach_money),
                  ),
                  label: pageTitles[1],
                ),
                BottomNavigationBarItem(
                  icon: badges.Badge(
                    showBadge: event.showBadge[2],
                    badgeContent: Icon(
                      Icons.notification_important,
                      size: 28,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: const Icon(Icons.people),
                  ),
                  label: pageTitles[2],
                ),
                BottomNavigationBarItem(
                  icon: badges.Badge(
                    showBadge: event.showBadge[3],
                    badgeContent: Icon(
                      Icons.notification_important,
                      size: 28,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: const Icon(Icons.mail),
                  ),
                  label: pageTitles[3],
                ),
                BottomNavigationBarItem(
                  icon: badges.Badge(
                    showBadge: event.showBadge[4],
                    badgeContent: Icon(
                      Icons.notification_important,
                      size: 28,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: const Icon(Icons.info),
                  ),
                  label: pageTitles[4],
                ),
              ],
              onTap: onNavTapped,
            );
          },
        ),
      ),
    );
  }

  void handleClick(int item) async {
    switch (item) {
      case 0:
        bool result = await showConfirmation(
              context: context,
              title: 'Confirmation',
              text: 'Sign out?',
              noText: 'No',
              yesText: 'Yes',
            ) ??
            false;
        if (result == true) {
          await auth.signout();
        }
        break;
      case 1:
        bool result = await showConfirmation(
              context: context,
              title: 'Confirmation',
              text: 'Reset game?',
              noText: 'No',
              yesText: 'Yes',
            ) ??
            false;
        if (result == true) {
          await firestore.resetData();
        }
        break;
      // case 2:
      //   bool result = await showConfirmation(
      //         context: context,
      //         title: 'Confirmation',
      //         text: 'Proceed?',
      //         noText: 'No',
      //         yesText: 'Yes',
      //       ) ??
      //       false;
      //   if (result == true) {
      //     await firestore.careful();
      //   }
      //   break;
    }
  }
}
