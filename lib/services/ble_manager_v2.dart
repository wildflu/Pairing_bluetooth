import 'package:flutter/cupertino.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'constantes.dart';

class BLEManagmentV2 extends ChangeNotifier {
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  List<int> value_BPM = [];
  List<int> value_GL = [];
  List<int> value_ACC = [];

  Constantes constantes = new Constantes();

  void increaseMTU(BluetoothDevice device) async {
    await device.requestMtu(185);
    var mtu = device.mtu.first;
  }

  void searchDevices() {
    flutterBlue.scanResults.listen((List<ScanResult> results) async {
      for (ScanResult result in results) {
        if (result.device.name == Constantes.device_name) {
          print("device ${result.device.name} trouve");
          _connectDevice(result.device);
        }
      }
    });
    flutterBlue.startScan();
  }

  void _connectDevice(BluetoothDevice device) async {
    flutterBlue.stopScan();
    try {
      await device.connect();
      // increaseMTU(device);
    } catch (e) {
      if (e.toString() != 'already_connected') {
        print(e.toString());
      }
    } finally {
      List<BluetoothService> services = await device.discoverServices();
      print("liste des services ${services.toString()}");
      _getData(services);
    }
  }

  Future<bool> _getData(List<BluetoothService> services) async {
    for (BluetoothService s in services) {
      int i = 0;
      if (s.uuid.toString() == constantes.service1) {
        var characteristics = s.characteristics;
        for (BluetoothCharacteristic c in characteristics) {
          if ((c.uuid.toString() == constantes.CHARACTERISTIC_UUID_RH) &&
              (c.properties.read)) {
            print(
                "characteristique HR et GLYCEMIE trouve valeur ==  ${c.value.toString()} ");
            await Future.delayed(new Duration(seconds: 2), () {
              getValue(c);
            });
          }
          if ((c.uuid.toString() ==
                  constantes.CHARACTERISTIC_UUID_ACCELEROMETRE) &&
              (c.properties.read)) {
            print(
                "characteristique ACCELEROMETRE trouve valeur ==  ${c.value.toString()} ");
            //getValue(c);
            await Future.delayed(new Duration(seconds: 2), () {
              getValue(c);
            });
          }
          if ((c.uuid.toString() == constantes.CHARACTERISTIC_UUID_GYRO) &&
              (c.properties.read)) {
            print(
                "characteristique GYRO trouve valeur ==  ${c.value.toString()} ");
            //getValue(c);
            await Future.delayed(new Duration(seconds: 2), () {
              getValue(c);
            });
          }
        }
      }
    }
    return false;
  }

  void getValue(BluetoothCharacteristic c) async {
    try {
      await c.setNotifyValue(true);
      c.value.listen((value) {
        if (c.uuid.toString() == constantes.CHARACTERISTIC_UUID_RH) {
          value_BPM = value;
          print("valeur BPM changée : $value ");
        } else if (c.uuid.toString() == constantes.CHARACTERISTIC_UUID_GYRO) {
          value_GL = value;
          print("valeur Sugar changée : ${value} ");
        } else if (c.uuid.toString() ==
            constantes.CHARACTERISTIC_UUID_ACCELEROMETRE) {
          value_ACC = value;
          print("valeur ACCELEROMETRE changée : ${value} ");
        }
        notifyListeners();
      });
    } catch (e) {
      print("erreur lors de setNotifyValue ${e.toString()}");
    }
  }

  List<int> get value_rh => value_BPM;
  List<int> get value_gl => value_GL;
  List<int> get value_acc => value_ACC;
}
