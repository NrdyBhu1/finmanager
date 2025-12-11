import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
    financeProvider = Provider.of<FinanceProvider>(context);
    currentSheet = financeProvider.currentSheet!;
    
    return Scaffold(
      appBar: AppBar(title: Text("Recent Transactions"), backgroundColor: primaryDarkBackground),
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
              print('Wide button pressed!');
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
  
  // late AnimationController _controller;
  // late Animation<Offset> _offsetAnimationDownToUp;
  // late Animation<Offset> _offsetAnimationMiddleToUp;
  // bool hasTapped = false;

  // void _handleTap() {
  //   setState(() {
  //       hasTapped = true;
  //   });

  //   _controller.duration = const Duration(milliseconds: 500);

  //   _controller.reset();
  //   _controller.forward();
  // }

  // void _handleLongPress() {
  //   print("hello!");
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   _controller = AnimationController(
  //     vsync: this,
  //     duration: const Duration(seconds: 2),
  //   );

  //   _offsetAnimationDownToUp = Tween<Offset>(
  //     begin: Offset(0.0, 20.0),
  //     end: Offset(0.0, 0.0),
  //   ).animate(
  //     CurvedAnimation(
  //       parent: _controller,
  //       curve: Curves.elasticOut,
  //     ),
  //   );

  //   _offsetAnimationMiddleToUp = Tween<Offset>(
  //     begin: Offset(0.0, 0.0),
  //     end: Offset(0.0, -20.0),
  //   ).animate(
  //       _controller,
  //   );
    
  //   Future.delayed(const Duration(seconds: 1), () {
  //       if (mounted) {
  //         _controller.forward();
  //       }
  //   });
  // }

  // @override
  // void dispose() {
  //   _controller.dispose();
  //   super.dispose();
  // }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: Center(
  //       child: GestureDetector(
  //         onLongPress: _handleLongPress,
  //         // onTap: _handleTap,  
  //         child: SlideTransition(
  //           position: !hasTapped ? _offsetAnimationDownToUp : _offsetAnimationMiddleToUp,
  //           child: const Text(
  //             "Hello!",
  //             style: TextStyle(
  //               fontSize: 32.0,
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
