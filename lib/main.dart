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
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '${currentSheet.balance.toString()} bucks',
                style: TextStyle(
                  fontSize: 35.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Expanded(
              child: ListView(
                children: currentSheet.transactions.map((tran) {
                    return TransactionCard(transaction: tran);
                }).toList(),
              ),
            ),
          ],
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
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return TransactionForm();
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
