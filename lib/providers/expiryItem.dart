import 'package:flutter/foundation.dart';
import '../db/database_provider.dart';

class ExpiryItem with ChangeNotifier {
  String id;
  String name;
  DateTime expiryDate;

  ExpiryItem(
      {@required this.id, @required this.name, @required this.expiryDate});

  ExpiryItem.fromJson(Map<String, dynamic> jsonData) {
    this.id = jsonData[DatabaseProvider.COLUMN_ID];
    this.name = jsonData[DatabaseProvider.COLUMN_NAME];
    this.expiryDate =
        DateTime.parse(jsonData[DatabaseProvider.COLUMN_EXPIRY_DATE]);
  }

  Map<String, dynamic> toMap() {
    return {
      DatabaseProvider.COLUMN_ID: this.id,
      DatabaseProvider.COLUMN_NAME: this.name,
      DatabaseProvider.COLUMN_EXPIRY_DATE: this.expiryDate.toString()
    };
  }
}