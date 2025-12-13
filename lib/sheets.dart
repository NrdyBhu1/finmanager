import 'package:hive/hive.dart';
import 'transaction.dart';

part 'sheets.g.dart';

@HiveType(typeId: 1)
class Sheet {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  List<Transaction> transactions;
  @HiveField(3)
  double balance;

  Sheet({
    required this.id,
    required this.name,
    required this.transactions,
    required this.balance,
  });

  // Map<String, dynamic> toJson() => {
  //   'id': id,
  //   'name': name,
  //   'transactions': transactions.map((t) => t.toJson()).toList(),
  //   'balance': balance,
  // };

  // factory Sheet.fromJson(Map<String, dynamic> json) => Sheet(
  //    id: json['id'],
  //    name: json['name'],
  //    transactions: (json['transactions'] as List).map((t) => Transaction.fromJson(t)).toList(),
  //    balance: (json['balance'] as num).toDouble(),
  // );
}
