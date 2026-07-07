import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Constant/Myconstant.dart';
import '../Constant/api_session.dart';
import '../Model/GetC_regis_Model.dart';
import '../Model/GetCustomer_Model.dart';
import '../screen_Intents/APIS-V2/payment-intents.dart';
import 'Screen_new/fitness_app_home_screen.dart';

class MarketService {
  static Future<void> applyMarket(BuildContext ctx, c_regis_Model model) async {
    final rser = model.rser;
    final cusno = model.custno;

    await ApiSession.setBearerToken(model.payEncoded64 ?? '');
    await ApiSession.setNonceId(model.fid ?? '');

    final url =
        '${MyConstant().domain}/Gc_customer_user.php?isAdd=true&ren=$rser&cusno=$cusno';
    final response = await http.get(Uri.parse(url));
    final result = json.decode(response.body);

    for (var map in result) {
      final cm = CustomerModel.fromJson(map);
      final prefs = await SharedPreferences.getInstance();
      // ✅ await ทุกครั้งเพื่อให้แน่ใจว่า SharedPreferences flush เสร็จ
      // ก่อนที่ AuthGate (ตอน refresh) จะอ่านกลับมา
      await prefs.setString('custno', model.custno ?? '');
      await prefs.setString('lang', model.language?.toString() ?? 'TH');
      await prefs.setString('renTalSer', model.rser ?? '');
      await prefs.setString('renTalName', model.pn ?? '');
      await prefs.setString('lintid', cm.lineid.toString());
      await prefs.setString('ser', model.ser.toString());
      await prefs.setString('cname', cm.cname.toString());
      await prefs.setString('sname', cm.scname.toString());
      await prefs.setString('email', cm.email.toString());
      await prefs.setString('photo', cm.addr2.toString());
      await prefs.setString('address', cm.addr1.toString());
      await prefs.setString('contact', cm.attn.toString());
      await prefs.setString('stype', cm.stype.toString());
      await prefs.setString('tel', cm.tel.toString());
      await prefs.setString('tax', cm.tax.toString());
      await prefs.setString('foder', cm.foder.toString());
      await prefs.setString('pay_token', model.payToken ?? '');
      await prefs.setString('pay_encoded64', model.payEncoded64 ?? '');
      await prefs.setString('fid', model.fid ?? '');

      await _storeCustomerToken(cusno, rser);
    }

    if (!ctx.mounted) return;
    Navigator.pushAndRemoveUntil(
      ctx,
      MaterialPageRoute(
          builder: (_) => FitnessAppHomeScreen(custno_s: model.custno)),
      (route) => false,
    );
  }

  static Future<void> _storeCustomerToken(String? cusno, String? rser) async {
    if (cusno == null || rser == null) return;
    await getCustomerToken(
      customerNo: cusno.trim(),
      propertyNo: rser.trim(),
    );
  }
}
