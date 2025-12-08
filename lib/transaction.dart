import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class Transaction {
  @HiveField(0)
  String id;
  @HiveField(1)
  double amount;
  @HiveField(2)
  String? description;
  @HiveField(3)
  DateTime date;
  @HiveField(4)
  String type;

  Transaction({
      required this.id,
      required this.amount,
      this.description,
      required this.date,
      required this.type
  });

  // Map<String, dynamic> toJson() => {
  //   'id': id,
  //   'amount': amount,
  //   'description': description,
  //   'date': date.toIso8601String(),
  //   'type': type
  // };

  // factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
  //   id: json['id'],
  //   amount: (json['amount'] as num).toDouble(),
  //   description: json['description'],
  //   date: DateTime.parse(json['date']),
  //   type: json['type'],
  // );
}
