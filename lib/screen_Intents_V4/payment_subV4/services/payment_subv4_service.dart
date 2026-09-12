import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';

import 'package:chaoperty_user/Constant/Myconstant.dart';
import 'package:chaoperty_user/Constant/global_http.dart';
import 'package:chaoperty_user/Model/GetInvoice_Model.dart';
import 'package:chaoperty_user/Model/GetPayMent_Model.dart';
import 'package:chaoperty_user/Model/GetRenTal_Model.dart';
import 'package:chaoperty_user/Model/GetTeNant_Model.dart';
import 'package:chaoperty_user/Model/Model_V2/payment_IntentsModel.dart';
import 'package:chaoperty_user/screen_Intents/APIS-V2/config-intents.dart';
import 'package:chaoperty_user/screen_Intents/APIS-V2/payment-intents.dart';
import 'package:chaoperty_user/screen_Intents/Model/IntentsContractx_Fine_Model.dart';
import 'package:chaoperty_user/screen_Intents/Model/IntentsInv_history_Model.dart';

/// Facade Service จัดการ API ทั้งหมดสำหรับ Payment V4
class PaymentSubV4Service {
  final http.Client _client;

  PaymentSubV4Service({http.Client? client})
      : _client = client ?? httpClient;

  /// ตรวจสอบสิทธิ์ Payment Intent
  Future<bool> checkAuth() async {
    try {
      return await MyHeadersIntents.checkauthpaymentintents();
    } catch (e) {
      debugPrint('❌ checkAuth error: $e');
      return false;
    }
  }

