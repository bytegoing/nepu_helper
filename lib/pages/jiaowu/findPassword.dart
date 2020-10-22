import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nepu_helper/common/jiaowu.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nepu_helper/common/Global.dart';

class findPasswordForm extends StatefulWidget {
  @override
  _findPasswordFormState createState() => new _findPasswordFormState();
}

class _findPasswordFormState extends State<findPasswordForm> {
  TextEditingController _xhController = new TextEditingController();
  TextEditingController _passController = new TextEditingController();
  GlobalKey _formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    //Global.nowContext = context;
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("找回教务系统密码"),
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
                          keyboardType: TextInputType.number,
                          controller: _passController,
                          decoration: InputDecoration(
                            labelText: "身份证号码",
                            hintText: "身份证号码",
                            icon: Icon(Icons.lock),
                          ),
                          //校验
                          validator: (v) {
                            return v.trim().length > 0 ? null : "身份证号码不能为空!";
                          }
                      ),
                      new Text(""),
                      new RaisedButton(
                        child: new Text("确认"),
                        onPressed: () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          if((_formKey.currentState as FormState).validate()) {
                            Fluttertoast.showToast(
                              msg: "正在请求...",
                              gravity: ToastGravity.TOP,
                              backgroundColor: Colors.grey,
                              fontSize: 16,
                            );
                            try {
                              await Jiaowu().findPassword(_xhController.text, _passController.text);
                            } catch(e) {
                              print(e.toString());
                              Fluttertoast.showToast(
                                msg: "找回失败: " + e.toString(),
                                gravity: ToastGravity.TOP,
                                backgroundColor: Colors.grey,
                                fontSize: 16,
                              );
                              return;
                            }
                            Fluttertoast.showToast(
                              msg: "找回成功!教务系统密码已重置为身份证后六位!",
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
                    ]
                )
            )
        )
    );
  }
}