import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:nepu_helper/pages/jiaowu/scoreQuery.dart';
import 'package:nepu_helper/pages/loginForm.dart';
import 'package:nepu_helper/common/Global.dart';
import 'package:nepu_helper/common/jiaowu.dart';
import 'package:nepu_helper/pages/jiaowu/selfInfo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class JiaowuPage extends StatefulWidget {
  @override
  _JiaowuPageState createState() => new _JiaowuPageState();
}

class _JiaowuPageState extends State<JiaowuPage> {

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      //home: new LoginRoute()
        home: new Scaffold(
            appBar: new AppBar(
              title: new Text("教务相关"),
              backgroundColor: Colors.blueAccent,
              centerTitle: true,
            ),
            body: FlutterEasyLoading (
              child: new ListView (
                  padding: const EdgeInsets.all(15.0),
                  children: <Widget> [
                    _buildProfile(context),
                    new SizedBox(height: 20),
                    _buildFunction(context)
                  ]
              ),
            )
        )
    );
  }
  Widget _buildProfile(BuildContext context) {
    //进行操作，判断是否保存过密码
    if(!Global.ifSavedJWProfile()) {
      //未登录
      return SizedBox(
          height: 145.0, //高度
          child: new Card(
              elevation: 10.0, //阴影
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14.0))), //圆角
              child: new Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 15.0),
                  child: new Column(
                      children: [
                        new ListTile(
                          title: new Text('请登录教务系统!', style: new TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: new Text('未登录'),
                        ),
                        RaisedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) {
                              return LoginForm();
                            })).then((data) {
                              setState(() {});
                            });
                          },
                          child: Text("登录"),
                          color: Colors.blueAccent,
                          textColor: Colors.white,
                        )
                      ]
                  )
              )
          )
      );
    } else {
      //已登录
      return SizedBox(
          height: 145.0, //高度
          child: new Card(
              elevation: 15.0, //阴影
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14.0))), //圆角
              child: new Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 15.0),
                  child: new Column(
                      children: [
                        new ListTile(
                          title: new Text(Global.profile.xm + ", 欢迎使用东油助手!", style: new TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: new Text("学号: "+Global.profile.xh),
                        ),
                        new Flex(
                          direction: Axis.horizontal,
                          children: [
                            Expanded(
                              flex: 1,
                              child: new Text(""),
                            ),
                            Expanded(
                              flex: 2,
                              child: RaisedButton(
                                onPressed: () async {
                                  //个人信息
                                  EasyLoading.show(status: "正在获取...");
                                  var info;
                                  try {
                                    info = await Jiaowu().getInfo();
                                  } catch(e) {
                                    EasyLoading.showError("加载失败! " + e.toString());
                                    return;
                                  }
                                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                                    return SelfInfo(info);
                                  }));
                                  EasyLoading.dismiss();
                                },
                                child: Text("个人信息", style: TextStyle(fontSize: 12)),
                                color: Colors.blueAccent,
                                textColor: Colors.white,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: new Text(""),
                            ),
                            Expanded(
                              flex: 2,
                              child: RaisedButton(
                                onPressed: () {
                                  //退出登录
                                  Global.removeJWProfile();
                                  setState(() {});
                                },
                                child: Text("退出登录",style: TextStyle(fontSize: 12)),
                                color: Colors.red,
                                textColor: Colors.white,
                              )
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(""),
                            )
                          ]
                        )
                      ]
                  )
              )
          )
      );
    }
  }

  Widget _buildFunction(BuildContext context) {
    List formList = [
      ['成绩查询', Icons.toc],
      ['补考报名', Icons.close],
      ['重修报名', Icons.refresh],
      ['教学计划', Icons.help_outline],
      ['学生选课', Icons.favorite_border],
      ['修改密码', Icons.lock_outline],
    ];
    List<Widget> tiles = [];
    for(var item in formList) {
      tiles.add(
        Container(
            /*decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 1,
              ),
            ),*/
            child: InkWell(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(item[1], size: 35),
                      Text(""),
                      Text(item[0], style: TextStyle(fontSize: 18))
                    ]
                ),
                onTap: () {
                  _onClick(item[0]);
                }
            )
        )
      );
    }
    return new Container(
      child: GridView.count(
          crossAxisCount: 3, //每行个数
          childAspectRatio: 1.0, //宽高比
          crossAxisSpacing: 0.0, //x轴间距
          mainAxisSpacing: 0.0, //y轴间距
          shrinkWrap: true,
          children: tiles,
      ),
    );
  }

  void _onClick(String type) {
    print("clicked: " + type);
    if(!Global.ifSavedJWProfile()) {
      EasyLoading.showError("请先登录教务系统!");
      return;
    }
    switch(type) {
      case "成绩查询":
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return scoreQueryPage();
        }));
        break;
      default:
        EasyLoading.showInfo("暂未开放!");
        break;
    }
  }
}