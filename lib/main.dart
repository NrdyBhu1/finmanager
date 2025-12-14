import 'dart:io';
import 'dart:typed_data'; // Required for Uint8List
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart'; // Or use share_plus
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'config.dart';
import 'transaction.dart';
import 'sheets.dart';
import 'finance_provider.dart';

import 'monthly_chart.dart';

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


Future<Uint8List> generateTransactionPdf(List<Transaction> transactions) async {
  final pdf = pw.Document();

  // Define the table headers
  final headers = ['Date', 'Description', 'Amount'];

  // Map your Transaction objects to a list of lists (table rows)
  final data = transactions.map((t) {
    return [
      DateFormat('yyyy-MM-dd').format(t.date),
      t.description ?? '',
      '${t.type == 'incoming' ? '+' : '-'}${t.amount.toStringAsFixed(2)}',
    ];
  }).toList();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(level: 0, text: 'Monthly Transaction Report'),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: headers,
              data: data,
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerRight,
            ),
          ],
        );
      },
    ),
  );

  return pdf.save(); // Returns the PDF as byte data
}

Future<void> exportAndOpenFile(Uint8List pdfBytes, String sheetName) async {
  try {
    final output = await getTemporaryDirectory();
    
    final fileName = '${sheetName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${output.path}/$fileName');
    
    await file.writeAsBytes(pdfBytes);

    final result = await OpenFilex.open(file.path);
    
    if (result.type != ResultType.done) {
      print('Could not open file: ${result.message}');
    }

  } catch (e) {
    print('Error during PDF export: $e');
  }
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

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late FinanceProvider financeProvider;
  late Sheet currentSheet;

  void onExportButtonPressed(BuildContext context) async {

    if (currentSheet == null) {
      return; 
    }

    final transactions = currentSheet!.transactions;
    final sheetName = currentSheet!.name;

    final pdfBytes = await generateTransactionPdf(transactions);
    
    await exportAndOpenFile(pdfBytes, sheetName); 
  }

  @override
  Widget build(BuildContext context) {
    financeProvider = context.watch<FinanceProvider>();
    currentSheet = financeProvider.currentSheet!;

    return Scaffold(
      appBar: AppBar(
        title: Text("Recent Transactions"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save_as),
            tooltip: 'Export sheet',
            onPressed: () { onExportButtonPressed(context); },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '${currentSheet.balance.toString()} bucks',
                style: TextStyle(fontSize: 35.0, fontWeight: FontWeight.bold),
              ),
            ),

            MonthlyDebitChart(),

            Expanded(
              child: ListView(
                children: currentSheet.transactions.map((tran) {
                  return TransactionCard(transaction: tran);
                }).toList(),
              ),
            ),
            SizedBox(height: 90.0),
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
                Text('Create Transaction', style: TextStyle(fontSize: 18)),
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
