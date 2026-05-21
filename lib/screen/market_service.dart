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
      prefs.setString('custno', model.custno ?? '');
      prefs.setString('lang', model.language?.toString() ?? 'TH');
      prefs.setString('renTalSer', model.rser ?? '');
      prefs.setString('renTalName', model.pn ?? '');
      prefs.setString('lintid', cm.lineid.toString());
      prefs.setString('ser', model.ser.toString());
      prefs.setString('cname', cm.cname.toString());
      prefs.setString('sname', cm.scname.toString());
      prefs.setString('email', cm.email.toString());
      prefs.setString('photo', cm.addr2.toString());
      prefs.setString('address', cm.addr1.toString());
      prefs.setString('contact', cm.attn.toString());
      prefs.setString('stype', cm.stype.toString());
      prefs.setString('tel', cm.tel.toString());
      prefs.setString('tax', cm.tax.toString());
      prefs.setString('foder', cm.foder.toString());
      prefs.setString('pay_token', model.payToken.toString());
      prefs.setString('pay_encoded64', model.payEncoded64.toString());
      prefs.setString('fid', model.fid.toString());

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
    int toU16(String? v) => (int.tryParse((v ?? '0').trim()) ?? 0) + 65535;
    await getCustomerToken(
      customerNo: toU16(cusno).toString(),
      propertyNo: toU16(rser).toString(),
    );
  }
}
