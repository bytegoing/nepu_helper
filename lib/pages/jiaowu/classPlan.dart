import 'package:flutter/material.dart';
import 'package:nepu_helper/common/Global.dart';
import 'package:nepu_helper/common/jiaowu.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class classPlanPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    //Global.nowContext = context;
    return FutureBuilder<List<dynamic>>(
      future: Jiaowu().getClassPlan(),
      builder: (context, AsyncSnapshot<List<dynamic>> value) {
        if(value.data != null) {
          return new Scaffold(
            appBar: new AppBar(
              title: new Text("教学计划"),
              backgroundColor: Colors.blueAccent,
              centerTitle: true,
            ),
            body: _getBodyWidget(value.data),
          );
        } else {
          return new Scaffold(
              appBar: new AppBar(
                title: new Text("教学计划"),
                backgroundColor: Colors.blueAccent,
                centerTitle: true,
              ),
              body: Center(
                child: Text("正在加载...", style: TextStyle(fontSize: 18)),
              )
          );
        }
      }
    );
  }
  Widget _getBodyWidget(list) {
    return FlutterEasyLoading (
        child: Padding(
            padding: EdgeInsets.only(left:20.0, right:20.0, bottom: 10.0),
            child: ListView (
                padding: EdgeInsets.only(bottom: 10.0),
                children: <Widget>[
                  list.length > 0
                      ? new Container(
                      child: new ListView.builder(
                          shrinkWrap: true,
                          itemCount: list.length,
                          physics: ScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            return _getClassCard(list[index]);
                          }
                      )
                  )
                      : Container(padding: EdgeInsets.only(top: 10.0), alignment: Alignment.center, child: Text("暂无教学计划"),),//scoreWidget,
                ]
            )
        )
    );
  }

  Widget _getClassCard(detailList) {
    return InkWell(
      child: Card (
          elevation: 5.0, //阴影
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14.0))), //圆角
          child: new Padding(
              padding: EdgeInsets.all(10.0),
              child: new Column(
                  children: <Widget>[
                    new Row(
                      children: <Widget>[
                        Expanded(
                            flex: 4,
                            child: Text(
                              detailList[0] + "学期",
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            )
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(
                            "课程编码: " + detailList[1],
                          ),
                        ),
                        /*Expanded(
                          flex: 2,
                          child: Text(
                            detailList[4] + "学分",
                          ),
                        ),*/
                      ]
                    ),
                    new Row(
                        children: <Widget> [
                          Expanded(
                            flex: 7,
                            child: Text(
                              detailList[2],
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              detailList[6],
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          )
                        ]
                    ),
                    new Row(
                        children: <Widget> [
                          Expanded(
                              flex: 1,
                              child: Text(
                                detailList[9],
                              )
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              detailList[3] + "学时",
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              detailList[4] + "学分",
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              detailList[5],
                            )
                          )
                        ]
                    ),
                    new Row(
                      children: <Widget>[new Text("开课单位: " + detailList[10], textAlign: TextAlign.left,),]
                    ),
                    new Row(
                      children: <Widget>[
                        Expanded(
                          flex: 6,
                          child: Text(
                            "方向: " + detailList[7]
                          )
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(detailList[8])
                        )
                      ],
                    )
                  ]
              )
          )
      ),
    );
  }
}