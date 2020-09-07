import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:nepu_helper/common/Global.dart';
import 'package:nepu_helper/common/jiaowuCaptcha.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:universal_html/parsing.dart';
import 'package:flutter/services.dart';

class Jiaowu {
  String baseUrl = "http://jwgl.nepu.edu.cn/";

  var httpHeaders = {
    'Accept': 'application/json, text/plain, */*',
    'Accept-Encoding': 'gzip, deflate, br',
    'Accept-Language': 'zh-CN,zh;q=0.9',
    'Connection': 'keep-alive',
    'Host': 'jwgl.nepu.edu.cn',
    'Origin': 'http://jwgl.nepu.edu.cn',
    'Referer': 'http://jwgl.nepu.edu.cn/',
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.77 Safari/537.36',
  };

  Future<Dio> getDio({bool addCookie = true, bool autoLogin = true}) async {
    print("新建Dio!");
    Dio dio = Dio();
    dio.options.baseUrl = baseUrl;
    dio.options.connectTimeout = 6000; //5s
    dio.options.receiveTimeout = 4000;
    if(addCookie) {
      if(Global.jSessionID == "") print("Dio: Lack jSessionID!");
      else {
        httpHeaders['Cookie'] = Global.jSessionID;
        print("Dio: Added JSessionID: " + Global.jSessionID+";");
      }
    }
    dio.options.headers = httpHeaders;
    if(autoLogin) {
      print("autoLogin开启,检查结果: ");
      if(Global.jSessionID != "") {
        print("有cookie,正检查账号密码");
        if(Global.ifSavedJWProfile()) {
          print("有账号密码,正在检查有效性");
          String page;
          try {
            page = (await dio.get("/xszhxxAction.do?method=addStudentPic&tktime=" + DateTime.now().toString())).data.toString();
          } catch(e) {
            if(Global.ifReportDio) {
              throw e;
            } else {
              throw new Exception("网络错误!请稍后重试...");
            }
          }
          if(page.contains("过长时间没有操作")) {
            print("登录失效,重新登录");
            await login(Global.profile.xh, Global.profile.pass);
          } else {
            print("登录有效!");
          }
        } else {
          print("无账号密码");
          Global.jSessionID = "";
          throw new Exception("尚未登录!");
        }
      } else {
        print("缺少cookie,正检查账号密码");
        if(Global.ifSavedJWProfile()) {
          print("有账号密码,重新登录");
          await login(Global.profile.xh, Global.profile.pass);
        } else {
          print("无账号密码");
          throw new Exception("尚未登录!");
        }
      }
    }
    return dio;
  }

  Future<void> _getCookie() async {
    print("获取Cookie中...");
    var dio = await getDio(addCookie: false, autoLogin: false);
    Response res_cookie;
    try {
      res_cookie = await dio.get(baseUrl);
    } catch(e) {
      if(Global.ifReportDio) {
        throw e;
      } else {
        throw new Exception("网络错误!请稍后重试...");
      }
    }
    String sessionID = "";
    sessionID = res_cookie.headers.value("set-cookie").toString();
    if(sessionID.isNotEmpty && sessionID != "null") {
      Global.jSessionID = sessionID;
      print("Get and Saved SessionID: " + sessionID);
    } else {
      print("Get SessionID Fail!");
    }
}

  Future<Uint8List> getCaptchaIMG() async {
    await _getCookie();
    var dio = await getDio(autoLogin: false);
    dio.options.responseType = ResponseType.stream;
    Response res;
    try {
      res = await dio.get("/verifycode.servlet");
    }catch(e) {
      if(Global.ifReportDio) {
        throw e;
      } else {
        throw new Exception("网络错误!请稍后重试...");
      }
    }
    ResponseBody resBody = res.data;
    print("Get Captcha IMG OK!");
    return resBody.stream.first;
  }

  Future<String> getCaptchaText(Uint8List uInt8ListImg) async {
    return await JiaowuCaptcha().GetText(uInt8ListImg);
  }

