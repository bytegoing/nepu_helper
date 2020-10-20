import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nepu_helper/common/jiaowu.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nepu_helper/common/Global.dart';

class changePasswordForm extends StatefulWidget {
  @override
  _changePasswordFormState createState() => new _changePasswordFormState();
}

class _changePasswordFormState extends State<changePasswordForm> {
  TextEditingController _oldPassController = new TextEditingController();
  TextEditingController _newPass1Controller = new TextEditingController();
  TextEditingController _newPass2Controller = new TextEditingController();
  GlobalKey _formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Global.nowContext = context;
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("修改教务系统密码"),
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
                      /*new TextFormField(
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
                      ),*/
                      new Text(
                        "教务系统账号: " + Global.profile.xh,
                      ),
                      new TextFormField(
                          controller: _oldPassController,
                          decoration: InputDecoration(
                            labelText: "教务系统原密码",
                            hintText: "原密码",
                            icon: Icon(Icons.lock),
                          ),
                          obscureText: true,
                          //校验
                          validator: (v) {
                            return v.trim().length > 0 ? null : "原密码不能为空!";
                          }
                      ),
                      new TextFormField(
                          controller: _newPass1Controller,
                          decoration: InputDecoration(
                            labelText: "新密码",
                            hintText: "新密码",
                            icon: Icon(Icons.lock),
                          ),
                          obscureText: true,
                          //校验
                          validator: (v) {
                            if(v.trim().length < 8) return "新密码必须不少于八位!";
                            if(_newPass2Controller.text != v) return "两次密码输入不一致!";
                            return null;
                          }
                      ),
                      new TextFormField(
                          controller: _newPass2Controller,
                          decoration: InputDecoration(
                            labelText: "确认新密码",
                            hintText: "确认新密码",
                            icon: Icon(Icons.lock),
                          ),
                          obscureText: true,
                          //校验
                          validator: (v) {
                            if(v.trim().length < 8) return "确认新密码必须不少于八位!";
                            if(_newPass1Controller.text != v) return "两次密码输入不一致!";
                            return null;
                          }
                      ),
                      new Text(""),
                      new RaisedButton(
                        child: new Text("确认"),
                        onPressed: () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          if((_formKey.currentState as FormState).validate()) {
                            Fluttertoast.showToast(
                              msg: "正在重置...",
                              gravity: ToastGravity.TOP,
                              backgroundColor: Colors.grey,
                              fontSize: 16,
                            );
                            try {
                              await Jiaowu().changePassword(_oldPassController.text, _newPass1Controller.text);
                            } catch(e) {
                              print(e.toString());
                              Fluttertoast.showToast(
                                msg: "修改失败: " + e.toString(),
                                gravity: ToastGravity.TOP,
                                backgroundColor: Colors.grey,
                                fontSize: 16,
                              );
                              return;
                            }
                            Fluttertoast.showToast(
                              msg: "修改成功!请重新登录",
                              gravity: ToastGravity.TOP,
                              backgroundColor: Colors.grey,
                              fontSize: 16,
                            );
                            Navigator.pop(context);
                          }
                        },
                        color: Colors.blueAccent,
                        textColor: Colors.white,
                      ),
                      new Text(
                          "提示: 若忘记教务系统密码,请退出登录后使用登录界面的“找回密码”功能进行找回。",
                          style: TextStyle(color: Colors.red),
                      ),
                    ]
                )
            )
        )
    );
  }
}