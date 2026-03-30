import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projectmercury/data/event_data.dart';
import 'package:projectmercury/data/room_data.dart';
import 'package:projectmercury/data/transaction_data.dart';
import 'package:projectmercury/models/event.dart';
import 'package:projectmercury/models/furniture.dart';
import 'package:projectmercury/models/store_item.dart';
import 'package:projectmercury/models/user.dart' as model;
import 'package:projectmercury/models/transaction.dart' as model;
import 'package:projectmercury/resources/app_state.dart';
import 'package:projectmercury/resources/auth_methods.dart';
import 'package:projectmercury/resources/firestore_path.dart';
import 'package:projectmercury/resources/firestore_service.dart';
import 'package:projectmercury/resources/locator.dart';
import 'package:projectmercury/resources/task_mapping_validator.dart';
import 'package:projectmercury/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

//main firestore methods
class FirestoreMethods {
  final FirestoreService _firestoreService = FirestoreService.instance;
  model.User? lastUserData;
  late StreamSubscription _userSubscription;
  late StreamSubscription _itemsSubscription;
  late StreamSubscription _eventsSubscription;
  late StreamSubscription _transactionsSubscription;
  bool _taskMappingLoaded = false;
  bool _taskMappingLoadFailed = false;
  final Map<String, TaskMappingRow> _eventTaskMapping = {};
  final Map<String, TaskMappingRow> _txnTaskMapping = {};
  final Map<String, dynamic> _pendingDataRowFields = {};
  final Map<String, Map<String, dynamic>> _pendingDocumentUpdates = {};
  final Map<String, dynamic> _pendingUserSets = {};
  final Map<String, num> _pendingUserIncrements = {};
  final Map<int, Map<String, dynamic>> _pendingSessionSummarySets = {};
  final Map<int, Map<String, num>> _pendingSessionSummaryIncrements = {};
  bool _loadedBufferedState = false;
  static const String _bufferPrefsKey = 'firestore_buffer_v1';

  Future<void> _ensureTaskMappingLoaded() async {
    if (_taskMappingLoaded || _taskMappingLoadFailed) {
      return;
    }
    try {
      final rows = await TaskMappingValidator.loadMappingRows();
      for (final row in rows) {
        if (!row.countAsTask) {
          continue;
        }
        if (row.entityType == 'EVNT') {
          _eventTaskMapping[row.templateId] = row;
        } else if (row.entityType == 'TXN') {
          _txnTaskMapping[row.templateId] = row;
        }
      }
      _taskMappingLoaded = true;
    } catch (e) {
      _taskMappingLoadFailed = true;
      debugPrint('Task mapping could not be loaded: $e');
    }
  }

  String _eventTemplateId(Event event) {
    return event.id.split('_').first;
  }

  String _transactionTemplateId(model.Transaction transaction) {
    return transaction.id.split('_').first;
  }

  bool? _transactionSucceeded(model.Transaction transaction, bool approve) {
    if (transaction.isScam) {
      return !approve;
    }
    return approve;
  }

  Map<String, num> _taskOutcomeIncrements({
    required String difficulty,
    required bool success,
  }) {
    final Map<String, num> increments = {};
    if (difficulty == 'easy') {
      increments[success ? 'easyCompleted' : 'easyFailed'] = 1;
    } else {
      increments[success ? 'hardCompleted' : 'hardFailed'] = 1;
    }
    increments[success ? 'tasksCompleted' : 'tasksFailed'] = 1;
    increments['tasksTotal'] = 1;
    return increments;
  }

  String? _transactionDifficulty(model.Transaction transaction) {
    final String? type = transaction.type?.name.toLowerCase();
    if (type == null) {
      return null;
    }
    if (type.contains('hard')) {
      return 'hard';
    }
    if (type.contains('easy')) {
      return 'easy';
    }
    return null;
  }

  bool get _hasPendingBufferedWrites =>
      _pendingDocumentUpdates.isNotEmpty ||
      _pendingDataRowFields.isNotEmpty ||
      _pendingUserSets.isNotEmpty ||
      _pendingUserIncrements.isNotEmpty ||
      _pendingSessionSummarySets.isNotEmpty ||
      _pendingSessionSummaryIncrements.isNotEmpty;

  Map<String, dynamic> _encodeDynamicMap(Map<String, dynamic> input) {
    final out = <String, dynamic>{};
    input.forEach((key, value) {
      if (value is DateTime) {
        out[key] = {'__dt': value.toIso8601String()};
      } else {
        out[key] = value;
      }
    });
    return out;
  }

  Map<String, dynamic> _decodeDynamicMap(Map<String, dynamic> input) {
    final out = <String, dynamic>{};
    input.forEach((key, value) {
      if (value is Map && value.length == 1 && value['__dt'] is String) {
        out[key] = DateTime.tryParse(value['__dt'] as String) ?? value;
      } else {
        out[key] = value;
      }
    });
    return out;
  }

