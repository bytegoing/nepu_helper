class Profile {
  String xh;
  String pass;
  String xm;
  String dwUsr;
  String dwPass;

  Profile({this.xh, this.pass, this.xm, this.dwUsr, this.dwPass});

  Profile.fromJson(Map<String, dynamic> json) {
    xh = json['xh'];
    pass = json['pass'];
    xm = json['xm'];
    dwUsr = json['dwUsr'];
    dwPass = json['dwPass'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['xh'] = this.xh;
    data['pass'] = this.pass;
    data['xm'] = this.xm;
    data['dwUsr'] = this.dwUsr;
    data['dwPass'] = this.dwPass;
    return data;
  }
}