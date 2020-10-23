import 'package:flutter/material.dart';
import 'package:nepu_helper/common/Global.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class Class extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //Global.nowContext = context;
    //List<String> datas = getDataList();
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text("我的课表"),
          backgroundColor: Colors.blueAccent,
          centerTitle: true,
        ),
        body: new StaggeredGridView.countBuilder(
          crossAxisCount: 8,
        )
      )
    );
  }
}