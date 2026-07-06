enum TransactionType {
  given, // Lending money (Green/Positive)
  received, // Borrowing money (Red/Negative)
}

class FriendTransaction {
  final int? id;
  final int friendId;
  final double amount;
  final String description;
  final DateTime date;
  final TransactionType type;

  FriendTransaction({
    this.id,
    required this.friendId,
    required this.amount,
    required this.description,
    required this.date,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'friend_id': friendId,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'type': type.index, // 0 for given, 1 for received
    };
  }

  factory FriendTransaction.fromMap(Map<String, dynamic> map) {
    return FriendTransaction(
      id: map['id'],
      friendId: map['friend_id'],
      amount: map['amount']?.toDouble() ?? 0.0,
      description: map['description'] ?? '',
      date: DateTime.parse(map['date']),
      type: TransactionType.values[map['type']],
    );
  }
}
