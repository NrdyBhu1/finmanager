import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import 'config.dart';
import 'transaction.dart';
import 'sheets.dart';
import 'finance_provider.dart';

import 'screens/lock_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(SheetAdapter());
  
  await Hive.openBox<Sheet>('sheetsBox');
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => FinanceProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fin Manager',
      theme: appTheme,
      routes: {
        '/': (context) => const LockScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

class AddTransactionForm extends StatefulWidget {
  const AddTransactionForm({super.key});

  @override
  State<AddTransactionForm> createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends State<AddTransactionForm> {
  final _formKey = GlobalKey<FormState>();

  String _type = 'outgoing';
  String? _description = null;
  double _amount = 0.00;
  DateTime _date = DateTime.now();

  String get _formattedDate => DateFormat('MMM dd, yyyy').format(_date);

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

      Provider.of<FinanceProvider>(context, listen: false).addTransaction(
        Transaction(id: uuid.v1(),
          amount: _amount,
          description: _description,
          date: _date,
          type: _type));

      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added Transaction')),
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
                      'Add Transaction',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.add),
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late FinanceProvider financeProvider;
  late Sheet currentSheet;

  @override
  Widget build(BuildContext context) {
    financeProvider = context.watch<FinanceProvider>();
    currentSheet = financeProvider.currentSheet!;
    
    return Scaffold(
      appBar: AppBar(title: Text("Recent Transactions")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: currentSheet.transactions.map((tran) {
              return TransactionCard(transaction: tran);
          }).toList(),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 60.0,
          child: ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return AddTransactionForm();
                },
              );
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0), 
              ),
              backgroundColor: Theme.of(context).colorScheme.secondary, 
              foregroundColor: Colors.white,
              elevation: 6.0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Create Transaction',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(width: 8),
                Icon(Icons.add),
              ],
            ),
          ),
        ),
      ),

    );

  }
  
}
