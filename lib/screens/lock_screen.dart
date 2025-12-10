import 'package:flutter/material.dart';

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