  Future<void> _persistBufferedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = {
        'docUpdates': _pendingDocumentUpdates.map(
          (key, value) => MapEntry(key, _encodeDynamicMap(value)),
        ),
        'dataRow': _encodeDynamicMap(_pendingDataRowFields),
        'userSets': _encodeDynamicMap(_pendingUserSets),
        'userIncrements': _pendingUserIncrements,
        'summarySets': _pendingSessionSummarySets.map(
          (key, value) => MapEntry(key.toString(), _encodeDynamicMap(value)),
        ),
        'summaryIncrements': _pendingSessionSummaryIncrements.map(
          (key, value) => MapEntry(key.toString(), value),
        ),
      };
      await prefs.setString(_bufferPrefsKey, jsonEncode(encoded));
    } catch (_) {}
  }

  Future<void> _loadBufferedStateIfNeeded() async {
    if (_loadedBufferedState) return;
    _loadedBufferedState = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_bufferPrefsKey);
      if (raw == null || raw.isEmpty) {
        return;
      }
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return;
      }

      final docUpdates = decoded['docUpdates'];
      if (docUpdates is Map<String, dynamic>) {
        docUpdates.forEach((path, value) {
          if (value is Map<String, dynamic>) {
            _pendingDocumentUpdates[path] = _decodeDynamicMap(value);
          }
        });
      }

      final dataRow = decoded['dataRow'];
      if (dataRow is Map<String, dynamic>) {
        _pendingDataRowFields.addAll(_decodeDynamicMap(dataRow));
      }

      final userSets = decoded['userSets'];
      if (userSets is Map<String, dynamic>) {
        _pendingUserSets.addAll(_decodeDynamicMap(userSets));
      }

      final userIncrements = decoded['userIncrements'];
      if (userIncrements is Map<String, dynamic>) {
        userIncrements.forEach((k, v) {
          if (v is num) {
            _pendingUserIncrements[k] = v;
          }
        });
      }

      final summarySets = decoded['summarySets'];
      if (summarySets is Map<String, dynamic>) {
        summarySets.forEach((k, v) {
          final session = int.tryParse(k);
          if (session != null && v is Map<String, dynamic>) {
            _pendingSessionSummarySets[session] = _decodeDynamicMap(v);
          }
        });
      }

      final summaryIncrements = decoded['summaryIncrements'];
      if (summaryIncrements is Map<String, dynamic>) {
        summaryIncrements.forEach((k, v) {
          final session = int.tryParse(k);
          if (session != null && v is Map<String, dynamic>) {
            _pendingSessionSummaryIncrements[session] = {};
            v.forEach((innerK, innerV) {
              if (innerV is num) {
                _pendingSessionSummaryIncrements[session]![innerK] = innerV;
              }
            });
          }
        });
      }
    } catch (_) {}
  }

  void _queueDocumentUpdate(String path, Map<String, dynamic> fields) {
    _pendingDocumentUpdates.putIfAbsent(path, () => {});
    _pendingDocumentUpdates[path]!.addAll(fields);
    unawaited(_persistBufferedState());
  }

  void _queueDataRowFields(Map<String, dynamic> fields) {
    _pendingDataRowFields.addAll(fields);
    unawaited(_persistBufferedState());
  }

  void _queueUserSetFields(Map<String, dynamic> fields) {
    fields.forEach((key, value) {
      _pendingUserSets[key] = value;
      _pendingUserIncrements.remove(key);
    });
    unawaited(_persistBufferedState());
  }

  void _queueUserIncrementFields(Map<String, num> fields) {
    fields.forEach((key, value) {
      _pendingUserIncrements[key] = (_pendingUserIncrements[key] ?? 0) + value;
    });
    unawaited(_persistBufferedState());
  }

  void _queueSessionSummarySetFields(int session, Map<String, dynamic> fields) {
    _pendingSessionSummarySets.putIfAbsent(session, () => {});
    _pendingSessionSummarySets[session]!.addAll(fields);
    unawaited(_persistBufferedState());
  }

  void _queueSessionSummaryIncrementFields(int session, Map<String, num> fields) {
    _pendingSessionSummaryIncrements.putIfAbsent(session, () => {});
    fields.forEach((key, value) {
      _pendingSessionSummaryIncrements[session]![key] =
          (_pendingSessionSummaryIncrements[session]![key] ?? 0) + value;
    });
    unawaited(_persistBufferedState());
  }

  Future<String?> _ensureCurrDataId() async {
    final fs = _firestoreService;
    final app = locator.get<AppState>();
    final auth = locator.get<AuthMethods>();

    String? dataId = app.currDataId;
    if (dataId != null && dataId.isNotEmpty) {
      return dataId;
    }

    final String name = '${getRoomInit(app.rooms[0].name)}_Start';
    dataId = await fs.addDocument(
      path: FirestorePath.newData(),
      data: {
        '0_User_Id': auth.uid,
        '0_Email': auth.currentUser.email,
        '1_${name}_time': DateTime.now(),
        '1_${name}_bal': depositAmount[0],
      },
    );

    await fs.updateDocument(
      path: FirestorePath.user(),
      data: {'currDataId': dataId},
    );
    app.currDataId = dataId;
    return dataId;
  }

  Future<void> flushBufferedWrites({String reason = 'manual'}) async {
    await _loadBufferedStateIfNeeded();
    if (!_hasPendingBufferedWrites) {
      return;
    }

    final docUpdates = Map<String, Map<String, dynamic>>.fromEntries(
      _pendingDocumentUpdates.entries
          .map((e) => MapEntry(e.key, Map<String, dynamic>.from(e.value))),
    );
    final dataRowFields = Map<String, dynamic>.from(_pendingDataRowFields);
    final userSets = Map<String, dynamic>.from(_pendingUserSets);
    final userIncrements = Map<String, num>.from(_pendingUserIncrements);
    final summarySets =
        Map<int, Map<String, dynamic>>.fromEntries(_pendingSessionSummarySets
            .entries
            .map((e) => MapEntry(e.key, Map<String, dynamic>.from(e.value))));
    final summaryIncrements = Map<int, Map<String, num>>.fromEntries(
      _pendingSessionSummaryIncrements.entries
          .map((e) => MapEntry(e.key, Map<String, num>.from(e.value))),
    );

    try {
      for (final entry in docUpdates.entries) {
        await _firestoreService.updateDocument(
          path: entry.key,
          data: entry.value,
        );
      }

      if (dataRowFields.isNotEmpty) {
        final dataId = await _ensureCurrDataId();
        if (dataId != null) {
          await _firestoreService.updateDocument(
            path: FirestorePath.newDataRow(dataId),
            data: dataRowFields,
          );
        }
      }

      if (userSets.isNotEmpty || userIncrements.isNotEmpty) {
        final userPayload = <String, dynamic>{...userSets};
        userIncrements.forEach((key, value) {
          userPayload[key] = FieldValue.increment(value);
        });
        await _firestoreService.updateDocument(
          path: FirestorePath.user(),
          data: userPayload,
        );
      }

      final sessions = {
        ...summarySets.keys,
        ...summaryIncrements.keys,
      };
      for (final session in sessions) {
        await _upsertSessionSummary(
          session: session,
          setFields: summarySets[session] ?? const {},
          incrementFields: summaryIncrements[session] ?? const {},
        );
      }

      _pendingDocumentUpdates.clear();
      _pendingDataRowFields.clear();
      _pendingUserSets.clear();
      _pendingUserIncrements.clear();
      _pendingSessionSummarySets.clear();
      _pendingSessionSummaryIncrements.clear();
      await _persistBufferedState();
      debugPrint('Buffered Firestore writes flushed ($reason).');
    } catch (e) {
      debugPrint('Failed to flush buffered Firestore writes ($reason): $e');
      await _persistBufferedState();
    }
  }

  Future<void> _upsertSessionSummary({
    required int session,
    Map<String, dynamic> setFields = const {},
    Map<String, num> incrementFields = const {},
  }) async {
    final auth = locator.get<AuthMethods>();
    final app = locator.get<AppState>();
    final String uid = auth.uid;
    if (uid.isEmpty) {
      return;
    }

    final String? email = auth.currentUser.email;
    final Map<String, dynamic> payload = {
      'uid': uid,
      'email': email,
      'emailNormalized': email?.toLowerCase(),
      'session': session,
      'currDataId': app.currDataId,
      'summaryVersion': 'v1',
      'updatedAt': FieldValue.serverTimestamp(),
      ...setFields,
    };

    incrementFields.forEach((key, value) {
      payload[key] = FieldValue.increment(value);
    });

    await FirebaseFirestore.instance
        .doc(FirestorePath.sessionSummary(uid, session))
        .set(payload, SetOptions(merge: true));
  }

  Future<void> _initializeSessionSummary(int session) async {
    final app = locator.get<AppState>();
    final uid = locator.get<AuthMethods>().uid;
    if (uid.isEmpty) {
      return;
    }
    final summaryPath = FirestorePath.sessionSummary(uid, session);
    if (await _firestoreService.documentExists(path: summaryPath)) {
      await _upsertSessionSummary(session: session);
      return;
    }

    await _upsertSessionSummary(
      session: session,
      setFields: {
        'sessionStartTs': FieldValue.serverTimestamp(),
        'sessionEndTs': null,
        'mocaCompleted': false,
        'mocaTotal': null,
        'mocaClass': null,
        'mocaAttempt': null,
        'mocaVersion': null,
        'mocaMaxScore': null,
        'easyCompleted': 0,
        'easyFailed': 0,
        'hardCompleted': 0,
        'hardFailed': 0,
        'tasksCompleted': 0,
        'tasksFailed': 0,
        'tasksTotal': 0,
        'approvedTxns': 0,
        'disputedTxns': 0,
        'eventYes': 0,
        'eventNo': 0,
        'startingBalance': app.balance,
        'endingBalance': null,
        'hasMissingData': false,
      },
    );
  }

  Future<void> initializeSubscriptions() async {
    await _loadBufferedStateIfNeeded();
    _userSubscription = _firestoreService
        .documentStream(
            path: FirestorePath.user(),
            builder: (data) => model.User.fromSnap(data))
        .listen((event) {
      if (lastUserData != null) {
        if (lastUserData!.currDataId != event.currDataId) {
          locator.get<AppState>().currDataId = event.currDataId;
        }
        if (lastUserData!.txnCnt != event.txnCnt) {
          locator.get<AppState>().txnCnt = event.txnCnt;
        }
        if (lastUserData!.evntCnt != event.evntCnt) {
          locator.get<AppState>().evntCnt = event.evntCnt;
        }
        if (lastUserData!.mocaCnt != event.mocaCnt) {
          locator.get<AppState>().mocaCnt = event.mocaCnt;
        }
        if (lastUserData!.session != event.session) {
          locator.get<AppState>().onSessionChanged(event.session);
        }
        if (lastUserData!.balance != event.balance) {
          locator.get<AppState>().onBalanceChanged(event.balance);
        }
      } else {
        locator.get<AppState>().currDataId = event.currDataId;
        locator.get<AppState>().txnCnt = event.txnCnt;
        locator.get<AppState>().evntCnt = event.evntCnt;
        locator.get<AppState>().mocaCnt = event.mocaCnt;
        locator.get<AppState>().onSessionChanged(event.session);
        locator.get<AppState>().onBalanceChanged(event.balance);
      }
      lastUserData = event;
    });
    _itemsSubscription = _firestoreService
        .collectionStream(
            path: FirestorePath.items(),
            builder: (data) => PurchasedItem.fromSnap(data))
        .listen((event) {
      locator.get<AppState>().onItemsChanged(event);
    });

    _eventsSubscription = _firestoreService
        .collectionStream(
            path: FirestorePath.events(),
            builder: (data) => Event.fromSnap(data))
        .listen((event) {
      locator.get<AppState>().onEventsChanged(event);
    });

    _transactionsSubscription = _firestoreService
        .collectionStream(
            path: FirestorePath.transactions(),
            builder: (data) => model.Transaction.fromSnap(data))
        .listen((event) {
      locator.get<AppState>().onTransactionsChanged(event);
    });
  }

  Future<void> pauseSubscriptions() async {
    _userSubscription.pause();
    _itemsSubscription.pause();
    _eventsSubscription.pause();
    _transactionsSubscription.pause();
  }

  Future<void> resumeSubscriptions() async {
    _userSubscription.resume();
    _itemsSubscription.resume();
    _eventsSubscription.resume();
    _transactionsSubscription.resume();
  }

  Future<void> cancelSubscriptions() async {
    _userSubscription.cancel();
    _itemsSubscription.cancel();
    _eventsSubscription.cancel();
    _transactionsSubscription.cancel();
  }

