import 'package:flutter/material.dart';
import 'dart:async';
import 'package:nepu_helper/common/Global.dart';

//加载页面
class LoadingPage extends StatefulWidget {
  @override
  _LoadingState createState() => new _LoadingState();
}

class _LoadingState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    //运行init()
    Global.init();
    //停顿3秒
    new Future.delayed(Duration(seconds: 3), (){
      print("东油助手...");
      Navigator.of(context).pushReplacementNamed("/app");
    });
  }
  @override
  Widget build(BuildContext context) {
    return new Center(
      child: Stack(
        children: <Widget>[
          //加载图片
          //Image.asset("images/loading.png", fit: BoxFit.cover,),
        ]
      ),
    );
  }
}