import 'package:flutter/material.dart';
import 'package:nepu_helper/app.dart';
import 'package:nepu_helper/loading.dart';

//程序主入口点
void main() => runApp(NEPUHelper());

MaterialApp NEPUHelper() {
  return MaterialApp(
    title: '东油助手',
    //注册路由表
    routes: <String, WidgetBuilder> {
      "/app": (BuildContext context) => new App(),
    },
    home: new LoadingPage(), //加载页面
  );
}