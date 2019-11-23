// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// import 'package:flutter/material.dart';
import 'package:bluetooth_pc_control/Main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  testWidgets('Enable Bluetooth test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(BluetoothControlApplication());

    // Verify that our counter starts at 0.
    expect(find.text('Enable Bluetooth'), findsOneWidget);

    expect(find.text('Devices discovery and connection'), findsNothing);
    expect(find.text('Explore discovered devices'), findsNothing);
    expect(find.text('Connect to paired PC to Control'), findsNothing);
    

    // Tap the enable bluetooth and trigger a frame.
    await tester.tap(find.text('Enable Bluetooth'));
    await tester.pumpAndSettle();

    // Verify that bluetooth has been turned on    
    // expect(find.text('Devices discovery and connection'), findsOneWidget);
    // expect(find.text('Explore discovered devices'), findsOneWidget);
    // expect(find.text('Connect to paired PC to Control'), findsOneWidget);
  });
}
