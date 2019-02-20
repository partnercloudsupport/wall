import 'package:flutter/material.dart';
import 'package:wall_ly/ui/root_page.dart';
import 'package:wall_ly/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  await Firestore.instance.settings(timestampsInSnapshotsEnabled: true);
  
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Wall.ly',
        theme: ThemeData(
          // Define the default Brightness and Colors
          brightness: Brightness.dark,
          primaryColor: Colors.lightBlue[800],
          accentColor: Colors.cyan[600],

          // Define the default Font Family
          fontFamily: 'Montserrat',

          // Define the default TextTheme. Use this to specify the default
          // text styling for headlines, titles, bodies of text, and more.
          textTheme: TextTheme(
            headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
            title: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
            body1: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
          ),
        ),
        home: new RootPage(auth: new Auth()));
        //home: new GridListDemo());
  }
}
