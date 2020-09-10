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

class Dawu {
  String baseUrl = "http://61.167.120.8/";

  var httpHeaders = {
    'Accept': 'application/json, text/plain, */*',
    'Accept-Encoding': 'gzip, deflate, br',
    'Accept-Language': 'zh-CN,zh;q=0.9',
    'Connection': 'keep-alive',
    'Host': '61.167.120.8',
    'Origin': 'http://61.167.120.8',
    'Referer': 'http://61.167.120.8/',
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.77 Safari/537.36',
  };

  Future<Dio> getDio({bool addCookie = true, bool autoLogin = true}) async {
    print("新建Dio!");
    Dio dio = Dio();
    dio.options.baseUrl = baseUrl;
    dio.options.connectTimeout = 6000; //5s
    dio.options.receiveTimeout = 4000;
    if(addCookie) {
      print("addCookie开启!");
      String cookie = "";
      await _getAuth();
      if(Global.profile.dwToken == "") print("addCookie:缺少dawuToken!");
      else {
        cookie = Global.profile.dwToken;
        print("addCookie: 加入了dawuToken: " + Global.profile.dwToken);
      }
      if(Global.lastCookie != "") {
        print("addCookie: 加入了dawuCookie: " + Global.lastCookie);
        if(cookie != "") cookie += ";";
        cookie += Global.lastCookie;
      } else {
        print("addCookie: 缺少dawuCookie");
      }
      httpHeaders['Cookie'] = cookie;
    }
    dio.options.headers = httpHeaders;
    if(autoLogin) {
      print("autoLogin开启,检查结果: ");
      if(Global.profile.dwToken != "") {
        print("有cookie,正检查账号密码");
        if(Global.ifSavedDWProfile()) {
          print("有账号密码,正在检查有效性");
          String page;
          try {
            page = (await dio.get("/")).data.toString();
          } catch(e) {
            if(Global.ifReportDio) {
              throw e;
            } else {
              throw new Exception("网络错误!请稍后重试...");
            }
          }
          if(page.contains("登出") && page.contains("更改密码")) {
            print("登录有效!");
          } else {
            print("登录失效,重新登录");
            await login(Global.profile.dwUsr, Global.profile.dwPass);
          }
        } else {
          print("无账号密码");
          Global.profile.dwToken = "";
          throw new Exception("尚未登录!");
        }
      } else {
        print("缺少cookie,正检查账号密码");
        if(Global.ifSavedDWProfile()) {
          print("有账号密码,重新登录");
          await login(Global.profile.dwUsr, Global.profile.dwPass);
        } else {
          print("无账号密码");
          throw new Exception("尚未登录!");
        }
      }
    }
    return dio;
  }

  Future<void> _getAuth() async {
    print("获取Auth中...");
    var dio = await getDio(addCookie: false, autoLogin: false);
    Response res_cookie;
    try {
      res_cookie = await dio.get('/users/sign_in');
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
      Global.lastCookie = sessionID;
      print("Get and Saved SessionID: " + sessionID);
    } else {
      print("Get SessionID Fail!");
    }
    String pageStr = res_cookie.data.toString();
    await _getCSRFByText(pageStr);
  }

  Future _getCSRFByText(String pageStr) async {
    print("Getting CSRF By Page Text");
    RegExp reg = new RegExp("<meta name=\"csrf-param\" content=\".*\" />");
    String csrfParam = reg.firstMatch(pageStr).group(0);
    print("Raw CSRF Param: " + csrfParam);
    csrfParam = csrfParam.substring(33, csrfParam.length - 4);
    reg = new RegExp("<meta name=\"csrf-token\" content=\".*\" />");
    String csrfToken = reg.firstMatch(pageStr).group(0);
    print("Raw CSRF Token: " + csrfToken);
    csrfToken = csrfToken.substring(33, csrfToken.length - 4);
    print("CSRF Token: " + csrfToken);
    if(csrfParam != null && csrfToken != null && csrfParam.isNotEmpty && csrfToken.isNotEmpty) {
      Global.lastAuthenticityParam = csrfParam;
      Global.lastAuthenticityToken = csrfToken;
      print("Get CSRF: " + Global.lastAuthenticityParam + "=" + Global.lastAuthenticityToken);
    } else {
      throw new Exception("CSRF Token获取失败!");
      print("Get CSRF Fail!");
    }
  }

  Future<void> login(String xh, String password) async {
    var dio = await getDio(autoLogin: false);
    //await _getAuth();
    Map<String, dynamic> formData = {
      "utf8": "✓",
      Global.lastAuthenticityParam: Global.lastAuthenticityToken,
      "user[account_numb]": xh,
      "user[password]": password,
      "user[remember_me]": 1,
      "commit": "登录",
    };
    print("Login Form: " + formData.toString());
    print("Now DWCookie: " + dio.options.headers['Cookie']);
    Response res;
    try {
      res = await dio.post("/users/sign_in", data: formData, options: Options(contentType:Headers.formUrlEncodedContentType,
          followRedirects: false,
          validateStatus: (status) { return status < 500;}));
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
      Global.removeDWProfile();
      throw new Exception("用户名或密码错误");
    } else if(rtn.contains("You are being ")) {
      //OK
      print("登录成功");
      Global.profile.dwUsr = xh;
      Global.profile.dwPass = password;
      List cookies = res.headers["set-cookie"];
      for(int i = 0;i < cookies.length;i++) {
        if(cookies[i].contains("remember_user_token")) {
          Global.profile.dwToken = cookies[i];
          print("获取到Token: " + cookies[i]);
        }
        if(cookies[i].contains("_nepu_phy_lab_session")) {
          Global.lastCookie = cookies[i];
          print("获取到Cookie: " + cookies[i]);
        }
      }
      Response res2;
      try {
        res2 = await dio.get("/");
      } catch(e) {
        if(Global.ifReportDio) {
          throw e;
        } else {
          throw new Exception("网络错误!请稍后重试...");
        }
      }
      String pageStr = res2.data.toString();
      if(pageStr == "") throw new Exception("获取个人信息失败");
      RegExp reg = new RegExp("<a href=\"#\" class=\"dropdown-toggle\" data-toggle=\"dropdown\" role=\"button\" aria-haspopup=\"true\" aria-expanded=\"false\"><b>.*</a>");
      String nameStr = reg.firstMatch(pageStr).group(0);
      nameStr = nameStr.substring(119, nameStr.length - 36);
      Global.profile.dwXm = nameStr;
      _getCSRFByText(pageStr);
      Global.saveProfile();
    } else {
      //未知错误
      print("未知错误");
      throw new Exception("未知错误");
    }
  }

}