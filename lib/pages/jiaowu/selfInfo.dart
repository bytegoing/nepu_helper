import 'package:flutter/material.dart';
import 'package:nepu_helper/common/Global.dart';
import 'package:nepu_helper/common/jiaowu.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class SelfInfo extends StatelessWidget {
  Map<String, dynamic> _info;

  SelfInfo(info) {
    _info = info;
  }

  @override
  Widget build(BuildContext context) {
    //获取信息
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("个人信息"),
          backgroundColor: Colors.blueAccent,
          centerTitle: true,
        ),
        body: new Center(
            child: new FlutterEasyLoading(
                child: new Padding(
                    padding: EdgeInsets.all(15),
                    child: new Card (
                        elevation: 10.0, //阴影
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(14.0))), //圆角
                        child: new ListView(
                            padding: const EdgeInsets.all(15),
                            children: <Widget>[
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Image(
                                      image: new NetworkImage(
                                          'http://jwgl.nepu.edu.cn/uploadfile/studentphoto/pic/' +
                                              Global.profile.xh + ".JPG"),
                                      height: 120,
                                    ),
                                    Text("学籍照片"),
                                    Text(""),
                                  ]
                              ),
                              Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: Text("姓名"),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Text(_info["姓名"]),
                                    )
                                  ]
                              ),
                              Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: Text("出生日期"),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(_info["出生日期"]),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text("本人电话"),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(_info["本人电话"]),
                                    )
                                  ]
                              ),
                              Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: Text("身份证号"),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Text(_info["身份证编号"]),
                                    )
                                  ]
                              ),
                              Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: Text("院系"),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Text(_info["院系"]),
                                    )
                                  ]
                              ),
                              Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: Text("班级"),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(_info["班级"]),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text("学制"),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(_info["学制"]),
                                    )
                                  ]
                              ),
                              Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: Text("入学日期"),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(_info["入学日期"]),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text("入学考号"),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(_info["入学考号"]),
                                    )
                                  ]
                              ),
                              Text(""),
                              Text(
                                "提示：请注意保护信息安全,不要透露给别人!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              )
                            ]
                        )
                    )
                )
            )
        )
    );
  }
}
