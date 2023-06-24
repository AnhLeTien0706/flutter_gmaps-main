import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gmaps/Detail.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'MQTT.dart';

class DetailMonitor extends StatefulWidget {
  const DetailMonitor({super.key, required this.index});

  final String index;

  @override
  _DetailMonitorState createState() => _DetailMonitorState();
}

class _DetailMonitorState extends State<DetailMonitor> {
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(10.765669, 106.6800009),
    zoom: 15,
  );

  LatLng parseLatLngFromString(String latLngString) {
    List<String> latLngList = latLngString.split(',');
    double latitude = double.parse(latLngList[0]);
    double longitude = double.parse(latLngList[1]);
    return LatLng(latitude, longitude);
  }

  Completer<GoogleMapController> _controller = Completer();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        title: Text('Node ' + widget.index + ' Monitoring'),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            mapType: MapType.normal,
            //markers: Set<Marker>.from(Markerss),
            markers: Markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            compassEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
        ],
      ),
    );
  }

  Set<Marker> Markers = {};

  @override
  void initState() {
    super.initState();
    Markers.add(Marker(
      markerId: MarkerId('Node' + widget.index),
      position:
          LatLng(lat[int.parse(widget.index)], long[int.parse(widget.index)]),
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
                      '  ${ID_arr[int.parse(widget.index)]}',
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
                      '  Status: ${Status_arr[int.parse(widget.index)]}',
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
                      '  Speed: ${Speed_arr[int.parse(widget.index)]}',
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
                        '  Position: ${LocationName_arr[int.parse(widget.index)]}',
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
                      '  ${Day_arr[int.parse(widget.index)]} | ${Time_arr[int.parse(widget.index)]}',
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
      //infoWindow: InfoWindow(title: data['title']),
    ));
    getIcons();
    UpdatePosition();
  }

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

  void updateMarkerPosition(LatLng newPosition) {
    setState(() {
      Markers = Markers.map((Marker marker) {
        print(marker.markerId.value);
        if (marker.markerId.value == 'Node' + widget.index) {
          return marker.copyWith(
            positionParam: newPosition,
            iconParam: icon,
          );
        }
        return marker;
      }).toSet();
    });
  }

  void UpdatePosition() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (LatLong_arr[int.parse(widget.index)].length > 1) {
        updateMarkerPosition(
            parseLatLngFromString(LatLong_arr[int.parse(widget.index)]));
      }
    });
  }
}
