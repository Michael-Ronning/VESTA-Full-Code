import 'package:flutter/material.dart';
import 'package:projectmercury/pages/homePage/floor_plan.dart';
import 'package:projectmercury/pages/homePage/room.dart';
import 'package:projectmercury/pages/storePage/receipt_page.dart';
import 'package:projectmercury/resources/app_state.dart';
import 'package:projectmercury/resources/locator.dart';
import 'package:projectmercury/utils/utils.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void callback(Room? room) {
    setState(() {
      locator.get<AppState>().setRoom(room);
    });
  }

  @override
  Widget build(BuildContext context) {
    AppState event = locator.get<AppState>();
    FloorPlan homeLayout = FloorPlan(callback);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 230, 230),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 100),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: FittedBox(
                  child: event.currentRoom ?? homeLayout,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  event.currentRoom != null
                      ? capitalize(event.currentRoom!.name)
                      : 'Full View',
                  style: const TextStyle(
                      fontSize: 30,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          event.currentRoom != null
              ? Positioned(
                  right: 10,
                  top: 15,
                  child: SizedBox(
                    height: 70,
                    width: 70,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 5,
                            color: Theme.of(context).colorScheme.onSurface,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: RichText(
                          text: TextSpan(
                            text: event.currentRoom != null
                                ? "${event.currentRoom!.distinctFilledSlots.length} / ${event.currentRoom!.distinctSlots.length}"
                                : "${event.session + (event.sessionProgress == 1 ? 0 : -1)} / ${event.rooms.length}",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : Container(),
          Selector<AppState, List<InlineSpan>?>(
            selector: (p0, p1) => p1.tip,
            builder: (context, tip, __) => tip != null
                ? Positioned(
                    left: 5,
                    top: 10,
                    child: Container(
                      decoration: elevatedCardDecor(context),
                      height: 80,
                      width: 250,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RichText(
                            text: TextSpan(
                              children: tip,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  )
                : Container(),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button. Only visible when inside a room
            event.currentRoom != null
                ? FloatingActionButton(
                    /* key: _tutorial.buttonKey2, */
                    heroTag: null,
                    child: const Icon(Icons.arrow_back, size: 42),
                    onPressed: () {
                      setState(() {
                        event.setRoom(null);
                      });
                    },
                  )
                : const SizedBox(width: 42),
            FloatingActionButton(
              heroTag: null,
              child: const Icon(Icons.storefront, size: 42),
              onPressed: () {
                showModalBottomSheet(
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  context: context,
                  builder: (context) {
                    return const ReceiptPage();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
