import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:nepu_helper/pages/class.dart';
import 'package:nepu_helper/pages/jiaowu.dart';
import 'package:nepu_helper/common/Global.dart';

class App extends StatefulWidget {
  @override
  _AppState createState() => new _AppState();
}

class _AppState extends State<App> with SingleTickerProviderStateMixin {
  TabController tabController;

  //初始化,主要初始化tabController
  @override
  void initState() {
    tabController = new TabController(length: 2, vsync: this);
  }

  //销毁时操作
  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  //底边栏具体布局
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorKey: Global.navigatorKey,
        home: new Scaffold(
          body: new TabBarView(
            controller: tabController,
            //底部栏元素所对应的方法
            children: <Widget>[
              new ClassPage(),
              new JiaowuPage(),
            ],
          ),
          bottomNavigationBar: new Material(
              color: Colors.white,
              child: new TabBar(
                  controller: tabController,
                  //选中后颜色
                  labelColor: Colors.blueAccent,
                  //未选中标签颜色
                  unselectedLabelColor: Colors.black26,
                  //底部栏元素（对应上方方法）
                  tabs: <Widget>[
                    new Tab(
                        text: "课表",
                        icon: new Icon(Icons.calendar_today)
                    ),
                    new Tab(
                        text: "教务",
                        icon: new Icon(Icons.assessment)
                    ),
                  ]
              )
          ),
        ),
        builder: (BuildContext context, Widget child) {
          return FlutterEasyLoading(child: child);
        },
    );
  }
}