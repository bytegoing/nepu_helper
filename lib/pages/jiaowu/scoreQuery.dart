import 'package:flutter/material.dart';
import 'package:nepu_helper/common/jiaowu.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class scoreQueryPage extends StatefulWidget {
  @override
  _scoreQueryPageState createState() => new _scoreQueryPageState();
}

class _scoreQueryPageState extends State<scoreQueryPage> {
  List<DropdownMenuItem<dynamic>> kkxqList;
  List scoreList = [];
  Widget scoreWidget;
  String _dropdownValue;
  bool ifQuery = false;

  void initState() {
    super.initState();
    _loadXQ();
  }

  Future _loadXQ() async {
    Future.delayed(Duration.zero, () {
      EasyLoading.show(status: "正在加载学期信息...");
    });
    try {
      await _getXQInfo().then((value) {
        kkxqList = value;
      });
    } catch(e) {
      //错误
      Future.delayed(Duration.zero, () {
        EasyLoading.showError("加载失败! " + e.toString());
      });
      return;
    }
    Future.delayed(Duration.zero, () {
      EasyLoading.dismiss();
    });
    setState(() { });
  }

  Future _getXQInfo() async {
    return Jiaowu().getScoreXQ();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("成绩查询"),
          backgroundColor: Colors.blueAccent,
          centerTitle: true,
        ),
        body: FlutterEasyLoading (
          child: Padding(
            padding: EdgeInsets.only(left:20.0, right:20.0, bottom: 10.0),
            child: ListView (
                padding: EdgeInsets.only(bottom: 10.0),
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("选择学期："),
                      DropdownButton(
                          value: _dropdownValue,
                          items: kkxqList,
                          onChanged: (value) async {
                            _dropdownValue = value;
                            print("选中了: " + value);
                            EasyLoading.show(status: "正在加载成绩信息...");
                            try {
                              scoreList = await Jiaowu().getScore(value);
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
                          itemCount: scoreList.length,
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
        ),
    );
  }

  Widget _getScoreCard(int index) {
    if(index == 0) {
      return Container( alignment: Alignment.center, child: Text("已修读" + scoreList[index][0] + "学分,平均学分绩点:" + scoreList[index][1]));
    }
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
                              scoreList[index][1],
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
                              scoreList[index][2].toString() + scoreList[index][3],
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
                            flex: 2,
                            child: Text(
                              scoreList[index][0] + "学期",
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            )
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              scoreList[index][7] + "学时",
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                                scoreList[index][8] + "学分",
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              "查看详情"
                            ),
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
      scoreDetailList = await Jiaowu().getScoreDetail(scoreList[index][4]);
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
                    scoreList[index][1],
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
                    scoreList[index][2].toString() + scoreList[index][3],
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
                                scoreList[index][0]
                            )
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            scoreList[index][7] + "学时",
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            scoreList[index][8] + "学分",
                          ),
                        ),
                      ]
                  ),
                  new Row(
                      children: <Widget> [
                        Text(
                            "课程性质: " + scoreList[index][5]
                        )
                      ]
                  ),
                  new Row(
                      children: <Widget>[
                        new Text(
                          "课程类别: "+scoreList[index][6],
                        ),
                      ]
                  ),
                  new Row(
                      children: <Widget>[
                        new Text(
                            "考试性质: " + scoreList[index][9]
                        ),
                      ]
                  ),
                  new Row(
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
                  ),
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