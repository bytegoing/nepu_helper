class Profile {
  String xh;
  String pass;
  String xm;
  String dwUsr;
  String dwPass;
  String dwToken;
  String dwXm;

  Profile({this.xh, this.pass, this.xm, this.dwUsr, this.dwPass, this.dwToken, this.dwXm});

  Profile.fromJson(Map<String, dynamic> json) {
    xh = json['xh'];
    pass = json['pass'];
    xm = json['xm'];
    dwUsr = json['dwUsr'];
    dwPass = json['dwPass'];
    dwToken = json['dwToken'];
    dwXm = json['dwXm'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['xh'] = this.xh;
    data['pass'] = this.pass;
    data['xm'] = this.xm;
    data['dwUsr'] = this.dwUsr;
    data['dwPass'] = this.dwPass;
    data['dwToken'] = this.dwToken;
    data['dwXm'] = this.dwXm;
    return data;
  }
}