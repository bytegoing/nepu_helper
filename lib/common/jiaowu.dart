import 'dart:async';
import 'dart:convert';
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
import 'package:nepu_helper/pages/jiaowu/captcha.dart';
import 'package:steel_crypt/steel_crypt.dart';
import 'package:xpath_parse/xpath_selector.dart';
import 'package:nepu_helper/widget/renamedialog.dart';
import 'package:nepu_helper/widget/renamedialogcontent.dart';

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
    dio.options.connectTimeout = 6000; //6s
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
            page = (await dio.get("/login!welcome.action")).data.toString();
          } catch(e) {
            if(Global.ifReportDio) {
              throw e;
            } else {
              throw new Exception("网络错误!请稍后重试...");
            }
          }
          if(page.contains("立即登录")) {
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
      res = await dio.get("/yzm?d="+ new DateTime.now().millisecondsSinceEpoch.toString());
    }catch(e) {
      if(Global.ifReportDio) {
        throw e;
      } else {
        throw new Exception("网络错误!请稍后重试...");
      }
    }
    ResponseBody resBody = res.data;
    print("Get Captcha IMG OK!");
    Uint8List imgList = await resBody.stream.first;
    //print(base64Encode(imgList));
    return imgList;
  }

  Future getCaptchaTextByWidget() async {
    String tipText = "请输入验证码";
    if(Global.lastCaptcha.length > 0) tipText = "验证码错误,请重新输入";
    Global.lastCaptcha = "";
    TextEditingController _vc = new TextEditingController();
    Uint8List _img = await getCaptchaIMG();
    await showDialog(
      barrierDismissible: false,
      context: Global.navigatorKey.currentState.overlay.context,
      builder: (context) {
        return RenameDialog(
          contentWidget: RenameDialogContent(
            title: tipText,
            okBtnTap: () {
              Global.lastCaptcha = _vc.text;
            },
            vc: _vc,
            cancelBtnTap: () {},
            img: _img,
          ),
        );
      }
    );
    print("验证码:"+Global.lastCaptcha);
  }

  /*Future<String> getCaptchaText(Uint8List uInt8ListImg) async {
    return await JiaowuCaptcha().GetText(uInt8ListImg);
  }*/

  static toHex(Uint8List bArr) {
    int length;
    if (bArr == null || (length = bArr.length) <= 0) {return "";}
    Uint8List cArr = new Uint8List(length << 1);
    int i = 0;
    for (int i2 = 0; i2 < length; i2++) {
      int i3 = i + 1;
      var cArr2 = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'];
      var index = (bArr[i2] >> 4) & 15;
      cArr[i] = cArr2[index].codeUnitAt(0);
      i = i3 + 1;
      cArr[i3] = cArr2[bArr[i2] & 15].codeUnitAt(0);
    }
    return new String.fromCharCodes(cArr);
  }

  static hex(int c) {
    if (c >= '0'.codeUnitAt(0) && c <= '9'.codeUnitAt(0)) {return c - '0'.codeUnitAt(0);}
    if (c >= 'A'.codeUnitAt(0) && c <= 'F'.codeUnitAt(0)) {return (c - 'A'.codeUnitAt(0)) + 10;}
  }

  static toUnitList(String str) {
    int length = str.length;
    if (length % 2 != 0) {
      str = "0" + str;
      length++;
    }
    List<int> s = str.toUpperCase().codeUnits;
    Uint8List bArr = Uint8List(length >> 1);
    for (int i = 0; i < length; i += 2) {
      bArr[i >> 1] = ((hex(s[i]) << 4) | hex(s[i + 1]));
    }
    return bArr;
  }

  String aesEncrypt(String plainText, String key) {
    print("AES Info: $plainText, $key");
    var Encrypter = AesCrypt(key, 'ecb', 'pkcs7');
    var EncryptedData = Encrypter.encrypt(plainText);
    var list = Base64Decoder().convert(EncryptedData);
    return toHex(list).toString().toLowerCase();
  }

  Future<void> login(String xh, String password) async {
    int codeErrorCount = 0;
    while(codeErrorCount < 5) {
      //String captcha = await JiaowuCaptcha().GetText(await getCaptchaIMG());
      await getCaptchaTextByWidget();
      if(Global.lastCaptcha.length <= 0) {
        throw new Exception("请输入验证码!");
      }
      String captcha = Global.lastCaptcha;
      var dio = await getDio(autoLogin: false);
      Map<String, dynamic> formData = {
        "account": xh,
        "pwd": aesEncrypt(password, captcha+captcha+captcha+captcha),
        "verifycode": captcha,
      };
      Response res;
      try {
        res = await dio.post("/new/login", data: formData, options: Options(contentType:Headers.formUrlEncodedContentType));
      } catch(e) {
        if(Global.ifReportDio) {
          throw e;
        } else {
          throw new Exception("网络错误!请稍后重试...");
        }
      }
      var rtn = jsonDecode(res.toString());
      if(rtn['code'] == "0" || rtn['code'] == 0) {
        //OK
        print("登录成功");
        Global.profile.xh = xh;
        Global.profile.pass = password;
        String mainPageStr;
        try {
          mainPageStr = (await dio.get("/login!welcome.action")).data.toString();
        } catch(e) {
          if(Global.ifReportDio) {
            throw e;
          } else {
            throw new Exception("网络错误!请稍后重试...");
          }
        }
        Global.profile.xm = XPath.source(mainPageStr).query("//div[@class='top']/text()").list()[0];
        Global.saveProfile();
        return;
      } else {
        //NOT OK
        if (rtn["message"].contains("验证码")) {
          //再试一次
          print("验证码错误");
          //throw new Exception("");
          codeErrorCount++;
          continue;
        } else {
          throw new Exception(rtn["message"]);
        }
      }
    }
    throw new Exception("验证码错误超过5次，请重试");
  }

  Future<Map> getInfo() async {
    Map<String, String> info = {};
    var dio = await getDio();
    String infoPageStr;
    try {
      infoPageStr = (await dio.get("/new/student/xjkpxx/edit.page")).toString();
    } catch(e) {
      if(Global.ifReportDio) {
        throw e;
      } else {
        throw new Exception("网络错误!请稍后重试...");
      }
    }
    var infoList1 = XPath.source(infoPageStr).query("//label/text()").list();
    info["入学年份"] = infoList1[2];
    info["院系"] = infoList1[3];
    info["专业"] = infoList1[4];
    info["班级"] = infoList1[6];
    info["所在年级"] = infoList1[7];
    info["学制"] = infoList1[8];
    info["所在校区"] = infoList1[9];
    info["学生状态"] = infoList1[10];
    info["学籍状态"] = infoList1[11];
    info["本人电话"] = XPath.source(infoPageStr).query("//input[@id='dh']/text()").get();
    info["姓名拼音"] = XPath.source(infoPageStr).query("//input[@id='py']/text()").get();
    info["本人电话"] = XPath.source(infoPageStr).query("//input[@id='dh']/text()").get();
    info["找回密码凭据"] = XPath.source(infoPageStr).query("//input[@id='mmtip']/text()").get();
    info["身份证编号"] = XPath.source(infoPageStr).query("//input[@id='sfzh']/text()").get();
    info["入学考号"] = XPath.source(infoPageStr).query("//input[@id='ksh']/text()").get();
    print(info);
    return info;
  }

  Future<Map> getKcXnxq() async {
    print("获取课表学期...");
    Map<String, String> info = new Map<String, String>();
    //List<Widget> rtn = new List<Widget>();
    var dio = await getDio();
    String pageStr;
    try {
      pageStr = (await dio.get("/xskccjxx!xskccj.action")).toString();
    } catch(e) {
      if(Global.ifReportDio) {
        throw e;
      } else {
        throw new Exception("网络错误!请稍后重试...");
      }
    }
    var pageStrXPath = XPath.source(pageStr);
    var xnxqNameList = pageStrXPath.query("//select[@id='xnxqdm']/option/text()").list();
    var xnxqValueList = pageStrXPath.query("//select[@id='xnxqdm']/option/@value").list();
    for(int i = 0;i < xnxqNameList.length;i++) {
      //print(xnxqNameList[i] + ":" + xnxqValueList[i]); //+ ":" + xnxqValueList[i].substring(0,4));
      if(xnxqNameList[i] == "全部") continue;
      //print(xnxqValueList[i].substring(0,4));
      //if(int.parse(xnxqValueList[i].substring(0,4)) > DateTime.now().year + 1) continue;
      //rtn.add(FlatButton(child: new Text(xnxqNameList[i]), onPressed: () => _getKcInfo(xnxqValueList[i]),));
      //xnxqList.add(DropdownMenuItem(child: Text(xnxqNameList[i]), value: xnxqValueList[i]));
      info[xnxqNameList[i]] = xnxqValueList[i];
    }
    return info;
  }

  Future<List> getKcInfo(String xnxqdm) async {
    print("获取课程, 学期$xnxqdm");
    Map classes;
    var dio = await getDio();
    String pageStr;
    try {
      pageStr = (await dio.get("/xsgrkbcx!xsAllKbList.action?xnxqdm=$xnxqdm")).toString();
    } catch(e) {
      if(Global.ifReportDio) {
        throw e;
      } else {
        throw new Exception("网络错误!请稍后重试...");
      }
    }
    if(pageStr.contains("还未开放")) {
      print("未开放");
      throw new Exception("本学期课表还未开放,请稍后查询!");
    }
    //print("页面:$pageStr");
    RegExp reg = new RegExp(r"\[\{.*\}\]");
    var kcxx = reg.firstMatch(pageStr).group(0);
    //print("获取到:$kcxx");
    return jsonDecode(kcxx);
  }

  Future<List> getScoreInfo() async {
    print("获取成绩学期和计划类型...");
    List<DropdownMenuItem<dynamic>> scoreXQ = [];
    var dio = await getDio();
    String pageStr;
    try {
      pageStr = (await dio.get("/xskccjxx!xskccj.action")).toString();
    } catch(e) {
      if(Global.ifReportDio) {
        throw e;
      } else {
        throw new Exception("网络错误!请稍后重试...");
      }
    }
    var pageStrXPath = XPath.source(pageStr);
    List<DropdownMenuItem<String>> xnxqList = [];
    List<DropdownMenuItem<String>> jhlxList = [];
    var xnxqNameList = pageStrXPath.query("//select[@id='xnxqdm']/option/text()").list();
    var xnxqValueList = pageStrXPath.query("//select[@id='xnxqdm']/option/@value").list();
    var jhlxNameList = pageStrXPath.query("//select[@id='jhlx']/option/text()").list();
    var jhlxValueList = pageStrXPath.query("//select[@id='jhlx']/option/@value").list();
    for(int i = 0;i < xnxqNameList.length;i++) {
      xnxqList.add(DropdownMenuItem(child: Text(xnxqNameList[i]), value: xnxqValueList[i]));
    }
    for(int i = 0;i < jhlxNameList.length;i++) {
      jhlxList.add(DropdownMenuItem(child: Text(jhlxNameList[i]), value: jhlxValueList[i]));
    }
    return [xnxqList, jhlxList];
  }

  Future<List> getScore(String xq, String jh) async {
    print("获取成绩");
    var dio = await getDio();
    Map<String, dynamic> formData = {
      "xnxqdm": xq,
      "jhlxdm": jh, //计划类型
      "page": 1,
      "rows": 9999,
      "sort": "xnxqdm",
      "order": "asc"
    };
    String pageStr;
    try {
      pageStr = (await dio.post("/xskccjxx!getDataList.action",
          data: formData,
          options: Options(contentType:Headers.formUrlEncodedContentType))).toString();
    } catch(e) {
      if(Global.ifReportDio) {
        throw e;
      } else {
        throw new Exception("网络错误!请稍后重试...");
      }
    }
    var rtnJson = jsonDecode(pageStr);
    return rtnJson["rows"];
  }

  Future<List> getScoreDetail(String cjdm) async {
    print("获取成绩比例");
    List detail = [];
    var dio = await getDio();
    String pageStr;
    try {
      pageStr = (await dio.get("/xskccjxx!getDetail.action?cjdm="+cjdm)).toString();
    } catch(e) {
      if(Global.ifReportDio) {
        throw e;
      } else {
        throw new Exception("网络错误!请稍后重试...");
      }
    }
    var rtnJson = jsonDecode(pageStr);
    return rtnJson;
  }

  Future<List> getClassPlan() async {
    print("获取教学计划");
    var dio = await getDio();
    List classPlan = [];
    String pageStr;
    try {
      pageStr = (await dio.get("/pyfajhgl.do?method=toViewJxjhXs&tktime=" + DateTime.now().toString())).data.toString();
    } catch(e) {
      if(Global.ifReportDio) {
        throw e;
      } else {
        throw new Exception("网络错误!请稍后重试...");
      }
    }
    var page = parseHtmlDocument(pageStr);
    for(int i = 1;;i++) {
      var singleElem = page.getElementById(i.toString());
      List singleList = [];
      String str = "";
      if(singleElem == null) break;
      var single = singleElem.children;
      for(int j = 1;j <= 11;j++) {
        singleList.add(single[j].innerText.toString());
      }
      //0: 学期    1: 课程编码  2: 课程名称  3: 学时  4: 学分  5: 课程体系
      //6: 课程属性 7: 方向  8: 方向年度  9: 考核方式  10:开课单位
      classPlan.add(singleList);
    }
    classPlan.sort((left, right) => right[0].compareTo(left[0])); //降序排列
    return classPlan;
  }

  Future<void> findPassword(String username, String id) async {
    print("找回密码: " + username + " " + id);
    var dio = await getDio(addCookie: false, autoLogin: false);
    String pageStr;
    Map<String, dynamic> formData = {
      "account": username,
      "sfzjh": id,
    };
    try {
      pageStr = (await dio.post("/yhxigl.do?method=resetPasswd",
          data: formData,
          options: Options(contentType:Headers.formUrlEncodedContentType))).data.toString();
    } catch(e) {
      if(Global.ifReportDio) {
        throw e;
      } else {
        throw new Exception("网络错误!请稍后重试...");
      }
    }
    if(pageStr.contains("身份证件号输入错误")) {
      throw new Exception("身份证件号输入错误或者你在系统中没有身份证号");
    } else if(pageStr.contains("密码已重置为身份证号的后六位")) {
      return;
    } else {
      throw new Exception("结果未知!");
    }
  }

  Future<void> changePassword(String oldPass, String newPass) async {
    print("更改密码");
    var dio = await getDio();
    String pageStr;
    Map<String, dynamic> formData = {
      "oldpassword": oldPass,
      "password1": newPass,
      "password2": newPass,
    };
    try {
      pageStr = (await dio.post("/yhxigl.do?method=changMyUserInfo",
          data: formData,
          options: Options(contentType:Headers.formUrlEncodedContentType))).data.toString();
    } catch(e) {
      if(Global.ifReportDio) {
        throw e;
      } else {
        throw new Exception("网络错误!请稍后重试...");
      }
    }
    if(pageStr.contains("旧密码输入错误")) {
      throw new Exception("旧密码输入错误!");
    } else if(pageStr.contains("修改密码成功")) {
      Global.removeJWProfile();
      return;
    } else {
      throw new Exception("结果未知!");
    }
  }

  Future<List> getXkList() async {
    print("获取选课列表");
    var dio = await getDio();
    List xkList = [];
    String pageStr;
    try {
      pageStr = (await dio.get("/xkglAction.do?method=xsxkXsxk&tktime=" + DateTime.now().toString())).data.toString();
    } catch(e) {
      if(Global.ifReportDio) {
        throw e;
      } else {
        throw new Exception("网络错误!请稍后重试...");
      }
    }
    var page = parseHtmlDocument(pageStr);
    for(int i = 1;;i++) {
      var singleElem = page.getElementById(i.toString());
      List singleList = [];
      if(singleElem == null) break;
      var single = singleElem.children;
      for(int j = 1;j <= 5;j++) {
        singleList.add(single[j].innerText.toString());
      }
      String str = single[6].innerHtml.toString();
      singleList.add(str.substring(63, str.length-35).replaceAll("&amp;", "&"));
      //0: 学期    1: 选课类型  2: 选课阶段  3: 选课开始时间  4: 选课结束时间  5: 选课链接
      xkList.add(singleList);
    }
    return xkList;
  }

  Future<List> getXkDetail(String url) async {
    print("获取选课详细信息： " + url);
    var dio = await getDio();
    List xkList = [];
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
    var mainFrmAdd = page.getElementById("mainFrame").getAttribute("src");
    print("Main Frame Address: " + mainFrmAdd);
    try {
      pageStr = (await dio.get(mainFrmAdd)).data.toString();
    } catch(e) {
      if(Global.ifReportDio) {
        throw e;
      } else {
        throw new Exception("网络错误!请稍后重试...");
      }
    }
    page = parseHtmlDocument(pageStr);
    mainFrmAdd = page.getElementById("centerFrame").getAttribute("src");
    print("Center Frame Address: " + mainFrmAdd);
    try {
      pageStr = (await dio.get(mainFrmAdd)).data.toString();
    } catch(e) {
      if(Global.ifReportDio) {
        throw e;
      } else {
        throw new Exception("网络错误!请稍后重试...");
      }
    }
    page = parseHtmlDocument(pageStr);
    var mxhDivStr = page.getElementById("mxhDiv").children[0].innerHtml;
    RegExp reg = new RegExp("<td.*</td>");
    Iterable<Match> matches = reg.allMatches(mxhDivStr);
    int nowClass = -1;
    for(int i = 0;i < matches.length;i++) {
      var tStr = matches.elementAt(i).group(0).toString();
      if(tStr.contains("width=\"50\"") && tStr.contains("vJsMod")) {
        //Start of an Class
        print("Detected a new Class!");
        nowClass++;
        xkList.add(new List());
      } else {
        RegExp reg = new RegExp("(?<=title=\").*?(?=\")");
        if(reg.hasMatch(tStr)) {
          print("Have Title Match!");
          String singleStr = reg.firstMatch(tStr).group(0);
          xkList[nowClass].add(singleStr);
        } else {
          print("No Title Match!");
          RegExp reg2 = new RegExp(r"(?<=javascript:vJsMod\(').*(?=',400,250\);return false;)");
          if(reg2.hasMatch(tStr)) {
            print("Have Link Match!");
            String linkStr = reg2.firstMatch(tStr).group(0).replaceAll("&amp;", "&");
            xkList[nowClass].add(linkStr);
          } else {
            print("No Link Match!");
          }
        }
      }
    }
    //print(xkList);
    return xkList;
  }

  Future XuanKe(String url) async {
    print("选课： " + url);
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
    RegExp reg = new RegExp(r"(?<=alert\(').*(?='\);)");
    print("PageStr="+pageStr);
    if(reg.hasMatch(pageStr)) {
      //获取结果
      String resultStr = reg.firstMatch(pageStr).group(0);
      if(resultStr.contains("成功")) return;
      else throw new Exception(resultStr);
      //print(resultStr);
    } else {
      throw new Exception("未知错误!");
    }
    print(pageStr);
  }
}