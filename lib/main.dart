import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'transaction.dart';
import 'sheets.dart';
import 'finance_provider.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      routes: {
        '/': (context) => const LockScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}


class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  double _sliderValue = 5;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text("Lock Screen"))),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            child: Text("Hello"),
            onTap: () {
              setState(() {
                _sliderValue = 5;
              });
            },
          ),
          Center(
            child: Container(
              width: 500.0,
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 60,
                  activeTrackColor: Colors.black87,
                  inactiveTrackColor: Colors.black54,
                  thumbColor: Colors.white70,
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 25.0),
                ),
                child: Slider(
                  value: _sliderValue,
                  min: 0,
                  max: 100,
                  onChanged: (double value) {
                    if (value >= 85) {
                      setState(() {
                        _sliderValue = 100;
                      });
                      Navigator.of(context).pushReplacementNamed('/home');
                      return;
                    }
                    if (value > _sliderValue) {
                      setState(() {
                        _sliderValue = value;
                      });
                    }
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 50.0,
            ),
          ),
        ],
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
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimationDownToUp;
  late Animation<Offset> _offsetAnimationMiddleToUp;
  bool hasTapped = false;

  void _handleTap() {
    setState(() {
        hasTapped = true;
    });

    _controller.duration = const Duration(milliseconds: 500);

    _controller.reset();
    _controller.forward();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _offsetAnimationDownToUp = Tween<Offset>(
      begin: Offset(0.0, 20.0),
      end: Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _offsetAnimationMiddleToUp = Tween<Offset>(
      begin: Offset(0.0, 0.0),
      end: Offset(0.0, -20.0),
    ).animate(
        _controller,
    );
    
    Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          _controller.forward();
        }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: _handleTap,
          child: SlideTransition(
            position: !hasTapped ? _offsetAnimationDownToUp : _offsetAnimationMiddleToUp,
            child: const Text("Hello!"),
          ),
        ),
      ),
    );
  }
}
