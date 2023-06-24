import 'package:flutter/material.dart';
import 'package:flutter_gmaps/Detail.dart';
import 'Detail.dart';
import 'MQTT.dart';

class MonitoringPage extends StatefulWidget {
  @override
  _MonitoringPageState createState() => _MonitoringPageState();
}

class _MonitoringPageState extends State<MonitoringPage> {
  final List<Map<String, dynamic>> _allUsers = [
    {"id": 1, "name": '${ID_arr[0]}', "Status": '${Status_arr[0]}'},
    {"id": 2, "name": '${ID_arr[1]}', "Status": '${Status_arr[1]}'},
    {"id": 3, "name": '${ID_arr[2]}', "Status": '${Status_arr[2]}'},
    {"id": 4, "name": '${ID_arr[3]}', "Status": '${Status_arr[3]}'},
    {"id": 5, "name": '${ID_arr[4]}', "Status": '${Status_arr[4]}'},
    {"id": 6, "name": '${ID_arr[5]}', "Status": '${Status_arr[5]}'},
    {"id": 7, "name": '${ID_arr[6]}', "Status": '${Status_arr[6]}'},
    {"id": 8, "name": '${ID_arr[7]}', "Status": '${Status_arr[7]}'},
    {"id": 9, "name": '${ID_arr[8]}', "Status": '${Status_arr[8]}'},
    {"id": 10, "name": '${ID_arr[9]}', "Status": '${Status_arr[9]}'},
  ];

  // This list holds the data for the list view
  List<Map<String, dynamic>> _foundUsers = [];

  @override
  initState() {
    _foundUsers = _allUsers;
    super.initState();
  }

  // This function is called whenever the text field changes
  void _runFilter(String enteredKeyword) {
    List<Map<String, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = _allUsers;
    } else {
      results = _allUsers
          .where((user) =>
              user["name"].toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();

      // we use the toLowerCase() method to make it case-insensitive
    }
    setState(() {
      _foundUsers = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            TextField(
              onChanged: (value) => _runFilter(value),
              decoration: const InputDecoration(
                  labelText: 'Search', suffixIcon: Icon(Icons.search)),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: _foundUsers.isNotEmpty
                  ? ListView.builder(
                      itemCount: _foundUsers.length,
                      itemBuilder: (context, index) => Card(
                        key: ValueKey(_foundUsers[index]["id"]),
                        color: Colors.white,
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: ListTile(
                          leading: Image.asset('assets/CX5.png'),
                          title: Text(_foundUsers[index]['name'],
                              style: TextStyle(color: Colors.black)),
                          subtitle: Text(_foundUsers[index]["Status"],
                              style: TextStyle(color: Colors.black)),
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DetailScreen(
                                      index: (_foundUsers[index]["id"] - 1)
                                          .toString()))),
                        ),
                      ),
                    )
                  : const Text(
                      'No results found',
                      style: TextStyle(fontSize: 24),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
