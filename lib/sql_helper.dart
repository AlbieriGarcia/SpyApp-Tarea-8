import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:image_picker/image_picker.dart';

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""
      CREATE TABLE items(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        titulo TEXT,
        descripcion TEXT,
        foto TEXT,
        audio TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    """);
  }

  // Albieri 2022-0004

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'dbstech.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  static Future<int> createItem(String titulo , String? descripcion, String? foto, String? audio) async {
    final db = await SQLHelper.db();

    final data = {'titulo': titulo ,'descripcion': descripcion, 'foto': foto, 'audio': audio};
    final id = await db.insert('items', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    return db.query('items', orderBy: "id");
  }

  static Future<int> updateItem(
      int id, String titulo, String? descripcion, String? foto, String? audio) async {
    final db = await SQLHelper.db();

    final data = {
      'titulo': titulo,
      'descripcion': descripcion,
      'foto': foto,
      'audio': audio,
      'createdAt': DateTime.now().toString()
    };
    final result =
        await db.update('items', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<void> deleteItem(int id) async {
    final db = await SQLHelper.db();

    try {
      await db.delete("items", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Algo salio mal cuando se intento borrar este item: $err");
    }
  }

  static Future<void> deleteAllItems() async {
    final db = await SQLHelper.db();
    await db.delete('items');
  }
}
