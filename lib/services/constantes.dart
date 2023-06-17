// import 'package:rudder_sdk_flutter/RudderClient.dart';
// import 'package:rudder_sdk_flutter/RudderConfig.dart';
// import 'package:rudder_sdk_flutter/RudderController.dart';
// import 'package:rudder_sdk_flutter/RudderLogger.dart';
// import 'package:rudder_sdk_flutter/RudderProperty.dart';
// import 'package:rudder_sdk_flutter/RudderTraits.dart';

class Constantes {
  final String service1 = "c786c856-8f6e-11ed-a1eb-0242ac120002";
  final String CHARACTERISTIC_UUID_RH = "c786cdf6-8f6e-11ed-a1eb-0242ac120002";
  final String CHARACTERISTIC_UUID_ACCELEROMETRE =
      "c786cc20-8f6e-11ed-a1eb-0242ac120002";
  final String CHARACTERISTIC_UUID_GYRO =
      "3fb74be6-8f94-11ed-a1eb-0242ac120002";

  static String device_name = "WellChain";

  final List<Map<String, dynamic>> contents = [
    {
      "type": "BPM",
      "characteristic": '0',
      "createdAt": DateTime.now().timeZoneName.toString()
    },
    {
      "type": "GL",
      "characteristic": '0',
      "createdAt": DateTime.now().timeZoneName.toString()
    },
    {
      "type": "ACC",
      "characteristic": '0',
      "createdAt": DateTime.now().timeZoneName.toString()
    },
  ];

  void addCharacteristic(type, value) {
    contents.add({
      "type": type,
      "characteristic": value,
      "createdAt": DateTime.now().timeZoneName.toString(),
    });

    /**
     * 
     * 
     */

    /**send characteristics to S3 Bucket*/
    // final RudderController rudderClient = RudderController.instance;
    // RudderLogger.init(RudderLogger.VERBOSE);
    // RudderConfigBuilder builder = RudderConfigBuilder();
    // builder.withDataPlaneUrl("https://ofpptwidakfvt.dataplane.rudderstack.com");
    // builder.withTrackLifecycleEvents(false);
    // rudderClient.initialize("2Lh25fqKTU7Z2FxYx5jR81szaOM",
    //     config: builder.build());
    // //var val = value.toString().split(",");
    // print("values to send  $value, $type");
    // //print("values to send  ${val[0]}, ${val[1]}, ${val[2]}");
    // RudderProperty property = RudderProperty();
    // property.put(type, value);
    // rudderClient.track("sensors_list", properties: property);
    /***
     * 
     */
  }

  String getvalueToScreen(int index) {
    if (contents[index]["characteristic"] == "0")
      return "--";
    else {
      return contents[index]["characteristic"]!;
    }
  }

  List<int> getValuesToScreen() {
    List<int> Liste = [];
    if (contents[contents.length - 1]["characteristic"] != "0") {
      var arr = contents[contents.length - 1]["characteristic"].split(',');
      for (var i in arr) {
        if (i == '') i = '0';
        Liste.add(int.parse(i));
      }
    } else {
      Liste = [0, 0, 0];
    }
    return Liste;
  }
}
