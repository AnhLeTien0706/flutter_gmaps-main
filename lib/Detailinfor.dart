import 'package:flutter/material.dart';

import 'MQTT.dart';
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MyInfor extends StatefulWidget {
//  const MyInfor({Key? key}) : super(key: key);
   const MyInfor({super.key, required this.index});
   final String index;

  @override
  State<MyInfor> createState() => _MyInforState();
}

class _MyInforState extends State<MyInfor> {
  bool status = false;
  bool status1 = false;

  Widget VehicleStatus() {
    return Column(children: <Widget>[
      const Divider(),
      Row(
        children: [
          Flexible(
              flex: 10,
              child: Container(
                  alignment: Alignment.center,
                  child: Container(
                      width: 30,
                      height: 30,
                      child: Image.asset('assets/taxi.png')))),
          Flexible(
              flex: 30,
              child: Container(
                alignment: Alignment.centerLeft,
                child: const Text(
                  ' Status:',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              )),
          Flexible(
              flex: 60,
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${Status_arr[int.parse(widget.index)]}',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              )),
        ],
      ),
      const Divider(),
      Row(
        children: [
          Flexible(
              flex: 10,
              child: Container(
                  alignment: Alignment.center,
                  child: Container(
                      width: 30,
                      height: 30,
                      child: Image.asset('assets/speed.png')))),
          Flexible(
              flex: 30,
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  ' Speed:',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              )),
          Flexible(
              flex: 60,
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${Speed_arr[int.parse(widget.index)]} km/h',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              )),
        ],
      ),
      const Divider(),
      Row(
        children: [
          Flexible(
              flex: 10,
              child: Container(
                  alignment: Alignment.center,
                  child: Container(
                      width: 30,
                      height: 30,
                      child: Image.asset('assets/daytime.png')))),
          Flexible(
              flex: 30,
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  ' Time:',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              )),
          Flexible(
              flex: 60,
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${Time_arr[int.parse(widget.index)]} | ${Day_arr[int.parse(widget.index)]}',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              )),
        ],
      ),
      const Divider(),
      Row(
        children: [
          Flexible(
              flex: 10,
              child: Container(
                  alignment: Alignment.center,
                  child: Container(
                      width: 30,
                      height: 30,
                      child: Image.asset('assets/km.png')))),
          Flexible(
              flex: 30,
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  ' Km in day:',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              )),
          Flexible(
              flex: 60,
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  '15 km',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              )),
        ],
      ),
      const SizedBox(height: 6),
    ]);
  }

  Widget LocationandTime() {
    return Column(children: <Widget>[
      const Divider(),
      Row(
        children: [
          Flexible(
              flex: 10,
              child: Container(
                  alignment: Alignment.center,
                  child: Container(
                      width: 30,
                      height: 30,
                      child: Image.asset('assets/daytime.png')))),
          Flexible(
              flex: 30,
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  ' Update at:',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              )),
          Flexible(
              flex: 60,
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${Time_arr[int.parse(widget.index)]} | ${Day_arr[int.parse(widget.index)]}',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              )),
        ],
      ),
      const Divider(),
      Row(
        children: [
          Flexible(
              flex: 10,
              child: Container(
                  alignment: Alignment.center,
                  child: Container(
                      width: 30,
                      height: 30,
                      child: Image.asset('assets/address.png')))),
          Flexible(
              flex: 30,
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  ' Address:',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              )),
          Flexible(
              flex: 60,
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${LocationName_arr[int.parse(widget.index)]}',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              )),
        ],
      ),
      const Divider(),
      Row(
        children: [
          Flexible(
              flex: 10,
              child: Container(
                  alignment: Alignment.center,
                  child: Container(
                      width: 30,
                      height: 30,
                      child: Image.asset('assets/longitude.png')))),
          Flexible(
              flex: 30,
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  ' Longitude:',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              )),
          Flexible(
              flex: 60,
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${long[int.parse(widget.index)]}',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              )),
        ],
      ),
      const Divider(),
      Row(
        children: [
          Flexible(
              flex: 10,
              child: Container(
                  alignment: Alignment.center,
                  child: Container(
                      width: 30,
                      height: 30,
                      child: Image.asset('assets/latitude.png')))),
          Flexible(
              flex: 30,
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  ' Latitude:',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              )),
          Flexible(
              flex: 60,
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${lat[int.parse(widget.index)]}',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              )),
        ],
      ),
      const SizedBox(height: 6),
    ]);
  }

