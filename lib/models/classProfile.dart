import 'dart:convert';

class ClassProfile {
  String xnxq;
  List<SingleClassProfile> classes;

  ClassProfile({this.xnxq, this.classes});

  ClassProfile.fromJson(Map<String, dynamic> json) {
    xnxq = json['xnxq'];
    classes = json['classes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['xnxq'] = xnxq;
    data['classes'] = classes;
    return data;
  }
}

class SingleClassProfile {
  String kcmc;
  String kcbh;
  String jxbmc;
  String kcrwdm;
  String jcdm2;
  String zcs;
  String xq;
  String jxcdmcs;
  String teaxms;

  SingleClassProfile(
      {this.kcmc,
        this.kcbh,
        this.jxbmc,
        this.kcrwdm,
        this.jcdm2,
        this.zcs,
        this.xq,
        this.jxcdmcs,
        this.teaxms});

  SingleClassProfile.fromJson(Map<String, dynamic> json) {
    kcmc = json['kcmc'];
    kcbh = json['kcbh'];
    jxbmc = json['jxbmc'];
    kcrwdm = json['kcrwdm'];
    jcdm2 = json['jcdm2'];
    zcs = json['zcs'];
    xq = json['xq'];
    jxcdmcs = json['jxcdmcs'];
    teaxms = json['teaxms'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['kcmc'] = this.kcmc;
    data['kcbh'] = this.kcbh;
    data['jxbmc'] = this.jxbmc;
    data['kcrwdm'] = this.kcrwdm;
    data['jcdm2'] = this.jcdm2;
    data['zcs'] = this.zcs;
    data['xq'] = this.xq;
    data['jxcdmcs'] = this.jxcdmcs;
    data['teaxms'] = this.teaxms;
    return data;
  }
}