import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nepu_helper/common/jiaowu.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => new _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  TextEditingController _xhController = new TextEditingController();
  TextEditingController _passController = new TextEditingController();
  GlobalKey _formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        home: new Scaffold(
            appBar: new AppBar(
              title: new Text("教务系统登录"),
              backgroundColor: Colors.blueAccent,
              centerTitle: true,
            ),
            body: FlutterEasyLoading(
              child: Form(
                  key: _formKey,
                  autovalidate: true,
                  child: new ListView(
                      padding: const EdgeInsets.all(15.0),
                      children: <Widget>[
                        new TextFormField(
                            keyboardType: TextInputType.number,
                            controller: _xhController,
                            decoration: InputDecoration(
                              labelText: "教务系统账号",
                              hintText: "学号",
                              icon: Icon(Icons.people),
                            ),
                            //校验
                            validator: (v) {
                              return v.trim().length > 0 ? null : "用户名不能为空!";
                            }
                        ),
                        new TextFormField(
                            controller: _passController,
                            decoration: InputDecoration(
                              labelText: "教务系统密码",
                              hintText: "密码",
                              icon: Icon(Icons.lock),
                            ),
                            obscureText: true,
                            //校验
                            validator: (v) {
                              return v.trim().length > 0 ? null : "密码不能为空!";
                            }
                        ),
                        new Text(""),
                        new Flex(
                            direction: Axis.horizontal,
                            children: <Widget>[
                              Expanded(
                                  flex: 1,
                                  child: new Text("")
                              ),
                              Expanded(
                                flex: 2,
                                child: RaisedButton(
                                  child: new Text("确认"),
                                  onPressed: () async {
                                    EasyLoading.show(status: '正在登录...');
                                    if((_formKey.currentState as FormState).validate()) {
                                      //OK
                                      try {
                                        await Jiaowu().login(_xhController.text, _passController.text);
                                      } catch(e) {
                                        print(e.toString());
                                        EasyLoading.showError("登录失败: " + e.toString());
                                        return;
                                      }
                                      EasyLoading.showSuccess("登录成功");
                                      Navigator.pop(context);
                                    }
                                  },
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
                                    child: new Text("取消"),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    color: Colors.blueAccent,
                                    textColor: Colors.white,
                                  )
                              ),
                              Expanded(
                                  flex: 1,
                                  child: new Text("")
                              ),
                            ]
                        )
                      ]
                  )
              )
            )
        )
    );
  }
}