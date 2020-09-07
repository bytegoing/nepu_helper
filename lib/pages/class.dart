import 'package:flutter/material.dart';

class Class extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text("我的课表"),
          backgroundColor: Colors.blueAccent,
          centerTitle: true,
        ),
        body: new Center(
          child: new Text("课表正文,暂未开放,点击下方“教务”试试看吧！"),
        )
      )
    );
  }
}