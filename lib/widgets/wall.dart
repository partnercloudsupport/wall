import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:wall_ly/ui/fullscreen_image.dart';

class Wall extends StatefulWidget {
  const Wall({this.wallId, this.displayName});

  factory Wall.fromDocument(DocumentSnapshot document) {
    if(document == null)
      return null;

    return new Wall(
      wallId: document.documentID,
      displayName: document['displayName'],
    );
  }

  final String wallId;
  final String displayName;

  _Wall createState() => new _Wall(
        wallId: this.wallId,
        displayName: this.displayName,
      );
}

class _Wall extends State<Wall> {
  _Wall({this.wallId, this.displayName});

  final String wallId;
  final String displayName;

  StreamSubscription<QuerySnapshot> subscription;
  List<DocumentSnapshot> imageList;

  void _openWall(String wallId) {    
    subscription?.cancel();
    
    var collectionReference = Firestore.instance.collection('image_posts').where('wallId', isEqualTo: wallId);

    subscription = collectionReference.snapshots().listen((datasnapshot) {
      setState(() {
        imageList = datasnapshot.documents;
      });
    });
  }

  @override
  void initState() {
    super.initState();

    _openWall(widget.wallId);
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (imageList != null) {
      return new StaggeredGridView.countBuilder(
        padding: const EdgeInsets.all(8.0),
        crossAxisCount: 4,
        itemCount: imageList.length,
        itemBuilder: (context, i) {
          String imgPath = imageList[i].data['mediaUrl'];
          return new Material(
            elevation: 4.0,
            borderRadius: new BorderRadius.all(new Radius.circular(4.0)),
            child: new InkWell(
              onTap: () {
                Navigator.push(context, new MaterialPageRoute(builder: (context) => new FullScreenImagePage(imgPath)));
              },
              child: new Hero(
                tag: imgPath,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: new FadeInImage(
                    image: new NetworkImage(imgPath),
                    fit: BoxFit.cover,
                    placeholder: new AssetImage("assets/images/logo_couple_greyscale.png"),
                  ),
                ),
              ),
            ),
          );
        },
        staggeredTileBuilder: (i) => new StaggeredTile.count(2, i.isEven ? 2 : 3),
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
      );
    } else {
      return new Container(
          child: Center(
        child: new CircularProgressIndicator(),
      ));
    }
  }
}
