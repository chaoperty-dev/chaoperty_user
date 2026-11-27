import 'package:flutter_test/flutter_test.dart';
import 'package:chaoperty_user/Model/GetInvoice_Model.dart';
import 'package:chaoperty_user/Model/GetInvoice_pay_Model.dart';
import 'package:chaoperty_user/screen_Intents/Model/IntentsInv_history_Model.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/models/payment_intent_payload.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/services/payment_subv4_service.dart';

InvoiceModel _inv({
  String? docno,
  String? ser,
  String? amt,
  String? vat,
  String? wht,
  String? dis,
  String? amtall,
  String? pvat,
  String? disendbill,
  String? totalBill,
}) {
  final m = InvoiceModel();
  m.docno = docno;
  m.ser = ser;
  m.amt = amt;
  m.vat = vat;
  m.wht = wht;
  m.dis = dis;
  m.amtall = amtall;
  m.pvat = pvat;
  m.disendbill = disendbill;
  m.total_bill = totalBill;
  return m;
}

IntentsInvoiceHistoryModel _hist({
  String? refno,
  String? docno,
  String? descr,
  String? cid,
  String? custno,
  String? pri,
  String? pvat,
  String? vat,
  String? nvat,
  String? wht,
  // ชื่อ parameter ตาม field จริงใน model (total_t) เพื่อให้อ่านเทียบต้นแบบได้ตรง
  // ignore: non_constant_identifier_names
  String? total_t,
  String? sname,
  String? cname,
  String? zn,
  String? zser,
  String? aser,
  String? ln,
  String? date,
  String? disendbill,
}) {
  final m = IntentsInvoiceHistoryModel();
  m.refno = refno;
  m.docno = docno;
  m.descr = descr;
  m.cid = cid;
  m.custno = custno;
  m.pri = pri;
  m.pvat = pvat;
  m.vat = vat;
  m.nvat = nvat;
  m.wht = wht;
  m.total_t = total_t;
  m.sname = sname;
  m.cname = cname;
  m.zn = zn;
  m.zser = zser;
  m.aser = aser;
  m.ln = ln;
  m.date = date;
  m.disendbill = disendbill;
  return m;
}

