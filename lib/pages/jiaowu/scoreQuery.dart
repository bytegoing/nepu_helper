import 'package:flutter/material.dart';
import 'package:nepu_helper/common/jiaowu.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:nepu_helper/common/Global.dart';

class scoreQueryPage extends StatefulWidget {
  @override
  _scoreQueryPageState createState() => new _scoreQueryPageState();
}

class _scoreQueryPageState extends State<scoreQueryPage> {
  List scoreList = [];
  String xq = "";
  String jh = "";
  String _xqDropdownValue, _jhDropdownValue;
  bool ifQuery = false;

  @override
  Widget build(BuildContext context) {
    //Global.nowContext = context;
    return new FutureBuilder<List>(
      future: Jiaowu().getScoreInfo(),
      builder: (context, value) {
        if(value.data != null) {
          return new Scaffold(
            appBar: new AppBar(
              title: new Text("成绩查询"),
              backgroundColor: Colors.blueAccent,
              centerTitle: true,
            ),
            /*body: FlutterEasyLoading (
                child:
            ),*/
            body: Padding(
                padding: EdgeInsets.only(left:20.0, right:20.0, bottom: 10.0),
                child: ListView (
                    padding: EdgeInsets.only(bottom: 10.0),
                    children: <Widget>[
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text("选择学期："),
                            DropdownButton(
                                value: _xqDropdownValue,
                                items: value.data[0],
                                onChanged: (value) async {
                                  _xqDropdownValue = value;
                                  print("选中了: " + value);
                                  EasyLoading.show(status: "正在加载成绩信息...");
                                  xq = value;
                                  try {
                                    scoreList = await Jiaowu().getScore(xq, jh);
                                  } catch(e) {
                                    //错误
                                    EasyLoading.showError("加载失败! " + e.toString());
                                    return;
                                  }
                                  EasyLoading.dismiss();
                                  ifQuery = true;
                                  setState(() { });
                                }
                            ),
                          ]
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text("选择计划："),
                            DropdownButton(
                                value: _jhDropdownValue,
                                items: value.data[1],
                                hint: Text("全部"),
                                onChanged: (value) async {
                                  _jhDropdownValue = value;
                                  print("选中了: " + value);
                                  jh = value;
                                  EasyLoading.show(status: "正在加载成绩信息...");
                                  try {
                                    scoreList = await Jiaowu().getScore(xq, jh);
                                  } catch(e) {
                                    //错误
                                    EasyLoading.showError("加载失败! " + e.toString());
                                    return;
                                  }
                                  EasyLoading.dismiss();
                                  ifQuery = true;
                                  setState(() { });
                                }
                            ),
                          ]
                      ),
                      scoreList.length > 1 || !ifQuery
                          ? new Container(
                          child: new ListView.builder(
                              shrinkWrap: true,
                              itemCount: scoreList.length+1,
                              physics: ScrollPhysics(),
                              itemBuilder: (BuildContext context, int index) {
                                return _getScoreCard(index);
                              }
                          )
                      )
                          : Container(padding: EdgeInsets.only(top: 10.0), alignment: Alignment.center, child: Text("该学期暂无成绩"),),//scoreWidget,
                    ]
                )
            )
          );
        } else {
          return new Scaffold(
              appBar: new AppBar(
                title: new Text("成绩信息"),
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

  Widget _getScoreCard(int index) {
    if(index == 0) {
      return Container( alignment: Alignment.center, child: Text("共有"+scoreList.length.toString()+"条记录"));
    }
    index--;
    return InkWell (
      child: Card (
          elevation: 5.0, //阴影
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14.0))), //圆角
          child: new Padding(
              padding: EdgeInsets.all(10.0),
              child: new Column(
                  children: <Widget>[
                    new Row(
                        children: <Widget> [
                          Expanded(
                            flex: 5,
                            child: Text(
                              scoreList[index]["kcmc"],
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              scoreList[index]["zcj"].toString(),
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          )
                        ]
                    ),
                    new Text(""),
                    new Row(
                        children: <Widget> [
                          Expanded(
                              flex: 3,
                              child: Text(
                                scoreList[index]["xnxqmc"],
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              )
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              scoreList[index]["xf"] + "学分",
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              "GPA"+scoreList[index]["cjjd"],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                                scoreList[index]["xdfsmc"],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              "详情",
                            )
                          )
                        ]
                    ),
                  ]
              )
          )
      ),
      onTap: () {
        _showScoreDetail(index);
      },
    );
  }

  Future _showScoreDetail(int index) async {
    //先获取详细成绩信息
    List scoreDetailList = [];
    try {
      scoreDetailList = await Jiaowu().getScoreDetail(scoreList[index]["cjdm"]);
    } catch(e) {
      //错误
      EasyLoading.showError("加载失败! " + e.toString());
      return;
    }
    EasyLoading.dismiss();
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
              title: new Row(
                  children: <Widget> [
                    Expanded(
                      flex: 5,
                      child: Text(
                        scoreList[index]["kcmc"],
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        scoreList[index]["zcj"],
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    )
                  ]
              ),
              content: new SingleChildScrollView(
                child: new ListBody(
                    children: <Widget>[
                      new Row(
                          children: <Widget> [
                            Expanded(
                                flex: 2,
                                child: Text(
                                    scoreList[index]["xnxqmc"]
                                )
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                scoreList[index]["zxs"] + "学时",
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                scoreList[index]["xf"] + "学分",
                              ),
                            ),
                          ]
                      ),
                      new Row(
                          children: <Widget> [
                            Text(
                                "课程性质: " + scoreList[index]["kcdlmc"]
                            )
                          ]
                      ),
                      new Row(
                          children: <Widget>[
                            new Text(
                              "课程类别: "+scoreList[index]["xdfsmc"],
                            ),
                          ]
                      ),
                      new Row(
                          children: <Widget>[
                            new Text(
                                "考试性质: " + scoreList[index]["ksxzmc"]
                            ),
                          ]
                      ),
                      /*new Row(
                          children: <Widget> [
                            Expanded(
                                flex: 1,
                                child: Text("平时成绩:" + scoreDetailList[0])
                            ),
                            Expanded(
                                flex: 1,
                                child: Text("比列:" + scoreDetailList[1])
                            ),
                          ]
                      ),
                      new Row(
                          children: <Widget>[
                            Expanded(
                                flex: 1,
                                child: Text("期中成绩:" + scoreDetailList[2])
                            ),
                            Expanded(
                                flex: 1,
                                child: Text("比列:" + scoreDetailList[3])
                            )
                          ]
                      ),
                      new Row(
                          children: <Widget> [
                            Expanded(
                                flex: 1,
                                child: Text("期末成绩:" + scoreDetailList[4])
                            ),
                            Expanded(
                                flex: 1,
                                child: Text("比列:" + scoreDetailList[5])
                            ),
                          ]
                      ),*/
                    ]
                ),
              ),
              actions: <Widget>[
                new FlatButton(
                    child: new Text("返回"),
                    textColor: Colors.blueAccent,
                    onPressed: () {
                      Navigator.of(context).pop();
                    }
                )
              ]
          );
        }
    );
  }
}