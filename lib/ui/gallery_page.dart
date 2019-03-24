import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter/material.dart';
import 'package:wall_ly/style/theme.dart' as ThemeColors;
import 'package:wall_ly/services/auth.dart';
import 'package:wall_ly/ui/add_wall.dart';
import 'package:wall_ly/widgets/wall.dart';
import 'package:wall_ly/widgets/wall_list.dart';

class GalleryPage extends StatefulWidget {
  GalleryPage({Key key, this.auth, this.userId, this.onSignedOut}) : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;

  @override
  _GalleryPageState createState() => new _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  File _image;
  bool uploading = false;

  DocumentSnapshot currentWall;
  List<Wall> wallList = new List<Wall>();
  void setWallList(List<Wall> newList) {
    setState(() {
      wallList = newList;
    });
  }

  String view = "grid";
  int crossAxisCount = 4;

  _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  Future getImageFromCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
    });

    postImage();
  }

  void postImage() {
    setState(() {
      uploading = true;
    });
    //compressImage();
    uploadImage(_image).then((String data) {
      postToFireStore(mediaUrl: data, description: "");
    }).then((_) {
      setState(() {
        _image = null;
        uploading = false;
      });
    });
  }

  Future<String> uploadImage(var imageFile) async {
    var uuid = new Uuid().v1();
    StorageReference ref = FirebaseStorage.instance.ref().child("post_$uuid.jpg");
    StorageUploadTask uploadTask = ref.putFile(imageFile);

    String downloadUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
    return downloadUrl;
  }

  void postToFireStore({String mediaUrl, String description}) async {
    var reference = Firestore.instance.collection('image_posts');

    reference.add({
      "wallId": currentWall.documentID,
      "mediaUrl": mediaUrl,
      "description": description,
      "ownerId": widget.auth.getCurrentUserInfo() != null ? widget.auth.getCurrentUserInfo().uid : "",
      "timestamp": new DateTime.now().toString(),
    }).then((DocumentReference doc) {
      String docId = doc.documentID;
      reference.document(docId).updateData({"postId": docId});
    });
  }

  void _openWall(String wallId) async {
    DocumentSnapshot w = await Firestore.instance.collection('walls').document(wallId).get();

    //rebuild layout
    setState(() {
      currentWall = w;
    });
  }

  @override
  void initState() {
    super.initState();

    widget.auth.getCurrentUserInfo();

    //TODO: open last wall
    _openWall("Pa7tjHw8XeA5LypbxVs2");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Wall.ly', style: TextStyle(color: Colors.white, fontFamily: 'AsmelinaHarley', fontWeight: FontWeight.bold, fontSize: 24)),
          centerTitle: true,
          backgroundColor: const Color(0xFFFE7B80),
        ),
        drawer: Drawer(
            child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              margin: EdgeInsets.all(0),
              decoration: BoxDecoration(
                gradient: new LinearGradient(
                    colors: [ThemeColors.Colors.loginGradientStart, ThemeColors.Colors.loginGradientEnd],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    stops: [0.0, 1.0],
                    tileMode: TileMode.clamp),
              ),
              accountName:
                  Text(widget.auth.getCurrentUserInfo() != null ? widget.auth.getCurrentUserInfo().displayName : ""),
              accountEmail:
                  Text(widget.auth.getCurrentUserInfo() != null ? widget.auth.getCurrentUserInfo().email : ""),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Theme.of(context).platform == TargetPlatform.iOS ? Colors.blue : Colors.white,
                child: Text(
                  "A",
                  style: TextStyle(fontSize: 40.0),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                physics: const AlwaysScrollableScrollPhysics(),
                primary: true,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.0, 0, 10, 0),
                    child: Text(
                      'Walls',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  WallListView(
                      userId: widget.userId,
                      currentWallId: currentWall?.documentID,
                      onOpenWall: _openWall,
                      wallList: wallList,
                      onWallListChanged: setWallList),
                  Divider(),
                  ListTile(
                    title: Text("Wall hinzufügen"),
                    leading: Icon(Icons.add),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddWallPage(auth: widget.auth, userId: widget.userId)),
                      );
                    },
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Abmelden"),
                    leading: Icon(Icons.exit_to_app),
                    onTap: () {
                      _signOut();
                    },
                  ),
                ],
              ),
            ),
          ],
        )),
        body: Wall.fromDocument(currentWall),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            getImageFromCamera();
          },
          child: Icon(Icons.add_a_photo),
          backgroundColor: ThemeColors.Colors.loginGradientEnd,
        ),
      ),
    );
  }

  getRandomString() {}
}