// initialize data
  Future<void> initializeData(User user) async {
    var batch = _firestoreService.newBatch();
    if (!(await _firestoreService.documentExists(path: FirestorePath.user()))) {
      model.User userModel = model.User(id: user.uid, email: user.email);
      _firestoreService.addDocument(
        path: FirestorePath.users(),
        data: userModel.toJson(),
        myId: user.uid,
        batch: batch,
      );
    }
    // add initial transaction if new user
    if (!(await _firestoreService.collectionExists(
        path: FirestorePath.transactions()))) {
      String name =
          '${getRoomInit(locator.get<AppState>().rooms[0].name)}_Start';
      await _firestoreService.updateDocument(path: FirestorePath.user(), data: {
        'currDataId': await _firestoreService
            .addDocument(path: FirestorePath.newData(), data: {
          '0_User_Id': user.uid,
          '0_Email': user.email,
          '1_${name}_time': DateTime.now(),
          '1_${name}_bal': depositAmount[0],
        })
      });
      await _firestoreService.updateDocument(
        path: FirestorePath.user(),
        data: {'TXN_CNT': 0, 'EVNT_CNT': 0, 'MOCA_CNT': 0},
      );
      await addTransaction(initialTransaction(), batch);
    }
    batch.commit();
    await _initializeSessionSummary(locator.get<AppState>().session);
    locator.get<AppState>().updateBadge([0, 1, 3, 4]);
  }

// reset data
  Future<void> resetData() async {
    await flushBufferedWrites(reason: 'reset_data');
    cancelSubscriptions();
    _firestoreService.updateDocument(
      path: FirestorePath.user(),
      data: model.User.getJson(
        score: 0,
        balance: 0,
        session: 1,
      ),
    );
    _firestoreService.updateDocument(
      path: FirestorePath.user(),
      data: {'TXN_CNT': 0, 'EVNT_CNT': 0, 'MOCA_CNT': 0},
    );
    _firestoreService.deleteCollection(path: FirestorePath.items());
    _firestoreService.deleteCollection(path: FirestorePath.transactions());
    await _firestoreService.deleteCollection(path: FirestorePath.events());
    initializeData(locator.get<AuthMethods>().currentUser);
    locator.get<AppState>().setRoom(null);
    initializeSubscriptions();
  }

