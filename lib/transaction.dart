import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'config.dart';
import 'finance_provider.dart';

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
    return GestureDetector(
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return TransactionForm(isEditing: true, oldTransaction: widget.transaction);
          },
        );
      },
      child: Container(
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
      ),
    );
  }
}


class TransactionForm extends StatefulWidget {
  final Transaction? oldTransaction;
  final bool? isEditing;

  const TransactionForm({
      super.key,
      this.isEditing,
      this.oldTransaction
  });
  
  
  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();

  late String _id;
  late String _type;
  late String? _description;
  late double _amount;
  late DateTime _date;

  String get _formattedDate => DateFormat('MMM dd, yyyy').format(_date);

  @override
  void initState() {
    super.initState();

    if (widget.isEditing != null) {
      _id = widget.oldTransaction!.id;
      _type = widget.oldTransaction!.type;
      _description = widget.oldTransaction!.description;
      _amount = widget.oldTransaction!.amount;
      _date = widget.oldTransaction!.date;
    } else {
      _id = uuid.v1();
      _type = 'outgoing';
      _description = null;
      _amount = 0.00;
      _date = DateTime.now();
    
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _date) {
      setState(() {
          _date = picked;
      });
    }
  }

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Transaction newTransaction = Transaction(id: _id,
        amount: _amount,
        description: _description,
        date: _date,
        type: _type);

      if (widget.isEditing != null ) {
        Provider.of<FinanceProvider>(context, listen: false).editTransaction(widget.oldTransaction!, newTransaction);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction Edited!')),
        );
      } else { 
        Provider.of<FinanceProvider>(context, listen: false).addTransaction(newTransaction);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction Added!')),
        );
      }

      Navigator.of(context).pop();
    }
  }

  void _deleteTransaction(BuildContext context) {
    if (widget.isEditing != null) {
      Provider.of<FinanceProvider>(context, listen: false).deleteTransaction(widget.oldTransaction!);
      
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction Deleted!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Transaction details")),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[

              // Amount
              TextFormField(
                initialValue: _amount.toString(),
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  fontSize: 32.0,
                ),
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  filled: false,
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: accentGreen, width: 2.0),
                  ),

                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: secondaryGray, width: 1.0),
                  ),
                  hintText: "Amount",
                  suffix: Text('Bucks'),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                    
                  }

                  return null;
                },

                onSaved: (value) {
                  _amount = double.parse(value!);
                },
              ),
              
              const SizedBox(height: 30),
              
              // Type
              DropdownButtonFormField<String> (
                value: _type,

                items: const [
                  DropdownMenuItem<String>(
                    value: 'outgoing',
                    child: Text('Debit'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'incoming',
                    child: Text('Credit'),
                  ),
                ],

                validator: (value) {
                  if (value == null) {
                    return 'Please select a transaction type';
                  }
                  return null;
                },

                onSaved: (value) {
                  _type = value!;
                },

                onChanged: (String? newValue) {
                  setState(() {
                      _type = newValue!;
                  });
                },
                
              ),
              
              const SizedBox(height: 30),

              // Description
              if (_type == 'outgoing')
              TextFormField(
                initialValue: _description ?? '',
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: "Description",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                    
                  }

                  return null;
                },

                onSaved: (value) {
                  _description = value;
                },
              ),
              const SizedBox(height: 30),

              // Date Picker
              TextFormField(
                controller: TextEditingController(text: _formattedDate),

                readOnly: true,

                onTap: () => _selectDate(context),

                decoration: InputDecoration(
                  hintText: 'Select a Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a date.';
                  }
                  return null;
                },
              ),
              
              Spacer(),
              
              ElevatedButton(
                onPressed: () {
                  _submitForm(context);
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0), 
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Submit Transaction',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.check_circle),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),

              if (widget.isEditing != null)
              ElevatedButton(
                onPressed: () {
                  _deleteTransaction(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: negativeRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0), 
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Delete Transaction',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.delete),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
