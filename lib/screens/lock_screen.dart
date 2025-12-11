import 'package:flutter/material.dart';
import '../config.dart';

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
      appBar: AppBar(title: Center(child: Text("Slide to unlock")), backgroundColor: Colors.black38),
      backgroundColor: Colors.black38,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 80,
                  activeTrackColor: lighten(primaryDarkBackground, 0.3),
                  inactiveTrackColor: lighten(primaryDarkBackground, 0.1),
                  thumbColor: Colors.white70,
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 35.0),
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
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.175,
            ),
          ),
        ],
      ),
    );
  }
}