// update user session
  Future<void> incrementSession() async {
    await flushBufferedWrites(reason: 'room_finished');
    var batch = _firestoreService.newBatch();
    int session = locator.get<AppState>().session;
    // new
    String name =
        '${getRoomInit(locator.get<AppState>().sessionRoom!.name)}_End';
    DateTime time = DateTime.now();
    num balance = locator.get<AppState>().balance;
    _firestoreService.updateDocument(
        path: FirestorePath.newDataRow(locator.get<AppState>().currDataId!),
        data: {
          '${session}_${name}_time': time,
          '${session}_${name}_bal': balance,
        });
    // record session progress
    // _firestoreService.addDocument(
    //   path: FirestorePath.data(),
    //   data: Data(
    //     userId: locator.get<AuthMethods>().uid,
    //     actionType: ActionType.progress,
    //     actionId: name,
    //     time: time,
    //     balanceRemaining: balance,
    //   ).toJson(),
    //   batch: batch,
    // );
    if (locator.get<AppState>().session <
        locator.get<AppState>().rooms.length) {
      // reset balance
      await _firestoreService.updateDocument(
        path: FirestorePath.user(),
        data: model.User.getJson(balance: 0),
        batch: batch,
      );
      // add balance defined for session
      await addTransaction(
        initialTransaction(session: locator.get<AppState>().session + 1),
        batch,
      );
      // new
      String name =
          '${getRoomInit(locator.get<AppState>().rooms[locator.get<AppState>().session].name)}_Start';
      _firestoreService.updateDocument(
          path: FirestorePath.newDataRow(locator.get<AppState>().currDataId!),
          data: {
            '${session + 1}_${name}_time': time,
            '${session + 1}_${name}_bal':
                depositAmount[locator.get<AppState>().session],
          });
    }
    // increment session
    await _firestoreService.updateDocument(
      path: FirestorePath.user(),
      data: model.User.getJson(addToSession: 1),
      batch: batch,
    );
    batch.commit();

    await _upsertSessionSummary(
      session: session,
      setFields: {
        'sessionEndTs': FieldValue.serverTimestamp(),
        'endingBalance': locator.get<AppState>().balance,
      },
    );

    await _initializeSessionSummary(session + 1);
  }

  Future<void> unhideEvent(String? eventId, var batch) async {
    if (eventId != null) {
      _firestoreService.updateDocument(
        path: FirestorePath.event(eventId),
        batch: batch,
        data: Event.getJson(
          hidden: false,
          timeSent: DateTime.now(),
        ),
      );
    }
  }

  Future<void> unhideTransaction(String eventId, var batch) async {
    List<model.Transaction> pending = locator
        .get<AppState>()
        .transactions
        .where((element) => element.linkedEventId == eventId)
        .where(
            (element) => element.initialState == model.TransactionState.pending)
        .toList();
    for (model.Transaction transaction in pending) {
      _firestoreService.updateDocument(
        path: FirestorePath.transaction(transaction.id),
        batch: batch,
        data: model.Transaction.getJson(
          currentState: model.TransactionState.actionNeeded,
          timeStamp: DateTime.now(),
          hidden: false,
        ),
      );
    }
  }

  Future<void> buyItem(StoreItem item, String room, Slot slot) async {
    final fs = _firestoreService;
    final app = locator.get<AppState>();
    var batch = fs.newBatch();

    int session = app.session;
    List<int> events = slot.setting.delayEvent;
    String itemId = slot.id;
    DateTime time = DateTime.now();
    int priceRank = slot.getItemPriceRank(item.item);

    // ── Ensure currDataId is available ──
    String? dataId = app.currDataId;
    if (dataId == null) {
      dataId = await fs.addDocument(
        path: FirestorePath.newData(),
        data: {
          '0_User_Id': locator.get<AuthMethods>().uid,
          '0_Email': locator.get<AuthMethods>().currentUser.email,
          '1_${getRoomInit(room)}_Start_time': time,
          '1_${getRoomInit(room)}_bal': depositAmount[0],
        },
      );
      await fs.updateDocument(
        path: FirestorePath.user(),
        data: {'currDataId': dataId},
      );
      app.currDataId = dataId;
      debugPrint('↪︎ Generated currDataId on demand: $dataId');
    }

    // ── Add item to Firestore ──
    fs.addDocument(
      path: FirestorePath.items(),
      myId: itemId,
      batch: batch,
      data: PurchasedItem(
        name: item.name,
        price: item.price,
        item: item.item,
        seller: item.seller,
        id: itemId,
        timeBought: time,
        room: room,
        slotID: slot.order,
        priceRank: priceRank,
        delivered: false,
      ).toJson(),
    );

    // ── Add associated events ──
    String? prevId;
    for (int i = events.length - 1; i >= 0; i--) {
      String eventId = '${itemId}_$i';
      Event? event = getEvent(events[i]);
      if (event != null) {
        fs.addDocument(
          path: FirestorePath.events(),
          myId: eventId,
          batch: batch,
          data: Event.getJson(
            event: event,
            id: eventId,
            timeSent: time,
            session: session,
            unhideOnResolved: prevId,
            hidden: true,
          ),
        );
        prevId = eventId;
      }
    }

    // ── Add receipt event ──
    fs.addDocument(
      path: FirestorePath.events(),
      myId: itemId,
      batch: batch,
      data: Event.getJson(
        event: receiptEvent(item, prevId),
        id: itemId,
        timeSent: time,
      ),
    );

    // ── Add transaction ──
    fs.addDocument(
      path: FirestorePath.transactions(),
      myId: itemId,
      batch: batch,
      data: model.Transaction.getJson(
        transaction: itemTransaction(
          item,
          slot,
          itemId,
          prevId ?? itemId,
        ),
        id: itemId,
        timeStamp: time,
      ),
    );

    // ── Reset user counters ──
    _queueUserSetFields({'TXN_CNT': 0, 'EVNT_CNT': 0});
    app.txnCnt = 0;
    app.evntCnt = 0;

    // ── Record data row ──
    String name = '${slot.id}_BUY';
    _queueDataRowFields({
      '${session}_${name}_time': time,
      '${session}_${name}_item': item.name,
      '${session}_${name}_rank': priceRank,
      '${session}_${name}_cost': item.price,
    });

    // ── Final commit ──
    await Future.delayed(
        const Duration(milliseconds: 150), () => batch.commit());
  }

  Future<void> submitMocaResult({
    required int totalScore,
    required Map<String, int> sectionScores,
    String mocaVersion = 'moca22',
    int mocaMaxScore = 22,
    int normalCutoff = 19,
  }) async {
    final fs = _firestoreService;
    final app = locator.get<AppState>();
    final auth = locator.get<AuthMethods>();
    final DateTime time = DateTime.now();
    final int session = app.session;

    String? dataId = app.currDataId;
    if (dataId == null) {
      String name = '${getRoomInit(app.rooms[0].name)}_Start';
      dataId = await fs.addDocument(
        path: FirestorePath.newData(),
        data: {
          '0_User_Id': auth.uid,
          '0_Email': auth.currentUser.email,
          '1_${name}_time': time,
          '1_${name}_bal': depositAmount[0],
        },
      );
      await fs.updateDocument(
        path: FirestorePath.user(),
        data: {'currDataId': dataId},
      );
      app.currDataId = dataId;
    }

    final int attempt = app.mocaCnt ?? 0;
    final String mocaKey = 'MOCA_M$attempt';
    final String mocaClass = totalScore >= normalCutoff ? 'normal' : 'needs_followup';
    final Map<String, dynamic> payload = {
      '${session}_${mocaKey}_time': time,
      '${session}_${mocaKey}_session': session,
      '${session}_${mocaKey}_userId': auth.uid,
      '${session}_${mocaKey}_version': mocaVersion,
      '${session}_${mocaKey}_max': mocaMaxScore,
      '${session}_${mocaKey}_total': totalScore,
      '${session}_${mocaKey}_class': mocaClass,
    };

    sectionScores.forEach((key, value) {
      payload['${session}_${mocaKey}_$key'] = value;
    });

    _queueDataRowFields(payload);
    _queueUserIncrementFields({'MOCA_CNT': 1});
    _queueSessionSummarySetFields(session, {
      'mocaCompleted': true,
      'mocaTotal': totalScore,
      'mocaClass': mocaClass,
      'mocaAttempt': attempt,
      'mocaVersion': mocaVersion,
      'mocaMaxScore': mocaMaxScore,
    });

    app.mocaCnt = attempt + 1;
  }

  // DEBUG ONLY: Remove before committing to production.
  Future<Map<String, dynamic>?> getLatestMocaDebugData() async {
    final app = locator.get<AppState>();
    final String? dataId = app.currDataId;
    if (dataId == null || dataId.isEmpty) {
      return null;
    }

    final String dataPath = FirestorePath.newDataRow(dataId);
    final bool exists = await _firestoreService.documentExists(path: dataPath);
    if (!exists) {
      return null;
    }

    final Map<String, dynamic> row =
        await _firestoreService.documentFuture<Map<String, dynamic>>(
      path: dataPath,
      builder: (data) => data,
    );

    final RegExp keyPattern = RegExp(r'^(\d+)_MOCA_M(\d+)_(.+)$');
    int latestAttempt = -1;
    int latestSession = -1;
    final Map<String, dynamic> latestFields = {};

    row.forEach((key, value) {
      final Match? match = keyPattern.firstMatch(key);
      if (match == null) {
        return;
      }

      final int session = int.tryParse(match.group(1) ?? '') ?? -1;
      final int attempt = int.tryParse(match.group(2) ?? '') ?? -1;
      final String field = match.group(3) ?? '';

      if (attempt > latestAttempt ||
          (attempt == latestAttempt && session > latestSession)) {
        latestAttempt = attempt;
        latestSession = session;
        latestFields.clear();
      }

      if (attempt == latestAttempt && session == latestSession) {
        latestFields[field] = value;
      }
    });

    if (latestAttempt < 0 || latestSession < 0) {
      return null;
    }

    return {
      'attempt': latestAttempt,
      'session': latestSession,
      ...latestFields,
    };
  }

  // this is old code for reference add item and events linked to item
