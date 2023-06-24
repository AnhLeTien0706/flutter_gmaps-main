import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'DetailMonitor.dart';
import 'DetailTrip.dart';
import 'Detailinfor.dart';
import 'DetailReview.dart';

String index1 = '';
int _selectedIndex = 0;

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.index});

  final String index;

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  void initState() {
    super.initState();
    index1 = widget.index;
  }

  @override
  void dispose() {
    //super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      MyInfor(index: index1),
      DetailMonitor(index: index1),
      DetailTrip(index: index1),
      DetailReview(index: index1),
    ];

    return Scaffold(
      body: Center(
        child: _widgetOptions[
            _selectedIndex], //_widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: GNav(
        backgroundColor: Colors.blueAccent,
        color: Colors.white,
        activeColor: Colors.white,
        tabBackgroundColor: Colors.black26,
        gap: 8,
        padding: EdgeInsets.all(16),
        tabs: const [
          GButton(
            icon: Icons.info,
            text: 'Information',
          ),
          GButton(
            icon: Icons.place,
            text: 'Monitoring',
          ),
          GButton(
            icon: Icons.map,
            text: 'Trip',
          ),
          GButton(
            icon: Icons.replay,
            text: 'Review',
          ),
        ],
        selectedIndex: _selectedIndex,
        onTabChange: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
