import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:nepu_helper/common/Global.dart';
import 'package:nepu_helper/common/jiaowu.dart';
//import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ClassPage extends StatefulWidget {
  @override
  _ClassPageState createState() => new _ClassPageState();
}

class _ClassPageState extends State<ClassPage> {
  List nowKb = [];
  String nowXnxq = "";
  int nowWeek = 0;

  Future _getKb(String xnxq) async {
    EasyLoading.show(status: "正在加载课表信息...");
    try {
      nowKb = await Jiaowu().getKcInfo(xnxq);
    } catch(e) {
      EasyLoading.showError("错误:"+e.toString());
    }
    EasyLoading.showSuccess("课表信息加载成功!");
    print("课表$nowKb");
  }

  List _getXnxqInfoWidget(context, xnxqInfo) {
    List<Widget> xnxqInfoWidget = [];
    xnxqInfo.forEach((key, value) {
      xnxqInfoWidget.add(
          SimpleDialogOption(
              onPressed: () {
                _getKb(value);
                Navigator.pop(context);
              },
              child: Text(key)
          )
      );
    });
    return xnxqInfoWidget;
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text("0000-0000-0学期,第00周"),
          backgroundColor: Colors.blueAccent,
          centerTitle: true,
          actions: <Widget>[
            new PopupMenuButton<String>(
              onSelected: (String value) async {
                switch(value) {
                  case "changeWeek":
                    break;
                  case "changeXnxq":
                    break;
                  case "importFromJW":
                    if(!Global.ifSavedJWProfile()) {
                      EasyLoading.showError("请先登录教务系统!");
                      return;
                    }
                    EasyLoading.show(status: "正在加载学年学期信息...");
                    Map xnxqInfo;
                    try {
                      xnxqInfo = await Jiaowu().getKcXnxq();
                    } catch(e) {
                      EasyLoading.showError("错误:"+e.toString());
                    }
                    EasyLoading.showSuccess("学年学期信息加载成功");
                    await showDialog(
                        context: context,
                        builder: (context) {
                          return SimpleDialog(
                            title: Text("请选择学期"),
                            children: _getXnxqInfoWidget(context, xnxqInfo),
                          );
                        }
                    );
                    break;
                  case "importFromDW":
                    if(!Global.ifSavedDWProfile()) {
                      EasyLoading.showError("请先登录大物实验系统!");
                      return;
                    }
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
        //body: nowKb.length > 0 ?  : StaggeredGridView.count(crossAxisCount: 8)
        /*body: new StaggeredGridView.countBuilder(
          crossAxisCount: 8,
        )*/
      )
    );
  }
}