//   Future<void> buyItem(StoreItem item, String room, Slot slot) async {
//     var batch = _firestoreService.newBatch();
//     int session = locator.get<AppState>().session;
//     List<int> events = slot.setting.delayEvent;
//     String itemId = slot.id;
//     DateTime time = DateTime.now();
//     int priceRank = slot.getItemPriceRank(item.item);
//     _firestoreService.addDocument(
//       path: FirestorePath.items(),
//       myId: itemId,
//       batch: batch,
//       data: PurchasedItem(
//         name: item.name,
//         price: item.price,
//         item: item.item,
//         seller: item.seller,
//         id: itemId,
//         timeBought: time,
//         room: room,
//         slotID: slot.order,
//         priceRank: priceRank,
//         delivered: false,
//       ).toJson(),
//     );
//     String? prevId;
//     bool hasEvent = events.isNotEmpty;
//     if (hasEvent) {
//       for (int i = events.length - 1; i >= 0; i--) {
//         String eventId = '${itemId}_$i';
//         Event? event = getEvent(events[i]);
//         if (event != null) {
//           _firestoreService.addDocument(
//               path: FirestorePath.events(),
//               myId: eventId,
//               batch: batch,
//               data: Event.getJson(
//                 event: event,
//                 id: eventId,
//                 timeSent: time,
//                 session: locator.get<AppState>().session,
//                 unhideOnResolved: prevId,
//                 hidden: true,
//               ));
//           prevId = eventId;
//         }
//       }
//     }
//     _firestoreService.addDocument(
//       path: FirestorePath.events(),
//       myId: itemId,
//       batch: batch,
//       data: Event.getJson(
//         event: receiptEvent(item, prevId),
//         id: itemId,
//         timeSent: time,
//       ),
//     );
//     _firestoreService.addDocument(
//       path: FirestorePath.transactions(),
//       myId: itemId,
//       batch: batch,
//       data: model.Transaction.getJson(
//           transaction: itemTransaction(
//             item,
//             slot,
//             itemId,
//             hasEvent ? '${itemId}_${events.length - 1}' : itemId,
//           ),
//           id: itemId,
//           timeStamp: time),
//     );
//     // new
//     // Reset user counters
//     _firestoreService.updateDocument(
//       path: FirestorePath.user(),
//       data: {'TXN_CNT': 0, 'EVNT_CNT': 0},
//     );

// // Safely get currDataId
//     final currDataId = locator.get<AppState>().currDataId;

//     if (currDataId == null) {
//       print(
//           'Error: currDataId is null. Skipping Firestore update for newDataRow.');
//       return;
//     }

//     String name = '${slot.id}_BUY';