  Future<void> login(String xh, String password) async {
    int codeErrorCount = 0;
    while(codeErrorCount < 5) {
      String captcha = await JiaowuCaptcha().GetText(await getCaptchaIMG());
      var dio = await getDio(autoLogin: false);
      Map<String, dynamic> formData = {
        "USERNAME": xh,
        "PASSWORD": password,
        "RANDOMCODE": captcha,
        "useDogCode": "",
        "x": 0,
        "y": 0
      };
      Response res;
      try {
        res = await dio.post("/Logon.do?method=logon", data: formData, options: Options(contentType:Headers.formUrlEncodedContentType));
      } catch(e) {
        if(Global.ifReportDio) {
          throw e;
        } else {
          throw new Exception("网络错误!请稍后重试...");
        }
      }
      String rtn = res.data.toString();
      if(rtn.contains("密码错误")) {
        //密码错误
        Global.removeJWProfile();
        throw new Exception("用户名或密码错误");
      } else if(rtn.contains("验证码错误")) {
        //再试一次
        print("验证码错误");
        codeErrorCount++;
        continue;
      } else if(rtn.contains("window.location.href=")) {
        //OK
        print("登录成功");
        Global.profile.xh = xh;
        Global.profile.pass = password;
        try {
          await dio.get("/Logon.do?method=logonBySSO");
        } catch(e) {
          if(Global.ifReportDio) {
            throw e;
          } else {
            throw new Exception("网络错误!请稍后重试...");
          }
        }
        String mainPageStr;
        try {
          mainPageStr = (await dio.get("/framework/main.jsp")).data.toString();
        } catch(e) {
          if(Global.ifReportDio) {
            throw e;
          } else {
            throw new Exception("网络错误!请稍后重试...");
          }
        }
        var mainPage = parseHtmlDocument(mainPageStr);
        Global.profile.xm = mainPage.head.children[1].innerHtml.split("[")[0];
        Global.saveProfile();
        return;
      } else {
        //未知错误
        print("未知错误");
        throw new Exception("未知错误");
      }
    }
    throw new Exception("自动识别验证码错误超过5次，请重试");
  }

  Future<Map> getInfo() async {
    Map<String, String> info = {};
    var dio = await getDio();
    String infoPageStr;
    try {
      infoPageStr = (await dio.get("/xszhxxAction.do?method=addStudentPic&tktime=" + DateTime.now().toString())).data.toString();
    } catch(e) {
      if(Global.ifReportDio) {
        throw e;
      } else {
        throw new Exception("网络错误!请稍后重试...");
      }
    }
    var infoPage = parseHtmlDocument(infoPageStr);
    RegExp reg = new RegExp(r"<td.*</td>");
    Iterable<Match> matches = reg.allMatches(infoPage.getElementById("xjkpTable").innerHtml);
    bool breakNext = false;
    for(int i = 0;i < matches.length;i++) {
      var str = matches.elementAt(i).group(0);
      if(breakNext) {
        breakNext = false;
        continue;
      }
      if(str.contains("院系：")) {
        info["院系"] = str.substring(19, str.length - 5);
      } else if(str.contains("专业：")) {
        info["专业"] = str.substring(19, str.length - 5);
      } else if(str.contains("学制：")) {
        info["学制"] = str.substring(7, str.length - 5);
      } else if(str.contains("班级：")) {
        info["班级"] = str.substring(7, str.length - 5);
      } else if(str == "<td>姓名</td>") {
        var str1 = matches.elementAt(i+1).group(0);
        if(info["姓名"] == null || info["姓名"].isEmpty) {
          info["姓名"] = str1.substring(5, str1.length - 5);
        }
        breakNext = true;
      } else if(str == "<td>性别</td>") {
        var str1 = matches.elementAt(i+1).group(0);
        info["性别"] = str1.substring(5, str1.length - 5);
        breakNext = true;
      } else if(str == "<td>出生日期</td>") {
        var str1 = matches.elementAt(i+1).group(0);
        info["出生日期"] = str1.substring(5, str1.length - 5);
        breakNext = true;
      } else if(str == "<td>本人电话</td>") {
        var str1 = matches.elementAt(i+1).group(0);
        info["本人电话"] = str1.substring(5, str1.length - 5);
        breakNext = true;
      } else if(str == "<td>入学日期</td>") {
        var str1 = matches.elementAt(i+1).group(0);
        info["入学日期"] = str1.substring(17, str1.length - 5);
        breakNext = true;
      } else if(str == "<td>入学考号</td>") {
        var str1 = matches.elementAt(i+1).group(0);
        info["入学考号"] = str1.substring(17, str1.length - 5);
        breakNext = true;
      } else if(str == "<td>身份证编号</td>") {
        var str1 = matches.elementAt(i+1).group(0);
        info["身份证编号"] = str1.substring(17, str1.length - 5);
        breakNext = true;
      }
    }
    return info;
  }

