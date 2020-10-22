import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nepu_helper/common/Global.dart';
import 'package:nepu_helper/common/jiaowu.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CaptchaPage extends StatefulWidget {
  @override
  _captchaPageState createState() => new _captchaPageState();
}

class _captchaPageState extends State<CaptchaPage> {

  @override
  Widget build(BuildContext context) {
    //Global.nowContext = context;
    //获取信息
    return FutureBuilder<Uint8List>(
      future: Jiaowu().getCaptchaIMG(),
      builder: (context, AsyncSnapshot<Uint8List> value) {
        if(value.data != null) {
          return new Scaffold(
              appBar: new AppBar(
                title: new Text("请输入验证码"),
                backgroundColor: Colors.blueAccent,
                centerTitle: true,
              ),
              body: new Center(
                  child: new FlutterEasyLoading(
                      child: new Padding(
                          padding: EdgeInsets.all(15),
                          child: new Column(
                            children: <Widget>[
                              new Expanded(
                                child: new Center(
                                    child: new Container(
                                      child: new Image.memory(
                                        value.data,
                                        fit: BoxFit.contain,
                                      ),
                                    )
                                ),
                                flex: 1,
                              ),
                              new Expanded(
                                child: new TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(10.0),
                                    icon: Icon(Icons.text_fields),
                                    labelText: '请输入验证码',
                                    helperText: '请输入验证码',
                                  ),
                                  onChanged: _textFieldChanged,
                                  autofocus: false,
                                ),
                                flex: 1,
                              ),
                              new Expanded(
                                child: new FlatButton(
                                    child: new Text("确认"),
                                    textColor: Colors.blueAccent,
                                    onPressed: () {
                                      /*if(Global.lastCaptcha.length <= 0) {
                                        Fluttertoast.showToast(
                                          msg: "请输入验证码!",
                                          gravity: ToastGravity.TOP,
                                          backgroundColor: Colors.grey,
                                          fontSize: 16,
                                        );
                                      } else {
                                        Navigator.of(context).pop();
                                      }*/
                                    }
                                ),
                                flex: 1,
                              )
                            ]
                          )
                      )
                  )
              )
          );
        } else {
          return new Scaffold(
              appBar: new AppBar(
                title: new Text("请输入验证码"),
                backgroundColor: Colors.blueAccent,
                centerTitle: true,
              ),
              body: Center(
                child: Text("正在加载验证码...", style: TextStyle(fontSize: 18)),
              )
          );
        }
      },
    );
  }
  void _textFieldChanged(String str) {
    //Global.lastCaptcha = str;
  }
}