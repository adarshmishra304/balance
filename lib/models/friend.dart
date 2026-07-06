class Friend {
  final int? id;
  final String name;
  final double totalBalance;

  Friend({this.id, required this.name, this.totalBalance = 0.0});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'totalBalance': totalBalance};
  }

  factory Friend.fromMap(Map<String, dynamic> map) {
    return Friend(
      id: map['id'],
      name: map['name'],
      totalBalance: map['totalBalance']?.toDouble() ?? 0.0,
    );
  }

  Friend copyWith({int? id, String? name, double? totalBalance}) {
    return Friend(
      id: id ?? this.id,
      name: name ?? this.name,
      totalBalance: totalBalance ?? this.totalBalance,
    );
  }
}
