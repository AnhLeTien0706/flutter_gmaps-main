import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'MQTT.dart';
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import 'package:geocoding/geocoding.dart';
import 'LoginPage.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

//15.453764, 108.597456
class _MapScreenState extends State<MapScreen> {
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(10.775669, 106.6900009),
    zoom: 15,
  );

  Completer<GoogleMapController> _controller = Completer();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  List<Map<String, dynamic>> markerData = [
    {'id': 'Node0', 'lat': -83.453277, 'lng': 9.815188, 'title': 0},
    {'id': 'Node1', 'lat': -83.453277, 'lng': 9.815188, 'title': 1},
    {'id': 'Node2', 'lat': -83.453277, 'lng': 9.815188, 'title': 2},
    {'id': 'Node3', 'lat': -83.453277, 'lng': 9.815188, 'title': 3},
    {'id': 'Node4', 'lat': -83.453277, 'lng': 9.815188, 'title': 4},
    {'id': 'Node5', 'lat': -83.453277, 'lng': 9.815188, 'title': 5},
    {'id': 'Node6', 'lat': -83.453277, 'lng': 9.815188, 'title': 6},
    {'id': 'Node7', 'lat': -83.453277, 'lng': 9.815188, 'title': 7},
    {'id': 'Node8', 'lat': -83.453277, 'lng': 9.815188, 'title': 8},
    {'id': 'Node9', 'lat': -83.453277, 'lng': 9.815188, 'title': 9},
    {'id': 'Node10', 'lat': -83.453277, 'lng': 9.815188, 'title': 10},
    {'id': 'Node11', 'lat': -83.453277, 'lng': 9.815188, 'title': 11},
    {'id': 'Node12', 'lat': -83.453277, 'lng': 9.815188, 'title': 12},
    {'id': 'Node13', 'lat': -83.453277, 'lng': 9.815188, 'title': 13},
    {'id': 'Node14', 'lat': -83.453277, 'lng': 9.815188, 'title': 14},
    {'id': 'Node15', 'lat': -83.453277, 'lng': 9.815188, 'title': 15},
    {'id': 'Node16', 'lat': -83.453277, 'lng': 9.815188, 'title': 16},
    {'id': 'Node17', 'lat': -83.453277, 'lng': 9.815188, 'title': 17},
    {'id': 'Node18', 'lat': -83.453277, 'lng': 9.815188, 'title': 18},
    {'id': 'Node19', 'lat': -83.453277, 'lng': 9.815188, 'title': 19},
    {'id': 'Node20', 'lat': -83.453277, 'lng': 9.815188, 'title': 20},
    {'id': 'Node21', 'lat': -83.453277, 'lng': 9.815188, 'title': 21},
    {'id': 'Node22', 'lat': -83.453277, 'lng': 9.815188, 'title': 22},
    {'id': 'Node23', 'lat': -83.453277, 'lng': 9.815188, 'title': 23},
    {'id': 'Node24', 'lat': -83.453277, 'lng': 9.815188, 'title': 24},
    {'id': 'Node25', 'lat': -83.453277, 'lng': 9.815188, 'title': 25},
    {'id': 'Node26', 'lat': -83.453277, 'lng': 9.815188, 'title': 26},
    {'id': 'Node27', 'lat': -83.453277, 'lng': 9.815188, 'title': 27},
    {'id': 'Node28', 'lat': -83.453277, 'lng': 9.815188, 'title': 28},
    {'id': 'Node29', 'lat': -83.453277, 'lng': 9.815188, 'title': 29},
    {'id': 'Node30', 'lat': -83.453277, 'lng': 9.815188, 'title': 30},
    {'id': 'Node31', 'lat': -83.453277, 'lng': 9.815188, 'title': 31},
    {'id': 'Node32', 'lat': -83.453277, 'lng': 9.815188, 'title': 32},
    {'id': 'Node33', 'lat': -83.453277, 'lng': 9.815188, 'title': 33},
    {'id': 'Node34', 'lat': -83.453277, 'lng': 9.815188, 'title': 34},
    {'id': 'Node35', 'lat': -83.453277, 'lng': 9.815188, 'title': 35},
    {'id': 'Node36', 'lat': -83.453277, 'lng': 9.815188, 'title': 36},
    {'id': 'Node37', 'lat': -83.453277, 'lng': 9.815188, 'title': 37},
    {'id': 'Node38', 'lat': -83.453277, 'lng': 9.815188, 'title': 38},
    {'id': 'Node39', 'lat': -83.453277, 'lng': 9.815188, 'title': 39},
    {'id': 'Node40', 'lat': -83.453277, 'lng': 9.815188, 'title': 40},
    {'id': 'Node41', 'lat': -83.453277, 'lng': 9.815188, 'title': 41},
    {'id': 'Node42', 'lat': -83.453277, 'lng': 9.815188, 'title': 42},
    {'id': 'Node43', 'lat': -83.453277, 'lng': 9.815188, 'title': 43},
    {'id': 'Node44', 'lat': -83.453277, 'lng': 9.815188, 'title': 44},
    {'id': 'Node45', 'lat': -83.453277, 'lng': 9.815188, 'title': 45},
    {'id': 'Node46', 'lat': -83.453277, 'lng': 9.815188, 'title': 46},
    {'id': 'Node47', 'lat': -83.453277, 'lng': 9.815188, 'title': 47},
    {'id': 'Node48', 'lat': -83.453277, 'lng': 9.815188, 'title': 48},
    {'id': 'Node49', 'lat': -83.453277, 'lng': 9.815188, 'title': 49},
    {'id': 'Node50', 'lat': -83.453277, 'lng': 9.815188, 'title': 50},
    // Add more marker data as needed
  ];

  Set<Marker> Markers = {};

  late BitmapDescriptor icon;

  getIcons() async {
    var icon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(
          devicePixelRatio: 3.2,
          size: Size.square(4),
        ),
        "assets/car.png");
    setState(() {
      this.icon = icon;
    });
  }

  // markerId: MarkerId(ID_arr[data['title']]),
  // position: LatLng(lat[data['title']], long[data['title']]),
  Future<void> createMarkers() async {
    for (var data in markerData) {
      final marker = Marker(
        markerId: MarkerId(data['id']),
        position: LatLng(data['lat'], data['lng']),
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Container(
                height: 280,
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                          alignment: Alignment.centerLeft,
                          child: Container(
                              width: 30,
                              height: 30,
                              child: Image.asset('assets/plates.png'))),
                      Text(
                        '  ${ID_arr[data['title']]}',
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                    ]),
                    const Divider(),
                    Row(children: [
                      Container(
                          alignment: Alignment.centerLeft,
                          child: Container(
                              width: 30,
                              height: 30,
                              child: Image.asset('assets/statusCar.png'))),
                      Text(
                        '  Status: ${Status_arr[data['title']]}',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ]),
                    const Divider(),
                    Row(children: [
                      Container(
                          alignment: Alignment.centerLeft,
                          child: Container(
                              width: 30,
                              height: 30,
                              child: Image.asset('assets/speed.png'))),
                      Text(
                        '  Speed: ${Speed_arr[data['title']]}',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ]),
                    const Divider(),
                    Row(children: [
                      Container(
                          alignment: Alignment.centerLeft,
                          child: Container(
                              width: 35,
                              height: 35,
                              child: Image.asset('assets/poisition.png'))),
                      Flexible(
                        child: Text(
                          '  Position: ${LocationName_arr[data['title']]}',
                          style: TextStyle(fontSize: 16.0),
                          overflow: TextOverflow.visible,
                          maxLines: null,
                        ),
                      ),
                    ]),
                    const Divider(),
                    Row(children: [
                      Container(
                          alignment: Alignment.centerLeft,
                          child: Container(
                              width: 30,
                              height: 30,
                              child: Image.asset('assets/daytime.png'))),
                      Text(
                        '  ${Day_arr[data['title']]} | ${Time_arr[data['title']]}',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ]),
                    const Divider(),
                  ],
                ),
              );
            },
          );
        },
        icon: await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(
              devicePixelRatio: 3.2,
              size: Size.square(4),
            ),
            "assets/car.png"),
        //infoWindow: InfoWindow(title: data['title']),
      );
      Markers.add(marker);
    }
  }

  void updateMarkerPosition(String markerId, double lat, double lng) {
    setState(() {
      Markers = Markers.map((marker) {
        if (marker.markerId.value == markerId) {
          return marker.copyWith(positionParam: LatLng(lat, lng));
        }
        return marker;
      }).toSet();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  int extractNumber(String str) {
    String numberString = str.replaceAll(RegExp(r'[^0-9]'), '');
    int number = int.parse(numberString);
    return number;
  }

  Future<MqttServerClient?> connectToBroker() async {
    client.port = 1883;
    client.secure = false;
    client.setProtocolV311();
    final connMessage = MqttConnectMessage()
        .authenticateAs('letienanh@thaco.com.vn', '@Gps123')
        .withClientIdentifier('')
        .withWillTopic('willtopic')
        .withWillMessage('Will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    client.connectionMessage = connMessage;
    client.logging(on: false); // Enable logging (optional)

    try {
      await client.connect();
      client.subscribe('GPS/NowUserMaster', MqttQos.atLeastOnce);
      client.updates
          ?.listen((List<MqttReceivedMessage<MqttMessage>> messages) async {
        final message = messages[0].payload as MqttPublishMessage;
        final payload =
            MqttPublishPayload.bytesToStringAsString(message.payload.message);

        print(messages[0].topic);

        if (messages[0].topic == 'GPS/NowUserMaster') {
          try {
            var mapObject = jsonDecode(payload);

            // if (mapObject['ID'] == 'Node0') {
            //   i = 0;
            // }
            // if (mapObject['ID'] == 'Node1') {
            //   i = 1;
            // }
            // if (mapObject['ID'] == 'Node2') {
            //   i = 2;
            // }
            // if (mapObject['ID'] == 'Node3') {
            //   i = 3;
            // }
//---------------------------------------------------------
//             for (int k = 0; k < 300; k++) {
//               if (mapObject['ID'] == 'Node' + k.toString()) {
//                 i = k;
//               }
//             }
            i = extractNumber(mapObject['ID']);
//---------------------------------------------------------
            ID_arr[i] = mapObject['ID'];
            print(ID_arr[i]);

            Time_arr[i] = mapObject['Time'];
            Day_arr[i] = mapObject['Day'];
            Status_arr[i] = mapObject['Status'];
            if (Status_arr[i] == '0') {
              Status_arr[i] = 'Start Point';
            }
            if (Status_arr[i] == '1') {
              Status_arr[i] = 'Finish Point';
            }
            if (Status_arr[i] == '2') {
              Status_arr[i] = 'Running';
            }
            if (Status_arr[i] == '3') {
              Status_arr[i] = 'Stopped';
            }
            if (Status_arr[i] == '4') {
              Status_arr[i] = 'Device Problem!';
            }
            LatLong_arr[i] = mapObject['LatLong'];
//-------------------------------------------------------------------------
            lat[i] = getFirstNumber(LatLong_arr[i]);
            long[i] = getSecondNumber(LatLong_arr[i]);
            LocationName_arr[i] = await getLocationName(lat[i], long[i]);
            Speed_arr[i] = mapObject['Speed'];
            //timerr = mapObject['Timer'];
            Battery_arr[i] = mapObject['Battery'];
          } catch (e) {
            print(e);
          }
        }
        //print('Received message: $payload from topic: ${messages[0].topic}');
      });
    } catch (e) {
      print('Exception: $e');
      client.disconnect();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          alignment: Alignment.center,
          children: [
            GoogleMap(
              initialCameraPosition: _initialCameraPosition,
              mapType: MapType.normal,
              markers: Markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              compassEnabled: true,
              // polylines: _polyline,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.black,
          onPressed: () async {
            getUserCurrentLocation().then((value) async {
              print(
                  value.latitude.toString() + " " + value.longitude.toString());

              LatLng latLng = parseLatLng(
                  value.latitude.toString() + "," + value.longitude.toString());

              // _addMarker(latLng);
              //
              // _googleMapController.animateCamera(
              //   CameraUpdate.newCameraPosition(CameraPosition(
              //     target: latLng,
              //     zoom: 15,
              //   )),
              // );
            });
          },
          child: const Icon(Icons.center_focus_strong),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat);
  }

  //${place1.locality},

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      print("ERROR" + error.toString());
    });
    return await Geolocator.getCurrentPosition();
  }

//----------------------------MQTT---------------------------------------------------

  @override
  void initState() {
    super.initState();
    getIcons();
    connectToBroker();
    UpdatePosition();
    createMarkers();
  }

  void UpdatePosition() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      for (int j = 0; j < 100; j++) {
        updateMarkerPosition('Node' + j.toString(), lat[j], long[j]);
      }
    });
  }
}

Future<String> getLocationName(double latitude, double longitude) async {
  try {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);
    Placemark place1 = placemarks[0];

    return "${place1.thoroughfare}, ${place1.administrativeArea}"; //, ${place1.country}";
  } catch (e) {
    print(e);
    return 'Unknown location';
  }
}

double getFirstNumber(String input) {
  List<String> parts = input.split(',');
  if (parts.length >= 1) {
    return double.tryParse(parts[0]) ?? 0.0;
  }
  return 0.0;
}

double getSecondNumber(String input) {
  List<String> parts = input.split(',');
  if (parts.length >= 2) {
    return double.tryParse(parts[1]) ?? 0.0;
  }
  return 0.0;
}
