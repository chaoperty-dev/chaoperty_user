import 'dart:convert';

class PaymentIntentsResponse {
  final String? message;
  final List<PaymentIntent> data;
  final Meta? meta;

  PaymentIntentsResponse({
    this.message,
    required this.data,
    this.meta,
  });

  factory PaymentIntentsResponse.fromJson(Map<String, dynamic> json) {
    return PaymentIntentsResponse(
      message: json['message'] as String?,
      data: (json['data'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map((e) => PaymentIntent.fromJson(e))
          .toList(),
      meta: json['meta'] is Map<String, dynamic>
          ? Meta.fromJson(json['meta'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'message': message,
        'data': data.map((e) => e.toJson()).toList(),
        if (meta != null) 'meta': meta!.toJson(),
      };

  static PaymentIntentsResponse parse(String body) =>
      PaymentIntentsResponse.fromJson(jsonDecode(body) as Map<String, dynamic>);
}

class PaymentIntent {
  final Connected? connected;
  final String? intentUuid;
  final String? paymentIntentNo;
  final int? customerId;
  final int? bankmerchantid;
  final String? customerNo;
  final String? propertyNo; // Added
  final String? channel;
  final double? requestedAmount;
  final double? amount; // Added
  final double? total; // Added
  final String? currency;
  final String? status;
  final String? systemStatus;
  final String? ref1; // Added
  final String? ref2; // Added
  final String? ref3; // Added
  final StatusExtended? statusExtended;
  final DateTime? softExpireAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Invoice> invoices;
  final dynamic latestSlip;
  final List<dynamic> payments;

  PaymentIntent({
    this.connected,
    this.intentUuid,
    this.paymentIntentNo,
    this.customerId,
    this.bankmerchantid,
    this.customerNo,
    this.propertyNo, // Added
    this.channel,
    this.requestedAmount,
    this.amount, // Added
    this.total, // Added
    this.currency,
    this.status,
    this.systemStatus,
    this.ref1, // Added
    this.ref2, // Added
    this.ref3, // Added
    this.statusExtended,
    this.softExpireAt,
    this.createdAt,
    this.updatedAt,
    this.invoices = const [],
    this.latestSlip,
    this.payments = const [],
  });

  factory PaymentIntent.fromJson(Map<String, dynamic> json) {
    return PaymentIntent(
      connected: json['connected'] is Map<String, dynamic>
          ? Connected.fromJson(json['connected'])
          : null,
      intentUuid: (json['intent_uuid'] ?? json['uuid']) as String?,
      paymentIntentNo: (json['payment_intent_no'] ?? '').toString(),
      customerId: _toInt(json['customer_id']),
      bankmerchantid: _toInt(json['bank_merchant_id']),
      customerNo: json['customer_no'] as String?,
      propertyNo: json['property_no'] as String?, // Added
      channel: json['channel'] as String?,
      requestedAmount: _toDouble(json['requested_amount'] ?? json['amount']),
      amount: _toDouble(json['amount']), // Added
      total: _toDouble(json['total']), // Added
      currency: json['currency'] as String?,
      status: json['status'] as String?,
      systemStatus: json['system_status'] as String?,
      ref1: json['ref1'] as String?, // Added
      ref2: json['ref2'] as String?, // Added
      ref3: json['ref3'] as String?, // Added
      statusExtended: json['status_extended'] is Map<String, dynamic>
          ? StatusExtended.fromJson(json['status_extended'])
          : null,
      softExpireAt: _toDate(json['soft_expire_at']),
      createdAt: _toDate(json['created_at']),
      updatedAt: _toDate(json['updated_at']),
      invoices: (json['invoices'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map((e) => Invoice.fromJson(e))
          .toList(),
      latestSlip: json['latest_slip'],
      payments: (json['payments'] as List? ?? const []),
    );
  }

  Map<String, dynamic> toJson() => {
        if (connected != null) 'connected': connected!.toJson(),
        'intent_uuid': intentUuid,
        'payment_intent_no': paymentIntentNo,
        'customer_id': customerId,
        'bank_merchant_id': bankmerchantid,
        'customer_no': customerNo,
        'property_no': propertyNo, // Added
        'channel': channel,
        // ส่งเป็น string 2 ตำแหน่ง เพื่อให้สอดคล้อง API response
        'requested_amount': _money2(requestedAmount),
        'amount': _money2(amount), // Added
        'total': _money2(total), // Added
        'currency': currency,
        'status': status,
        'system_status': systemStatus,
        'ref1': ref1, // Added
        'ref2': ref2, // Added
        'ref3': ref3, // Added
        if (statusExtended != null) 'status_extended': statusExtended!.toJson(),
        'soft_expire_at': softExpireAt?.toIso8601String(),
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'invoices': invoices.map((e) => e.toJson()).toList(),
        'latest_slip': latestSlip,
        'payments': payments,
      };
}

class Connected {
  final int? id;
  final String? code;
  final String? name;

  Connected({this.id, this.code, this.name});

  factory Connected.fromJson(Map<String, dynamic> json) => Connected(
        id: _toInt(json['id']),
        code: json['code'] as String?,
        name: json['name'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
      };
}

class StatusExtended {
  final String? statusVerbose;
  final String? statusThai;
  final bool? isActive;
  final bool? isExpired;

  StatusExtended(
      {this.statusVerbose, this.statusThai, this.isActive, this.isExpired});

  factory StatusExtended.fromJson(Map<String, dynamic> json) => StatusExtended(
        statusVerbose: json['status_verbose'] as String?,
        statusThai: json['status_thai'] as String?,
        isActive: json['is_active'] as bool?,
        isExpired: json['is_expired'] as bool?,
      );

  Map<String, dynamic> toJson() => {
        'status_verbose': statusVerbose,
        'status_thai': statusThai,
        'is_active': isActive,
        'is_expired': isExpired,
      };
}

class Invoice {
  final int? invoiceId;
  final String? billReference;
  final double? originalAmount;
  final double? amount; // Added
  final double? lateFee;
  final double? total; // Added
  final double? discountAmount;
  final List<Metadata> metadata;
  final double? desiredAmount;
  final int? orderIndex;

  Invoice({
    this.invoiceId,
    this.billReference,
    this.originalAmount,
    this.amount, // Added
    this.lateFee,
    this.discountAmount,
    this.total, // Added
    this.metadata = const [],
    this.desiredAmount,
    this.orderIndex,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
        invoiceId: _toInt(json['invoice_id']),
        billReference: json['bill_reference'] as String?,
        originalAmount: _toDouble(json['original_amount']),
        amount: _toDouble(json['amount']), // Added
        lateFee: _toDouble(json['late_fee']),
        discountAmount: _toDouble(json['discount_amount']),
        total: _toDouble(json['total']), // Added
        metadata: (json['metadata'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map((e) => Metadata.fromJson(e))
            .toList(),
        desiredAmount: _toDouble(json['desired_amount']),
        orderIndex: _toInt(json['order_index']),
      );

  Map<String, dynamic> toJson() => {
        'invoice_id': invoiceId,
        'bill_reference': billReference,
        'original_amount': _money2(originalAmount),
        'amount': _money2(amount), // Added
        'late_fee': _money2(lateFee),
        'discount_amount': _money2(discountAmount),
        'total': _money2(total), // Added
        'metadata': metadata.map((e) => e.toJson()).toList(),
        'desired_amount': _money2(desiredAmount),
        'order_index': orderIndex,
      };
}

class Metadata {
  final String? docno;
  final String? date; // ถ้าต้อง DateTime ให้เปลี่ยน type แล้วใช้ _toDate
  final String? cid;
  final String? custno;
  final String? st;
  final String? status; // sample เป็น "1" (string)
  final int? payser;
  final int? docnoAll;
  final int? pvatBill;
  final double? vatBill;
  final int? whtBill;
  final int? totalBill;

  Metadata({
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
  });

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
        docno: json['docno'] as String?,
        date: json['date'] as String?,
        cid: json['cid'] as String?,
        custno: json['custno'] as String?,
        st: json['st'] as String?,
        status: json['status']?.toString(),
        payser: _toInt(json['payser']),
        docnoAll: _toInt(json['docno_all']),
        pvatBill: _toInt(json['pvat_bill']),
        vatBill: _toDouble(json['vat_bill']),
        whtBill: _toInt(json['wht_bill']),
        totalBill: _toInt(json['total_bill']),
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
      };
}

class Meta {
  final int? currentPage;
  final int? perPage;
  final int? total;
  final int? lastPage;

  Meta({this.currentPage, this.perPage, this.total, this.lastPage});

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        currentPage: _toInt(json['current_page']),
        perPage: _toInt(json['per_page']),
        total: _toInt(json['total']),
        lastPage: _toInt(json['last_page']),
      );

  Map<String, dynamic> toJson() => {
        'current_page': currentPage,
        'per_page': perPage,
        'total': total,
        'last_page': lastPage,
      };
}

/// ---------- helpers ----------
int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

DateTime? _toDate(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is String) {
    try {
      return DateTime.parse(v);
    } catch (_) {
      return null;
    }
  }
  return null;
}

/// ส่งเงินเป็น string 2 ตำแหน่ง (หรือ null ถ้าไม่มีค่า)
String? _money2(double? v) => (v == null) ? null : v.toStringAsFixed(2);
