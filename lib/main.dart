import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wellblue/pairing/bluetooth_scanner.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GetMaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
    title: "wellchain",
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BleScanner();
  }
}
