import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'config.dart';

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


class TransactionCard extends StatefulWidget {
  final Transaction transaction;

  const TransactionCard({super.key, required this.transaction});

  State<TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<TransactionCard> {
  late double amount;
  late DateTime date;
  late Color cardColor;
  late IconData cardIcon;

  @override
  void initState() {
    super.initState();

    if (widget.transaction.type == 'incoming') {
      cardColor = accentGreen;
      cardIcon = Icons.south_west;
    } else {
      cardColor = negativeRed;
      cardIcon = Icons.north_east;
    }
    amount = widget.transaction.amount;
    date = widget.transaction.date;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.all(5.0),
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        color: lighten(primaryDarkBackground, 0.1),
        borderRadius: BorderRadiusGeometry.all(Radius.circular(10)),
        boxShadow: [
          const BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 8.0,
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(cardIcon, color: cardColor, size: 24.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (widget.transaction.description != null)
                Text(
                widget.transaction.description!,
                style: TextStyle(fontSize: 24.0, color: Colors.white),
              ),
              Text(
                DateFormat("MMM dd, yyyy").format(date),
                style: TextStyle(fontSize: 14.0, color: Colors.white70),
              ),
            ],
          ),
          Spacer(),
          Transform.translate(
            offset: Offset(0.0, 7.5),
            child: Text(
              '$amount bucks',
              style: TextStyle(
                fontSize: 18.0,
                color: cardColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
