// import 'package:flutter/material.dart';
// import 'package:projectmercury/models/furniture.dart';
// import 'package:projectmercury/models/store_item.dart';
// import 'package:projectmercury/data/store_data.dart';
// import 'package:projectmercury/resources/app_state.dart';
// import 'package:projectmercury/resources/firestore_methods.dart';
// import 'package:projectmercury/resources/locator.dart';
// import 'package:projectmercury/utils/utils.dart';

// class StorePage extends StatefulWidget {
//   final String roomName;
//   final Slot slot;
//   const StorePage({
//     required this.roomName,
//     required this.slot,
//     Key? key,
//   }) : super(key: key);

//   @override
//   State<StorePage> createState() => _StorePageState();
// }

// class _StorePageState extends State<StorePage> {
//   int selected = -1;
//   @override
//   Widget build(BuildContext context) {
//     List<StoreItem> sellables = storeItems
//         .where((item) => widget.slot.getFurniture(item.item) != null)
//         .toList();
//     sellables.sort(((a, b) => a.price.compareTo(b.price)));
//     return GestureDetector(
//       behavior: HitTestBehavior.opaque,
//       onTap: () => Navigator.of(context).pop(),
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             const SizedBox(height: 120),
//             Center(
//               child: Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: const Color.fromARGB(235, 250, 255, 250),
//                   border: Border.all(
//                     color: const Color.fromARGB(245, 190, 255, 190),
//                     width: 2,
//                   ),
//                   borderRadius: const BorderRadius.all(
//                     Radius.circular(10),
//                   ),
//                 ),
//                 child: const Column(
//                   children: [
//                     Text(
//                       "Shopping",
//                       style:
//                           TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//                     ),
//                     Text(
//                       "Tap a box to select an item, or tap anywhere else on your screen to return home.",
//                       style: TextStyle(fontSize: 20),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             SizedBox(
//               height: MediaQuery.of(context).size.height / 1.6,
//               width: MediaQuery.of(context).size.width - 15,
//               child: GridView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: sellables.length,
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 5,
//                   mainAxisSpacing: 5,
//                   childAspectRatio: MediaQuery.of(context).size.width /
//                       (MediaQuery.of(context).size.height / 2.5),
//                 ),
//                 itemBuilder: (BuildContext context, int index) {
//                   return GestureDetector(
//                     onTap: () async {
//                       setState(() {
//                         selected = index;
//                       });
//                       if (locator.get<AppState>().waitingTransactionAction()) {
//                         showConfirmation(
//                             context: context,
//                             static: true,
//                             title: 'Purchase Failed',
//                             text:
//                                 'Complete all transactions to make a new purchase.');
//                         setState(() {
//                           selected = -1;
//                         });
//                       } else if (locator.get<AppState>().waitingEventAction()) {
//                         showConfirmation(
//                             context: context,
//                             static: true,
//                             title: 'Purchase Failed',
//                             text:
//                                 'Complete all events to make a new purchase.');
//                         setState(() {
//                           selected = -1;
//                         });
//                       } else {
//                         Image image = Image.asset(
//                           'furniture/${sellables[index].item}.png',
//                           errorBuilder: (context, _, stacktrace) {
//                             return Image.asset(
//                               'furniture/${sellables[index].item}_NE.png',
//                               errorBuilder: (context, _, stacktrace) {
//                                 return Image.asset(
//                                   'furniture/${sellables[index].item}_NW.png',
//                                   width: 150,
//                                   height: 150,
//                                 );
//                               },
//                               width: 150,
//                               height: 150,
//                             );
//                           },
//                           width: 150,
//                           height: 150,
//                         );
//                         bool result = await showConfirmation(
//                               context: context,
//                               title: 'Confirmation',
//                               image: image,
//                               richText: RichText(
//                                 text: TextSpan(
//                                   style: const TextStyle(
//                                       fontSize: 20, color: Colors.black),
//                                   children: [
//                                     const TextSpan(text: 'Purchase '),
//                                     TextSpan(
//                                       text: sellables[index].name,
//                                       style: const TextStyle(
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                     const TextSpan(
//                                       text: " from ",
//                                     ),
//                                     TextSpan(
//                                       text: sellables[index].seller.real,
//                                       style: const TextStyle(
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                     const TextSpan(
//                                       text: "?\n\nCost: ",
//                                     ),
//                                     TextSpan(
//                                       text: formatCurrency
//                                           .format(sellables[index].price),
//                                       style: const TextStyle(
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               noText: 'Don\'t Buy',
//                               yesText: 'Buy',
//                             ) ??
//                             false;
//                         if (result == true) {
//                           locator.get<FirestoreMethods>().buyItem(
//                               sellables[index], widget.roomName, widget.slot);
//                           if (mounted) {
//                             // ignore: use_build_context_synchronously
//                             Navigator.pop(context);
//                           }
//                         } else {
//                           setState(() {
//                             selected = -1;
//                           });
//                         }
//                       }
//                     },
//                     child: Container(
//                       decoration: BoxDecoration(
//                           color: selected == index
//                               ? Colors.green
//                               : const Color.fromARGB(255, 225, 255, 225),
//                           border: Border.all(
//                             color: Colors.green,
//                             width: 2,
//                           ),
//                           borderRadius:
//                               const BorderRadius.all(Radius.circular(20))),
//                       child: SizedBox(
//                         width: 120,
//                         height: 120,
//                         child: Column(
//                           children: [
//                             const SizedBox(
//                               height: 3,
//                             ),
//                             SizedBox(
//                               height: 48,
//                               child: Center(
//                                 child: Text(
//                                   sellables[index].name,
//                                   textAlign: TextAlign.center,
//                                   maxLines: 2,
//                                   style: const TextStyle(
//                                     fontSize: 20,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(
//                               height: 3,
//                             ),
//                             Expanded(
//                               child: Image.asset(
//                                 widget.slot.getFurniture(
//                                             sellables[index].item) ==
//                                         null
//                                     ? 'assets/furniture/${sellables[index].item}.png'
//                                     : 'assets/furniture/${sellables[index].item}${{
//                                         "_SE",
//                                         "_SW",
//                                         "_CORNER"
//                                       }.contains(widget.slot.getFurniture(sellables[index].item)!.getDirection()) ? "_NE" : widget.slot.getFurniture(sellables[index].item)!.getDirection()}.png',
//                                 fit: BoxFit.scaleDown,
//                                 // width: 100,
//                                 // height: 100,
//                               ),
//                             ),
//                             const SizedBox(
//                               height: 3,
//                             ),
//                             Text(
//                               formatCurrency.format(sellables[index].price),
//                               style: const TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                                 fontStyle: FontStyle.italic,
//                               ),
//                             ),
//                             const SizedBox(
//                               height: 3,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:projectmercury/models/furniture.dart';
import 'package:projectmercury/models/store_item.dart';
import 'package:projectmercury/data/store_data.dart';
import 'package:projectmercury/resources/app_state.dart';
import 'package:projectmercury/resources/firestore_methods.dart';
import 'package:projectmercury/resources/locator.dart';
import 'package:projectmercury/utils/utils.dart';

class StorePage extends StatefulWidget {
  final String roomName;
  final Slot slot;

  const StorePage({
    required this.roomName,
    required this.slot,
    Key? key,
  }) : super(key: key);

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  int selected = -1;

  // /// Helper function to safely get the asset path
  // String getFurnitureAsset(String itemName, String? direction) {
  //   const basePath = 'assets/furniture/';
  //   if (direction == null) return '$basePath$itemName.png';

  //   final validDirections = {"_NE", "_NW", "_SE", "_SW", "_CORNER"};
  //   String suffix = validDirections.contains(direction) ? direction : "_NE";
  //   return '$basePath$itemName$suffix.png';
  // }
  /// Helper function to safely get the asset path
  String getFurnitureAsset(String itemName, String? direction) {
    const basePath = 'assets/furniture/';
    final validDirections = {"_NE", "_NW", "_SE", "_SW", "_CORNER"};

    // If direction is valid, check that file exists
    if (direction != null && validDirections.contains(direction)) {
      return '$basePath$itemName$direction.png';
    }

    // Fallback: return item without direction
    return '$basePath$itemName.png';
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWeb = screenWidth > 800;
    List<StoreItem> sellables = storeItems
        .where((item) => widget.slot.getFurniture(item.item) != null)
        .toList();
    sellables.sort(((a, b) => a.price.compareTo(b.price)));

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop(),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 120),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color.fromARGB(235, 250, 255, 250),
                border: Border.all(
                  color: const Color.fromARGB(245, 190, 255, 190),
                  width: 2,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child: const Column(
                children: [
                  Text(
                    "Shopping",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Tap a box to select an item, or tap anywhere else on your screen to return home.",
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: MediaQuery.of(context).size.height / 1.6,
              width: MediaQuery.of(context).size.width - 15,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sellables.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isWeb ? 3 : 2,
                    crossAxisSpacing: isWeb ? 8 : 5,
                    mainAxisSpacing: isWeb ? 8: 5,
                    childAspectRatio: isWeb
                        ? screenWidth / screenWidth
                        : MediaQuery.of(context).size.width /
                            (MediaQuery.of(context).size.height / 2)),
                itemBuilder: (BuildContext context, int index) {
                  StoreItem item = sellables[index];
                  String? direction =
                      widget.slot.getFurniture(item.item)?.getDirection();
                  String assetPath = getFurnitureAsset(item.item, direction);

                  return GestureDetector(
                    onTap: () async {
                      setState(() {
                        selected = index;
                      });

                      if (locator.get<AppState>().waitingTransactionAction()) {
                        showConfirmation(
                          context: context,
                          static: true,
                          title: 'Purchase Failed',
                          text:
                              'Complete all transactions to make a new purchase.',
                        );
                        setState(() {
                          selected = -1;
                        });
                        return;
                      }

                      if (locator.get<AppState>().waitingEventAction()) {
                        showConfirmation(
                          context: context,
                          static: true,
                          title: 'Purchase Failed',
                          text: 'Complete all events to make a new purchase.',
                        );
                        setState(() {
                          selected = -1;
                        });
                        return;
                      }

                      Image image = Image.asset(
                        assetPath,
                        errorBuilder: (context, _, __) {
                          return Image.asset(
                            getFurnitureAsset(item.item, "_NE"),
                            width: 150,
                            height: 150,
                          );
                        },
                        width: 150,
                        height: 150,
                      );

                      bool result = await showConfirmation(
                            context: context,
                            title: 'Confirmation',
                            image: image,
                            richText: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                    fontSize: 20, color: Colors.black),
                                children: [
                                  const TextSpan(text: 'Purchase '),
                                  TextSpan(
                                    text: item.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const TextSpan(text: " from "),
                                  TextSpan(
                                    text: item.seller.real,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const TextSpan(text: "?\n\nCost: "),
                                  TextSpan(
                                    text: formatCurrency.format(item.price),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            noText: 'Don\'t Buy',
                            yesText: 'Buy',
                          ) ??
                          false;

                      if (result) {
                        locator
                            .get<FirestoreMethods>()
                            .buyItem(item, widget.roomName, widget.slot);
                        // ignore: use_build_context_synchronously
                        if (mounted) Navigator.pop(context);
                      } else {
                        setState(() {
                          selected = -1;
                        });
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: selected == index
                            ? Colors.green
                            : const Color.fromARGB(255, 225, 255, 225),
                        border: Border.all(color: Colors.green, width: 2),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                      ),
                      child: SizedBox(
                        width: 120,
                        height: 120,
                        child: Column(
                          children: [
                            const SizedBox(height: 3),
                            SizedBox(
                              height: 48,
                              child: Center(
                                child: Text(
                                  item.name,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Expanded(
                              child: Image.asset(
                                assetPath,
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              formatCurrency.format(item.price),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 3),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
