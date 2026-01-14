import 'package:flutter/material.dart';
import 'package:projectmercury/models/furniture.dart';
import 'package:projectmercury/models/store_item.dart';
import 'package:projectmercury/resources/app_state.dart';
import 'package:projectmercury/resources/firestore_methods.dart';
import 'package:projectmercury/resources/locator.dart';
import 'package:projectmercury/utils/utils.dart';

class StoreItemCard extends StatelessWidget {
  final StoreItem storeItem;
  final String roomName;
  final Slot slot;

  const StoreItemCard({
    Key? key,
    required this.storeItem,
    required this.roomName,
    required this.slot,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4.0, 4.0, 16.0, 4.0),
      child: Container(
       
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.brown),
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
        child: Row(
          children: [
            furnitureImage(storeItem.item),
            // // Simplified image loading
            // Image.asset(
            //   'assets/furniture/${storeItem.item}.png',
            //   width: 100,
            //   height: 150,
            //   fit: BoxFit.contain,
            //   errorBuilder: (context, _, __) {
            //     // Try fallback NE image
            //     return Image.asset(
            //       'assets/furniture/${storeItem.item}_NE.png',
            //       width: 100,
            //       height: 150,
            //       fit: BoxFit.contain,
            //       errorBuilder: (context, _, __) {
            //         // Try fallback NW image
            //         return Image.asset(
            //           'assets/furniture/${storeItem.item}_NW.png',
            //           width: 100,
            //           height: 150,
            //           fit: BoxFit.contain,
            //           errorBuilder: (context, _, __) {
            //             // If still fails, show placeholder icon
            //             return const Icon(
            //               Icons.image_not_supported,
            //               size: 64,
            //               color: Colors.redAccent,
            //             );
            //           },
            //         );
            //       },
            //     );
            //   },
            // ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    storeItem.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Seller: ${storeItem.seller.real}',
                    style: const TextStyle(fontSize: 20),
                  ),
                  Text(
                    'Cost: ${formatCurrency.format(storeItem.price)}',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      if (locator.get<AppState>().waitingTransactionAction()) {
                        showConfirmation(
                          context: context,
                          static: true,
                          title: 'Purchase Failed',
                          text:
                              'Complete all transactions to make a new purchase.',
                        );
                      } else if (locator.get<AppState>().waitingEventAction()) {
                        showConfirmation(
                          context: context,
                          static: true,
                          title: 'Purchase Failed',
                          text: 'Complete all events to make a new purchase.',
                        );
                      } else {
                        bool result = await showConfirmation(
                              context: context,
                              title: 'Confirmation',
                              text:
                                  'Purchase ${storeItem.name} from "${storeItem.seller.real}" for ${formatCurrency.format(storeItem.price)}?\n\nYour balance: ${formatCurrency.format(locator.get<AppState>().balance)}',
                              noText: 'Don\'t Buy',
                              yesText: 'Buy',
                            ) ??
                            false;
                        if (result == true) {
                          locator
                              .get<FirestoreMethods>()
                              .buyItem(storeItem, roomName, slot);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Buy Item',
                        style: TextStyle(
                          fontSize: 24,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}

Widget furnitureImage(String itemName) {
  const double width = 100;
  const double height = 150;

  return Image.asset(
    'assets/furniture/$itemName.png',
    width: width,
    height: height,
    fit: BoxFit.contain,
    errorBuilder: (context, _, __) => Image.asset(
      'assets/furniture/${itemName}_NE.png',
      width: width,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, _, __) => Image.asset(
        'assets/furniture/${itemName}_NW.png',
        width: width,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, _, __) => const Icon(
          Icons.image_not_supported,
          size: 64,
          color: Colors.redAccent,
        ),
      ),
    ),
  );
}

      // child: Container(
      //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      //   decoration: BoxDecoration(
      //     borderRadius: BorderRadius.circular(8),
      //     border: Border.all(color: Colors.brown),
      //     color: Theme.of(context).colorScheme.primaryContainer,
      //   ),
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       Text(
      //         storeItem.name,
      //         textAlign: TextAlign.center,
      //         style: const TextStyle(fontWeight: FontWeight.bold),
      //       ),
      //       Text(
      //         'Sold by: ${storeItem.seller.real}',
      //         textAlign: TextAlign.center,
      //         style: const TextStyle(fontSize: 12),
      //       ),
      //       Image.asset(
      //         'assets/furniture/${storeItem.item}.png',
      //         errorBuilder: (context, _, stacktrace) {
      //           return Image.asset(
      //             'assets/furniture/${storeItem.item}_NE.png',
      //             height: 50,
      //           );
      //         },
      //         height: 50,
      //       ),
      //       Text(formatCurrency.format(storeItem.price)),
      //       ElevatedButton(
      //         onPressed: () async {
      //           if (locator.get<AppState>().waitingTransactionAction()) {
      //             showConfirmation(
      //                 context: context,
      //                 static: true,
      //                 title: 'Purchase Failed',
      //                 text:
      //                     'Complete all transactions to make a new purchase.');
      //           } else if (locator
      //               .get<AppState>()
      //               .waitingEventAction()) {
      //             showConfirmation(
      //                 context: context,
      //                 static: true,
      //                 title: 'Purchase Failed',
      //                 text: 'Complete all events to make a new purchase.');
      //           } else {
      //             bool result = await showConfirmation(
      //                   context: context,
      //                   title: 'Confirmation',
      //                   text:
      //                       'Would you like to purchase "${storeItem.name}" from "${storeItem.seller.real}"?\n\nYour current balance: ${formatCurrency.format(locator.get<AppState>().balance)}',
      //                   noText: 'Cancel',
      //                   yesText: formatCurrency.format(-storeItem.price),
      //                 ) ??
      //                 false;
      //             if (result == true) {
      //               locator
      //                   .get<AppState>()
      //                   .buyItem(storeItem, roomName, slot);
      //               Navigator.pop(context);
      //             }
      //           }
      //         },
      //         style: ElevatedButton.styleFrom(
      //           shape: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(50),
      //           ),
      //         ),
      //         child: Text(
      //           'Buy Item',
      //           style: TextStyle(
      //             color: Theme.of(context).colorScheme.onPrimary,
      //           ),
      //         ),
      //       )
      //     ],
      //   ),
      // ),
  
