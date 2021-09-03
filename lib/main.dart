// @dart=2.9
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_assignment/screens/navigation_drawer.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

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
      home: MyHomePage(title: 'Epic'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File pickedImage;
  bool isImageLoaded = false;
  String text = "";

  Future pickImage() async {
    text = "";
    var tempStore = await ImagePicker().pickImage(source: ImageSource.gallery);
    File x = File(tempStore.path);

    setState(() {
      pickedImage = x;
      isImageLoaded = true;
    });
  }

  Future readText() async {
    FirebaseVisionImage ourImage = FirebaseVisionImage.fromFile(pickedImage);
    TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
    VisionText readText = await recognizeText.processImage(ourImage);

    for (TextBlock block in readText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement word in line.elements) {
          setState(() {
            text = text + " " + word.text;
          });
        }
      }
    }
  }

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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home)),
              Tab(icon: Icon(Icons.image)),
              Tab(icon: Icon(Icons.camera)),
            ],
          ),
          title: Text(widget.title),
        ),
        drawer: NavigationDrawer(),
        body: TabBarView(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20.0),
                  itemBuilder: (BuildContext context, int index) {
                    return index == 0 ? _searchBar() : _listItem(index - 1);
                  },
                  itemCount: _locationForDisplay.length + 1,
                ),
              ),
            ),
            Center(
              child: CachedNetworkImage(
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                imageUrl: 'https://picsum.photos/250?image=9',
              ),
            ),
            Column(
              children: <Widget>[
                SizedBox(height: 100.0),
                isImageLoaded
                    ? Center(
                        child: Container(
                          height: 200.0,
                          width: 200.0,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: FileImage(pickedImage),
                                fit: BoxFit.cover),
                          ),
                        ),
                      )
                    : Container(),
                SizedBox(height: 10.0),
                ElevatedButton(
                  child: Text('Pick an image'),
                  onPressed: () {
                    pickImage();
                  },
                ),
                SizedBox(height: 10.0),
                ElevatedButton(
                  child: Text('Read Text'),
                  onPressed: () {
                    readText();
                  },
                ),
                SizedBox(height: 10.0),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(text),
                )
              ],
            )
          ],
        ),
      ),
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
              var title = location.title.toLowerCase();
              return title.contains(text);
            }).toList();
          });
        },
      ),
    );
  }

  _listItem(index) {
    return Card(
        child: Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(Icons.place),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _locationForDisplay[index].title.toString(),
              ),
              Text(
                _locationForDisplay[index].lattLong.toString(),
              ),
            ],
          ),
        ],
      ),
    ));
  }
}

class Location {
  String title;
  String lattLong;

  Location(this.title, this.lattLong);

  Location.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    lattLong = json['lattLong'];
  }
}
