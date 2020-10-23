import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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
          actions: <Widget>[
            new PopupMenuButton<String>(
              onSelected: (String value) {
                switch(value) {
                  case "changeWeek":
                    break;
                  case "changeXnxq":
                    break;
                  case "importFromJW":
                    break;
                  case "importFromDW":
                    break;
                  case "add":
                    break;
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem(
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      new Text('更改周'),
                    ],
                  ),
                  value: "changeWeek",
                ),
                PopupMenuItem(
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      new Text('更改学期'),
                    ],
                  ),
                  value: "changeXnxq",
                ),
                PopupMenuItem(
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        new Text('导入教务系统课表'),
                      ],
                    ),
                    value: "importFromJW",
                ),
                PopupMenuItem(
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        new Text('导入大物实验课表'),
                      ],
                    ),
                  value: "importFromDW",
                ),
                PopupMenuItem(
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        new Text('添加课程'),
                      ],
                    ),
                  value: "add",
                )
              ],
            )
          ],
        ),

        /*body: new StaggeredGridView.countBuilder(
          crossAxisCount: 8,
        )*/
      )
    );
  }
}