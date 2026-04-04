// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projectmercury/data/store_data.dart';

var formatCurrency = NumberFormat.simpleCurrency();
String formatDateTime(DateTime dateTime) {
  return DateFormat.yMMMMd().add_jm().format(dateTime);
}

String timeAgo(DateTime d) {
  Duration diff = DateTime.now().difference(d);
  if (diff.inDays > 365) {
    return "${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? "year" : "years"} ago";
  }
  if (diff.inDays > 30) {
    return "${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? "month" : "months"} ago";
  }
  if (diff.inDays > 7) {
    return "${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? "week" : "weeks"} ago";
  }
  if (diff.inDays > 0) {
    return "${diff.inDays} ${diff.inDays == 1 ? "day" : "days"} ago";
  }
  if (diff.inHours > 0) {
    return "${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"} ago";
  }
  if (diff.inMinutes > 0) {
    return "${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "minutes"} ago";
  }
  return "just now";
}

String getRoomInit(String s) {
  switch (s) {
    case 'bedroom':
      return 'Bd';
    case 'living room':
      return 'LR';
    case 'bathroom':
      return 'Ba';
    case 'kitchen':
      return 'K';
    case 'dining room':
      return 'D';
    case 'garage':
      return 'Ga';
    default:
      return s;
  }
}

String getSessionRoom(int i) {
  switch (i) {
    case 1:
      return 'Bd';
    case 2:
      return 'LR';
    case 3:
      return 'Ba';
    case 4:
      return 'K';
    case 5:
      return 'D';
    case 6:
      return 'Ga';
    default:
      return "";
  }
}

int getRoomSession(String s) {
  switch (s) {
    case 'bedroom':
      return 1;
    case 'living room':
      return 2;
    case 'bathroom':
      return 3;
    case 'kitchen':
      return 4;
    case 'dining room':
      return 5;
    case 'garage':
      return 6;
    default:
      return -1;
  }
}

// format time in HH:mm:ss format
String formatTime(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return "${twoDigits(duration.inHours) != '00' ? '${twoDigits(duration.inHours)}:' : ''}$twoDigitMinutes:$twoDigitSeconds";
}

bool isItemName(String string) {
  return storeItems.where((element) => element.item == string).isNotEmpty;
}

Future<T?> animatedDialog<T extends Object?>(
    {required BuildContext context,
    required Widget widget,
    int duration = 150}) {
  return showGeneralDialog(
    context: context,
    pageBuilder: (ctx, a1, a2) {
      return Container();
    },
    transitionBuilder: (ctx, a1, a2, child) {
      var curve = Curves.easeInOut.transform(a1.value);
      return Transform.scale(
        scale: curve,
        child: widget,
      );
    },
    transitionDuration: Duration(milliseconds: duration),
  );
}

// shows pop-up with yes/no options. Returns true if 'yes' selected; else false.
Future<bool?> showConfirmation({
  required BuildContext context,
  String? title,
  RichText? richText,
  String? text,
  Image? image,
  String noText = 'No',
  String yesText = 'Yes',
  bool static = false,
}) async {
  bool? result = false;
  result = await animatedDialog<bool>(
    context: context,
    widget: AlertDialog(
      actionsAlignment: MainAxisAlignment.spaceAround,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      title: title != null
          ? Text(
              title,
              style: const TextStyle(fontSize: 24),
            )
          : null,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          image ?? Container(),
          text != null
              ? Text(
                  text,
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                )
              : Container(child: richText),
        ],
      ),
      actions: [
        if (static == false) ...[
          Row(
            children: [
              const SizedBox(width: 8),
              Flexible(
                fit: FlexFit.tight,
                child: OutlinedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800]),
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: Text(
                    noText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                fit: FlexFit.tight,
                child: OutlinedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800]),
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: Text(
                    yesText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ] else ...[
          Row(
            children: [
              const SizedBox(width: 8),
              Flexible(
                fit: FlexFit.tight,
                child: OutlinedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                  ),
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ],
    ),
  );
  return result;
}

String capitalize(String string) {
  String result = string[0].toUpperCase();
  for (int i = 1; i < string.length; i++) {
    if (string[i - 1] == " ") {
      result += string[i].toUpperCase();
    } else {
      result += string[i];
    }
  }
  return result;
}

// shows a snackbar with content message
void showSnackBar(String text, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      duration: const Duration(seconds: 1),
    ),
  );
}