// // Update data row only if currDataId is available
//     _firestoreService.updateDocument(
//       path: FirestorePath.newDataRow(currDataId),
//       data: {
//         '${session}_${name}_time': time,
//         '${session}_${name}_item': item.name,
//         '${session}_${name}_rank': priceRank,
//         '${session}_${name}_cost': item.price,
//       },
//     );

  // record data
  // _firestoreService.addDocument(
  //   path: FirestorePath.data(),
  //   data: Data(
  //     userId: locator.get<AuthMethods>().uid,
  //     email: locator.get<AuthMethods>().currentUser.email,
  //     actionType: ActionType.purchase,
  //     actionId: slot.id,
  //     time: time,
  //     purchaseName: item.name,
  //     purchaseRank: priceRank,
  //     balanceChange: -item.price,
  //     balanceRemaining: locator.get<AppState>().balance,
  //   ).toJson(),
  //   batch: batch,
  // );
  //   await Future.delayed(
  //       Duration(milliseconds: 150), (() => batch.commit()));
  // }

  Future<void> resolveTransaction(
      BuildContext context, model.Transaction transaction, bool approve) async {
    await _ensureTaskMappingLoaded();
    var batch = _firestoreService.newBatch();
    int session = locator.get<AppState>().session;
    final service = FirestoreService.instance;
    DateTime time = DateTime.now();
    int point = 0;
    model.TransactionState newState;
    model.Transaction? utility;
    if (transaction.linkedItemId != null) {
      service.updateDocument(
        path: FirestorePath.item(transaction.linkedItemId!),
        batch: batch,
        data: {'delivered': true},
      );
      String itemName =
          locator.get<AppState>().getItem(transaction.linkedItemId!)!.name;
      showConfirmation(
        context: context,
        static: true,
        title: 'Good News!',
        richText: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 20, color: Colors.black),
            children: [
              if (!approve && !transaction.isScam) ...[
                const TextSpan(
                  text: "Your bank confirmed that the charge for ",
                ),
                TextSpan(
                  text: itemName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text: " was legitimate and approved the charge. ",
                ),
              ],
              TextSpan(
                text: itemName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text: " has been delivered to your home.",
              ),
            ],
          ),
        ),
      );
      int deployUtilAfter = locator.get<AppState>().sessionRoom!.deployUtil;
      if (deployUtilAfter > locator.get<AppState>().roomProgress[1]) {
        deployUtilAfter = locator.get<AppState>().roomProgress[1];
      }
      if (locator.get<AppState>().roomProgress[0] == deployUtilAfter) {
        utility = utilityTransaction(locator.get<AppState>().session);
      }
    }
    // update transaction state
    if (approve == true) {
      newState = model.TransactionState.approved;
      if (!transaction.isScam) {
        point = 1;
      }
    } else {
      newState = model.TransactionState.disputed;
      if (transaction.isScam) {
        point = 1;
      }
      for (int i = 0; i < transaction.transactionOnDispute.length; i++) {
        await addTransaction(
          model.Transaction.fromSnap(
            model.Transaction.getJson(
                transaction: transaction.transactionOnDispute[i],
                id: "${transaction.id}_$i"),
          ),
          batch,
        );
      }
    }
    service.updateDocument(
      path: FirestorePath.transaction(transaction.id),
      batch: batch,
      data: model.Transaction.getJson(
        currentState: newState,
        timeActed: time,
      ),
    );
    service.updateDocument(
      path: FirestorePath.user(),
      batch: batch,
      data: model.User.getJson(
        addToScore: point,
        addToBalance: transaction.amount,
      ),
    );
    if (transaction.eventOnResolved.isNotEmpty) {
      String? prevId;
      List<int> events = transaction.eventOnResolved;
      for (int i = events.length - 1; i >= 0; i--) {
        Event? event = getEvent(events[i]);
        String eventId = '${transaction.id}_${events[i]}';
        if (event != null) {
          _firestoreService.addDocument(
              path: FirestorePath.events(),
              myId: eventId,
              batch: batch,
              data: Event.getJson(
                event: event,
                id: eventId,
                timeSent: DateTime.now(),
                session: locator.get<AppState>().session,
                unhideOnResolved: prevId,
                hidden: i == 0 ? false : true,
              ));
          prevId = eventId;
        }
      }
      _firestoreService.addDocument(
        path: FirestorePath.transactions(),
        myId: '${transaction.id}_',
        batch: batch,
        data: model.Transaction.getJson(
          transaction: transaction.transactionOnResolved[0],
          linkedEventId: '${transaction.id}_${events[events.length - 1]}',
          timeStamp: DateTime.now(),
        ),
      );
    } else {
      for (int i = 0; i < transaction.transactionOnResolved.length; i++) {
        await addTransaction(
            model.Transaction.fromSnap(
              model.Transaction.getJson(
                transaction: transaction.transactionOnResolved[i],
                id: "${transaction.id}_${i + transaction.transactionOnDispute.length}",
              ),
            ),
            batch);
      }
    }
    if (utility != null) {
      await addTransaction(utility, batch);
    }
    //new
    List<String> name = transaction.id.split('_');
    if (name.length == 2 && name[1] == 'Util') {
      name[0] += (locator.get<AppState>().roomProgress[0] - 1).toString();
      name[0] == matchingIdwithDoc(name[0]);
    }
    final app = locator.get<AppState>();
    final int txnCnt = app.txnCnt ?? 0;
    String txnName = '${name[0]}_T$txnCnt';
    _queueDataRowFields({
      '${session}_${txnName}_time': time,
      '${session}_${txnName}_type': transaction.type?.name,
      '${session}_${txnName}_desc': transaction.description,
      '${session}_${txnName}_resp': approve ? 'approved' : 'disputed',
      '${session}_${txnName}_pnt': point,
      '${session}_${txnName}_amt': transaction.amount,
      '${session}_${txnName}_bal': app.balance,
    });
    _queueUserIncrementFields({'TXN_CNT': 1});
    app.txnCnt = txnCnt + 1;

    final templateId = _transactionTemplateId(transaction);
    final rule = _txnTaskMapping[templateId];
    final String decision = approve ? 'approve' : 'dispute';

    String? difficulty;
    bool? success;
    if (rule != null) {
      difficulty = rule.difficulty;
      success = rule.successDecision == decision;
    } else {
      difficulty = _transactionDifficulty(transaction);
      success = _transactionSucceeded(transaction, approve);
      debugPrint('Missing TXN mapping for templateId: $templateId');
    }

    final Map<String, num> increments = {
      approve ? 'approvedTxns' : 'disputedTxns': 1,
    };
    if (difficulty != null && success != null) {
      increments.addAll(
        _taskOutcomeIncrements(
          difficulty: difficulty,
          success: success,
        ),
      );
    }
    _queueSessionSummaryIncrementFields(session, increments);
    // record data
    // _firestoreService.addDocument(
    //   path: FirestorePath.data(),
    //   data: Data(
    //     userId: locator.get<AuthMethods>().uid,
    //     actionType: ActionType.transaction,
    //     actionId: transaction.id,
    //     time: time,
    //     userResponse: approve,
    //     pointChange: point,
    //     balanceChange: transaction.amount,
    //   ).toJson(),
    //   batch: batch,
    // );
    batch.commit();
  }

  Future<void> resolveEvent(Event event, bool approve) async {
    await _ensureTaskMappingLoaded();
    final app = locator.get<AppState>();
    int session = locator.get<AppState>().session;
    DateTime time = DateTime.now();
    EventState newState;
    int point = 0;
    if (approve == true) {
      newState = EventState.approved;
      if (!event.isScam) {
        point = 1;
      }
    } else {
      newState = EventState.rejected;
      if (event.isScam) {
        point = 1;
      }
    }
    _queueDocumentUpdate(
      FirestorePath.event(event.id),
      Event.getJson(
        state: newState,
        timeActed: time,
      ),
    );
    _queueUserIncrementFields({'score': point});
    if (event.unhideOnResolved != null) {
      _queueDocumentUpdate(
        FirestorePath.event(event.unhideOnResolved!),
        Event.getJson(
          hidden: false,
          timeSent: DateTime.now(),
        ),
      );
    }
    for (model.Transaction transaction in app.transactions
        .where((element) => element.linkedEventId == event.id)
        .where((element) =>
            element.initialState == model.TransactionState.pending)
        .toList()) {
      _queueDocumentUpdate(
        FirestorePath.transaction(transaction.id),
        model.Transaction.getJson(
          currentState: model.TransactionState.actionNeeded,
          timeStamp: DateTime.now(),
          hidden: false,
        ),
      );
      transaction.currentState = model.TransactionState.actionNeeded;
      transaction.hidden = false;
      transaction.timeStamp = DateTime.now();
    }
    // new
    final int evntCnt = app.evntCnt ?? 0;
    String name = '${event.id.split('_')[0]}_E$evntCnt';
    _queueDataRowFields({
      '${session}_${name}_time': time,
      '${session}_${name}_name': event.title,
      '${session}_${name}_type': event.isScam ? 'scam' : 'legit',
      '${session}_${name}_resp': approve ? 'approved' : 'rejected',
      '${session}_${name}_pnt': point,
      '${session}_${name}_lvl': event.difficulty.name,
    });
    _queueUserIncrementFields({'EVNT_CNT': 1});
    app.evntCnt = evntCnt + 1;

    final templateId = _eventTemplateId(event);
    final rule = _eventTaskMapping[templateId];
    final String decision = approve ? 'yes' : 'no';

    String difficulty;
    bool success;
    if (rule != null) {
      difficulty = rule.difficulty;
      success = rule.successDecision == decision;
    } else {
      difficulty = event.difficulty.name;
      success = !event.isScam == approve;
      debugPrint('Missing EVNT mapping for templateId: $templateId');
    }

    final Map<String, num> increments = {
      approve ? 'eventYes' : 'eventNo': 1,
    };
    increments.addAll(
      _taskOutcomeIncrements(
        difficulty: difficulty,
        success: success,
      ),
    );
    _queueSessionSummaryIncrementFields(session, increments);
    // record data
    // _firestoreService.addDocument(
    //   path: FirestorePath.data(),
    //   data: Data(
    //     userId: locator.get<AuthMethods>().uid,
    //     actionType: ActionType.event,
    //     actionId: event.id,
    //     eventLevel: event.difficulty,
    //     userResponse: approve,
    //     time: time,
    //     pointChange: point,
    //   ).toJson(),
    //   batch: batch,
    // );
    event.state = newState;
    event.timeActed = time;
    app.onEventsChanged(List<Event>.from(app.deployedEvents));
    app.onTransactionsChanged(List<model.Transaction>.from(app.transactions));
  }

  // add new transaction data
  Future<void> addTransaction(model.Transaction transaction, var batch) async {
    String id = await _firestoreService.addDocument(
      myId: transaction.id != "" ? transaction.id : null,
      path: FirestorePath.transactions(),
      batch: batch,
      data: model.Transaction.getJson(
        transaction: transaction,
        timeStamp: DateTime.now(),
      ),
    );
    if (transaction.initialState != model.TransactionState.pending &&
        transaction.initialState != model.TransactionState.actionNeeded) {
      _firestoreService.updateDocument(
        path: FirestorePath.user(),
        batch: batch,
        data: model.User.getJson(addToBalance: transaction.amount),
      );
    }
    if (transaction.initialState != model.TransactionState.pending) {
      _firestoreService.updateDocument(
        path: FirestorePath.transaction(id),
        batch: batch,
        data: model.Transaction.getJson(
          currentState: transaction.initialState,
        ),
      );
    }
  }

  // mark event as read
  Future<void> markRead(Event event) async {
    final app = locator.get<AppState>();
    if (event.state == EventState.static) {
      for (model.Transaction transaction in app.transactions
          .where((element) => element.linkedEventId == event.id)
          .where((element) =>
              element.initialState == model.TransactionState.pending)
          .toList()) {
        _queueDocumentUpdate(
          FirestorePath.transaction(transaction.id),
          model.Transaction.getJson(
            currentState: model.TransactionState.actionNeeded,
            timeStamp: DateTime.now(),
            hidden: false,
          ),
        );
        transaction.currentState = model.TransactionState.actionNeeded;
        transaction.hidden = false;
        transaction.timeStamp = DateTime.now();
      }
    }
    if (event.type == EventType.receipt) {
      if (event.unhideOnResolved != null) {
        _queueDocumentUpdate(
          FirestorePath.event(event.unhideOnResolved!),
          Event.getJson(
            hidden: false,
            timeSent: DateTime.now(),
          ),
        );
      }
    }
    _queueDocumentUpdate(
      FirestorePath.event(event.id),
      Event.getJson(
        wasOpened: true,
      ),
    );
    event.wasOpened = true;
    app.onEventsChanged(List<Event>.from(app.deployedEvents));
    app.onTransactionsChanged(List<model.Transaction>.from(app.transactions));
  }

