import 'package:chaoperty_user/Model/GetInvoice_Model.dart';
import 'package:chaoperty_user/Model/GetInvoice_pay_Model.dart';
import 'package:chaoperty_user/screen_Intents/Model/IntentsInv_history_Model.dart';

/// สร้าง payload สำหรับ POST /v1/payment/intent
///
/// แยกเป็น pure function เพื่อให้ unit test เทียบกับต้นแบบได้ทุก field
/// โดยไม่ต้องมี ViewModel หรือ network
///
/// อ้างอิงโครงสร้างจากต้นแบบ `payment_subV4_InvAll.dart` (CreatePaymentItem)
class PaymentIntentPayload {
  const PaymentIntentPayload({
    required this.invoices,
    required this.trans,
    required this.customerData,
    required this.requestedAmount,
    required this.lateFee,
    required this.discountAmount,
  });

  final List<Map<String, dynamic>> invoices;
  final List<Map<String, dynamic>> trans;
  final List<Map<String, dynamic>> customerData;
  final double requestedAmount;
  final double lateFee;
  final double discountAmount;

  /// ยอดที่ส่งเป็น late_fee คือผลรวมค่าปรับราย invoice (fine ของแต่ละบิล)
  /// ไม่ใช่ fine_total ที่คิดจาก payment method — สองค่าคนละความหมาย
  static double sumInvoiceFine(List<InvoicePayModel> invoicePayModels) {
    var sum = 0.0;
    for (final m in invoicePayModels) {
      sum += _d(m.fine);
    }
    return _d2(sum);
  }

  /// ยอดรวมปลายทางตามสูตรต้นแบบ
  ///
  /// `sumPvat + sumTranFine - disSumPakan - (sumDiscount + sumDisIn)
  ///  + (sumAmtIn + sumTranFineIn) + fineTotal`
  ///
  /// หมายเหตุความต่างจากต้นแบบ (ตั้งใจ ไม่ replicate):
  /// - ต้นแบบใช้ `sum_disamt = disendbill` เป็น **assignment** (บิลสุดท้ายทับ) ซึ่งเป็น bug
  ///   เมื่อมีหลายใบ ที่นี่รับค่าที่ผู้เรียกเตรียมมาแล้ว จึงคิดเป็นยอดรวมได้ตรงจริง
  /// - ต้นแบบบวก `sum_pvat + sum_tran_fine` ใน setState ที่เรียก async โดยไม่ await
  ///   ค่าจึงขึ้นกับ race ที่อ่านไม่ซ้ำได้ ที่นี่บวกทั้งสองก้อนตรง ๆ แบบ deterministic
  static double requestedTotal({
    required double sumPvat,
    required double sumTranFine,
    required double sumAmtIn,
    required double sumTranFineIn,
    required double sumDiscount,
    required double sumDisIn,
    required double fineTotal,
    required double disSumPakan,
  }) {
    final v = sumPvat +
        sumTranFine -
        disSumPakan -
        (sumDiscount + sumDisIn) +
        (sumAmtIn + sumTranFineIn) +
        fineTotal;
    return _d2(v);
  }

  /// ค่าที่ต้องใช้คิด `sumDiscount` ตามความหมายของต้นแบบ
  ///
  /// ต้นแบบเขียน `sum_disamt = double.parse(disendbill)` ในลูป จึงได้ค่าของ
  /// invoice history แถว **สุดท้าย** ไม่ใช่ผลรวม — ฟังก์ชันนี้ทำแบบเดียวกัน
  /// เพื่อให้ยอดตรงกับที่ server เคยเห็น แต่ระบุชัดว่าเป็นพฤติกรรมที่สืบทอดมา
  static double legacyLastDiscount(List<IntentsInvoiceHistoryModel> history) {
    if (history.isEmpty) return 0.0;
    return _d(history.last.disendbill);
  }

  /// `sum_disamt_in` ในต้นแบบไม่เคยถูกกำหนดค่านอกการ reset จึงเป็น 0 เสมอ
  static const double legacySumDisIn = 0.0;

  /// metadata ต่อ invoice — สร้างจาก invoice history ของบิลนั้น
  static List<Map<String, dynamic>> buildMetadata({
    required List<IntentsInvoiceHistoryModel> history,
    required int payser,
    required String selectedDocno,
  }) {
    return history.map<Map<String, dynamic>>((b) {
      return {
        'expname': b.descr ?? '',
        'docno': b.refno ?? '',
        'date': b.date,
        'cid': b.cid ?? '',
        'payser': payser,
        'pri_bill': _d(b.pri),
        'pvat_bill': _d(b.pvat),
        'vat_bill': _d(b.vat),
        'nvat': _d(b.nvat),
        'wht_bill': _d(b.wht),
        'late_fee': 0,
        'list_fee': const <Map<String, dynamic>>[],
        'total_bill': _d(b.total_t),
        'selected': selectedDocno,
      };
    }).toList();
  }

