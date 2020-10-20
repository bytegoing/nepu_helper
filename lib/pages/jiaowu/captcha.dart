import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nepu_helper/common/Global.dart';
import 'package:nepu_helper/common/jiaowu.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class CaptchaPage extends StatefulWidget {
  @override
  _captchaPageState createState() => new _captchaPageState();
}

class _captchaPageState extends State<CaptchaPage> {

  @override
  Widget build(BuildContext context) {
    Global.nowContext = context;
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
                          child: new Row(
                            children: <Widget>[
                              new Image.memory(value.data),
                              new TextField(
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
                              new FlatButton(
                                  child: new Text("返回"),
                                  textColor: Colors.blueAccent,
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  }
                              ),
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
    Global.lastCaptcha = str;
  }
}