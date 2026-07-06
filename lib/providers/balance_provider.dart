import 'package:flutter/foundation.dart';
import '../database/db_helper.dart';
import '../models/friend.dart';
import '../models/transaction.dart';

class BalanceProvider with ChangeNotifier {
  List<Friend> _friends = [];
  bool _isLoading = false;

  List<Friend> get friends => [..._friends];
  bool get isLoading => _isLoading;

  double get totalOwedToMe {
    return _friends
        .where((f) => f.totalBalance > 0)
        .fold(0.0, (sum, f) => sum + f.totalBalance);
  }

  double get totalIOwe {
    return _friends
        .where((f) => f.totalBalance < 0)
        .fold(0.0, (sum, f) => sum + f.totalBalance.abs());
  }

  Future<void> fetchFriends() async {
    _isLoading = true;
    notifyListeners();

    _friends = await DatabaseHelper.instance.getAllFriends();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addFriend(String name) async {
    final newFriend = Friend(name: name);
    await DatabaseHelper.instance.insertFriend(newFriend);
    await fetchFriends();
  }

  Future<void> deleteFriend(int id) async {
    await DatabaseHelper.instance.deleteFriend(id);
    await fetchFriends();
  }

  Future<void> addTransaction(FriendTransaction transaction) async {
    await DatabaseHelper.instance.insertTransaction(transaction);
    await fetchFriends(); // Refresh balances in friend list
  }

  Future<void> deleteTransaction(int transactionId, int friendId) async {
    await DatabaseHelper.instance.deleteTransaction(transactionId, friendId);
    await fetchFriends();
  }

  Future<List<FriendTransaction>> getTransactions(int friendId) async {
    return await DatabaseHelper.instance.getTransactionsByFriend(friendId);
  }
}
