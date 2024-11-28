import 'dart:typed_data';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Создаем приватный конструктор
  DatabaseHelper._internal();

  // Статический геттер для доступа к экземпляру класса
  static DatabaseHelper get instance => _instance;

  // Геттер для доступа к базе данных
  Future<Database> get myDatabase async {
    if (_database != null) return _database!;
    _database = await _initMyDatabase();
    return _database!;
  }

  // Инициализация базы данных
  Future<Database> _initMyDatabase() async {
    String path = join(await getDatabasesPath(), 'wish_list.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE my_wish_list (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          item TEXT NOT NULL,
          image TEXT
        );
      ''');

        await db.execute('''
        CREATE TABLE friends_wish_list (
          id INTEGER NOT NULL PRIMARY KEY,
          checkbox INTEGER DEFAULT 0 NOT NULL, 
          item TEXT NOT NULL,
          image TEXT
        );
      ''');
      },
    );
  }

  // Метод для добавления элемента в список желаемого
  Future<void> insertWishListItem(String item, Uint8List? image) async {
    final String imageName = '${DateTime.now().millisecondsSinceEpoch}.png';
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/$imageName';
    final db = await myDatabase;

    if (image != null) {
      final file = File(imagePath);
      await file.writeAsBytes(image);
      await db.insert('my_wish_list', {'item': item, 'image': imagePath});
    } else {
      await db.insert('my_wish_list', {'item': item});
    }
  }

  // Метод для добавления элемента в список желаемого
  Future<bool> findWishListItem(String item) async {
    final db = await myDatabase;
    final isFind =
        await db.query('my_wish_list', where: 'item = ?', whereArgs: [item]);

    if (isFind.length != 0) {
      return false;
    } else {
      return true;
    }
  }

  // Метод для получения элементов списка желаемого
  Future<List<Map<String, dynamic>>> fetchWishListItems() async {
    final db = await myDatabase;
    return await db.query('my_wish_list');
  }

  // Метод для удаления элемента из списка желаемого
  Future<void> deleteWishListItem(int id, String? image) async {
    if (image != null) {
      final file = File(image);

      // Проверяем, существует ли файл
      if (await file.exists()) {
        await file.delete(); // Удаляем файл
        print('Изображение удалено: $image');
      } else {
        print('Файл не найден: $image');
      }
    }

    final db = await myDatabase;
    await db.delete('my_wish_list', where: 'id = ?', whereArgs: [id]);
  }

  // Метод для получения элементов списка желаемого
  Future<List<Map<String, dynamic>>> fetchFriendWishListItems() async {
    final db = await myDatabase;
    return await db.query('friends_wish_list');
  }

  // Метод для добавления элемента в список желаемого
  Future<void> updateWishListItem(int id, int ckeckbox) async {
    final db = await myDatabase;
    await db.update('friends_wish_list', {'checkbox': ckeckbox},
        where: 'id = ?', whereArgs: [id]);
  }

  // Метод для добавления элемента в список желаемого
  Future<void> insertFriendWishListItem(String item, Uint8List? image) async {
    final String imageName = '${DateTime.now().millisecondsSinceEpoch}.png';
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/$imageName';
    final db = await myDatabase;

    if (image != null) {
      final file = File(imagePath);
      await file.writeAsBytes(image);
      await db.insert('friends_wish_list', {'item': item, 'image': imagePath});
    } else {
      await db.insert('friends_wish_list', {'item': item});
    }
  }

  // Метод для удаления элемента из списка желаемого
  Future<void> deleteFriendWishListItem() async {
    final db = await myDatabase;
    final list_of_images = await db.query('friends_wish_list',
        columns: ['image'], // Указываем только столбец image
        where: 'checkbox = ? AND image IS NOT NULL',
        whereArgs: [1]);
    for (var i = 0; i < list_of_images.length; i++) {
      String image = list_of_images[i]['image'] as String;
      final file = File(image);

      // Проверяем, существует ли файл
      if (await file.exists()) {
        await file.delete(); // Удаляем файл
        print('Изображение удалено: $image');
      } else {
        print('Файл не найден: $image');
      }
    }
    await db.delete(
      'friends_wish_list',
      where: 'checkbox = 1',
    );
  }

  // Метод для удаления элемента из списка желаемого
  Future<void> deleteFriendWishListOneItem(int id, String? image) async {
    if (image != null) {
      final file = File(image);

      // Проверяем, существует ли файл
      if (await file.exists()) {
        await file.delete(); // Удаляем файл
        print('Изображение удалено: $image');
      } else {
        print('Файл не найден: $image');
      }
    }

    final db = await myDatabase;
    await db.delete('friends_wish_list', where: 'id = ?', whereArgs: [id]);
  }
}
