class c_regis_Model {
  String? ser;
  String? rser;
  String? pn;
  String? custno;
  String? cid;
  String? username;
  String? passwd;
  String? accessToken;
  String? idToken;
  String? userid;
  String? displayname;
  String? dataUpdate;
  String? language;
  String? open_set_date;
  String? payToken;
  String? payEncoded64;
  String? fid;
  String? rentalLogo;
  String? rentalFoder;
  String? rentalIdCard;
  c_regis_Model(
      {this.ser,
      this.rser,
      this.pn,
      this.custno,
      this.cid,
      this.username,
      this.passwd,
      this.accessToken,
      this.idToken,
      this.userid,
      this.displayname,
      this.dataUpdate,
      this.language,
      this.open_set_date,
      this.payToken,
      this.payEncoded64,
      this.fid,
      this.rentalLogo,
      this.rentalFoder,
      this.rentalIdCard});

  c_regis_Model.fromJson(Map<String, dynamic> json) {
    ser = json['ser']?.toString();
    rser = (json['rental_id'] ?? json['rser'])?.toString();
    pn = json['rental_name'] ?? json['pn'];
    custno = json['rental_custno'] ?? json['custno'];
    cid = json['cid'];
    username = json['username'];
    passwd = json['passwd'];
    accessToken = json['access_token'];
    idToken = json['id_token'];
    userid = json['userid'];
    displayname = json['displayname'];
    dataUpdate = json['data_update'];
    language = json['language'];
    open_set_date = json['open_set_date'];
    payToken = json['pay_token'];
    payEncoded64 = json['pay_encoded64'];
    fid = json['fid'];
    rentalLogo = json['rental_logo'];
    rentalFoder = json['rental_foder'];
    rentalIdCard = json['rental_id_card'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ser'] = this.ser;
    data['rser'] = this.rser;
    data['pn'] = this.pn;
    data['custno'] = this.custno;
    data['cid'] = this.cid;
    data['username'] = this.username;
    data['passwd'] = this.passwd;
    data['access_token'] = this.accessToken;
    data['id_token'] = this.idToken;
    data['userid'] = this.userid;
    data['displayname'] = this.displayname;
    data['data_update'] = this.dataUpdate;
    data['language'] = this.language;
    data['open_set_date'] = this.open_set_date;
    data['pay_token'] = this.payToken;
    data['pay_encoded64'] = this.payEncoded64;
    data['fid'] = this.fid;
    return data;
  }
}
