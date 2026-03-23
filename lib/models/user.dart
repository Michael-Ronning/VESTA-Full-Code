import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class User {
  final String id;
  String? currDataId;
  int score;
  num balance;
  int session;
  String? email;
  int txnCnt;
  int evntCnt;
  int mocaCnt;
  User({
    required this.id,
    this.currDataId,
    this.score = 0,
    this.balance = 0,
    this.session = 1,
    this.email,
    this.txnCnt = 0,
    this.evntCnt = 0,
    this.mocaCnt = 0,
  });

  Map<String, dynamic> toJson() {
    return ({
      'id': id,
      'currDataId': currDataId,
      'score': score,
      'balance': balance,
      'session': session,
      'email': email,
      'txnCnt': txnCnt,
      'evntCnt': evntCnt,
      'MOCA_CNT': mocaCnt,
    });
  }

  static User fromSnap(Map<String, dynamic> snap) {
    return User(
      id: snap['id'] ?? '',
      email: snap['email'] ?? '',
      currDataId: snap['currDataId'],
      score: snap['score'] ?? 0,
      balance: snap['balance'] ?? 0,
      session: snap['session'] ?? 1,
      txnCnt: snap['TXN_CNT'] ?? 0,
      evntCnt: snap['EVNT_CNT'] ?? 0,
      mocaCnt: snap['MOCA_CNT'] ?? 0,
    );
  }

  static Map<String, dynamic> getJson({
    int? score,
    num? balance,
    int? session,
    int? addToScore,
    num? addToBalance,
    int? addToSession,
  }) {
    Map<String, dynamic> data = {};
    if (score != null) {
      data.addAll({'score': score});
    }
    if (balance != null) {
      data.addAll({'balance': balance});
    }
    if (session != null) {
      data.addAll({'session': session});
    }
    if (addToScore != null) {
      data.addAll({'score': FieldValue.increment(addToScore)});
      debugPrint("Score change: $addToScore");
    }
    if (addToBalance != null) {
      data.addAll({'balance': FieldValue.increment(addToBalance)});
      debugPrint("Balance change: $addToBalance");
    }
    if (addToSession != null) {
      data.addAll({'session': FieldValue.increment(addToSession)});
    }
    return data;
  }
}
