import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Location> _locations = [];
  List<Location> _locationForDisplay = [];

  Future<List<Location>> _getLocations() async {
    var data = await http.get(
        Uri.parse("https://www.metaweather.com/api/location/search/?query=ba"));

    var jsonData = json.decode(data.body);

    List<Location> locations = [];

    for (var u in jsonData) {
      Location location = Location(u["title"], u["latt_long"]);

      locations.add(location);
    }

    return locations;
  }

  @override
  void initState() {
    _getLocations().then((value) {
      setState(() {
        _locations.addAll(value);
        _locationForDisplay = _locations;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return index == 0 ? _searchBar() : _listItem(index - 1);
              },
              itemCount: _locationForDisplay.length + 1,
            ),
          )),
    );
  }

  _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(hintText: 'Search Location'),
        onChanged: (text) {
          text = text.toLowerCase();
          setState(() {
            _locationForDisplay = _locations.where((location) {
              var title = location.title!.toLowerCase();
              return title.contains(text);
            }).toList();
          });
        },
      ),
    );
  }

  _listItem(index) {
    return Card(
      child: ListTile(
        title: Text(
          _locationForDisplay[index].title.toString(),
        ),
        subtitle: Text(
          _locationForDisplay[index].lattLong.toString(),
        ),
      ),
    );
  }
}

class Location {
  String? title;
  String? lattLong;

  Location(this.title, this.lattLong);

  Location.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    lattLong = json['lattLong'];
  }
}
