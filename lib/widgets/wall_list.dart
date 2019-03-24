import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wall_ly/widgets/wall.dart';

import 'package:wall_ly/style/theme.dart' as ThemeColors;

class WallListView extends StatefulWidget {
  const WallListView({this.userId, this.currentWallId, this.onOpenWall, this.wallList, this.onWallListChanged});

  final String userId;
  final String currentWallId;
  final Function(String) onOpenWall;
  final List<Wall> wallList;
  final Function(List<Wall>) onWallListChanged;

  _WallListView createState() => new _WallListView();
}

class _WallListView extends State<WallListView> {

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

      List<Wall> l = new List<Wall>();
      for (var i = 0; i < userWallIds.length; i++) {
        DocumentSnapshot w = await Firestore.instance.collection('walls').document(userWallIds[i]).get();
        l.add(Wall.fromDocument(w));
      }

      widget.onWallListChanged(l);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.wallList?.length ?? 0,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(widget.wallList[index].displayName),
          leading: new IconTheme(
            data: new IconThemeData(color: ThemeColors.Colors.loginGradientEnd),
            child: new Icon(Icons.burst_mode),
          ),
          onTap: () {
            widget.onOpenWall(widget.wallList[index].wallId);
          },
          selected: widget.wallList[index].wallId == widget.currentWallId ? true : false,
        );
      },
    );
  }
}
