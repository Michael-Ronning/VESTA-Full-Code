import 'package:projectmercury/resources/auth_methods.dart';
import 'package:projectmercury/resources/locator.dart';

class FirestorePath {
  static String users() => 'users';
  static String user() => 'users/${locator.get<AuthMethods>().uid}';
  static String specUser(String id) => 'users/$id';

  static String transactions() =>
      'users/${locator.get<AuthMethods>().uid}/transactions';
  static String transaction(String transactionId) =>
      'users/${locator.get<AuthMethods>().uid}/transactions/$transactionId';

  static String events() => 'users/${locator.get<AuthMethods>().uid}/events';
  static String event(String eventId) =>
      'users/${locator.get<AuthMethods>().uid}/events/$eventId';

  static String items() =>
      'users/${locator.get<AuthMethods>().uid}/purchased_items';
  static String item(String itemId) =>
      'users/${locator.get<AuthMethods>().uid}/purchased_items/$itemId';

  static String data() => 'data';
  static String specData(String dataId) => 'data/$dataId';

  static String newData() => 'newData';
  static String newDataRow(String dataId) => 'newData/$dataId';

    static String sessionSummaries() => 'sessionSummaries';
    static String sessionSummary(String uid, int session) =>
            'sessionSummaries/${uid}_S$session';
}
