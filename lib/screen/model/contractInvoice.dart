class ContractInvoice {
  final int? billAll;
  final double? pvatAll;
  final double? vatAll;
  final double? whtAll;
  final double? totalDisendbill;
  final double? totalAll;
  final List<Data>? data;

  ContractInvoice({
    this.billAll,
    this.pvatAll,
    this.vatAll,
    this.whtAll,
    this.totalDisendbill,
    this.totalAll,
    this.data,
  });

  factory ContractInvoice.fromJson(Map<String, dynamic> json) {
    return ContractInvoice(
      billAll: (json['billAll'] as num?)?.toInt(),
      pvatAll: (json['pvatAll'] as num?)?.toDouble(),
      vatAll: (json['vatAll'] as num?)?.toDouble(),
      whtAll: (json['whtAll'] as num?)?.toDouble(),
      totalDisendbill: (json['total_disendbill'] as num?)?.toDouble(),
      totalAll: (json['totalAll'] as num?)?.toDouble(),
      data: (json['data'] as List?)
          ?.map((e) => Data.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'billAll': billAll,
        'pvatAll': pvatAll,
        'vatAll': vatAll,
        'whtAll': whtAll,
        'total_disendbill': totalDisendbill,
        'totalAll': totalAll,
        'data': data?.map((e) => e.toJson()).toList(),
      };
}

class Data {
  final int? payser;
  final int? ptser;
  final String? bank;
  final String? bno;
  final String? bname;
  final String? ptname;
  final String? img;
  final int? serPayweb;
  final double? pvatBill;
  final double? vatBill;
  final double? whtBill;
  final double? totalBill;
  final double? totalDisendbill;
  final List<Bill>? bill;

  Data({
    this.payser,
    this.ptser,
    this.bank,
    this.bno,
    this.bname,
    this.ptname,
    this.img,
    this.serPayweb,
    this.pvatBill,
    this.vatBill,
    this.whtBill,
    this.totalBill,
    this.totalDisendbill,
    this.bill,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      payser: (json['payser'] as num?)?.toInt(),
      ptser: (json['ptser'] as num?)?.toInt(),
      bank: json['bank'] as String?,
      bno: json['bno'] as String?,
      ptname: json['ptname'] as String?,
      bname: json['bname'] as String?,
      img: json['img'] as String?,
      serPayweb: (json['ser_payweb'] as num?)?.toInt(),
      pvatBill: (json['pvat_bill'] as num?)?.toDouble(),
      vatBill: (json['vat_bill'] as num?)?.toDouble(),
      whtBill: (json['wht_bill'] as num?)?.toDouble(),
      totalBill: (json['total_bill'] as num?)?.toDouble(),
      totalDisendbill: (json['total_disendbill'] as num?)?.toDouble(),
      bill: (json['bill'] as List?)
          ?.map((e) => Bill.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'payser': payser,
        'ptser': ptser,
        'bank': bank,
        'bno': bno,
        'bname': bname,
        'img': img,
        'ser_payweb': serPayweb,
        'ptname': ptname,
        'pvat_bill': pvatBill,
        'vat_bill': vatBill,
        'wht_bill': whtBill,
        'total_bill': totalBill,
        'total_disendbill': totalDisendbill,
        'bill': bill?.map((e) => e.toJson()).toList(),
      };
}

class Bill {
  final String? docno;
  final String? date;
  final String? cid;
  final String? custno;
  final String? st;

  String? status; // <-- เอา final ออก แก้ค่านี้ได้

  final int? payser;
  final int? docnoAll;
  final double? pvatBill;
  final double? vatBill;
  final double? whtBill;
  final double? totalBill;
  final double? totalDisendbill;

  Bill({
    this.docno,
    this.date,
    this.cid,
    this.custno,
    this.st,
    this.status,
    this.payser,
    this.docnoAll,
    this.pvatBill,
    this.vatBill,
    this.whtBill,
    this.totalBill,
    this.totalDisendbill,
  });

  factory Bill.fromJson(Map<String, dynamic> json) => Bill(
        docno: json['docno'] as String?,
        date: json['date'] as String?,
        cid: json['cid'] as String?,
        custno: json['custno'] as String?,
        st: json['st'] as String?,
        status: json['status'] as String?,
        payser: (json['payser'] as num?)?.toInt(),
        docnoAll: (json['docno_all'] as num?)?.toInt(),
        pvatBill: (json['pvat_bill'] as num?)?.toDouble(),
        vatBill: (json['vat_bill'] as num?)?.toDouble(),
        whtBill: (json['wht_bill'] as num?)?.toDouble(),
        totalBill: (json['total_bill'] as num?)?.toDouble(),
        totalDisendbill: (json['total_disendbill'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'docno': docno,
        'date': date,
        'cid': cid,
        'custno': custno,
        'st': st,
        'status': status,
        'payser': payser,
        'docno_all': docnoAll,
        'pvat_bill': pvatBill,
        'vat_bill': vatBill,
        'wht_bill': whtBill,
        'total_bill': totalBill,
        'total_disendbill': totalDisendbill,
      };
}
