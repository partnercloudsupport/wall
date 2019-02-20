import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:wall_ly/services/auth.dart';

class AddWallPage extends StatefulWidget {
  AddWallPage({Key key, this.auth, this.userId}) : super(key: key);

  final BaseAuth auth;
  final String userId;

  @override
  _AddWallPageState createState() => new _AddWallPageState();
}

class _AddWallPageState extends State<AddWallPage> {
  TextEditingController wallIdController = new TextEditingController();

  void _back() {
    Navigator.pop(context);
  }

  void _addWall() async {
    Firestore.instance
        .collection('walls')
        .where('displayName', isEqualTo: wallIdController.text)
        .snapshots()
        .listen((data) {
      if (data.documents.isEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              title: new Text("Wall not found"),
              content: new Text("Please try another name"),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                new FlatButton(
                  child: new Text("Close"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );

        return;
      }

      var userReference = Firestore.instance.collection('users').document(widget.userId);
      var wallId = data.documents[0].documentID;

      userReference.setData({
        'walls': FieldValue.arrayUnion([wallId]),
      }, merge: true);
    });

    /*reference.snapshots().listen((data) {
      var wallsList = data['walls'].cast<String>();
      print(wallsList);
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('Wall hinzufügen'),
        centerTitle: true,
        backgroundColor: const Color(0xFFFE7B80),
        leading: IconButton(
          icon: Icon(Icons.clear),
          tooltip: 'Abbrechen',
          onPressed: _back,
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            tooltip: 'Akzeptieren',
            onPressed: _addWall,
          ),
        ],
      ),
      body: TextField(
        controller: wallIdController,
        decoration: InputDecoration(labelText: 'Wall ID'),
      ),
    ));
  }
}
