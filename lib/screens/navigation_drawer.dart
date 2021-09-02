import 'package:flutter/material.dart';

class NavigationDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            color: Theme.of(context).primaryColor,
            child: Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    margin: EdgeInsets.only(
                      top: 30,
                      bottom: 10,
                    ),
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: NetworkImage(
                            'https://avatars.githubusercontent.com/u/67167843?s=400&u=30fdbce294cab1615d1f10ad7ea1e00aca50c50b&v=4',
                          ),
                          fit: BoxFit.fill),
                    ),
                  ),
                  Text(
                    'Imasha Senarath',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Item 01"),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Item 02"),
          )
        ],
      ),
    );
  }
}
