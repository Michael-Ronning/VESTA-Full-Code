import 'package:flutter/material.dart';
import 'package:projectmercury/models/event.dart';
import 'package:projectmercury/models/furniture.dart';
import 'package:projectmercury/models/store_item.dart';
import 'package:projectmercury/models/transaction.dart';
import 'package:projectmercury/pages/homePage/room.dart';
import 'package:projectmercury/data/room_data.dart';
import '../pages/homePage/tip_message.dart';

class AppState with ChangeNotifier {
  int currentPage = 0;

  Room? _currentRoom;
  Room? get currentRoom => _currentRoom;
  setRoom(Room? room) {
    _currentRoom = room;
    _tip = tipMessage();
    notifyListeners();
  }

  final List<Room> _rooms = [
    bedroom,
    livingroom,
    bathroom,
    kitchen,
    diningroom,
    garage,
  ];
  List<Room> get rooms => _rooms;
  Room getRoom(String? name) {
    Iterable<Room> match = rooms.where((element) => element.name == name);
    return match.first;
  }

  List<InlineSpan>? _tip;
  List<InlineSpan>? get tip => _tip;
  bool showTip = true;
  void toggleTip() {
    showTip = !showTip;
    _tip = tipMessage();
    notifyListeners();
  }

  String? currDataId;
  int? txnCnt = 0;
  int? evntCnt = 0;

  num _balance = 0;
  num get balance => _balance;

  int _session = 1;
  int get session => _session;

  Room? _sessionRoom;
  Room? get sessionRoom => _sessionRoom;

  double _sessionProgress = 0;
  double get sessionProgress => _sessionProgress;

  List<int> _roomProgress = [0, 0];
  List<int> get roomProgress => _roomProgress;

  List<int> _eventProgress = [0, 0];
  List<int> get eventProgress => _eventProgress;

  List<PurchasedItem>? _purchasedItems;
  List<PurchasedItem> get purchasedItems => _purchasedItems ?? [];
  PurchasedItem? getItem(String? id) {
    Iterable<PurchasedItem> match =
        purchasedItems.where((element) => element.id == id);
    return match.isNotEmpty ? match.first : null;
  }

  List<Transaction>? _transactions;
  List<Transaction> get transactions => _transactions ?? [];
  Transaction? getTransaction(String? id) {
    Iterable<Transaction> match =
        transactions.where((element) => element.id == id);
    return match.isNotEmpty ? match.first : null;
  }

  List<Event>? _deployedEvents;
  List<Event> get deployedEvents => _deployedEvents ?? [];

  final List<bool> _showBadge = [false, false, false, false, false];
  List<bool> get showBadge => _showBadge;

