import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projectmercury/models/contact.dart';
import 'package:projectmercury/models/event.dart';
import 'package:projectmercury/data/contact_data.dart';
import 'package:projectmercury/resources/firestore_methods.dart';
import 'package:projectmercury/resources/locator.dart';
import 'package:projectmercury/utils/utils.dart';

class EventCard extends StatelessWidget {
  final Event event;
  const EventCard({required this.event, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? sender;
    Contact? contact;
    if (Relationship.values.asNameMap().containsKey(event.sender)) {
      contact = Relationship.values.byName(event.sender).contact;
      switch (event.type) {
        case EventType.text:
        case EventType.call:
          sender = "${contact.name} (${contact.phoneNumber})";
          break;
        case EventType.email:
          sender = contact.email ?? contact.name;
          break;
        default:
          sender = contact.name;
      }
    } else {
      sender = event.sender;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Container(
        decoration: elevatedCardDecor(
          context,
          color: event.state == EventState.static
              ? event.wasOpened
                  ? Colors.grey[350]
                  : null
              : event.state != EventState.actionNeeded
                  ? Colors.grey[350]
                  : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Column(
                  children: [
                    Icon(
                      event.type == EventType.email
                          ? Icons.email_outlined
                          : event.type == EventType.text
                              ? Icons.textsms_outlined
                              : event.type == EventType.call
                                  ? Icons.call_outlined
                                  : event.type == EventType.receipt
                                      ? Icons.receipt
                                      : Icons.question_mark,
                      size: 24,
                    ),
                    FittedBox(
                      child: Text(
                        capitalize(event.type.name),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    event.type == EventType.text
                        ? Text(
                            sender,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : event.type != EventType.call
                            ? Text('From $sender',
                                style: const TextStyle(fontSize: 16))
                            : Text(
                                'Missed call from $sender',
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                    event.type == EventType.text
                        ? Text(
                            event.dialog[0],
                            style: const TextStyle(fontSize: 18),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )
                        : event.type == EventType.call
                            ? const Text(
                                'New Voicemail',
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              )
                            : Text(event.title,
                                style: const TextStyle(fontSize: 18)),
                    Text.rich(
                      TextSpan(
                        text: 'Status: ',
                        style: const TextStyle(fontSize: 16),
                        children: [
                          event.state == EventState.static
                              ? event.wasOpened
                                  ? TextSpan(
                                      text: 'Opened',
                                      style:
                                          TextStyle(color: Colors.green[800]),
                                    )
                                  : const TextSpan(
                                      text: 'Not opened',
                                      style: TextStyle(color: Colors.red),
                                    )
                              : event.state == EventState.actionNeeded
                                  ? const TextSpan(
                                      text: 'Action Needed',
                                      style: TextStyle(color: Colors.red),
                                    )
                                  : TextSpan(
                                      text: 'Completed',
                                      style:
                                          TextStyle(color: Colors.green[800]),
                                    ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: event.state == EventState.static
                      ? event.wasOpened
                          ? Colors.grey[700]
                          : Theme.of(context).colorScheme.primary
                      : event.state == EventState.actionNeeded
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[700],
                ),
                child: const Text(
                  'Open',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  event.wasOpened
                      ? null
                      : locator.get<FirestoreMethods>().markRead(event);
                  animatedDialog(
                    context: context,
                    widget: _EventDialog(
                      event: event,
                      sender: sender ?? 'Unknown',
                    ),
                    duration: 250,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventDialog extends StatelessWidget {
  final Event event;
  final String sender;

  const _EventDialog({
    Key? key,
    required this.event,
    required this.sender,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String question = event.targetBehavior == TargetBehavior.sendInfo
        ? 'Send information?'
        : event.targetBehavior == TargetBehavior.sendMoney
            ? 'Send money?'
            : event.targetBehavior == TargetBehavior.clickLink
                ? 'Click link?'
                : event.targetBehavior == TargetBehavior.callBack
                    ? 'Call back?'
                    : '';
    return mainDialog(
      context,
      header: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      event.type == EventType.email
                          ? Icons.email_outlined
                          : event.type == EventType.text
                              ? Icons.textsms_outlined
                              : event.type == EventType.call
                                  ? Icons.call_outlined
                                  : event.type == EventType.receipt
                                      ? Icons.receipt
                                      : Icons.question_mark,
                      size: 32,
                    ),
                    Text(
                      event.type == EventType.call
                          ? 'Voicemail'
                          : capitalize(event.type.name),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text.rich(
                  TextSpan(
                    text: 'From: ',
                    style: const TextStyle(fontSize: 20),
                    children: [
                      TextSpan(
                        text: sender,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: event.type == EventType.text
          ? _TextEvent(event: event)
          : event.type == EventType.email
              ? _EmailEvent(event: event)
              : event.type == EventType.receipt
                  ? _ReceiptEvent(event: event)
                  : _CallEvent(event: event),
      footer: Column(
        children: [
          if (event.state != EventState.static) ...[
            Text(
              question,
              style: const TextStyle(fontSize: 20),
            ),
          ],
          if (event.state == EventState.actionNeeded) ...[
            yesOrNo(
              context,
              yesLabel: 'Yes',
              noLabel: 'No',
              confirmationTitle: 'Are you sure?',
              yesConfirmationMessage: '$question\nYou selected: Yes',
              noConfirmationMessage: '$question\nYou selected: No',
              onYes: () {
                //firestore.eventAction(event, true);
                locator.get<FirestoreMethods>().resolveEvent(event, true);
                Navigator.of(context).pop();
              },
              onNo: () {
                //firestore.eventAction(event, false);
                locator.get<FirestoreMethods>().resolveEvent(event, false);
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 12),
          ] else if (event.state == EventState.approved) ...[
            Text.rich(
              TextSpan(
                text: 'Selected ',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
                children: [
                  TextSpan(
                    text: 'Yes ',
                    style: TextStyle(
                      color: Colors.green[800],
                    ),
                  ),
                  TextSpan(
                    text: 'on ${formatDateTime(event.timeActed!)}.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ] else if (event.state == EventState.rejected) ...[
            Text.rich(
              TextSpan(
                text: 'Selected ',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                children: [
                  const TextSpan(
                    text: 'No ',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                  TextSpan(
                    text: 'on ${formatDateTime(event.timeActed!)}.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _TextEvent extends StatelessWidget {
  final Event event;
  const _TextEvent({required this.event, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        for (String dialog in event.dialog) ...[
          Padding(
            padding: const EdgeInsets.only(right: 50),
            child: Container(
              decoration: elevatedCardDecor(
                context,
                color: const Color.fromARGB(255, 216, 216, 216),
                flat: true,
                radius: 25,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  dialog,
                  style: const TextStyle(
                    fontSize: 24,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 12,
          )
        ],
        event.targetBehavior == TargetBehavior.clickLink
            ? Padding(
                padding: const EdgeInsets.only(right: 50, bottom: 12),
                child: Container(
                  decoration: elevatedCardDecor(
                    context,
                    color: const Color.fromARGB(255, 216, 216, 216),
                    flat: true,
                    radius: 25,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Attached Link',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.blue[900],
                      ),
                    ),
                  ),
                ),
              )
            : Container(),
      ],
    );
  }
}

class _EmailEvent extends StatelessWidget {
  final Event event;
  const _EmailEvent({required this.event, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          event.title,
          style: const TextStyle(fontSize: 32),
        ),
        const Divider(color: Colors.black),
        for (String dialog in event.dialog) ...[
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              dialog,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ],
        event.targetBehavior == TargetBehavior.clickLink
            ? Text(
                '\nAttached Link',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.blue[900],
                ),
              )
            : Container(),
      ],
    );
  }
}

class _ReceiptEvent extends StatelessWidget {
  final Event event;
  const _ReceiptEvent({required this.event, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          event.title,
          style: GoogleFonts.vt323(fontSize: 36),
        ),
        const Divider(),
        for (String dialog in event.dialog) ...[
          isItemName(dialog)
              ? Center(
                  child: Image.asset(
                    'assets/furniture/$dialog.png',
                    errorBuilder: (context, _, stacktrace) {
                      return Image.asset(
                        'assets/furniture/${dialog}_NE.png',
                        height: 100,
                        errorBuilder: (context, _, stacktrace) {
                          return Image.asset(
                            'assets/furniture/${dialog}_NW.png',
                            height: 100,
                          );
                        },
                      );
                    },
                    height: 100,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: dialog.contains(':')
                      ? Text.rich(
                          TextSpan(
                            text: dialog.substring(0, dialog.indexOf(':')),
                            children: [
                              TextSpan(
                                text: dialog.substring(
                                    dialog.indexOf(':'), dialog.length),
                                style: const TextStyle(
                                    fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                          style: GoogleFonts.vt323(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ))
                      : Text(
                          dialog,
                          style: GoogleFonts.vt323(fontSize: 28),
                        ),
                ),
        ],
      ],
    );
  }
}

class _CallEvent extends StatefulWidget {
  final Event event;
  const _CallEvent({required this.event, Key? key}) : super(key: key);

  @override
  State<_CallEvent> createState() => _CallEventState();
}

class _CallEventState extends State<_CallEvent> {
  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  bool showTranscript = false;

  @override
  void initState() {
    audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          isPlaying = state == PlayerState.playing;
        });
      }
    });
    audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          duration = newDuration;
        });
      }
    });
    audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          position = newPosition;
        });
      }
    });
    audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          isPlaying = false;
          audioPlayer.setSourceAsset('callAudio/${widget.event.audioPath}');
        });
      }
    });
    setAudio();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer.dispose();
  }

  Future setAudio() async {
    if (widget.event.audioPath != null) {
      audioPlayer.setSourceAsset('callAudio/${widget.event.audioPath}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.event.audioPath != null) ...[
          Slider(
            min: 0,
            max: duration.inSeconds.toDouble(),
            value: position.inSeconds.toDouble(),
            onChanged: (value) async {
              final position = Duration(seconds: value.toInt());
              await audioPlayer.seek(position);
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formatTime(position)),
              Text(formatTime(duration)),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () async {
              if (isPlaying) {
                await audioPlayer.pause();
              } else {
                await audioPlayer.resume();
              }
            },
            icon: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              size: 24,
            ),
            label: Text(isPlaying ? 'Pause' : 'Play',
                style: const TextStyle(fontSize: 18)),
          ),
          const Divider(),
        ],
        TextButton.icon(
          onPressed: () => setState(() {
            showTranscript = !showTranscript;
          }),
          icon: Icon(
            showTranscript
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down,
          ),
          label: Text(showTranscript ? 'Hide transcript' : 'Show transcript',
              style: const TextStyle(fontSize: 18)),
        ),
        if (showTranscript) ...[
          Container(
            height: 8,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (String dialog in widget.event.dialog) ...[
                Text(
                  dialog,
                  style: const TextStyle(fontSize: 24),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}
