import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wall_ly/widgets/wall.dart';

import 'package:wall_ly/style/theme.dart' as ThemeColors;

class WallListView extends StatefulWidget {
  const WallListView({this.userId, this.currentWallId, this.onOpenWall});

  final String userId;
  final String currentWallId;
  final Function(String) onOpenWall;

  _WallListView createState() => new _WallListView(
        userId: this.userId,
      );
}

class _WallListView extends State<WallListView> {
  _WallListView({this.userId});

  final String userId;

  List<Wall> wallsList;

  @override
  void initState() {
    super.initState();

    _initWallList();
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  StreamSubscription<DocumentSnapshot> subscription;

  void _initWallList() async {
    var reference = Firestore.instance.collection('users').document(widget.userId);
    subscription = reference.snapshots().listen((data) {
      _updateWallList(data);
    });
  }

  void _updateWallList(DocumentSnapshot data) async {
    if (data != null && data.exists && data['walls'] != null) {
      List<String> userWallIds;
      userWallIds = data['walls'].cast<String>();

      wallsList = new List<Wall>();

      for (var i = 0; i < userWallIds.length; i++) {
        DocumentSnapshot w = await Firestore.instance.collection('walls').document(userWallIds[i]).get();
        wallsList.add(Wall.fromDocument(w));
      }

      setState(() { });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: wallsList?.length ?? 0,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(wallsList[index].displayName),
          leading: new IconTheme(
            data: new IconThemeData(color: ThemeColors.Colors.loginGradientEnd),
            child: new Icon(Icons.burst_mode),
          ),
          onTap: () {
            widget.onOpenWall(wallsList[index].wallId);
          },
          selected: wallsList[index].wallId == widget.currentWallId ? true : false,
        );
      },
    );
  }
}
