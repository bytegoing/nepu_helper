import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nepu_helper/common/jiaowu.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nepu_helper/pages/jiaowu/findPassword.dart';
import 'package:nepu_helper/common/Global.dart';

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
    //Global.nowContext = context;
    return new Scaffold(
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
                      new RaisedButton(
                        child: new Text("确认"),
                        onPressed: () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          if((_formKey.currentState as FormState).validate()) {
                            EasyLoading.show(status: "正在登录...");
                            /*Fluttertoast.showToast(
                              msg: "正在登录...",
                              gravity: ToastGravity.TOP,
                              backgroundColor: Colors.grey,
                              fontSize: 16,
                            );*/
                            try {
                              await Jiaowu().login(_xhController.text, _passController.text);
                            } catch(e) {
                              print(e.toString());
                              EasyLoading.showError("登陆失败:"+e.toString());
                              /*Fluttertoast.showToast(
                                msg: "登录失败: " + e.toString(),
                                gravity: ToastGravity.TOP,
                                backgroundColor: Colors.grey,
                                fontSize: 16,
                              );*/
                              return;
                            }
                            /*Fluttertoast.showToast(
                              msg: "登录成功",
                              gravity: ToastGravity.TOP,
                              backgroundColor: Colors.grey,
                              fontSize: 16,
                            );*/
                            EasyLoading.showSuccess("登录成功");
                            Navigator.pop(context);
                          }
                        },
                        color: Colors.blueAccent,
                        textColor: Colors.white,
                      ),
                      new RaisedButton(
                        child: new Text("找回密码"),
                        onPressed: () async {
                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return findPasswordForm();
                          })).then((data) {
                            setState(() {});
                          });
                        },
                        color: Colors.blueAccent,
                        textColor: Colors.white,
                      ),
                    ]
                )
            )
        )
    );
  }
}