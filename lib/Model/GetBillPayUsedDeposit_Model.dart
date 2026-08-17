import 'dart:convert';

import 'package:http/http.dart' as http;

import '../Constant/Myconstant.dart';

/// ยิง API GC_billpay_used_deposit.php แล้วคืนรายการตัดมัดจำชำระ
/// ใช้แทนการบวก dis_sum_Matjum จาก finnancetransModel.dtype == 'MM'
class BillPayUsedDepositApi {
  static Future<List<BillPayUsedDepositModel>> fetch(
      {required dynamic ren, required dynamic docnoin}) async {
    List<BillPayUsedDepositModel> models = [];
    String url =
        '${MyConstant().domain}/GC_billpay_used_deposit.php?isAdd=true&ren=$ren&docnoin=$docnoin';
    print('USED_DEPOSIT>>>> $url');
    try {
      var response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);
      if (result.toString() != 'null') {
        for (var map in result) {
          models.add(BillPayUsedDepositModel.fromJson(map));
        }
      }
    } catch (e) {
      print('USED_DEPOSIT Error: $e');
    }
    return models;
  }

  /// ยอด "หักเงินมัดจำ" = รวม total ทุกแถว
  static double sumTotal(List<BillPayUsedDepositModel> models) =>
      models.fold(0.00, (sum, m) => sum + (m.total ?? 0.00));
}

/// Model สำหรับ API: GC_billpay_used_deposit.php
/// (รายการตัดมัดจำชำระของบิลนั้น ๆ)
class BillPayUsedDepositModel {
  String? docno;
  String? doctax;
  String? cid;
  String? expser;
  String? expname;
  double? pvat;
  double? vat;
  double? wht;
  double? total;
  String? billpay_dtype;
  double? total_billpay_diposit;

  BillPayUsedDepositModel({
    this.docno,
    this.doctax,
    this.cid,
    this.expser,
    this.expname,
    this.pvat,
    this.vat,
    this.wht,
    this.total,
    this.billpay_dtype,
    this.total_billpay_diposit,
  });

  /// API ส่งตัวเลขมาเป็น number (ไม่ใช่ string) จึงต้องแปลงแบบกัน type error
  static double _toDouble(dynamic v) {
    if (v == null) return 0.00;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString().replaceAll(',', '').trim()) ?? 0.00;
  }

  static String? _toStr(dynamic v) => (v == null) ? null : v.toString();

  BillPayUsedDepositModel.fromJson(Map<String, dynamic> json) {
    docno = _toStr(json['docno']);
    doctax = _toStr(json['doctax']);
    cid = _toStr(json['cid']);
    expser = _toStr(json['expser']);
    expname = _toStr(json['expname']);
    pvat = _toDouble(json['pvat']);
    vat = _toDouble(json['vat']);
    wht = _toDouble(json['wht']);
    total = _toDouble(json['total']);
    billpay_dtype = _toStr(json['billpay_dtype']);
    total_billpay_diposit = _toDouble(json['total_billpay_diposit']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['docno'] = this.docno;
    data['doctax'] = this.doctax;
    data['cid'] = this.cid;
    data['expser'] = this.expser;
    data['expname'] = this.expname;
    data['pvat'] = this.pvat;
    data['vat'] = this.vat;
    data['wht'] = this.wht;
    data['total'] = this.total;
    data['billpay_dtype'] = this.billpay_dtype;
    data['total_billpay_diposit'] = this.total_billpay_diposit;
    return data;
  }
}
