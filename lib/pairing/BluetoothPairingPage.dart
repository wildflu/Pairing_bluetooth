import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';


class BluetoothPairingPage extends StatefulWidget {
  const BluetoothPairingPage({super.key});

  @override
  _BluetoothPairingPageState createState() => _BluetoothPairingPageState();
}

class _BluetoothPairingPageState extends State<BluetoothPairingPage> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  late BluetoothDevice selectedDevice;
  List<BluetoothDevice> devices = [];

  @override
  void initState() {
    super.initState();
    print("init state");
    startScan();
  }

  void startScan() {
    print("start scan debut -- stop");
    flutterBlue.startScan();
    print("start scan debut -- scanResult");
    flutterBlue.scanResults.listen((scanResultList) {
      setState(() {
        devices =
            scanResultList.map((scanResult) => scanResult.device).toList();
        print("start scan devices $devices");
      });
      selectedDevice = devices[0];
    });

    //flutterBlue.startScan();
  }

  void stopScan() {
    flutterBlue.stopScan();
  }

  Future<void> pairDevice() async {
    if (selectedDevice == null) {
      return;
    }

    // Retrieve the BluetoothDevice instance
    BluetoothDevice device = (await flutterBlue.scan().firstWhere(
            (scanResult) => scanResult.device.id == selectedDevice.id))
        as BluetoothDevice;

    // Pairing is handled by the platform's Bluetooth stack
    await device.connect(autoConnect: false).timeout(Duration(seconds: 4));

    // Display a success message
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('52'.tr),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('home page'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                return ListTile(
                  title: Text(device.name),
                  subtitle: Text(device.id.toString()),
                  onTap: () {
                    setState(() {
                      selectedDevice = device;
                      print("device == $selectedDevice");
                    });
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF37CEFF),
            ),
            onPressed: () => pairDevice(),
            child: const Text("hit on "),
            // MediaQuery.of(context).size.width - 50
          ),
        ],
      ),
    );
  }
}
