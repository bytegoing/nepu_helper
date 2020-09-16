import 'package:flutter/material.dart';
import 'package:nepu_helper/common/jiaowu.dart';
import 'package:nepu_helper/pages/jiaowu/chooseClassDetail.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class chooseClassPage extends StatefulWidget {
  @override
  _chooseClassPageState createState() => new _chooseClassPageState();
}

class _chooseClassPageState extends State<chooseClassPage> {
  List xkList = [];

  void initState() {
    super.initState();
    _loadXK();
  }

  Future _loadXK() async {
    Future.delayed(Duration.zero, () {
      EasyLoading.show(status: "正在加载选课信息...");
    });
    try {
      await _getXKInfo().then((value) {
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

  Future _getXKInfo() async {
    return Jiaowu().getXkList();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("学生选课"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: FlutterEasyLoading(
          child: Padding(
              padding: EdgeInsets.only(left:20.0, right:20.0, bottom: 10.0),
              child: Column(
                children:[
                  new Text("警告：谨慎在访问密集时使用本功能!(例：体育课抢课）", style:TextStyle(color: Colors.red),),
                  xkList.length > 0
                      ? new Container(
                      child: new ListView.builder(
                          shrinkWrap: true,
                          itemCount: xkList.length,
                          physics: ScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            return _getXkCard(index);
                          }
                      )
                  )
                      : Container(padding: EdgeInsets.only(top: 10.0), alignment: Alignment.center, child: Text("目前暂无选课信息"),),//scoreWidget,
                ]
              )
          )
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
                    Text(
                      "选课类别: "+xkList[index][1],
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "选课类别: " + xkList[index][2],
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      xkList[index][0] + "学期",
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "选课开始时间: "+xkList[index][3],
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "选课结束时间: "+xkList[index][4],
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Text(
                        "点击进入选课",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ]
              )
          )
      ),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return chooseClassDetail(xkList[index][5]);
        }));
      },
    );
  }
}