//Create new Data rows from old user data
  // Future<void> careful() async {
  //   String targetId = "yY94WDW8PpPzWgeDto2rhjpHOxt2";
  //   List<model.User> users = await FirestoreService.instance.collectionFuture(
  //     path: FirestorePath.users(),
  //     builder: (data) => model.User.fromSnap(data),
  //   );
  //   for (model.User user in users) {
  //     if (user.id.compareTo(targetId) == 0) {
  //       String dataId = await _firestoreService
  //           .addDocument(path: FirestorePath.newData(), data: {
  //         '0_User_Id': user.id,
  //         '0_Email': user.email,
  //       });
  //       await _firestoreService.updateDocument(
  //         path: FirestorePath.specUser(targetId),
  //         data: {'currDataId': dataId},
  //       );
  //       List<PurchasedItem> userItems = await FirestoreService.instance
  //           .collectionFuture(
  //               path: '${FirestorePath.users()}/${user.id}/purchased_items',
  //               builder: (data) => PurchasedItem.fromSnap(data));
  //       userItems.sort((a, b) => a.timeBought!.compareTo(b.timeBought!));
  //       List<model.Transaction> userTransactions =
  //           await FirestoreService.instance.collectionFuture(
  //         path: '${FirestorePath.users()}/${user.id}/transactions',
  //         builder: (data) => model.Transaction.fromSnap(data),
  //       );
  //       userTransactions.sort((a, b) => a.timeStamp!.compareTo(b.timeStamp!));
  //       List<Event> userEvents =
  //           await FirestoreService.instance.collectionFuture(
  //         path: '${FirestorePath.users()}/${user.id}/events',
  //         builder: (data) => Event.fromSnap(data),
  //       );
  //       userEvents.sort((a, b) => a.timeSent!.compareTo(b.timeSent!));

  //       for (PurchasedItem item in userItems) {
  //         String name = "";
  //         int session = 0;
  //         if (item.id.contains('~')) {
  //           int s = item.id.indexOf("~");
  //           List<String> parts = [
  //             item.id.substring(0, s),
  //             item.id.substring(s + 1)
  //           ];
  //           name =
  //               '${matchIdWithDoc('${getRoomInit(parts[0])}${parts[1]}')}_BUY';
  //           session = getRoomSession(parts[0]);
  //         }
  //         await _firestoreService.updateDocument(
  //           path: FirestorePath.newDataRow(dataId),
  //           data: {
  //             '${session}_${name}_time': item.timeBought,
  //             '${session}_${name}_item': item.name,
  //             '${session}_${name}_rank': item.priceRank,
  //             '${session}_${name}_cost': item.price,
  //           },
  //         );
  //       }

  //       int eNum = 0;
  //       String eName = '';
  //       String prevName = '';
  //       int prevSess = 0;
  //       int eSess = 0;
  //       for (Event event in userEvents) {
  //         if (event.timeActed == null) {
  //           List<String> s = event.id.split("~");
  //           eName = matchIdWithDoc('${getRoomInit(s[0])}${s[1]}');
  //           if (eName != prevName) {
  //             eNum = 0;
  //           }
  //           continue;
  //         }
  //         if (event.id.contains('~')) {
  //           List<String> s = event.id.split("~");
  //           eSess = getRoomSession(s[0]);
  //           if (eSess == -1) {
  //             eName = prevName;
  //             eSess = prevSess;
  //           } else {
  //             eName = matchIdWithDoc('${getRoomInit(s[0])}${s[1]}');
  //             if (eName != prevName) {
  //               eNum = 0;
  //             }
  //             prevName = eName;
  //             prevSess = eSess;
  //           }
  //           eName = '${eName}_E$eNum';
  //           eNum++;
  //           await _firestoreService.updateDocument(
  //             path: FirestorePath.newDataRow(dataId),
  //             data: {
  //               '${eSess}_${eName}_time': event.timeActed,
  //               '${eSess}_${eName}_name': event.title,
  //               '${eSess}_${eName}_type': event.isScam ? 'scam' : 'legit',
  //               '${eSess}_${eName}_resp': event.state == EventState.approved
  //                   ? 'approved'
  //                   : 'rejected',
  //               '${eSess}_${eName}_pnt': ((event.isScam &&
  //                           event.state == EventState.rejected) ||
  //                       (!event.isScam && event.state == EventState.approved))
  //                   ? 1
  //                   : 0,
  //               '${eSess}_${eName}_lvl': event.difficulty.name,
  //             },
  //           );
  //         }
  //       }
  //       await _firestoreService.updateDocument(
  //           path: FirestorePath.specUser(targetId), data: {'EVNT_CNT': eNum});

  //       int tNum = 0;
  //       num balance = 16000;
  //       int tSess = 1;
  //       String tName = '';
  //       prevName = '';
  //       prevSess = 1;
  //       for (model.Transaction transaction in userTransactions) {
  //         if (transaction.timeActed == null) {
  //           if (depositAmount.contains(transaction.amount)) {
  //             continue;
  //           }
  //           if (transaction.amount == 15000) {
  //             continue;
  //           }
  //           if (transaction.currentState != model.TransactionState.pending &&
  //               transaction.currentState !=
  //                   model.TransactionState.actionNeeded) {
  //             balance += transaction.amount;
  //           }
  //           continue;
  //         }
  //         if (transaction.id.contains('~')) {
  //           List<String> s = transaction.id.split("~");
  //           tSess = getRoomSession(s[0]);
  //           if (tSess == -1) {
  //             tName = prevName;
  //             tSess = prevSess;
  //           } else {
  //             tName = matchIdWithDoc('${getRoomInit(s[0])}${s[1]}');
  //             if (tName != prevName) {
  //               tNum = 0;
  //             }
  //             if (tSess != prevSess) {
  //               await _firestoreService.updateDocument(
  //                 path: FirestorePath.newDataRow(dataId),
  //                 data: {
  //                   '${prevSess}_${getSessionRoom(prevSess)}_End_time':
  //                       transaction.timeActed!
  //                           .subtract(const Duration(milliseconds: 500)),
  //                   '${prevSess}_${getSessionRoom(prevSess)}_End_bal': balance,
  //                 },
  //               );
  //               balance = depositAmount[tSess - 1];
  //               await _firestoreService.updateDocument(
  //                   path: FirestorePath.newDataRow(dataId),
  //                   data: {
  //                     '${tSess}_${getSessionRoom(tSess)}_Start_time':
  //                         transaction.timeActed!
  //                             .subtract(const Duration(milliseconds: 500)),
  //                     '${tSess}_${getSessionRoom(tSess)}_Start_bal': balance,
  //                   });
  //             }
  //             prevName = tName;
  //             prevSess = tSess;
  //           }
  //         } else {
  //           tName = prevName;
  //           tSess = prevSess;
  //         }
  //         tName = '${tName}_T$tNum';
  //         tNum++;
  //         if (tName == 'Bd1_T0') {
  //           await _firestoreService
  //               .updateDocument(path: FirestorePath.newDataRow(dataId), data: {
  //             '1_Bd_Start_time': transaction.timeActed!
  //                 .subtract(const Duration(milliseconds: 500)),
  //             '1_Bd_Start_bal': balance,
  //           });
  //         }
  //         await _firestoreService.updateDocument(
  //           path: FirestorePath.newDataRow(dataId),
  //           data: {
  //             '${tSess}_${tName}_time': transaction.timeActed,
  //             '${tSess}_${tName}_type': transaction.isScam ? 'scam' : 'legit',
  //             '${tSess}_${tName}_desc': transaction.description,
  //             '${tSess}_${tName}_resp':
  //                 transaction.currentState == model.TransactionState.approved
  //                     ? 'approved'
  //                     : 'disputed',
  //             '${tSess}_${tName}_pnt': ((transaction.isScam &&
  //                         transaction.currentState ==
  //                             model.TransactionState.disputed) ||
  //                     (!transaction.isScam &&
  //                         transaction.currentState ==
  //                             model.TransactionState.approved))
  //                 ? 1
  //                 : 0,
  //             '${tSess}_${tName}_amt': transaction.amount,
  //             '${tSess}_${tName}_bal': balance
  //           },
  //         );
  //         balance += transaction.amount;
  //         if (tName == 'Ga5_T1') {
  //           await _firestoreService
  //               .updateDocument(path: FirestorePath.newDataRow(dataId), data: {
  //             '6_Ga_End_time':
  //                 transaction.timeActed!.add(const Duration(milliseconds: 500)),
  //             '6_Ga_End_bal': balance,
  //           });
  //         }
  //       }
  //       await _firestoreService.updateDocument(
  //           path: FirestorePath.specUser(targetId), data: {'TXN_CNT': tNum});
  //     }
  //}
  //}
}
