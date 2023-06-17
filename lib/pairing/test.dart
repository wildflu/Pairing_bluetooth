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
  late SharedPreferences _prefs;

  bool isFirstTime = true;
  String pinCode = "WellChain EPI_";

  @override
  void initState() {
    super.initState();
    initializeSharedPreferences();
    bluetoothStateStream = flutterBlue.state.asBroadcastStream();
    checkBluetoothState();
  }

  Future<void> initializeSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    // Initialize the stored value
    pinCode = _prefs.getString('pin') ?? '0000';

    setState(() {});
  }

  Future<void> changePIN() async {
    // Save a new value to SharedPreferences
    await _prefs.setString('pin', '6666');
    setState(() {
      pinCode = '6666';
    });
  }

  void checkBluetoothState() async {
    BluetoothState state = await flutterBlue.state.first;
    setState(() {
      bluetoothState = state;
    });
  }

  void increaseMTU(BluetoothDevice device) async {
    await device.requestMtu(185);
    var mtu = device.mtu.first;
    print("current value of MTU $mtu");
  }

  void searchDevices() {
    flutterBlue.scanResults.listen((results) {
      setState(() {
        scanResults = results;
        devices = scanResults.map((e) => e.device).toList();
      });
    });

    //flutterBlue.scanResults.listen((List<ScanResult> results) async {
    for (ScanResult result in scanResults) {
      //for (ScanResult result in results) {

      print("device ${result.device.name} trouve");
//_connectDevice(result.device, true);
    }
    // });
    flutterBlue.startScan();
  }

  //in first connection, send the pin code to EPI
  //else read characteristics
  void _connectDevice(BluetoothDevice device) async {
    flutterBlue.stopScan();
    try {
      await device.connect();
      //increaseMTU(device);
    } catch (e) {
      if (e.toString() != 'already_connected') {
        print(e.toString());
      }
    } finally {
      changePIN();
      _sendPIN(device);
      List<BluetoothService> services = await device.discoverServices();
      print("liste des services ${services.toString()}");
      // _getData(services);
    }
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

  bool startScan() {
    if (isScanning == true)
      return false;
    else {
      setState(() {
        scanResults.clear();
      });
      flutterBlue.startScan();
      return true;
    }
  }

  void stopScan() {
    setState(() {
      isScanning = false;
    });
    flutterBlue.stopScan();
  }

  Future<void> _sendPIN(BluetoothDevice device) async {
    print("Send Pin Process");
    changePIN();
    flutterBlue.stopScan();
    try {
      await device.connect();
      List<BluetoothService> services = await device.discoverServices();
      for (BluetoothService service in services) {
        if (service.uuid.toString() == '0000180a-0000-1000-8000-00805f9b34fb') {
          List<BluetoothCharacteristic> characteristics =
              service.characteristics;
          for (BluetoothCharacteristic characteristic in characteristics) {
            if (characteristic.uuid.toString() ==
                '00002a00-0000-1000-8000-00805f9b34fb') {
              List<int> bytes = utf8
                  .encode(pinCode); // Convertit la chaîne en tableau d'octets
              await characteristic.write(bytes); //, withoutResponse: true);
              print("Sending process terminated !!");
              break;
            }
          }
          break;
        }
      }
    } catch (e) {
      print(e.toString());
    }
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
          IconButton(
            onPressed: isScanning ? null : searchDevices,
            icon: const Icon(
              Icons.search,
              color: const Color(0xFF37CEFF),
            ),
          ),
          IconButton(
            onPressed: isScanning ? stopScan : null,
            icon: const Icon(
              Icons.search_off,
              color: const Color(0xFF37CEFF),
            ),
          ),
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
                  title: Text(scanResults[index].device.name),
                  subtitle: Text(scanResults[index].device.id.toString()),
                  onTap: () {
                    _connectDevice(scanResults[index].device);
                    print("codePIN ${_prefs.getString('pin')}");
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