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
import 'package:chaoperty_user/Model/GetTrans_Model.dart';
import 'package:chaoperty_user/Model/GetTrans_fine_Model.dart';
import 'package:chaoperty_user/Model/Model_V2/payment_IntentsModel.dart';
import 'package:chaoperty_user/screen_Intents/APIS-V2/config-intents.dart';
import 'package:chaoperty_user/screen_Intents/APIS-V2/payment-intents.dart';
import 'package:chaoperty_user/screen_Intents/Model/IntentsContractx_Fine_Model.dart';
import 'package:chaoperty_user/screen_Intents/Model/IntentsInv_history_Model.dart';

/// ผลลัพธ์จาก Service: แยก "ว่าง" ออกจาก "ล้มเหลว" ให้ ViewModel แสดง section error ได้
class PaymentFetchResult<T> {
  const PaymentFetchResult.success(this.data) : error = null;
  const PaymentFetchResult.failure(this.error) : data = null;

  final T? data;
  final String? error;

  bool get isSuccess => error == null;
  T get valueOr => data as T;
}

/// Facade Service จัดการ API ทั้งหมดสำหรับ Payment V4
class PaymentSubV4Service {
  final http.Client _client;

  PaymentSubV4Service({http.Client? client})
      : _client = client ?? httpClient;

  /// timeout ต่อ endpoint (ตามแผนข้อ 8)
  static const Duration requestTimeout = Duration(seconds: 20);

  /// timeout สำหรับอัปโหลดสลิป (ไฟล์ใหญ่กว่า จึงนานกว่า)
  static const Duration uploadTimeout = Duration(seconds: 60);

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
  Future<PaymentFetchResult<List<TeNantModel>>> loadTenantData({
    required String ren,
    required String cidDoc,
    required String qutser,
  }) async {
    final uri = Uri.parse('${MyConstant().domain}/GC_tenantlookAS.php').replace(
      queryParameters: {
        'isAdd': 'true',
        'ren': ren,
        'ciddoc': cidDoc,
        'qutser': qutser,
      },
    );
    try {
      final response =
          await _client.get(uri).timeout(requestTimeout);
      if (response.statusCode != 200) {
        return PaymentFetchResult.failure('tenant HTTP ${response.statusCode}');
      }
      final result = json.decode(response.body);
      if (result == null || result is! List) {
        return const PaymentFetchResult.success([]);
      }
      return PaymentFetchResult.success(
        result.map((m) => TeNantModel.fromJson(m)).toList(),
      );
    } catch (e) {
      debugPrint('❌ loadTenantData error: $e');
      return const PaymentFetchResult.failure('โหลดข้อมูลผู้เช่าไม่สำเร็จ');
    }
  }

  /// โหลดข้อมูล Rental / Property Info
  Future<PaymentFetchResult<RenTalModel?>> loadRentalData({
    required String ren,
  }) async {
    final uri =
        Uri.parse('${MyConstant().domain}/GC_rental_setring.php').replace(
      queryParameters: {'isAdd': 'true', 'ren': ren},
    );
    try {
      final response =
          await _client.get(uri).timeout(requestTimeout);
      if (response.statusCode != 200) {
        return PaymentFetchResult.failure(
          'rental HTTP ${response.statusCode}',
        );
      }
      final result = json.decode(response.body);
      if (result == null || result is! List || result.isEmpty) {
        return const PaymentFetchResult.success(null);
      }
      return PaymentFetchResult.success(RenTalModel.fromJson(result.first));
    } catch (e) {
      debugPrint('❌ loadRentalData error: $e');
      return const PaymentFetchResult.failure('โหลดข้อมูลโครงการไม่สำเร็จ');
    }
  }

  /// โหลดบัญชีรับชำระ (Payment methods)
  Future<PaymentFetchResult<List<PayMentModel>>> loadPaymentMethods({
    required String ren,
  }) async {
    final uri =
        Uri.parse('${MyConstant().domain_chao}/GC_payMent.php').replace(
      queryParameters: {'isAdd': 'true', 'ren': ren},
    );
    try {
      final response =
          await _client.get(uri).timeout(requestTimeout);
      if (response.statusCode == 500) {
        return const PaymentFetchResult.failure('ช่องทางชำระเงินตอบกลับผิดพลาด');
      }
      if (response.statusCode != 200) {
        return PaymentFetchResult.failure(
          'payment HTTP ${response.statusCode}',
        );
      }
      final result = json.decode(response.body);
      if (result == null || result is! List) {
        return const PaymentFetchResult.success([]);
      }
      return PaymentFetchResult.success(
        result.map((m) => PayMentModel.fromJson(m)).toList(),
      );
    } catch (e) {
      debugPrint('❌ loadPaymentMethods error: $e');
      return const PaymentFetchResult.failure('โหลดช่องทางชำระเงินไม่สำเร็จ');
    }
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
  /// คืน error เมื่อทุก cid ล้มเหลว; ถ้ามีบาง cid สำเร็จ ถือว่าสำเร็จ
  Future<PaymentFetchResult<List<IntentsContractxFineModel>>>
      loadContractFines({
    required String ren,
    required List<String> cids,
  }) async {
    final List<IntentsContractxFineModel> list = [];
    var failed = 0;

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
        final response = await _client.get(uri).timeout(requestTimeout);
        if (response.statusCode != 200) {
          failed++;
          continue;
        }
        final result = json.decode(response.body);
        if (result is List) {
          list.addAll(
            result.map((m) => IntentsContractxFineModel.fromJson(m)),
          );
        }
      } catch (e) {
        debugPrint('❌ loadContractFines for $cid error: $e');
        failed++;
      }
    }

