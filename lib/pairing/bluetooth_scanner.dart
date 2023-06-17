import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import '../../services/constantes.dart';



import 'dart:math' as math;



double timescan = 0;
bool onScan = false;
bool onFirst = true;

bool openContainer = false;


class BleScanner extends StatefulWidget {
  @override
  _BleScanner createState() => _BleScanner();
}

class _BleScanner extends State<BleScanner> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<ScanResult> scanResults = [];
  List<String> deviceIds = [];
  Map<String, String> deviceNames = {};

  @override
  void initState() {
    super.initState();
    scanDevices();
    loadDeviceData();

  }

  Future<void> stopScan()  async {
    FlutterBlue.instance.stopScan();
    Get.snackbar(
      animationDuration: const Duration(milliseconds: 500),
      margin: const EdgeInsets.all(10),
      "Devices Found", 
      "${scanResults.length} device",
      colorText: Colors.white,
    );
  }

  Future<void> scanDevices() async {
    flutterBlue.scanResults.listen((results) {
      setState(() {
        scanResults = results;
      });
    });
    flutterBlue.startScan(timeout: const Duration(seconds: 30),);
  }


  Future<void> loadDeviceData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedDeviceIds = prefs.getStringList('deviceIds');
    if (savedDeviceIds != null) {
      setState(() {
        deviceIds = savedDeviceIds;
        for (var deviceId in deviceIds) {
          String? deviceName = prefs.getString(deviceId);
          if (deviceName != null) {
            deviceNames[deviceId] = deviceName;
          }
        }
      });
    }
  }

  Future<void> saveDeviceData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('deviceIds', deviceIds);
    deviceNames.forEach((deviceId, deviceName) async {
      await prefs.setString(deviceId, deviceName);
    });
  }

  void addDevice(String deviceId, String deviceName) {
    setState(() {
      if (!deviceIds.contains(deviceId)) {
        deviceIds.add(deviceId);
        deviceNames[deviceId] = deviceName;
        saveDeviceData();
      }
    });
  }

  Future<void> showdialog(BuildContext context, String deviceId) async {
    String deviceName = deviceNames[deviceId] ?? '';
    TextEditingController textEditingController = TextEditingController(text: deviceName);
    AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      btnOkColor: const Color(0xFF37CEFF),
      btnCancelColor: const Color(0xFFFF5D78),
      animType: AnimType.rightSlide,
      padding: const EdgeInsets.all(10),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text("Give Adress A Name ?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: textEditingController,
              maxLength: 15,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Color(0xFF37CEFF)),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(10),
                hintText: "Name",
                suffixIcon: Icon(Icons.mode_edit_outlined),
                disabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(width: 2, color: Colors.grey)
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(width: 2, color: Color(0xFF37CEFF))
                )
              ),
            ),
          ),
        ],
      ),
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        String newName = textEditingController.text;
        if (newName.isNotEmpty) {
          addDevice(deviceId, newName);
          Constantes.device_name = newName;
          // Get.off(() => const DashbordHome());
        }
      },
    ).show();
  }


  @override
  void dispose() {
    flutterBlue.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(toolbarHeight: 70,
        backgroundColor: const Color(0xFF37CEFF),
        elevation: 0,
        title: const Text("Scan Page"),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFF37CEFF),
        body: Container(
          child: Stack(
            children: [
              Positioned(
                top: MediaQuery.of(context).size.width / 1.7,
                left: 10,
                right: 10,
                child: StreamBuilder<bool>(
                  stream: FlutterBlue.instance.isScanning,
                  initialData: false,
                  builder: (context, snapshot) {
                    if (snapshot.data!) {
                      return const RippleAnimation(
                          color: Colors.white,
                          repeat: true,
                          minRadius: 75,
                          duration: Duration(milliseconds: 6 * 300),
                          child: Icon(Icons.bluetooth, size: 130,color: Colors.white ,),
                        );
                    } else {
                      return const Icon(Icons.bluetooth, size: 130,color: Colors.white ,);
                    }
                  },
                  
                ),
              ),
              Positioned(
                top: 0,
                right: 20,
                child:  StreamBuilder<bool>(
                  stream: FlutterBlue.instance.isScanning,
                  initialData: false,
                  builder: (context, snapshot) {
                    if (snapshot.data!) {
                      return const CirculX();
                    } else {
                      return const Text('');
                    }
                  },
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height/8,
                right: 20,
                left: 20,
                bottom: MediaQuery.of(context).size.height/3.5,
                child: Container(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20
                    ), 
                    itemCount: scanResults.length,
                    itemBuilder: (context, index) {
                      ScanResult result = scanResults[index];
                      String deviceId = result.device.id.id;
                      String deviceName = deviceNames[deviceId] ?? 'UnKnoun';
                      bool isSaved = deviceIds.contains(deviceId);
                      return GestureDetector(
                          onTap: (){
                            showdialog(context, deviceId);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: const [
                                BoxShadow(
                                  offset: Offset(1, 1),
                                  blurRadius: 5,
                                  color: Colors.white54
                                )
                              ],
                              borderRadius: BorderRadius.circular(20),
                              color: const Color(0xFF37CEFF),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(deviceName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w300, fontSize: 18, fontStyle: FontStyle.italic),),
                                Text(deviceId, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),),
                              ],
                            ),
                            
                          ),
                        
                      );
                    },
                  ),
                ),
              ),

            Positioned(
                bottom: 50,
                right: 100,
                left: 100,
                child: StreamBuilder<bool>(
                  stream: FlutterBlue.instance.isScanning,
                  initialData: false,
                  builder: (c, snapshot) {
                    if (snapshot.data!) {
                      return OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30),),
                          side: const BorderSide(color: Colors.white, width: 2), 
                        ),
                        child: const Text("Turn Off", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),),
                        onPressed: (){
                          timescan = 0;
                          stopScan();
                          
                          setState(() {
                          });
                        },
                      );
                    } else {
                      return OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30),),
                          side: const BorderSide(color: Colors.white, width: 2), 
                        ),
                          child: const Text("Turn On", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),),
                          onPressed: () {
                            timescan = 1;
                            scanDevices();
                            setState(() {
                            });
                          });
                    }
                  },
                ),
                
              )
            ],
          ),
        ),
    );
  }
}




















