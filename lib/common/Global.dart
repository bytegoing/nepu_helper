//管理全局变量
import 'dart:convert';

import 'package:nepu_helper/models/classProfile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nepu_helper/models/profile.dart';

import 'package:flutter/material.dart';

class Global {
  static SharedPreferences _prefs;
  static String jSessionID = "";
  static String lastAuthenticityToken = "";
  static String lastAuthenticityParam = "authenticity_token";
  static String lastCookie = "";
  static String lastCaptcha = "";
  static Profile profile = Profile();
  static ClassProfile classProfile = ClassProfile();
  static bool ifReportDio = true;
  //static BuildContext nowContext;
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static bool get isRelease => bool.fromEnvironment("dart.vm.product");

  //初始化全局信息,APP启动执行
  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
    var _profileStr = _prefs.getString("Profile");
    if(_profileStr != null && _profileStr.isNotEmpty) {
      print("Got Profile: " + _profileStr);
    }
    var _classProfileStr = _prefs.getString("classProfile");
    if(_classProfileStr != null && _classProfileStr.isNotEmpty) {
      print("Got Class Profile: " + _classProfileStr);
    }
    Map<String, dynamic> _profileJson;
    Map<String, dynamic> _classProfileJson;
    try {
      _profileJson = jsonDecode(_profileStr);
      _classProfileJson = jsonDecode(_classProfileStr);
      profile = Profile.fromJson(_profileJson);
      classProfile = ClassProfile.fromJson(_classProfileJson);
    } catch(e) {
      print("Profile JSON Error! " + e.toString());
      removeJWProfile();
      removeDWProfile();
    }
  }

  static void saveProfile() async {
    _prefs = await SharedPreferences.getInstance();
    print("Saving Profile: " + jsonEncode(profile.toJson()));
    _prefs.setString("Profile", jsonEncode(profile.toJson()));
  }

  static void saveClassProfile() async {
    _prefs = await SharedPreferences.getInstance();
    print("Saving Class Profile: " + jsonEncode(classProfile.toJson()));
    _prefs.setString("Profile", jsonEncode(classProfile.toJson()));
  }

  static void removeJWProfile() async {
    print("Removing JW Profile.");
    profile.xh = "";
    profile.xm = "";
    profile.pass = "";
    saveProfile();
  }
  static void removeDWProfile() async {
    print("Removing DW Profile");
    profile.dwUsr = "";
    profile.dwPass = "";
    profile.dwToken = "";
    profile.dwXm = "";
    saveProfile();
  }

  static bool ifSavedJWProfile() {
    return profile.xh != null && profile.xh.isNotEmpty && profile.pass != null && profile.pass.isNotEmpty;
  }

  static bool ifSavedDWProfile() {
    return profile.dwUsr != null && profile.dwUsr.isNotEmpty && profile.dwPass != null && profile.dwPass.isNotEmpty;
  }
}