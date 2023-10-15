// import 'dart:async';
// import 'dart:typed_data';
//
// import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
// import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'display.dart';
// import 'home.dart';
//
// import 'package:flutter/material.dart';
//
// import 'mapscreen.dart';
//
//
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await PeripheralManager.instance.setUp();
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//
//     return MaterialApp(
//       title: 'AidConnect',
//       theme: ThemeData(
//         brightness: Brightness.dark,
//       ),
//
//       home: MyHomePage(title: 'AidConnect'),
//     );
//   }
// }
//
