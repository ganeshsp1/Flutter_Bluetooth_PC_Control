import 'package:flutter/material.dart';

import './MainPage.dart';

void main() => runApp(new BluetoothControlApplication());

class BluetoothControlApplication extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainPage()
    );
  }
}
