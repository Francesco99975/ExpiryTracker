import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../providers/expityItem.dart';

class DatabaseProvider {
  static const DATABASE_FILE = "expiry.db";
  static const TABLE_EXPIRY = "expiry_items";
  static const COLUMN_ID = "id";
  static const COLUMN_NAME = "name";
  static const COLUMN_EXPIRY_DATE = "expiry_date";

  DatabaseProvider._();
  static final db = DatabaseProvider._();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await createDatabase();

    return _database;
  }

  Future<Database> createDatabase() async {
    final dbPath = await getDatabasesPath();

    return await openDatabase(join(dbPath, DATABASE_FILE), version: 1,
        onCreate: (db, version) async {
      await db.execute("CREATE TABLE IF NOT EXISTS $TABLE_EXPIRY("
          "$COLUMN_ID TEXT PRIMARY KEY,"
          "$COLUMN_NAME TEXT NOT NULL,"
          "$COLUMN_EXPIRY_DATE TEXT NOT NULL);");
    });
  }

  Future<List<ExpiryItem>> getCredentials() async {
    final db = await database;

    var items = await db.query(TABLE_EXPIRY,
        columns: [COLUMN_ID, COLUMN_NAME, COLUMN_EXPIRY_DATE]);

    List<ExpiryItem> itemsList = [];
    items.forEach((itm) => itemsList.add(ExpiryItem.fromJson(itm)));

    return itemsList;
  }

  Future<ExpiryItem> insertCredential(ExpiryItem itm) async {
    final db = await database;
    await db.insert(TABLE_EXPIRY, itm.toMap());
    return itm;
  }

  Future<int> updateCredential(String id, ExpiryItem itm) async {
    final db = await database;
    return await db.update(TABLE_EXPIRY, itm.toMap(),
        where: "$COLUMN_ID = ?", whereArgs: [id]);
  }

  Future<int> deleteCredential(String id) async {
    final db = await database;
    return await db
        .delete(TABLE_EXPIRY, where: "$COLUMN_ID = ?", whereArgs: [id]);
  }
}
