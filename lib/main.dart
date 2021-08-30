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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
          child: FutureBuilder(
        future: _getLocations(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return Container(
              child: Center(
                child: Text("Loading"),
              ),
            );
          } else {
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(snapshot.data[index].title),
                    subtitle: Text("LattLong: "+snapshot.data[index].lattLong),
                  );
                });
          }
        },
      )),
    );
  }
}

class Location {
  final String title, lattLong;

  Location(this.title, this.lattLong);
}
