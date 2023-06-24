import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'MQTT.dart';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'Home.dart';
import 'LoginPage.dart';

class DetailReview extends StatefulWidget {
  const DetailReview({super.key, required this.index});

  final String index;

  @override
  _DetailReviewState createState() => _DetailReviewState();
}

class _DetailReviewState extends State<DetailReview> {
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(16.481435, 107.554640),
    zoom: 14,
  );

  int running = 0;
  int parking = 0;
  int finishing = 0;
  List<int> parking_arr = [];
  int indexParking = 0;

  List<String> L = [];
  List<String> S = [];
  List<String> T = [];
  List<String> Speed = [];
  Set<Marker> Markers = {};
  String _LatLong = '';
  String _Speed = '';

  double _sliderValue = 0.0;
  String _formattedTimestamp = '';
  String _Status = '';
  Timer? _timer;

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
      //const Divider(),
    ]);
  }

  bool isButtonToggled = false;

  void toggleButton() {
    setState(() {
      if (L.length > 1) {
        isButtonToggled = !isButtonToggled;
      }
    });
    if (isButtonToggled) {
      _startTimer();
    } else {
      _stopTimer();
    }
  }

  Widget PlayReview() {
    return Container(
        alignment: Alignment.topCenter,
        height: 200,
        color: Colors.white70,
        child: ListView(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: InkWell(
                  onTap: toggleButton,
                  child: Image.asset(
                    isButtonToggled
                        ? 'assets/PauseButton.png'
                        : 'assets/PlayButton.png',
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: Slider(
                  value: _sliderValue,
                  min: 0.0,
                  max: double.parse(T.length.toString()),
                  onChanged: (newValue) {
                    // setState(() {
                    _sliderValue = newValue.roundToDouble();
                    _updateFormattedTimestamp();
                    //});
                  },
                ),
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 5),
              Container(
                  alignment: Alignment.centerLeft,
                  child: Container(
                      width: 30,
                      height: 30,
                      child: Image.asset('assets/poisition.png'))),
              SizedBox(width: 5),
              Text(
                'Location: $_LatLong',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
                overflow: TextOverflow.visible,
                maxLines: null,
              ),
              //SizedBox(width: 10),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 5),
              Container(
                  alignment: Alignment.centerRight,
                  child: Container(
                      width: 30,
                      height: 30,
                      child: Image.asset('assets/daytime.png'))),
              SizedBox(width: 5),
              Text(
                'Time: $_formattedTimestamp',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
              ),
              //SizedBox(width: 10),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 5),
              Container(
                  alignment: Alignment.centerRight,
                  child: Container(
                      width: 30,
                      height: 30,
                      child: Image.asset('assets/speed.png'))),
              SizedBox(width: 5),
              Text(
                'Speed: $_Speed km/h',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
              ),
              //SizedBox(width: 10),
            ],
          ),
          const Divider(),
          Picker(),
        ]));
  }

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

  List<String> Point = []; //Add data to this arr

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
    // if(mounted) {
    setState(() {
      Markers.add(newMarker);
      no++;
    });
    //}
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
    for (int i = 0; i < Point.length; i = i + 4) {
      latLen.add(parseLatLngFromString(Point[i]));
    }

    for (int i = 1; i < Point.length + 1; i = i + 4) {
      if (Point[i] == '3') {
        count3++;
        //parking_arr.add(i);
      }
      if (Point[i] == '0') {
        running = i;
      }
      if (Point[i] == '1') {
        finishing = i;
      }
    }

    for (int i = 1; i < Point.length + 1; i = i + 4) {
      if (Point[i] == '3') {
        parking = i;
        double lat = getFirstNumber(Point[i - 1]);
        double long = getSecondNumber(Point[i - 1]);
        addMarker(
            parseLatLngFromString(Point[i - 1]),
            'Parking Point ',
            'ParkingPoint',
            Point[i + 1] + ' - ' + Point[i + 5],
            await getLocationName(lat, long));
//--------------------------------------------------------------
        count3--;
        if (count3 > 0) {
          indexParking++;
        }
        if (count3 <= 0) {}
      }
      if (Point[i] == '0') {
        double lat = getFirstNumber(Point[i - 1]);
        double long = getSecondNumber(Point[i - 1]);
        addMarker(parseLatLngFromString(Point[i - 1]), 'Start Point ',
            'StartPoint', Point[i + 1], await getLocationName(lat, long));
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
        title: Text('Node ' + widget.index + ' Review'),
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            mapType: MapType.normal,
            markers: Set<Marker>.from(Markers),
            //Markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            compassEnabled: true,
            polylines: _polyline,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          PlayReview(),
        ],
      ),
    );
  }

  List<dynamic> out = [];

  late BitmapDescriptor icon;

  getIcons() async {
    var icon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(
          devicePixelRatio: 3.2,
          size: Size.square(4),
        ),
        "assets/CarIcon.png");
    // setState(() {
    this.icon = icon;
    // });
  }

  @override
  void initState() {
    super.initState();
    connectToBrokerReview();
    getIcons();
    _sliderValue = 0.0;
    indexParking = 0;
    L.clear();
    S.clear();
    T.clear();
    Point.clear();
    clearLine();
    latLen.clear();
    _polyline.clear();
    out.clear();
    Markers.clear();
    Markers.add(Marker(
      markerId: MarkerId('Node' + widget.index),
      position: LatLng(-83.453277, 9.815188),
    ));
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  String id = '';

  Future<MqttServerClient?> connectToBrokerReview() async {
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
        L.clear();
        S.clear();
        T.clear();
        Point.clear();
        latLen.clear();
        clearLine();
        Markers.clear();
        Markers.add(Marker(
          markerId: MarkerId('Node' + widget.index),
          position: LatLng(-83.453277, 9.815188),
        ));
        _polyline.clear();
        out.clear();
        print(messages[0].topic);
        if (messages[0].topic == 'GPS/HistoryUserMaster') {
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
                Speed.add(out[j - 1]['Speed']);
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
              Point.add(Speed[j]);
            }
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
    // if(mounted) {
    setState(() {
      latLen.clear();
    });
    //}
  }

  void _startTimer() {
    if (_timer == null || !_timer!.isActive) {
      const duration = Duration(milliseconds: 500);
      _timer = Timer.periodic(duration, (Timer timer) {
        // setState(() {
        if (_sliderValue < T.length) {
          _updateFormattedTimestamp();
          _sliderValue += 1;
        } else {
          toggleButton();
          timer.cancel();
        }
        //});
      });
    }
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _updateFormattedTimestamp() async {
    int index = (_sliderValue).round();
    if (index < T.length + 1) {
      _formattedTimestamp = T[index];
      _Status = S[index];
      _LatLong = await getLocationName(
          getFirstNumber(L[index]), getSecondNumber(L[index]));
      _Speed = Speed[index];
      updateMarkerPosition(LatLng(
        double.parse(L[index].split(',')[0]),
        double.parse(L[index].split(',')[1]),
      ));
    } else {
      _formattedTimestamp = '';
      _Status = '';
      _LatLong = '';
      //Markers = {};
    }
  }

  void updateMarkerPosition(LatLng newPosition) {
    setState(() {
      Markers = Markers.map((Marker marker) {
        if (marker.markerId.value == 'Node' + widget.index) {
          return marker.copyWith(
            positionParam: newPosition,
            // iconParam: await
            iconParam: icon,
          );
        }
        return marker;
      }).toSet();
    });
  }
}