  /// โหลดข้อมูล Tenant
  Future<List<TeNantModel>> loadTenantData({
    required String ren,
    required String cidDoc,
    required String qutser,
  }) async {
    final url =
        '${MyConstant().domain}/GC_tenantlookAS.php?isAdd=true&ren=$ren&ciddoc=$cidDoc&qutser=$qutser';
    try {
      final response = await _client.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result != null && result is List) {
          return result.map((m) => TeNantModel.fromJson(m)).toList();
        }
      }
    } catch (e) {
      debugPrint('❌ loadTenantData error: $e');
    }
    return [];
  }

  /// โหลดข้อมูล Rental / Property Info
  Future<RenTalModel?> loadRentalData({required String ren}) async {
    final url =
        '${MyConstant().domain}/GC_rental_setring.php?isAdd=true&ren=$ren';
    try {
      final response = await _client.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result != null && result is List && result.isNotEmpty) {
          return RenTalModel.fromJson(result.first);
        }
      }
    } catch (e) {
      debugPrint('❌ loadRentalData error: $e');
    }
    return null;
  }

  /// โหลดบัญชีรับชำระ (Payment methods)
  Future<List<PayMentModel>> loadPaymentMethods({required String ren}) async {
    final url = '${MyConstant().domain_chao}/GC_payMent.php?isAdd=true&ren=$ren';
    try {
      final response = await _client.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result != null && result is List) {
          return result.map((m) => PayMentModel.fromJson(m)).toList();
        }
      }
    } catch (e) {
      debugPrint('❌ loadPaymentMethods error: $e');
    }
    return [];
  }

  /// โหลด Payment Intents จาก Server
  Future<List<PaymentIntent>> loadPaymentIntents({
    required String cusno,
    required String propertyno,
    String? serPayment,
  }) async {
    try {
      final response = await postPaymentIntentsState(
        cusno: cusno,
        propertyno: propertyno,
      );

      if (response == null || response.body.isEmpty) return [];

      final root = json.decode(response.body);
      if (root is! Map<String, dynamic>) return [];

      final intentsListRaw = root['data'];
      if (intentsListRaw is! List) return [];

      var list = intentsListRaw
          .whereType<Map<String, dynamic>>()
          .map((m) => PaymentIntent.fromJson(m))
          .toList();

      if (serPayment != null && serPayment.isNotEmpty) {
        list = list
            .where((p) => p.bankmerchantid.toString() == serPayment)
            .toList();
      }

      return list;
    } catch (e) {
      debugPrint('❌ loadPaymentIntents error: $e');
      return [];
    }
  }

  /// โหลดค่าปรับสัญญา (GC_fine)
  Future<List<IntentsContractxFineModel>> loadContractFines({
    required String ren,
    required List<String> cids,
  }) async {
    final List<IntentsContractxFineModel> list = [];
    for (final cid in cids) {
      final uri = Uri.parse('${MyConstant().domain_chao}/GC_fine.php').replace(
        queryParameters: {
          'isAdd': 'true',
          'ren': ren,
          'ciddoc': cid,
          'qutser': '1',
        },
      );
      try {
        final response = await _client.get(uri);
        final result = json.decode(response.body);
        if (result != null && result is List) {
          list.addAll(
            result.map((m) => IntentsContractxFineModel.fromJson(m)),
          );
        }
      } catch (e) {
        debugPrint('❌ loadContractFines for $cid error: $e');
      }
    }
    return list;
  }

  /// โหลด Invoices
  Future<List<InvoiceModel>> loadInvoices({
    required String ren,
    required List<String> cids,
    required String qutser,
  }) async {
    final List<InvoiceModel> list = [];
    for (final cid in cids) {
      final uri =
          Uri.parse('${MyConstant().domain_chao}/GC_bill_invoice.php').replace(
        queryParameters: {
          'isAdd': 'true',
          'ren': ren,
          'ciddoc': cid,
          'qutser': qutser,
        },
      );
      try {
        final response = await _client.get(uri);
        final result = json.decode(response.body);
        if (result != null && result is List) {
          list.addAll(result.map((m) => InvoiceModel.fromJson(m)));
        }
      } catch (e) {
        debugPrint('❌ loadInvoices for $cid error: $e');
      }
    }
    return list;
  }

  /// โหลด Fine ราย Invoice
  Future<Map<String, dynamic>> loadInvoiceFine({
    required String ren,
    required String docno,
  }) async {
    final uri =
        Uri.parse('${MyConstant().domain_chao}/GC_selectFine_inv.php').replace(
      queryParameters: {
        'isAdd': 'true',
        'ren': ren,
        'tdocno': docno,
      },
    );
    try {
      final response = await _client.get(uri);
      final decoded = json.decode(response.body);
      if (decoded is Map<String, dynamic>) {
        return {
          'ok': true,
          'expname': decoded['expname'],
          'expser': decoded['expser'],
          'no': decoded['no'],
          'pvat': (decoded['pvat'] as num?)?.toDouble() ?? 0.0,
          'vser': (decoded['vser'] as num?)?.toDouble() ?? 0.0,
          'vtype': decoded['vtype'],
          'nvat': (decoded['nvat'] as num?)?.toInt() ?? 0,
          'vat': (decoded['vat'] as num?)?.toDouble() ?? 0.0,
          'total': (decoded['total'] as num?)?.toDouble() ?? 0.0,
          'wht': (decoded['wht'] as num?)?.toDouble() ?? 0.0,
          'docno': decoded['docno'] ?? docno,
        };
      }
    } catch (e) {
      debugPrint('❌ loadInvoiceFine error: $e');
    }
    return {'ok': false};
  }

  /// โหลด History รายละเอียดบิลย่อย
  Future<List<IntentsInvoiceHistoryModel>> loadInvoiceHistory({
    required String ren,
    required String user,
    required String cidDoc,
    required String docno,
  }) async {
    final uri =
        Uri.parse('${MyConstant().domain_chao}/GC_bill_invoiceHistory_v2.php')
            .replace(
      queryParameters: {
        'isAdd': 'true',
        'ren': ren,
        'user': user,
        'ciddoc': cidDoc,
        'docnoin': docno,
      },
    );
    try {
      final response = await _client.get(uri);
      final result = json.decode(response.body);
      if (result != null && result is List) {
        return result
            .map((m) => IntentsInvoiceHistoryModel.fromJson(m))
            .toList();
      }
    } catch (e) {
      debugPrint('❌ loadInvoiceHistory error: $e');
    }
    return [];
  }

  /// สร้าง Payment Intent บน Server
  Future<Map<String, dynamic>?> createPaymentIntent({
    required String cusNo,
    required String propertyNo,
    required int payser,
    required int typepayser,
    required double requestedTotal,
    required double lateFee,
    required double discountAmount,
    required List<Map<String, dynamic>> inVoices,
    required List<Map<String, dynamic>> transSelect,
    required String payBno,
    required String payBname,
    required String payBnameEn,
    required String payBankNcode,
    required String payPaytypeNcode,
    required List<Map<String, dynamic>> customerData,
  }) async {
    final accountType = (payPaytypeNcode.isEmpty || payPaytypeNcode == 'null')
        ? payBankNcode
        : payPaytypeNcode;

    final response = await postPaymentIntents(
      cusNo: cusNo,
      propertyNo: propertyNo,
      payedType: 'invoice',
      chanNel: 'invoice',
      requestedAmount: requestedTotal,
      lateFee: lateFee,
      discountAmount: discountAmount,
      depositAmount: 0.0,
      insuranceAmount: 0.0,
      withholdingAmount: 0.0,
      requestedTotal: requestedTotal,
      isAdminCreated: true,
      bankMerchantId: payser,
      bankMerchantType: typepayser,
      descripTion: '',
      inVoices: inVoices,
      transSelect: transSelect,
      accountType: accountType,
      accountNumber: payBno,
      accountNameTh: payBname,
      accountNameEn: payBnameEn,
      customerData: customerData,
    );

    if (response != null &&
        response.statusCode >= 200 &&
        response.statusCode < 300) {
      final jsonRes = json.decode(response.body);
      return jsonRes['data'] ?? jsonRes;
    }
    return null;
  }

  /// โหลด Intent Detail
  Future<Map<String, dynamic>?> loadIntentDetail({
    required String cusNo,
    required String propertyNo,
    required String intentsUuid,
  }) async {
    try {
      final resp = await getDetailsPaymentIntents(
        cusNo: cusNo,
        propertyNo: propertyNo,
        intentsUuid: intentsUuid,
      );
      if (resp != null && resp.statusCode >= 200 && resp.statusCode < 300) {
        final root = json.decode(resp.body);
        return root['data'] as Map<String, dynamic>?;
      }
    } catch (e) {
      debugPrint('❌ loadIntentDetail error: $e');
    }
    return null;
  }

  /// Generate หรือ Renew QR Code
  Future<Map<String, dynamic>?> generateOrRenewQr({
    required String cusNo,
    required String propertyNo,
    required String intentsUuid,
    required int bankMerchantId,
  }) async {
    try {
      final resp = await postGeneratePaymentIntents(
        cusNo: cusNo,
        propertyNo: propertyNo,
        intentsUuid: intentsUuid,
        bankMerchantId: bankMerchantId,
      );

      if (resp != null && resp.statusCode >= 200 && resp.statusCode < 300) {
        final root = json.decode(resp.body);
        return root['data'] ?? root;
      }
    } catch (e) {
      debugPrint('❌ generateOrRenewQr error: $e');
    }
    return null;
  }

  /// อัปโหลดสลิปหลักฐาน
  Future<bool> uploadSlip({
    required String intentUuid,
    required Uint8List slipBytes,
    required String fileName,
    required String amount,
    String? ref3,
  }) async {
    try {
      final headers = await MyHeadersIntents.build();
      final uri = Uri.parse(
          '${MyconfigIntents().domainIntents}/v1/payment/intent/$intentUuid/upload/slip');

      final request = http.MultipartRequest('POST', uri);
      final now = DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(now);

      request.fields.addAll({
        'amount': amount,
        'transfer_date': dateStr,
        'transfer_ref_no': ref3 ?? '',
        'transfer_type': 'bank_transfer',
        'notes': 'อัปโหลดจากแอพผู้เช่า',
      });

      String contentType = 'image/jpeg';
      final ext = fileName.toLowerCase().split('.').last;
      if (ext == 'png') {
        contentType = 'image/png';
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          slipBytes,
          filename: fileName,
          contentType: MediaType.parse(contentType),
        ),
      );

      request.headers.addAll(headers);
      final response = await request.send();

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('❌ uploadSlip error: $e');
      return false;
    }
  }

  /// ยกเลิกรายการชำระเงิน
  Future<bool> cancelPaymentIntent({
    required String cusNo,
    required String propertyNo,
    required String intentsUuid,
    required int bankMerchantId,
  }) async {
    try {
      final response = await DeletePaymentIntents_UuidCanceled(
        cusNo: cusNo,
        propertyNo: propertyNo,
        intentsUuid: intentsUuid,
        bankMerchantId: bankMerchantId,
      );
      return response != null &&
          response.statusCode >= 200 &&
          response.statusCode < 300;
    } catch (e) {
      debugPrint('❌ cancelPaymentIntent error: $e');
      return false;
    }
  }
}