// Paint

class CirculX extends StatefulWidget {
  const CirculX({super.key});

  @override
  State<CirculX> createState() => _CirculXState();
}

class _CirculXState extends State<CirculX> with SingleTickerProviderStateMixin {

  Animation<double> ?animtion;
  AnimationController ?animatedController;
  @override
  void initState() {
    super.initState();
    animatedController = AnimationController(duration: const Duration(seconds: 30),vsync: this,);
    final curantAnim = CurvedAnimation(parent: animatedController!, curve: Curves.easeInOutCubic);
    animtion = Tween<double>(begin: 0.0, end: 6.28).animate(curantAnim)..addListener(() {
      if(animatedController!.isCompleted) {
        onScan = false;
        onFirst = true;
        timescan = 0;
      }
      setState(() {
        
      });
    });
    animatedController!.animateTo(1);
  }
  @override
  void dispose() {
    animatedController!.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: 
                  [
                    CustomPaint(
          size: const Size(100, 100),
          painter: Prograss(animtion!.value , Colors.white, false),
                  ),
                  Positioned(
                    top: 38,
                    left: 30,
                    right: 30,
                    child: Text("${(animtion!.value/6.28 *100).round()}%", style: const TextStyle(color: Colors.white),),
                  )
                ],
      ),
    );
  }
}



class Prograss extends CustomPainter {
  bool isBac;
  double arc;
  Color procolor;
  Prograss(this.arc, this.procolor, this.isBac);
  @override
  void paint(Canvas canvas, Size size) {
    final rect = const Rect.fromLTRB(10,10, 80, 80);
    final staAn = -math.pi;
    final awipAngel = arc != null ? arc : math.pi;
    final usercenter = false;
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..color = procolor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
      if(isBac) {
        // paint.shader = gradient.createShader(rect);
      }
      canvas.drawArc(rect, staAn, awipAngel, usercenter, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