  Transaction? actionNeededTransaction;
  Event? actionNeededEvent;

// checks if transaction action in needed
  bool waitingTransactionAction() {
    Iterable<Transaction> actionNeeded = transactions.where(
        (element) => element.currentState == TransactionState.actionNeeded);
    if (actionNeeded.isNotEmpty) {
      actionNeededTransaction = actionNeeded.first;
      return true;
    } else {
      actionNeededTransaction = null;
      return false;
    }
  }

// checks if event action is needed
  bool waitingEventAction() {
    Iterable<Event> actionNeeded = deployedEvents.where((element) =>
        element.state == EventState.actionNeeded || element.wasOpened == false);
    if (actionNeeded.isNotEmpty) {
      actionNeededEvent = actionNeeded.first;
      return true;
    } else {
      actionNeededEvent = null;
      return false;
    }
  }

// execute on balance changed
  void onBalanceChanged(num balance) {
    _balance = balance;
    notifyListeners();
  }

// execute on session changed
  void onSessionChanged(int session) {
    _session = session;
    if (session > rooms.length) {
      _sessionRoom = _sessionRoom =
          rooms.firstWhere((element) => element.unlockOrder == rooms.length);
    } else {
      _sessionRoom =
          rooms.firstWhere((element) => element.unlockOrder == session);
    }
    setRoom(_sessionRoom);
    calculateRoomProgress();
    updateBadge([0]);
    notifyListeners();
  }

// execute on events changed
  void onEventsChanged(List<Event> eventList) {
    _deployedEvents =
        eventList.where((element) => element.hidden == false).toList();
    deployedEvents.sort((a, b) => b.timeSent!.compareTo(a.timeSent!));
    if (sessionRoom != null) {
      calculateEventProgress();
    }
    updateBadge([3, 0]);
    notifyListeners();
  }

// executes on transactions changed
  void onTransactionsChanged(List<Transaction> transactionList) {
    _transactions = transactionList;
    transactions.sort((a, b) => b.timeStamp!.compareTo(a.timeStamp!));
    calculateSessionProgress();
    updateBadge([1, 0]);
    notifyListeners();
  }

// executes on purchased items changed
  void onItemsChanged(List<PurchasedItem> itemList) {
    _purchasedItems = itemList;
    purchasedItems.sort((a, b) => b.timeBought!.compareTo(a.timeBought!));
    furnishRoom();
    calculateRoomProgress();
    updateBadge([0]);
    notifyListeners();
  }

// updates the visibility of icon above tabs
  void updateBadge(List<int> pages) {
    for (int i in pages) {
      switch (i) {
        case 0:
          (roomProgress[0] != roomProgress[1] &&
                  !waitingTransactionAction() &&
                  !waitingEventAction() &&
                  transactions
                      .where((element) =>
                          element.currentState == TransactionState.pending)
                      .isEmpty &&
                  session <= rooms.length)
              ? _showBadge[0] = true
              : _showBadge[0] = false;
          break;
        case 1:
          waitingTransactionAction()
              ? _showBadge[1] = true
              : _showBadge[1] = false;
          break;
        case 2:
          break;
        case 3:
          waitingEventAction() ? _showBadge[3] = true : _showBadge[3] = false;
          break;
        case 4:
          sessionProgress == 1 ? _showBadge[4] = true : _showBadge[4] = false;
          break;
        default:
      }
    }
    _tip = tipMessage();
  }

  void calculateRoomProgress() {
    _roomProgress = [0, 0];
    if (sessionRoom != null) {
      int slotsTotal = sessionRoom!.distinctSlots.length;
      int slotsFilled = sessionRoom!.distinctFilledSlots.length;
      slotsFilled > slotsTotal ? slotsFilled = slotsTotal : null;
      _roomProgress = [slotsFilled, slotsTotal];
      calculateEventProgress();
    }
  }

  void calculateEventProgress() {
    _eventProgress = [0, 0];
    int eventsTotal = -2;
    for (var element in sessionRoom!.distinctSlots) {
      eventsTotal += element.setting.delayEvent.length;
      eventsTotal += element.setting.doubleAfterEvent.length;
    }
    int eventsDone = deployedEvents
        .where((element) => element.session == session)
        .where((element) =>
            element.state != EventState.actionNeeded &&
            element.state != EventState.static)
        .length;
    eventsDone > eventsTotal ? eventsDone = eventsTotal : null;
    _eventProgress = [eventsDone, eventsTotal];
    calculateSessionProgress();
  }

  void calculateSessionProgress() {
    int denom = _roomProgress[1] + _eventProgress[1];
    _sessionProgress =
        denom != 0 ? ((_roomProgress[0] + _eventProgress[0]) / denom) : 1;
    if (sessionProgress == 1) {
      if (waitingEventAction()) {
        _sessionProgress -= 0.01;
      }
      if (waitingTransactionAction()) {
        _sessionProgress -= 0.01;
      }
    }
    updateBadge([4]);
  }

// fills room with purchased items
  void furnishRoom() {
    for (Room room in rooms) {
      // reset room
      room.fillSlots(null, null);
      List<PurchasedItem> roomItems =
          purchasedItems.where((element) => element.room == room.name).toList();
      // fill in slots
      if (roomItems.isNotEmpty) {
        for (PurchasedItem purchase in roomItems) {
          List<Slot> matchingSlots = room.slots
              .where((element) => element.order == purchase.slotID)
              .toList();
          if (purchase.delivered) {
            // Fill all slots that take a given item
            if (matchingSlots.isNotEmpty) {
              matchingSlots.forEach(((element) => element.set(purchase.item)));
            }
          } else {
            if (matchingSlots.isNotEmpty) {}
          }
        }
      }
    }
  }
}
