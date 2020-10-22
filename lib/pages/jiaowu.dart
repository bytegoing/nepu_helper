import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:nepu_helper/common/Global.dart';

import 'package:nepu_helper/pages/jiaowu/scoreQuery.dart';
import 'package:nepu_helper/pages/jiaowu/classPlan.dart';
import 'package:nepu_helper/pages/jiaowu/loginForm.dart';
import 'package:nepu_helper/pages/jiaowu/selfInfo.dart';
import 'package:nepu_helper/pages/jiaowu/changePassword.dart';
import 'package:nepu_helper/pages/jiaowu/chooseClass.dart';
import 'package:nepu_helper/pages/jiaowu/resit.dart';
import 'package:nepu_helper/pages/jiaowu/retake.dart';

import 'package:nepu_helper/pages/dawu/loginDWForm.dart';
import 'package:nepu_helper/pages/dawu/changePassword.dart';
import 'package:nepu_helper/pages/dawu/chooseExp.dart';
import 'package:nepu_helper/pages/dawu/notification.dart';
import 'package:nepu_helper/pages/dawu/seeExp.dart';

class JiaowuPage extends StatefulWidget {
  @override
  _JiaowuPageState createState() => new _JiaowuPageState();
}

class _JiaowuPageState extends State<JiaowuPage> {

  @override
  Widget build(BuildContext context) {
    //Global.nowContext = context;
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
                    _buildFunction(context),
                    new SizedBox(height: 10),
                    _buildDWProfile(context),
                    new SizedBox(height: 20),
                    _buildDWFunction(context),
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
                                onPressed: () {
                                  //个人信息
                                  _onClick("个人信息");
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

  Widget _buildDWProfile(BuildContext context) {
    //进行操作，判断是否保存过密码
    if(!Global.ifSavedDWProfile()) {
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
                          title: new Text('请登录大物实验系统!', style: new TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: new Text('未登录'),
                        ),
                        RaisedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) {
                              return LoginDWForm();
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
                          title: new Text("已登录大物实验系统!", style: new TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: new Text(Global.profile.dwXm+","+Global.profile.dwUsr),
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
                                  onPressed: () {
                                    //个人信息
                                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                                      return SelfInfo();
                                    }));
                                  },
                                  child: Text("信息", style: TextStyle(fontSize: 16)),
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
                                      Global.removeDWProfile();
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
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, //每行个数
        childAspectRatio: 1.0, //宽高比
        crossAxisSpacing: 0.0, //x轴间距
        mainAxisSpacing: 0.0, //y轴间距
      ),
      itemCount: formList.length,
      shrinkWrap: true,
      physics: new NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(formList[index][1], size: 35),
                  Text(""),
                  Text(formList[index][0], style: TextStyle(fontSize: 18))
                ]
            ),
            onTap: () {
              _onClick(formList[index][0]);
            }
        );
      },
    );
  }

  Widget _buildDWFunction(context) {
    List formList = [
      ['查看通知', Icons.notifications_none],
      ['选择实验', Icons.calendar_today],
      ['已选实验', Icons.info_outline],
      ['修改密码', Icons.lock_outline],
    ];
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, //每行个数
        childAspectRatio: 1.0, //宽高比
        crossAxisSpacing: 0.0, //x轴间距
        mainAxisSpacing: 0.0, //y轴间距
      ),
      itemCount: formList.length,
      shrinkWrap: true,
      physics: new NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(formList[index][1], size: 35),
                  Text(""),
                  Text(formList[index][0], style: TextStyle(fontSize: 18))
                ]
            ),
            onTap: () {
              _onDWClick(formList[index][0]);
            }
        );
      },
    );
  }

  Future _onClick(String type) async {
    print("clicked: " + type);
    if(!Global.ifSavedJWProfile()) {
      EasyLoading.showError("请先登录教务系统!");
      return;
    }
    switch(type) {
      case "成绩查询":
        await Navigator.of(context).push(MaterialPageRoute(builder: (context) => scoreQueryPage()));
        setState(() {});
        break;
      case "教学计划":
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
          return classPlanPage();
        }));
        setState(() {});
        break;
      case "修改密码":
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
          return changePasswordForm();
        }));
        setState(() {});
        break;
      case "学生选课":
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
          return chooseClassPage();
        }));
        setState(() {});
        break;
      default:
        EasyLoading.showInfo("暂未开放!");
        break;
    }
    //Global.nowContext = context;
  }

  Future _onDWClick(String type) async {
    print("clicked DW: " + type);
    if(!Global.ifSavedDWProfile() && type != "查看通知") {
      EasyLoading.showError("请先登录大物实验系统!");
      return;
    }
    switch(type) {
      /*case "成绩查询":
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return scoreQueryPage();
        }));
        break;
      case "教学计划":
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return classPlanPage();
        }));
        break;*/
      default:
        EasyLoading.showInfo("暂未开放!");
        break;
    }
  }
}