  Widget Vehicleinformation() {
    return Column(children: <Widget>[
      const Divider(),
      Row(
        children: [
          Flexible(
              flex: 10,
              child: Container(
                  alignment: Alignment.center,
                  child: Container(
                      width: 30,
                      height: 30,
                      child: Image.asset('assets/plates.png')))),
          Flexible(
              flex: 30,
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  ' Plates:',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              )),
          Flexible(
              flex: 60,
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${ID_arr[int.parse(widget.index)]}',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              )),
        ],
      ),
      const Divider(),
      Row(
        children: [
          Flexible(
              flex: 10,
              child: Container(
                  alignment: Alignment.center,
                  child: Container(
                      width: 30,
                      height: 30,
                      child: Image.asset('assets/activated.png')))),
          Flexible(
              flex: 30,
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  ' Activation:',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              )),
          Flexible(
              flex: 60,
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Activation',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              )),
        ],
      ),
      const Divider(),
      Row(
        children: [
          Flexible(
              flex: 10,
              child: Container(
                  alignment: Alignment.center,
                  child: Container(
                      width: 30,
                      height: 30,
                      child: Image.asset('assets/expired.png')))),
          Flexible(
              flex: 30,
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  ' Expiration:',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              )),
          Flexible(
              flex: 60,
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Expiration',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              )),
        ],
      ),
      const Divider(),
      Row(
        children: [
          Flexible(
              flex: 10,
              child: Container(
                  alignment: Alignment.center,
                  child: Container(
                      width: 30,
                      height: 30,
                      child: Image.asset('assets/driver.png')))),
          Flexible(
              flex: 30,
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  ' Driver:',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              )),
          Flexible(
              flex: 60,
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Anh Le',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              )),
        ],
      ),
      const Divider(),
      Row(
        children: [
          Flexible(
              flex: 10,
              child: Container(
                  alignment: Alignment.center,
                  child: Container(
                      width: 30,
                      height: 30,
                      child: Image.asset('assets/phone.png')))),
          Flexible(
              flex: 30,
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  ' Phone Number:',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              )),
          Flexible(
              flex: 60,
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  '0982016432',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              )),
        ],
      ),
      const SizedBox(height: 6),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        title: Text('Node ' + widget.index + ' Information'),
      ),
      body: ListView(children: [
        Flexible(
            flex: 10,
            child: Container(
              alignment: Alignment.centerLeft,
              child: ExpansionTile(
                  title: Text(
                    'Vehicle Status',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  children: <Widget>[VehicleStatus()]),
            )),
        //const Divider(),
        Flexible(
            flex: 10,
            child: Container(
              alignment: Alignment.centerLeft,
              child: ExpansionTile(
                  title: Text(
                    'Location and Time',
                    style: TextStyle(fontSize: 20),
                  ),
                  children: <Widget>[LocationandTime()]),
            )),
        //const Divider(),
        Flexible(
            flex: 10,
            child: Container(
              alignment: Alignment.centerLeft,
              child: ExpansionTile(
                  title: Text(
                    'Vehicle information',
                    style: TextStyle(fontSize: 20),
                  ),
                  children: <Widget>[Vehicleinformation()]),
            )),
        //const Divider(),
      ]),
    );
  }


  @override
  void initState() {
    super.initState();
   // connectToBroker();
    print('-----------------------------------------------------------------');
    print(Status_arr[int.parse(widget.index)]);
    print(Speed);
  }

//   Future<MqttServerClient?> connectToBroker() async {
//     client.port = 1883;
//     client.secure = false;
//     client.setProtocolV311();
//     final connMessage = MqttConnectMessage()
//         .authenticateAs('letienanh@thaco.com.vn', '@Gps123')
//         .withClientIdentifier('')
//         .withWillTopic('willtopic')
//         .withWillMessage('Will message')
//         .startClean()
//         .withWillQos(MqttQos.atLeastOnce);
//
//     client.connectionMessage = connMessage;
//     client.logging(on: false); // Enable logging (optional)
//
//
//     try {
//       await client.connect();
//       client.subscribe('GPS/UserMaster'+widget.index, MqttQos.atLeastOnce);
//
//       client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
//         final message = messages[0].payload as MqttPublishMessage;
//         final payload =
//         MqttPublishPayload.bytesToStringAsString(message.payload.message);
//
//         try {
//           var mapObject = jsonDecode(payload);
//           ID_arr[int.parse(widget.index)] = mapObject['ID'];
//           Time_arr[int.parse(widget.index)] = mapObject['Time'];
//           Day_arr[int.parse(widget.index)] = mapObject['Day'];
//           Status_arr[int.parse(widget.index)] = mapObject['Status'];
//           if (Status_arr[int.parse(widget.index)] == '0') {
//             Status_arr[int.parse(widget.index)] = 'Start Point';
//           }
//           if (Status_arr[int.parse(widget.index)] == '1') {
//             Status_arr[int.parse(widget.index)] = 'Finish Point';
//           }
//           if (Status_arr[int.parse(widget.index)] == '2') {
//             Status_arr[int.parse(widget.index)] = 'Running';
//           }
//           if (Status_arr[int.parse(widget.index)] == '3') {
//             Status_arr[int.parse(widget.index)] = 'Stopped';
//           }
//           if (Status_arr[int.parse(widget.index)] == '4') {
//             Status_arr[int.parse(widget.index)] = 'Device Problem!';
//           }
//           LatLong_arr[int.parse(widget.index)] = mapObject['LatLong'];
// //-------------------------------------------------------------------------
//
//           Speed = mapObject['Speed'];
//           timerr = mapObject['Timer'];
//           Battery = mapObject['Battery'];
//
//           print('-----------------------------------------------------------------');
//           print(Status_arr[int.parse(widget.index)]);
//           print(Speed);
//         } catch (e) {
//           print(e);
//         }
//
//         //print('Received message: $payload from topic: ${messages[0].topic}');
//       });
//     } catch (e) {
//       print('Exception: $e');
//       client.disconnect();
//     }
//   }

}