  /// list_fee ต่อ invoice — ใส่เฉพาะเมื่อมีค่าปรับจริง
  static List<Map<String, dynamic>> buildListFee({
    required String docno,
    required Map<String, dynamic> fine,
  }) {
    final total = _d(fine['total']);
    if (fine['ok'] != true || total <= 0) {
      return const <Map<String, dynamic>>[];
    }
    return [
      {
        'docno': docno,
        'duedate': fine['duedate'] ?? '',
        'expser': _i(fine['expser']),
        'expname': fine['expname'] ?? 'ชำระเกินกำหนด',
        'no': _i(fine['no']),
        'pvat': _d(fine['pvat']),
        'vser': _i(fine['vser']),
        'vtype': fine['vtype'] ?? '',
        'nvat': _i(fine['nvat']),
        'vat': _d(fine['vat']),
        'wht': _d(fine['wht']),
        'total': total,
      }
    ];
  }

  /// customer_data — group trans ตาม refno
  static List<Map<String, dynamic>> buildCustomerData({
    required List<IntentsInvoiceHistoryModel> trans,
  }) {
    final grouped = <String, List<IntentsInvoiceHistoryModel>>{};
    for (final t in trans) {
      final key = (t.refno ?? '').trim();
      if (key.isEmpty) continue;
      grouped.putIfAbsent(key, () => []).add(t);
    }

    return grouped.values.map<Map<String, dynamic>>((group) {
      final first = group.first;
      final docno = (first.docno ?? '').trim();
      return {
        'customer_no': first.custno ?? '',
        'cid': first.cid ?? '',
        'sname': first.sname ?? '',
        'cname': first.cname ?? '',
        'zser': first.zser ?? '',
        'zn': first.zn ?? '',
        'aser': first.aser ?? '',
        'ln': first.ln ?? '',
        'lncode': '',
        'invoices': docno,
      };
    }).toList();
  }

  /// สร้าง invoices[] หนึ่งรายการ
  ///
  /// `amount` และฐาน `total` ใช้ยอดบิลรวม VAT (`total_bill`) เพื่อให้ตรงกับ
  /// ยอดที่ผู้ใช้เห็น; `late_fee` คือค่าปรับของ invoice และรวมอยู่ใน `total` แล้ว
  /// เช่น `220 + 250 = 470`. ถ้า API เก่าไม่มี `total_bill` ใช้ค่าเดิม fallback
  /// จาก `amtall`/`amt + vat - wht` ตามลำดับ
  static Map<String, dynamic> buildInvoiceEntry({
    required InvoiceModel inv,
    required List<IntentsInvoiceHistoryModel> history,
    required Map<String, dynamic> fine,
    required double invoiceFine,
    required int payser,
  }) {
    final docno = inv.docno ?? '';
    final amtNet = _d(inv.amt) + _d(inv.vat) - _d(inv.wht);
    final billTotal = _d(inv.total_bill);

    // `total_bill` คือยอดบิลรวม VAT ที่ผู้ใช้เห็นและต้องชำระจริง
    // `amtall` คือยอดก่อน VAT จึงห้ามใช้เป็น total ของ invoice payload
    // เมื่อมีค่าปรับ total ต้องรวมยอดบิล + late_fee: 220 + 250 = 470
    final amount = billTotal > 0 ? billTotal : amtNet;
    final total = (billTotal > 0 ? billTotal : _d(inv.amtall)) + invoiceFine;

    return {
      'invoice_id': 0,
      'bill_reference': docno,
      'amount': _d2(amount),
      'late_fee': _d2(invoiceFine),
      'discount_amount': _d(inv.dis),
      'deposit_amount': 0,
      'insurance_amount': 0,
      'withholding_amount': 0,
      'total': _d2(total),
      'list_fee': buildListFee(docno: docno, fine: fine),
      'metadata': buildMetadata(
        history: history,
        payser: payser,
        selectedDocno: docno,
      ),
    };
  }

  /// เลือกค่าปรับราย invoice จาก invoicePayModels ตาม docno
  static double fineForDocno(
    List<InvoicePayModel> models,
    String docno,
  ) {
    for (final m in models) {
      if ((m.docno ?? '').trim() == docno.trim()) {
        return _d(m.fine);
      }
    }
    return 0.0;
  }
}

/// parse แบบปลอดภัย — null/empty/comma คืน 0 ไม่ throw
double _d(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  final s = v.toString().replaceAll(',', '').trim();
  if (s.isEmpty) return 0;
  return double.tryParse(s) ?? 0;
}

/// ปัด 2 ตำแหน่งเพื่อตัด floating-point noise ก่อนส่ง API
double _d2(double v) => (v * 100).roundToDouble() / 100;

int _i(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString().trim()) ?? 0;
}