    if (failed > 0 && list.isEmpty && cids.isNotEmpty) {
      return const PaymentFetchResult.failure('โหลดค่าปรับไม่สำเร็จ');
    }
    return PaymentFetchResult.success(list);
  }

  /// โหลด Invoices
  Future<PaymentFetchResult<List<InvoiceModel>>> loadInvoices({
    required String ren,
    required List<String> cids,
    required String qutser,
  }) async {
    final List<InvoiceModel> list = [];
    var failed = 0;

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
        final response = await _client.get(uri).timeout(requestTimeout);
        if (response.statusCode != 200) {
          failed++;
          continue;
        }
        final result = json.decode(response.body);
        if (result is List) {
          list.addAll(result.map((m) => InvoiceModel.fromJson(m)));
        }
      } catch (e) {
        debugPrint('❌ loadInvoices for $cid error: $e');
        failed++;
      }
    }

    if (failed > 0 && list.isEmpty && cids.isNotEmpty) {
      return const PaymentFetchResult.failure('โหลดใบแจ้งหนี้ไม่สำเร็จ');
    }
    return PaymentFetchResult.success(list);
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
      final response = await _client.get(uri).timeout(requestTimeout);
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

  /// โหลดค่าปรับราย invoice (In_tran_select_fine_inv.php)
  ///
  /// endpoint นี้ตอบเป็น string "ชื่อค่าปรับ,ยอดเงิน" ไม่ใช่ JSON
  /// จึงต้อง parse เอง — แยกเป็น static เพื่อ unit test ได้
  static double parseFineInvResponse(String body) {
    final s = body.trim();
    if (s.isEmpty || s == 'null' || s == 'false') return 0.0;

    final idx = s.indexOf(',');
    if (idx == -1) return 0.0;

    final amountPart = s.substring(idx + 1).trim();
    if (amountPart.isEmpty) return 0.0;

    return double.tryParse(amountPart.replaceAll(',', '')) ?? 0.0;
  }

  /// โหลดค่าปรับของ invoice หนึ่งใบ คืนยอดค่าปรับ (0 ถ้าไม่มี/ผิดพลาด)
  Future<double> loadInvoiceFineAmount({
    required String ren,
    required String cidDoc,
    required String tser,
    required String tdocno,
    required String user,
  }) async {
    final uri =
        Uri.parse('${MyConstant().domain_chao}/In_tran_select_fine_inv.php')
            .replace(
      queryParameters: {
        'isAdd': 'true',
        'ren': ren,
        'ciddoc': cidDoc,
        'qutser': '1',
        'tser': tser,
        'tdocno': tdocno,
        'user': user,
      },
    );
    try {
      final response = await _client.get(uri).timeout(requestTimeout);
      if (response.statusCode != 200) return 0.0;
      return parseFineInvResponse(response.body);
    } catch (e) {
      debugPrint('❌ loadInvoiceFineAmount error: $e');
      return 0.0;
    }
  }

  /// โหลด History รายละเอียดบิลย่อย
  Future<PaymentFetchResult<List<IntentsInvoiceHistoryModel>>>
      loadInvoiceHistory({
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
      final response = await _client.get(uri).timeout(requestTimeout);
      if (response.statusCode != 200) {
        return PaymentFetchResult.failure(
          'invoice history HTTP ${response.statusCode}',
        );
      }
      final result = json.decode(response.body);
      if (result is List) {
        return PaymentFetchResult.success(
          result.map((m) => IntentsInvoiceHistoryModel.fromJson(m)).toList(),
        );
      }
      return const PaymentFetchResult.success([]);
    } catch (e) {
      debugPrint('❌ loadInvoiceHistory error: $e');
      return const PaymentFetchResult.failure('โหลดประวัติรายการไม่สำเร็จ');
    }
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
  /// ถือว่าสำเร็จเฉพาะเมื่อ HTTP 2xx และ body ไม่ได้ระบุ failure
  Future<bool> uploadSlip({
    required String intentUuid,
    required Uint8List slipBytes,
    required String fileName,
    required String amount,
    String? ref3,
  }) async {
    try {
      // ต้องมี auth header จริงก่อนยิง Payment API
      final headers = await MyHeadersIntents.build();
      if (headers['Authorization'] == null) {
        debugPrint('🚫 uploadSlip: ไม่มี Authorization → ยกเลิกการอัปโหลด');
        return false;
      }

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
      final streamed = await request.send().timeout(uploadTimeout);
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint('❌ uploadSlip HTTP ${response.statusCode}');
        return false;
      }

      // HTTP 200 อย่างเดียวไม่พอ ต้องตรวจ body ด้วย
      return bodyIndicatesSuccess(response.body);
    } catch (e) {
      debugPrint('❌ uploadSlip error: $e');
      return false;
    }
  }

  /// ตรวจ body ว่าไม่ได้ระบุ failure
  ///
  /// HTTP 2xx อย่างเดียวไม่พอ — บาง endpoint ตอบ 200 พร้อม body ที่บอกว่าล้มเหลว
  /// static เพื่อให้ unit test ตรวจได้โดยไม่ต้องยิง network
  static bool bodyIndicatesSuccess(String body) {
    if (body.trim().isEmpty) return true;
    try {
      final decoded = json.decode(body);
      if (decoded is Map<String, dynamic>) {
        if (decoded['success'] == false) return false;
        if (decoded['ok'] == false) return false;

        final status = decoded['status'];
        if (status is String) {
          final s = status.toLowerCase();
          if (s == 'failed' ||
              s == 'error' ||
              s == 'rejected' ||
              s == 'fail') {
            return false;
          }
        }

        final message = decoded['message'];
        if (message is String) {
          final m = message.toLowerCase();
          if (m.contains('fail') || m.contains('error') || m.contains('ไม่สำเร็จ')) {
            return false;
          }
        }
      }
      return true;
    } catch (_) {
      // body ไม่ใช่ JSON (เช่น HTML error page) — ให้ผ่านเฉพาะที่ดูเหมือน JSON object
      return body.trimLeft().startsWith('{');
    }
  }

  /// โหลดค่าปรับ transaction (GC_tran_select_fin.php)
  ///
  /// ใช้คิดยอด sum_tran_fine ในสูตร requestedTotal ของต้นแบบ
  Future<List<TransFineModel>> loadTransFines({
    required String ren,
    required List<String> cids,
    required String user,
  }) async {
    final all = <TransFineModel>[];
    var failed = 0;

    for (final cid in cids) {
      final uri = Uri.parse('${MyConstant().domain_chao}/GC_tran_select_fin.php')
          .replace(queryParameters: {
        'isAdd': 'true',
        'ren': ren,
        'user': user,
        'ciddoc': cid,
      });
      try {
        final response = await _client.get(uri).timeout(requestTimeout);
        if (response.statusCode != 200) {
          failed++;
          continue;
        }
        final result = json.decode(response.body);
        if (result is List) {
          all.addAll(result.map((m) => TransFineModel.fromJson(m)));
        }
      } catch (e) {
        debugPrint('❌ loadTransFines for $cid error: $e');
        failed++;
      }
    }

    if (failed > 0 && all.isEmpty && cids.isNotEmpty) {
      throw Exception('โหลดค่าปรับรายการไม่สำเร็จ');
    }
    return all;
  }

  /// โหลด transaction รวม (GC_tran_select.php)
  ///
  /// ใช้คิดยอด sum_pvat / sum_vat / sum_wht / sum_amt ในสูตรต้นแบบ
  Future<List<TransModel>> loadTransactions({
    required String ren,
    required List<String> cids,
    required String user,
  }) async {
    final all = <TransModel>[];
    var failed = 0;

    for (final cid in cids) {
      final uri = Uri.parse('${MyConstant().domain_chao}/GC_tran_select.php')
          .replace(queryParameters: {
        'isAdd': 'true',
        'ren': ren,
        'user': user,
        'ciddoc': cid,
      });
      try {
        final response = await _client.get(uri).timeout(requestTimeout);
        if (response.statusCode != 200) {
          failed++;
          continue;
        }
        final result = json.decode(response.body);
        if (result is List) {
          all.addAll(result.map((m) => TransModel.fromJson(m)));
        }
      } catch (e) {
        debugPrint('❌ loadTransactions for $cid error: $e');
        failed++;
      }
    }

    if (failed > 0 && all.isEmpty && cids.isNotEmpty) {
      throw Exception('โหลดรายการไม่สำเร็จ');
    }
    return all;
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
      ).timeout(requestTimeout);
      return response != null &&
          response.statusCode >= 200 &&
          response.statusCode < 300;
    } catch (e) {
      debugPrint('❌ cancelPaymentIntent error: $e');
      return false;
    }
  }
}
