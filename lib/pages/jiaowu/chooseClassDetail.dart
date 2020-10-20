import 'package:flutter/material.dart';
import 'package:nepu_helper/common/jiaowu.dart';
import 'package:nepu_helper/common/Global.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class chooseClassDetail extends StatefulWidget {
  final String url;
  chooseClassDetail(this.url);

  @override
  _chooseClassDetailState createState() => new _chooseClassDetailState();
  
}

class _chooseClassDetailState extends State<chooseClassDetail> {
  List xkList = [];

  void initState() {
    super.initState();
    _loadDetail();
  }

  Future _loadDetail() async {
    Future.delayed(Duration.zero, () {
      EasyLoading.show(status: "正在加载选课详细信息...");
    });
    try {
      await _getDetailInfo().then((value) {
        xkList = value;
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

  Future _getDetailInfo() async {
    return Jiaowu().getXkDetail(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    Global.nowContext = context;
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("学生选课"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: FlutterEasyLoading(
        child: Padding(
          padding: EdgeInsets.only(left:20.0, right:20.0, bottom: 10.0),
          child: xkList.length > 0 ? new Container(
            child: new ListView.builder(
                shrinkWrap: true,
                itemCount: xkList.length,
                physics: ScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return _getXkCard(index);
                }
            )
          ) : Container(padding: EdgeInsets.only(top: 10.0), alignment: Alignment.center, child: Text("暂无可选课程!"),),
        ),
      ),
    );
  }
  Widget _getXkCard(int index) {
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
                              xkList[index][0],
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
                              xkList[index][2].toString() + "学分",
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
                                "总量/余量: " + xkList[index][3] + "/" + xkList[index][4],
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              )
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              "周次: " + xkList[index][6],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              "时间: "+xkList[index][7],
                            ),
                          ),
                        ]
                    ),
                    new Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text("授课教师:"+xkList[index][5]),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text("授课单位:"+xkList[index][1], overflow: TextOverflow.ellipsis,),
                        )
                      ],
                    ),
                    new Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text("上课地点:"+xkList[index][8])
                        )
                      ]
                    ),
                    new Row(
                        children: [
                          Expanded(
                              flex: 2,
                              child: Text("课程属性:"+xkList[index][9])
                          ),
                          Expanded(
                              flex: 2,
                              child: Text("分组名:"+xkList[index][10])
                          )
                        ]
                    ),
                    new Row(
                        children: [
                          Expanded(
                              flex: 2,
                              child: Text("性别要求:"+xkList[index][11])
                          ),
                          Expanded(
                              flex: 2,
                              child: Text("上课班级:"+xkList[index][12])
                          )
                        ]
                    ),
                  ]
              )
          )
      ),
      onTap: () async {
        EasyLoading.show(status: "正在选课...");
        try {
          await Jiaowu().XuanKe(xkList[index][13]);
        } catch(e) {
          EasyLoading.showError(e.toString());
          return;
        }
        EasyLoading.showSuccess("选课成功!");
      },
    );
  }

}