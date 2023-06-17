import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';


class BluetoothScanPage extends StatefulWidget {
  const BluetoothScanPage({Key? key}) : super(key: key);

  @override
  _BluetoothScanPageState createState() => _BluetoothScanPageState();
}

class _BluetoothScanPageState extends State<BluetoothScanPage> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothState bluetoothState = BluetoothState.unknown;
  late Stream<BluetoothState> bluetoothStateStream;
  List<ScanResult> scanResults = [];
  bool isScanning = false;
  late BluetoothDevice selectedDevice;
  List<BluetoothDevice> devices = [];
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  bool isFirstTime = true;
  String pinCode = "WellChain EPI_";

  @override
  void initState() {
    super.initState();
    bluetoothStateStream = flutterBlue.state.asBroadcastStream();
    checkBluetoothState();

    flutterBlue.scanResults.listen((results) {
      setState(() {
        scanResults = results;
        devices = scanResults.map((e) => e.device).toList();
      });
    });
    flutterBlue.startScan();
  }

  Future<void> initializeSharedPreferences() async {
    final SharedPreferences prefs = await _prefs;

    // Initialisez les valeurs par défaut pour chaque clé
    prefs.setBool('isFirst', true);
    prefs.setString('codePin', "");
    prefs.setString('nameDevice', "");
  }

  void checkBluetoothState() async {
    BluetoothState state = await flutterBlue.state.first;
    setState(() {
      bluetoothState = state;
    });
  }

  void updateItem(int index, String newValue) async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      prefs.setString('codePin', scanResults[index].device.id.toString());
      prefs.setString('nameDevice', newValue);
    });
  }

  void showActivationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bluetooth Activation'),
        content: Text('Please activate Bluetooth on your device.'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void showUpdateDialog(BuildContext context, int index) {
    String currentValue = scanResults[index].device.id.toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController textEditingController =
            TextEditingController(text: currentValue);

        return AlertDialog(
          title: Text('Nouveau nom '),
          content: TextField(
            controller: textEditingController,
            decoration: InputDecoration(hintText: 'Nouvelle valeur'),
          ),
          actions: [
            ElevatedButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Mettre à jour'),
              onPressed: () {
                String newValue = textEditingController.text;
                if (newValue.isNotEmpty) {
                  updateItem(index, newValue);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    initializeSharedPreferences();
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuration'),
      ),
      body: Column(
        children: [
          StreamBuilder<BluetoothState>(
            stream: bluetoothStateStream,
            initialData: BluetoothState.unknown,
            builder: (context, snapshot) {
              BluetoothState bluetoothState = snapshot.data!;
              bluetoothState = bluetoothState;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (bluetoothState == BluetoothState.off) {
                        showActivationDialog();
                      }
                    },
                    child: Text(
                      (bluetoothState == BluetoothState.off)
                          ? 'Activate Bluetooth'
                          : '',
                    ),
                  ),
                ],
              );
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: scanResults.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text("${scanResults[index].device.id}"),
                  subtitle: Text(scanResults[index].device.id.toString()),
                  onTap: () {
                    //_sendPIN(scanResults[index].device);
                    showUpdateDialog(context, index);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void disableBluetooth() {}
}


//  Future<void> pairDevice() async {
//     if (selectedDevice == null) {
//       return;
//     }

//     // Retrieve the BluetoothDevice instance
//     BluetoothDevice device = (await flutterBlue.scan().firstWhere(
//             (scanResult) => scanResult.device.id == selectedDevice.id))
//         as BluetoothDevice;

//     // Pairing is handled by the platform's Bluetooth stack
//     await device.connect(autoConnect: false).timeout(Duration(seconds: 4));

//     // Display a success message
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text('52'.tr),
//     ));
//   }