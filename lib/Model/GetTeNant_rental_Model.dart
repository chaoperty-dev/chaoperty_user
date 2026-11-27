class TeNantRentalModel {
  String? ser;
  String? datex;
  String? timex;
  String? rser;
  String? zser;
  String? lncode;
  String? ln;
  String? area;
  String? rent;
  String? st;
  String? img;
  String? tser;
  String? tname;
  String? cid;
  String? dataUpdate;
  String? total;
  String? sdate;
  String? ldate;
  String? cdate;
  String? cname;
  String? sname;
  String? ln_c;
  String? area_c;
  String? docno;
  String? date;
  String? cname_q;
  String? sname_q;
  String? ln_q;
  String? ldate_q;
  String? sdate_q;
  String? area_q;
  String? quantity;
  String? period;
  String? period_q;
  String? rtname;
  String? rtname_q;
  String? stype;
  String? stype_q;
  String? attn;
  String? addr;
  String? tax;
  String? tel;
  String? email;
  String? ctype;
  String? zn;
  String? aser;
  String? qty;
  String? count_bill;
  String? invoice;
  String? expname;
  String? ser_tran;
  String? custno_1;
  String? custno_2;
  String? duedate;
  String? amt;
  String? amt_expser1;
  String? amt_expser9;
  String? amt_expser10;
  String? amt_expser11;
  String? amt_expser12;
  String? wnote;

  TeNantRentalModel({
    this.ser,
    this.datex,
    this.timex,
    this.rser,
    this.zser,
    this.lncode,
    this.ln,
    this.area,
    this.rent,
    this.st,
    this.img,
    this.tser,
    this.tname,
    this.cid,
    this.dataUpdate,
    this.total,
    this.sdate,
    this.ldate,
    this.cdate,
    this.cname,
    this.sname,
    this.ln_c,
    this.area_c,
    this.docno,
    this.date,
    this.cname_q,
    this.sname_q,
    this.ln_q,
    this.ldate_q,
    this.sdate_q,
    this.area_q,
    this.quantity,
    this.period,
    this.period_q,
    this.rtname,
    this.rtname_q,
    this.stype,
    this.stype_q,
    this.attn,
    this.addr,
    this.tax,
    this.tel,
    this.email,
    this.ctype,
    this.zn,
    this.aser,
    this.qty,
    this.count_bill,
    this.invoice,
    this.expname,
    this.ser_tran,
    this.custno_1,
    this.custno_2,
    this.duedate,
    this.amt,
    this.amt_expser1,
    this.amt_expser9,
    this.amt_expser10,
    this.amt_expser11,
    this.amt_expser12,
    this.wnote,
  });

  /// API บาง endpoint ส่งค่าตัวเลขมาเป็น int/double ไม่ใช่ String
  /// จึงต้องแปลงเป็น String ก่อนเก็บ ไม่เช่นนั้นจะเกิด cast error
  /// แล้วข้อมูลทั้งก้อนถูกทิ้งไป (หน้าจอแสดง '-')
  static String? _asString(dynamic value) => value?.toString();

  TeNantRentalModel.fromJson(Map<String, dynamic> json) {
    ser = _asString(json['ser']);
    datex = _asString(json['datex']);
    timex = _asString(json['timex']);
    rser = _asString(json['rser']);
    zser = _asString(json['zser']);
    lncode = _asString(json['lncode']);
    ln = _asString(json['ln']);
    area = _asString(json['area']);
    rent = _asString(json['rent']);
    st = _asString(json['st']);
    img = _asString(json['img']);
    tser = _asString(json['tser']);
    tname = _asString(json['tname']);
    cid = _asString(json['cid']);
    dataUpdate = _asString(json['data_update']);
    total = _asString(json['total']);
    sdate = _asString(json['sdate']);
    ldate = _asString(json['ldate']);
    cdate = _asString(json['cdate']);
    cname = _asString(json['cname']);
    sname = _asString(json['sname']);
    ln_c = _asString(json['ln_c']);
    area_c = _asString(json['area_c']);
    docno = _asString(json['docno']);
    date = _asString(json['date']);

    cname_q = _asString(json['cname_q']);
    sname_q = _asString(json['sname_q']);
    ln_q = _asString(json['ln_q']);
    ldate_q = _asString(json['ldate_q']);
    sdate_q = _asString(json['sdate_q']);
    area_q = _asString(json['area_q']);
    quantity = _asString(json['quantity']);
    period = _asString(json['period']);
    period_q = _asString(json['period_q']);
    rtname = _asString(json['rtname']);
    rtname_q = _asString(json['rtname_q']);
    stype = _asString(json['stype']);
    stype_q = _asString(json['stype_q']);
    attn = _asString(json['attn']);
    addr = _asString(json['addr']);
    tax = _asString(json['tax']);
    tel = _asString(json['tel']);
    email = _asString(json['email']);
    ctype = _asString(json['ctype']);
    zn = _asString(json['zn']);
    aser = _asString(json['aser']);
    qty = _asString(json['qty']);
    count_bill = _asString(json['count_bill']);
    invoice = _asString(json['invoice']);
    expname = _asString(json['expname']);
    ser_tran = _asString(json['ser_tran']);

    custno_1 = _asString(json['custno_1']);
    custno_2 = _asString(json['custno_2']);
    duedate = _asString(json['duedate']);
    amt = _asString(json['amt']);

    amt_expser1 = _asString(json['amt_expser1']);
    amt_expser9 = _asString(json['amt_expser9']);
    amt_expser10 = _asString(json['amt_expser10']);
    amt_expser11 = _asString(json['amt_expser11']);
    amt_expser12 = _asString(json['amt_expser12']);
    wnote = _asString(json['wnote']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ser'] = this.ser;
    data['datex'] = this.datex;
    data['timex'] = this.timex;
    data['rser'] = this.rser;
    data['zser'] = this.zser;
    data['lncode'] = this.lncode;
    data['ln'] = this.ln;
    data['area'] = this.area;
    data['rent'] = this.rent;
    data['st'] = this.st;
    data['img'] = this.img;
    data['tser'] = this.tser;
    data['tname'] = this.tname;
    data['cid'] = this.cid;
    data['data_update'] = this.dataUpdate;
    data['total'] = this.total;
    data['sdate'] = this.sdate;
    data['ldate'] = this.ldate;
    data['cdate'] = this.cdate;
    data['cname'] = this.cname;
    data['sname'] = this.sname;
    data['ln_c'] = this.ln_c;
    data['area_c'] = this.area_c;
    data['docno'] = this.docno;
    data['date'] = this.date;
    data['cname_q'] = this.cname_q;
    data['sname_q'] = this.sname_q;
    data['ln_q'] = this.ln_q;
    data['ldate_q'] = this.ldate_q;
    data['sdate_q'] = this.sdate_q;
    data['area_q'] = this.area_q;
    data['quantity'] = this.quantity;
    data['period'] = this.period;
    data['period_q'] = this.period_q;
    data['rtname'] = this.rtname;
    data['rtname_q'] = this.rtname_q;
    data['stype'] = this.stype;
    data['stype_q'] = this.stype_q;
    data['attn'] = this.attn;
    data['addr'] = this.addr;
    data['tax'] = this.tax;
    data['tel'] = this.tel;
    data['email'] = this.email;
    data['ctype'] = this.ctype;
    data['zn'] = this.zn;
    data['aser'] = this.aser;
    data['qty'] = this.qty;
    data['count_bill'] = this.count_bill;
    data['invoice'] = this.invoice;
    data['expname'] = this.expname;
    data['ser_tran'] = this.ser_tran;

    data['custno_1'] = this.custno_1;
    data['custno_2'] = this.custno_2;
    data['duedate'] = this.duedate;
    data['amt'] = this.amt;

    data['amt_expser1'] = this.amt_expser1;
    data['amt_expser9'] = this.amt_expser9;
    data['amt_expser10'] = this.amt_expser10;
    data['amt_expser11'] = this.amt_expser11;
    data['amt_expser12'] = this.amt_expser12;

    data['wnote'] = this.wnote;

    return data;
  }
}