// basic decoration used for listviews
BoxDecoration elevatedCardDecor(BuildContext context,
    {Color? color, bool flat = false, double? radius}) {
  return BoxDecoration(
    color: color ?? Theme.of(context).colorScheme.surface,
    boxShadow: flat
        ? []
        : [
            BoxShadow(
              blurRadius: 5,
              color: Theme.of(context).colorScheme.onSurface,
              offset: const Offset(0, 2),
            ),
          ],
    borderRadius: BorderRadius.circular(radius ?? 8),
  );
}

Dialog mainDialog(
  BuildContext context, {
  Widget? header,
  Widget? body,
  Widget? footer,
}) {
  ScrollController sc = ScrollController();
  final Size screen = MediaQuery.sizeOf(context);
  final double dialogWidth = screen.width < 700 ? screen.width * 0.92 : 700;
  return Dialog(
    insetPadding: EdgeInsets.symmetric(
      horizontal: screen.width * 0.04,
      vertical: screen.height * 0.08,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    elevation: 3,
    child: SizedBox(
      width: dialogWidth,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: 320,
          maxHeight: screen.height * 0.84,
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              header ?? Container(),
              const SizedBox(height: 12),
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.1),
                      width: 3,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                      ),
                      BoxShadow(
                        color: Colors.white,
                        blurRadius: 12.0,
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    controller: sc,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: body ?? Container(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              footer ?? Container(),
              Row(
                children: [
                  Flexible(
                    fit: FlexFit.tight,
                    child: OutlinedButton(
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget yesOrNo(
  BuildContext context, {
  required String yesLabel,
  required String noLabel,
  String confirmationTitle = 'Confirmation',
  required String yesConfirmationMessage,
  required String noConfirmationMessage,
  required Function() onYes,
  required Function() onNo,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      const SizedBox(width: 12),
      Flexible(
        fit: FlexFit.tight,
        child: ElevatedButton.icon(
          onPressed: () async {
            bool result = await showConfirmation(
                  context: context,
                  title: confirmationTitle,
                  text: noConfirmationMessage,
                  noText: 'Cancel',
                  yesText: 'Continue',
                ) ??
                false;
            if (result == true) {
              onNo();
            }
          },
          icon: const Icon(Icons.close, size: 32, color: Colors.white),
          label: Text(
            noLabel,
            style: const TextStyle(fontSize: 18,color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[700],
          ),
        ),
      ),
      const SizedBox(width: 12),
      Flexible(
        fit: FlexFit.tight,
        child: ElevatedButton.icon(
          onPressed: () async {
            bool result = await showConfirmation(
                  context: context,
                  title: confirmationTitle,
                  text: yesConfirmationMessage,
                  noText: 'Cancel',
                  yesText: 'Continue',
                ) ??
                false;
            if (result == true) {
              onYes();
            }
          },
          icon: const Icon(Icons.check, size: 32, color: Colors.white),
          label: Text(
            yesLabel,
            style: const TextStyle(fontSize: 18,color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
          ),
        ),
      ),
      const SizedBox(width: 12),
    ],
  );
}

Row listItem({
  required double leftMargin,
  required double textSize,
  required String text,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: leftMargin,
        child: Center(
          child: Text('-', style: TextStyle(fontSize: textSize)),
        ),
      ),
      Expanded(
        child: Text(
          text,
          style: TextStyle(
            fontSize: textSize,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    ],
  );
}

class AnimatedArrow extends AnimatedWidget {
  const AnimatedArrow({Key? key, required Animation<double> animation})
      : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    return Positioned(
      top: animation.value,
      child: Image.asset(
        'assets/textures/down_arrow.png',
        height: 70,
        width: 70,
        color: Colors.red.withOpacity(0.9),
      ),
    );
  }
}
