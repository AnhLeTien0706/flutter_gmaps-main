import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'MQTT.dart';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'Home.dart';
import 'LoginPage.dart';

class DetailTrip extends StatefulWidget {
  const DetailTrip({super.key, required this.index});

  final String index;

  @override
  _DetailTripState createState() => _DetailTripState();
}

class _DetailTripState extends State<DetailTrip> {
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(16.481435, 107.554640),
    zoom: 15,
  );

  int running = 0;
  int parking = 0;
  int finishing = 0;
  List<int> parking_arr = [];
  int indexParking = 0;

  Widget DatePicker() {
    return Column(children: <Widget>[
      Container(
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: SfDateRangePicker(
                onSelectionChanged: _onSelectionChanged,
                selectionMode: DateRangePickerSelectionMode.single,
                initialSelectedRange: PickerDateRange(
                    DateTime.now().subtract(const Duration(days: 4)),
                    DateTime.now().add(const Duration(days: 3))),
              ),
            )
          ],
        ),
      )
    ]);
  }

  Widget Picker() {
    return Column(children: <Widget>[
      Row(children: [
        Flexible(
            child: Container(
          alignment: Alignment.centerLeft,
          child: Container(
              color: Colors.lightBlueAccent,
              child: ExpansionTile(
                  title: Text(
                    '$_selectedDate',
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  leading: Container(
                    alignment: Alignment.centerLeft,
                    width: 40, // Specify the desired width
                    height: 40, // Specify the desired height
                    child: Image.asset(
                        'assets/calendar.png'), // Replace with your image path
                  ),
                  expandedAlignment: Alignment.center,
                  children: <Widget>[DatePicker()])),
        )),
      ]),
      const Divider(),
    ]);
  }

  Widget Parking(String long) {
    return Column(children: <Widget>[
      Row(children: [
        Container(
            alignment: Alignment.centerLeft,
            child: Container(
                width: 30,
                height: 30,
                child: Image.asset('assets/Parking.png'))),
        Text(
          '  ${Point[parking + 1]} - ${Point[parking + 4]}\n${long}',
          style: TextStyle(fontSize: 18.0),
        ),
      ]),
      const Divider(),
    ]);
  }

  Widget Running(String time, String long) {
    return Column(children: <Widget>[
      Row(children: [
        Container(
            alignment: Alignment.centerLeft,
            child: Container(
                width: 30,
                height: 30,
                child: Image.asset('assets/Running.png'))),
        Text(
          '$time\n$long',
          style: TextStyle(fontSize: 18.0),
        ),
      ]),
      const Divider(),
    ]);
  }

  // Widget Infor() {
  //   return Container(
  //       alignment: Alignment.topCenter,
  //       height: 200,
  //       color: Colors.white,
  //       child: ListView(children: WidgetList));
  // }

  var WidgetList = <Widget>[];

  String _selectedDate =
      DateFormat('dd-MM-yyyy').format(DateTime.now()).toString();

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      _selectedDate = DateFormat('dd-MM-yyyy').format(args.value);
      final data = {
        'UserID': UserName,
        'ID': 'Node' + widget.index,
        'Day': _selectedDate
      };
      final jsonPayload = jsonEncode(data);
      String f(String jsonPayload) => jsonPayload;

      client.publishMessage('GPS/HistoryUserClient', MqttQos.atMostOnce,
          MqttClientPayloadBuilder().addString(jsonPayload).payload!);
    });
  }

  final Set<Polyline> _polyline = {};
  List<LatLng> latLen = [];

  List<String> L = [];
  List<String> S = [];
  List<String> T = [];
  List<String> Point = []; //Add data to this arr

  String calculateTimeDifference(String startTimeString, String endTimeString) {
    DateTime startTime = DateTime.parse("1970-01-01 " + startTimeString);
    DateTime endTime = DateTime.parse("1970-01-01 " + endTimeString);

    Duration difference = endTime.difference(startTime);

    int hours = difference.inHours;
    int minutes = difference.inMinutes.remainder(60);
    int seconds = difference.inSeconds.remainder(60);

    return "  ${hours}h ${minutes}m ${seconds}s";
  }

  List<Marker> Markerss = [];
  int no = 1;

  Future<void> addMarker(LatLng position, String title, String Image,
      String snippet, String loca) async {
    final newMarker = Marker(
        markerId: MarkerId(position.toString()),
        position: position,
        infoWindow: InfoWindow(
          title: title + '(' + no.toString() + ')',
          snippet: '${loca}',
        ),
        icon: await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(
              devicePixelRatio: 3.2,
              size: Size.square(4),
            ),
            "assets/" + Image + ".png"));
    // if (mounted) {
    setState(() {
      Markerss.add(newMarker);
      no++;
    });
    // }
  }

  LatLng parseLatLngFromString(String latLngString) {
    List<String> latLngList = latLngString.split(',');
    double latitude = double.parse(latLngList[0]);
    double longitude = double.parse(latLngList[1]);
    return LatLng(latitude, longitude);
  }

  int count3 = 0;

  @override
  Future<void> AddPoint() async {
    for (int i = 0; i < Point.length; i = i + 3) {
      latLen.add(parseLatLngFromString(Point[i]));
    }
    WidgetList.add(Picker());
    for (int i = 1; i < Point.length; i = i + 3) {
      if (Point[i] == '3') {
        count3++;
        parking_arr.add(i);
      }
      if (Point[i] == '0') {
        running = i;
      }
      if (Point[i] == '1') {
        finishing = i;
      }
    }
    // print('---------------------------------');
    // print(parking_arr);
    for (int i = 1; i < Point.length; i = i + 3) {
      if (Point[i] == '3') {
        parking = i;
        double lat = getFirstNumber(Point[i - 1]);
        double long = getSecondNumber(Point[i - 1]);
        addMarker(
            parseLatLngFromString(Point[i - 1]),
            'Parking Point ',
            'ParkingPoint',
            Point[i + 1] + ' - ' + Point[i + 4],
            await getLocationName(lat, long));
        WidgetList.add(
            Parking(calculateTimeDifference(Point[i + 1], Point[i + 4])));
//--------------------------------------------------------------
        count3--;
        if (count3 > 0) {
          WidgetList.add(Running(
              '  ' +
                  Point[parking_arr[indexParking] + 4] +
                  ' - ' +
                  Point[parking_arr[indexParking + 1] + 1],
              calculateTimeDifference(Point[parking_arr[indexParking] + 4],
                  Point[parking_arr[indexParking + 1] + 1])));
          indexParking++;
        }
        if (count3 <= 0) {
          WidgetList.add(Running(
              '  ' +
                  Point[parking_arr[indexParking] + 4] +
                  ' - ' +
                  Point[finishing + 1],
              calculateTimeDifference(
                  Point[parking_arr[indexParking] + 4], Point[finishing + 1])));
        }
      }
      if (Point[i] == '0') {
        double lat = getFirstNumber(Point[i - 1]);
        double long = getSecondNumber(Point[i - 1]);
        addMarker(parseLatLngFromString(Point[i - 1]), 'Start Point ',
            'StartPoint', Point[i + 1], await getLocationName(lat, long));

        if (count3 != 0) {
          WidgetList.add(Running(
              '  ' + Point[running + 1] + ' - ' + Point[parking_arr[0] + 1],
              calculateTimeDifference(
                  Point[running + 1], Point[parking_arr[0] + 1])));
        }
        if (count3 == 0) {
          WidgetList.add(Running(
              '  ' + Point[running + 1] + ' - ' + Point[finishing + 1],
              calculateTimeDifference(
                  Point[running + 1], Point[finishing + 1])));
        }
      }
      if (Point[i] == '1') {
        double lat = getFirstNumber(Point[i - 1]);
        double long = getSecondNumber(Point[i - 1]);
        addMarker(parseLatLngFromString(Point[i - 1]), 'Finish Point ',
            'FinishPoint', Point[i + 1], await getLocationName(lat, long));
      }
    }
  }

  Completer<GoogleMapController> _controller = Completer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          centerTitle: true,
          title: Text('Node ' + widget.index + ' Trip'),
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
            GoogleMap(
              initialCameraPosition: _initialCameraPosition,
              mapType: MapType.normal,
              markers: Set<Marker>.from(Markerss),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              compassEnabled: true,
              polylines: _polyline,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.black,
          onPressed: () //async
              {
            // setState(() {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return Container(
                  height: 350,
                  padding: EdgeInsets.all(6.0),
                  child: ListView(
                    children: [
                      Column(
                        children: WidgetList,
                      )
                    ],
                  ),
                );
              },
            );
            // });
          },
          child: const Icon(Icons.info),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat);
  }

  List<dynamic> out = [];

  @override
  void initState() {
    super.initState();
    connectToBroker();
    indexParking = 0;
    parking_arr.clear();
    out.clear();
    L.clear();
    S.clear();
    T.clear();
    Point.clear();
    clearLine();
    latLen.clear();
    _polyline.clear();
    Markerss.clear();
    WidgetList.clear();
    WidgetList.add(Picker());
  }

  @override
  void dispose() {
    super.dispose();
  }

  String id = '';

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
    client.logging(on: true); // Enable logging (optional)

    try {
      await client.connect();
      client.subscribe('GPS/HistoryUserMaster', MqttQos.atLeastOnce);
      client.updates
          ?.listen((List<MqttReceivedMessage<MqttMessage>> messages) async {
        final message = messages[0].payload as MqttPublishMessage;
        final payload =
            MqttPublishPayload.bytesToStringAsString(message.payload.message);
        no = 1;
        indexParking = 0;
        parking_arr.clear();
        L.clear();
        S.clear();
        T.clear();
        Point.clear();
        latLen.clear();
        clearLine();
        _polyline.clear();
        Markerss.clear();
        out.clear();
        WidgetList.clear();
        print('-------------------------------------------------------');
        print(messages[0].topic);
        if (messages[0].topic == 'GPS/HistoryUserMaster') {
          print(id);
          try {
            var mapObject = jsonDecode(payload);
            id = mapObject['UserID'];

            if (id == UserName) {
              String size = mapObject['Size'];
              var jsonData = json.decode(payload);

              for (int j = 1; j <= int.parse(size); j++) {
                out.add(jsonData[j.toString()]);
                L.add(out[j - 1]['LatLong']);
                S.add(out[j - 1]['Status']);
                T.add(out[j - 1]['Time']);
              }
            }
          } catch (e) {
            print(e);
          }
          if (id == UserName) {
            for (int j = 0; j < L.length; j++) {
              Point.add(L[j]);
              Point.add(S[j]);
              Point.add(T[j]);
            }
            print(Point);
            AddPoint();
            for (int i = 0; i < latLen.length; i++) {
              _polyline.add(Polyline(
                polylineId: PolylineId('1'),
                width: 5,
                points: latLen,
                color: Colors.orange,
              ));
            }
          }
        }
      });
    } catch (e) {
      print('Exception: $e');
      client.disconnect();
    }
  }

  void clearLine() {
    // if (mounted) {
    setState(() {
      latLen.clear();
    });
    //}
  }
}