void main() {
  group('buildMetadata', () {
    test('maps every field used by the legacy payload', () {
      final meta = PaymentIntentPayload.buildMetadata(
        history: [
          _hist(
            refno: 'R1',
            descr: 'ค่าเช่า',
            cid: 'CID1',
            pri: '100.00',
            pvat: '7.00',
            vat: '7.00',
            nvat: '107',
            wht: '3.00',
            total_t: '104.00',
            date: '2026-01-15',
          ),
        ],
        payser: 42,
        selectedDocno: 'INV-1',
      );

      expect(meta, hasLength(1));
      final m = meta.first;
      expect(m['expname'], 'ค่าเช่า');
      expect(m['docno'], 'R1');
      expect(m['cid'], 'CID1');
      expect(m['payser'], 42);
      expect(m['pri_bill'], 100.0);
      expect(m['pvat_bill'], 7.0);
      expect(m['vat_bill'], 7.0);
      expect(m['nvat'], 107.0);
      expect(m['wht_bill'], 3.0);
      expect(m['total_bill'], 104.0);
      expect(m['late_fee'], 0);
      expect(m['selected'], 'INV-1');
      expect(m['list_fee'], isEmpty);
      expect(m.containsKey('date'), isTrue);
    });

    test('empty history yields empty metadata', () {
      final meta = PaymentIntentPayload.buildMetadata(
        history: [],
        payser: 1,
        selectedDocno: 'X',
      );
      expect(meta, isEmpty);
    });

    test('null numeric fields become 0, not null', () {
      final meta = PaymentIntentPayload.buildMetadata(
        history: [_hist(refno: 'R1')],
        payser: 1,
        selectedDocno: 'X',
      );
      final m = meta.first;
      expect(m['pri_bill'], 0.0);
      expect(m['total_bill'], 0.0);
      expect(m['nvat'], 0.0);
    });

    test('comma formatted numbers parse safely', () {
      final meta = PaymentIntentPayload.buildMetadata(
        history: [_hist(refno: 'R1', total_t: '1,234.56')],
        payser: 1,
        selectedDocno: 'X',
      );
      expect(meta.first['total_bill'], 1234.56);
    });
  });

  group('buildListFee', () {
    test('returns a single entry when fine exists', () {
      final list = PaymentIntentPayload.buildListFee(
        docno: 'INV-1',
        fine: {
          'ok': true,
          'expname': 'ชำระเกินกำหนด',
          'expser': '3',
          'no': '2',
          'pvat': 7.0,
          'vser': 1.0,
          'vtype': 'V',
          'nvat': 30,
          'vat': 7.0,
          'wht': 1.0,
          'total': 50.0,
        },
      );

      expect(list, hasLength(1));
      final f = list.first;
      expect(f['docno'], 'INV-1');
      expect(f['expname'], 'ชำระเกินกำหนด');
      expect(f['expser'], 3);
      expect(f['no'], 2);
      expect(f['nvat'], 30);
      expect(f['total'], 50.0);
    });

    test('returns empty when ok is false', () {
      expect(
        PaymentIntentPayload.buildListFee(
          docno: 'INV-1',
          fine: {'ok': false, 'total': 50.0},
        ),
        isEmpty,
      );
    });

    test('returns empty when total is zero or negative', () {
      expect(
        PaymentIntentPayload.buildListFee(
          docno: 'INV-1',
          fine: {'ok': true, 'total': 0.0},
        ),
        isEmpty,
      );
    });

    test('defaults expname when missing', () {
      final list = PaymentIntentPayload.buildListFee(
        docno: 'INV-1',
        fine: {'ok': true, 'total': 10.0},
      );
      expect(list.first['expname'], 'ชำระเกินกำหนด');
    });
  });

  group('buildCustomerData', () {
    test('groups trans by refno and keeps the first row per group', () {
      final data = PaymentIntentPayload.buildCustomerData(
        trans: [
          _hist(refno: 'R1', docno: 'INV-1', custno: 'C1', cid: 'CID1'),
          _hist(refno: 'R1', docno: 'INV-1', custno: 'C1', cid: 'CID1'),
          _hist(refno: 'R2', docno: 'INV-2', custno: 'C2', cid: 'CID2'),
        ],
      );

      expect(data, hasLength(2));
      expect(data[0]['invoices'], 'INV-1');
      expect(data[0]['customer_no'], 'C1');
      expect(data[1]['invoices'], 'INV-2');
      expect(data[1]['customer_no'], 'C2');
    });

    test('skips rows without refno', () {
      final data = PaymentIntentPayload.buildCustomerData(
        trans: [
          _hist(refno: '', docno: 'INV-1'),
          _hist(refno: null, docno: 'INV-2'),
          _hist(refno: 'R3', docno: 'INV-3'),
        ],
      );
      expect(data, hasLength(1));
      expect(data.first['invoices'], 'INV-3');
    });

    test('includes all identity fields as strings', () {
      final data = PaymentIntentPayload.buildCustomerData(
        trans: [
          _hist(
            refno: 'R1',
            docno: 'INV-1',
            sname: 'S',
            cname: 'C',
            zn: 'Z1',
            zser: 'ZS',
            aser: 'AS',
            ln: 'LN1',
          ),
        ],
      );
      final d = data.first;
      expect(d['sname'], 'S');
      expect(d['cname'], 'C');
      expect(d['zn'], 'Z1');
      expect(d['zser'], 'ZS');
      expect(d['aser'], 'AS');
      expect(d['ln'], 'LN1');
      expect(d['lncode'], '');
    });

    test('missing identity fields become empty strings', () {
      final data = PaymentIntentPayload.buildCustomerData(
        trans: [_hist(refno: 'R1', docno: 'INV-1')],
      );
      expect(data.first['sname'], '');
      expect(data.first['zn'], '');
    });
  });

  group('buildInvoiceEntry', () {
    test('amount is (amt + vat) - wht and total is amtall', () {
      final entry = PaymentIntentPayload.buildInvoiceEntry(
        inv: _inv(
          docno: 'INV-1',
          amt: '1000.00',
          vat: '70.00',
          wht: '30.00',
          amtall: '1100.00',
          dis: '50.00',
        ),
        history: [_hist(refno: 'R1')],
        fine: const {'ok': false},
        invoiceFine: 0,
        payser: 7,
      );

      expect(entry['invoice_id'], 0);
      expect(entry['bill_reference'], 'INV-1');
      // 1000 + 70 - 30 = 1040
      expect(entry['amount'], 1040.0);
      expect(entry['total'], 1100.0);
      expect(entry['discount_amount'], 50.0);
      expect(entry['late_fee'], 0.0);
      expect(entry['deposit_amount'], 0);
      expect(entry['insurance_amount'], 0);
      expect(entry['withholding_amount'], 0);
    });

    test('late_fee carries the per-invoice fine', () {
      final entry = PaymentIntentPayload.buildInvoiceEntry(
        inv:
            _inv(docno: 'INV-1', amt: '100', vat: '0', wht: '0', amtall: '100'),
        history: const [],
        fine: const {'ok': false},
        invoiceFine: 25.5,
        payser: 1,
      );
      expect(entry['late_fee'], 25.5);
    });

    test('uses total_bill and adds fine to invoice total', () {
      final entry = PaymentIntentPayload.buildInvoiceEntry(
        inv: _inv(
          docno: 'INV-220',
          amt: '205.6075',
          vat: '14.3925',
          wht: '0',
          amtall: '205.6075',
          totalBill: '220.00',
        ),
        history: const [],
        fine: const {'ok': true, 'total': 250.0},
        invoiceFine: 250.0,
        payser: 40,
      );

      // ผู้ใช้ต้องชำระ 220 + 250 = 470 ไม่ใช่ 205.61 หรือ 234.39
      expect(entry['amount'], 220.0);
      expect(entry['late_fee'], 250.0);
      expect(entry['total'], 470.0);
    });

    test('metadata and list_fee are populated from arguments', () {
      final entry = PaymentIntentPayload.buildInvoiceEntry(
        inv: _inv(docno: 'INV-1', amt: '100', amtall: '100'),
        history: [_hist(refno: 'R1', descr: 'rent')],
        fine: const {'ok': true, 'total': 30.0, 'expname': 'fine'},
        invoiceFine: 30.0,
        payser: 5,
      );

      expect(entry['metadata'], hasLength(1));
      expect((entry['metadata'] as List).first['expname'], 'rent');
      expect(entry['list_fee'], hasLength(1));
      expect((entry['list_fee'] as List).first['total'], 30.0);
    });
  });

  group('requestedTotal formula', () {
    test('matches legacy accumulation', () {
      final total = PaymentIntentPayload.requestedTotal(
        sumPvat: 1000,
        sumTranFine: 20,
        sumAmtIn: 500,
        sumTranFineIn: 10,
        sumDiscount: 100,
        sumDisIn: 50,
        fineTotal: 30,
        disSumPakan: 0,
      );
      // 1000 + 20 - 0 - (100+50) + (500+10) + 30 = 1410
      expect(total, 1410.0);
    });

    test('subtracts disSumPakan', () {
      final total = PaymentIntentPayload.requestedTotal(
        sumPvat: 1000,
        sumTranFine: 0,
        sumAmtIn: 0,
        sumTranFineIn: 0,
        sumDiscount: 0,
        sumDisIn: 0,
        fineTotal: 0,
        disSumPakan: 200,
      );
      expect(total, 800.0);
    });

    test('rounds to two decimals to avoid float noise', () {
      final total = PaymentIntentPayload.requestedTotal(
        sumPvat: 0.1,
        sumTranFine: 0.2,
        sumAmtIn: 0,
        sumTranFineIn: 0,
        sumDiscount: 0,
        sumDisIn: 0,
        fineTotal: 0,
        disSumPakan: 0,
      );
      expect(total, 0.3);
    });

    test('legacySumDisIn is always zero', () {
      expect(PaymentIntentPayload.legacySumDisIn, 0.0);
    });
  });

  group('legacyLastDiscount', () {
    test('returns the last row discount, not the sum', () {
      // ต้นแบบใช้ assignment จึงได้ค่าของแถวสุดท้าย (=100) ไม่ใช่ 50+100
      final v = PaymentIntentPayload.legacyLastDiscount([
        _hist(refno: 'R1', disendbill: '50'),
        _hist(refno: 'R2', disendbill: '100'),
      ]);
      expect(v, 100.0);
    });

    test('empty history yields zero', () {
      expect(PaymentIntentPayload.legacyLastDiscount([]), 0.0);
    });

    test('null discount on last row yields zero', () {
      final v = PaymentIntentPayload.legacyLastDiscount([
        _hist(refno: 'R1', disendbill: '50'),
        _hist(refno: 'R2'),
      ]);
      expect(v, 0.0);
    });
  });

  group('sumInvoiceFine and fineForDocno', () {
    test('sums fine across invoice pay models', () {
      final models = [
        InvoicePayModel.fromJson({'docno': 'A', 'fine': '10.50'}),
        InvoicePayModel.fromJson({'docno': 'B', 'fine': '20.25'}),
      ];
      expect(PaymentIntentPayload.sumInvoiceFine(models), 30.75);
    });

    test('empty list sums to zero', () {
      expect(PaymentIntentPayload.sumInvoiceFine([]), 0.0);
    });

    test('fineForDocno finds the matching docno', () {
      final models = [
        InvoicePayModel.fromJson({'docno': 'A', 'fine': '10.50'}),
        InvoicePayModel.fromJson({'docno': 'B', 'fine': '20.25'}),
      ];
      expect(PaymentIntentPayload.fineForDocno(models, 'B'), 20.25);
      expect(PaymentIntentPayload.fineForDocno(models, 'ZZ'), 0.0);
    });
  });

  group('parseFineInvResponse', () {
    test('parses name,amount format', () {
      expect(
        PaymentSubV4Service.parseFineInvResponse('ชำระเกินกำหนด,150.00'),
        150.0,
      );
    });

    test('handles multiple commas by taking the last segment', () {
      // ต้นแบบใช้ indexOf(',') ตัวแรก แล้ว parse ส่วนที่เหลือทั้งหมด
      expect(
        PaymentSubV4Service.parseFineInvResponse('ค่าเช่า,ค่าปรับ,250'),
        0.0,
      );
    });

    test('returns zero for empty, null or false bodies', () {
      expect(PaymentSubV4Service.parseFineInvResponse(''), 0.0);
      expect(PaymentSubV4Service.parseFineInvResponse('null'), 0.0);
      expect(PaymentSubV4Service.parseFineInvResponse('false'), 0.0);
    });

    test('returns zero when amount part is empty', () {
      expect(PaymentSubV4Service.parseFineInvResponse('ชำระเกินกำหนด,'), 0.0);
    });

    test('returns zero when there is no comma', () {
      expect(PaymentSubV4Service.parseFineInvResponse('ชำระเกินกำหนด'), 0.0);
    });

    test('returns zero for non numeric amount', () {
      expect(PaymentSubV4Service.parseFineInvResponse('name,abc'), 0.0);
    });
  });
}
