import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/friend.dart';
import '../models/transaction.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('balance_manager.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE friends (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        totalBalance REAL NOT NULL DEFAULT 0.0
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        friend_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        date TEXT NOT NULL,
        type INTEGER NOT NULL,
        FOREIGN KEY (friend_id) REFERENCES friends (id) ON DELETE CASCADE
      )
    ''');
  }

  // Friend Operations
  Future<int> insertFriend(Friend friend) async {
    final db = await instance.database;
    return await db.insert('friends', friend.toMap());
  }

  Future<List<Friend>> getAllFriends() async {
    final db = await instance.database;
    final result = await db.query('friends', orderBy: 'name ASC');
    return result.map((json) => Friend.fromMap(json)).toList();
  }

  Future<int> deleteFriend(int id) async {
    final db = await instance.database;
    return await db.delete('friends', where: 'id = ?', whereArgs: [id]);
  }

  // Transaction Operations
  Future<int> insertTransaction(FriendTransaction transaction) async {
    final db = await instance.database;
    final id = await db.insert('transactions', transaction.toMap());

    // Update friend balance
    await _updateFriendBalance(transaction.friendId);

    return id;
  }

  Future<List<FriendTransaction>> getTransactionsByFriend(int friendId) async {
    final db = await instance.database;
    final result = await db.query(
      'transactions',
      where: 'friend_id = ?',
      whereArgs: [friendId],
      orderBy: 'date DESC',
    );
    return result.map((json) => FriendTransaction.fromMap(json)).toList();
  }

  Future<int> deleteTransaction(int transactionId, int friendId) async {
    final db = await instance.database;
    final result = await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [transactionId],
    );

    // Update friend balance
    await _updateFriendBalance(friendId);

    return result;
  }

  Future<void> _updateFriendBalance(int friendId) async {
    final db = await instance.database;

    final transactions = await getTransactionsByFriend(friendId);
    double balance = 0.0;

    for (var tx in transactions) {
      if (tx.type == TransactionType.given) {
        balance += tx.amount;
      } else {
        balance -= tx.amount;
      }
    }

    await db.update(
      'friends',
      {'totalBalance': balance},
      where: 'id = ?',
      whereArgs: [friendId],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