  Future<List> getScoreXQ() async {
    print("获取成绩学期...");
    List<DropdownMenuItem<dynamic>> scoreXQ = [];
    var dio = await getDio();
    String pageStr;
    try {
      pageStr = (await dio.get("/jiaowu/cjgl/xszq/query_xscj.jsp")).data.toString();
    } catch(e) {
      if(Global.ifReportDio) {
        throw e;
      } else {
        throw new Exception("网络错误!请稍后重试...");
      }
    }
    RegExp reg = new RegExp("<select name=\"kksj\" id=\"kksj\" style=\"width:150px\" size=1><option value=\"\">---请选择---</option>.*</select>");
    String optionStr = reg.firstMatch(pageStr).group(0).substring(92);
    Iterable<Match> matches = new RegExp("<option value=\"[0-9\\\\-]*\">[0-9\\\\-]*</option>").allMatches(optionStr);
    scoreXQ.add(DropdownMenuItem(child: Text("全部学期"), value: ""));
    for(int i = 0;i < matches.length;i++) {
      var str = matches.elementAt(i).group(0);
      scoreXQ.add(DropdownMenuItem(child: Text(str.substring(str.indexOf('>'), str.indexOf("</"))), value: str.substring(15, str.lastIndexOf("\""))));
    }
    return scoreXQ;
  }

  Future<List> getScore(String xq) async {
    print("获取成绩");
    List score = [];
    var dio = await getDio();
    Map<String, dynamic> formData = {
      "kksj": xq,
      "kcxz": "", //课程性质
      "kcmc": "", //课程名称
      "xsfs": "" //显示方式
    };
    String pageStr;
    try {
      pageStr = (await dio.post("/xszqcjglAction.do?method=queryxscj",
          data: formData,
          options: Options(contentType:Headers.formUrlEncodedContentType))).data.toString();
    } catch(e) {
      if(Global.ifReportDio) {
        throw e;
      } else {
        throw new Exception("网络错误!请稍后重试...");
      }
    }
    var page = parseHtmlDocument(pageStr);
    var jdElem = page.getElementById("tblBm").innerHtml;
    var xfList = [];
    var str = RegExp("已修读<span>[0-9.]*</span>学分，").firstMatch(jdElem).group(0);
    xfList.add(str.substring(9, str.length - 10));
    str = RegExp("平均学分绩点<span>[0-9.]*。</span>").firstMatch(jdElem).group(0);
    xfList.add(str.substring(12, str.length - 8));
    str = RegExp("共<font color=\"#FF0000\">[0-9]*</font>条").firstMatch(jdElem).group(0);
    xfList.add(int.parse(str.substring(23, str.length - 8)));
    score.add(xfList);
    for(int i = 1;;i++) {
      var singleElem = page.getElementById(i.toString());
      List singleList = [];
      String str = "";
      if(singleElem == null) break;
      var single = singleElem.children;
      for(int j = 3;j <= 4;j++) {
        singleList.add(single[j].innerText.toString()); //0: 学期   1: 课程名称
      }
      singleList.add(int.parse(single[5].innerText.toString())); //2: 总成绩
      if(singleList[2] >= 60) { //3: 是否通过标志
        singleList.add("√");
      } else {
        singleList.add("×");
      }
      str = single[5].innerHtml.toString();
      singleList.add(str.substring(str.indexOf("JsMod(")+7, str.indexOf(",630,360)")-1).replaceAll("&amp;", "&")); //4: 成绩比例地址
      for(int j = 7;j <= 11;j++) {
        singleList.add(single[j].innerText.toString()); //5: 课程性质  6: 课程类别  7: 学时  8: 学分  9:考试性质
      }
      score.add(singleList);
    }
    return score;
  }

  Future<List> getScoreDetail(String url) async {
    print("获取成绩比例");
    List detail = [];
    var dio = await getDio();
    String pageStr;
    try {
      pageStr = (await dio.get(url)).data.toString();
    } catch(e) {
      if(Global.ifReportDio) {
        throw e;
      } else {
        throw new Exception("网络错误!请稍后重试...");
      }
    }
    var page = parseHtmlDocument(pageStr);
    var trElemChildren = page.getElementById("1").children;
    for(int i = 0;i <= 6;i++) {
      detail.add(trElemChildren[i].innerText);
    }
    return detail;
    // 0: 平时成绩  1: 平时成绩比列  2: 期中成绩   3: 期中成绩比列   4: 期末成绩   5: 期末成绩比列  6: 总成绩
  }
}