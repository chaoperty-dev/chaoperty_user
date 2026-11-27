import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Constant/Myconstant.dart';
import '../Model/GetInvoice_Model.dart';
import '../Model/GetTeNant_Model.dart';
import '../screen_Intents/bankCodeMap.dart';
import 'model/contractInvoice.dart';
import 'pay_bill_screen_Choice.dart';

class PaybillMainScreenChoiceNew extends StatefulWidget {
  const PaybillMainScreenChoiceNew({
    super.key,
    this.mainScreenAnimationController,
    this.mainScreenAnimation,
    this.teNantModel,
    this.cuslang,
    this.onContinueToPayment,
  });

  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;
  final List<TeNantModel>? teNantModel;
  final String? cuslang;
  final Future<void> Function(List<InvoiceModel> invoices, String invoiceAll)?
      onContinueToPayment;

  @override
  State<PaybillMainScreenChoiceNew> createState() =>
      _PaybillMainScreenChoiceNewState();
}

class _PaybillMainScreenChoiceNewState extends State<PaybillMainScreenChoiceNew>
    with SingleTickerProviderStateMixin {
  static final _money = NumberFormat('#,##0.00', 'en_US');
  static final _date = DateFormat('dd-MM-yyyy');

  List<_PaymentAccountGroup> _groups = const <_PaymentAccountGroup>[];
  Map<String, _BillPaymentStatus> _paymentStatuses =
      const <String, _BillPaymentStatus>{};
  Map<String, _ExistingQrPayment> _existingQrPayments =
      const <String, _ExistingQrPayment>{};
  final Set<String> _pendingPaymentDocNos = <String>{};
  late final AnimationController _fallbackAnimationController;
  Timer? _expiryTicker;
  bool _isLoading = true;
  bool _isPaymentAmountSummaryExpanded = false;
  String? _error;

  bool get _isEnglish => widget.cuslang == 'EN';

  @override
  void initState() {
    super.initState();
    _fallbackAnimationController = AnimationController(vsync: this, value: 1);
    _expiryTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    _loadGroups();
  }

  @override
  void dispose() {
    _expiryTicker?.cancel();
    _fallbackAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadGroups() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final preferences = await SharedPreferences.getInstance();
      final customerNumber = preferences.getString('custno');
      final rentalId = preferences.getString('renTalSer');
      if (customerNumber == null || customerNumber.isEmpty) {
        throw StateError('Missing customer number');
      }
      final pendingStatusKey =
          _pendingPaymentStatusKey(rentalId ?? '0', customerNumber);
      _pendingPaymentDocNos.addAll(
          preferences.getStringList(pendingStatusKey) ?? const <String>[]);
      final selectedCids = widget.teNantModel
              ?.map((tenant) => tenant.cid?.trim() ?? '')
              .where((cid) => cid.isNotEmpty)
              .toSet() ??
          <String>{};
      final response = await http.get(Uri.parse(
        '${MyConstant().domain}/GC_billGropInv_UserPaytypeV2.php'
        '?isAdd=true&ren=$rentalId&custno_inv=$customerNumber',
      ));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw StateError('Request failed: ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);
      final contracts = decoded is Map<String, dynamic>
          ? <ContractInvoice>[ContractInvoice.fromJson(decoded)]
          : decoded is List
              ? decoded
                  .whereType<Map<String, dynamic>>()
                  .map(ContractInvoice.fromJson)
                  .toList()
              : const <ContractInvoice>[];
      final groups = _toGroups(contracts, selectedCids);
      final paymentStatusResult = await _loadPaymentStatuses(
        rentalId: rentalId ?? '0',
        customerNumber: customerNumber,
        docNos: groups
            .expand((group) => group.bills)
            .map((bill) => bill.docNo)
            .toList(growable: false),
      );

      if (!mounted) return;
      setState(() {
        final mergedStatuses = <String, _BillPaymentStatus>{
          ...paymentStatusResult.statuses,
        };
        for (final docNo in _pendingPaymentDocNos) {
          mergedStatuses.putIfAbsent(
              docNo, () => _BillPaymentStatus.waitingPayment);
        }
        _pendingPaymentDocNos
            .removeWhere(paymentStatusResult.statuses.containsKey);
        preferences.setStringList(
            pendingStatusKey, _pendingPaymentDocNos.toList(growable: false));
        _groups = groups;
        _paymentStatuses = mergedStatuses;
        _existingQrPayments = paymentStatusResult.existingQrPayments;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = error.toString();
      });
    }
  }

  Future<_PaymentStatusResult> _loadPaymentStatuses({
    required String rentalId,
    required String customerNumber,
    required List<String> docNos,
  }) async {
    if (docNos.isEmpty) return const _PaymentStatusResult.empty();

    try {
      final response = await http.post(
        Uri.parse('${MyConstant().domain_chaoV2}/check_genqr_new.php'),
        headers: const <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'isAdd': true,
          'ren': rentalId,
          'invoice': docNos.map((docNo) => "'$docNo'").join(','),
          'custno': customerNumber,
        }),
      );
      if (response.statusCode != 200 || response.body.isEmpty) {
        return const _PaymentStatusResult.empty();
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic> || decoded['data'] is! Map) {
        return const _PaymentStatusResult.empty();
      }

      final statuses = <String, _BillPaymentStatus>{};
      final existingQrPayments = <String, _ExistingQrPayment>{};
      final groups = decoded['data'] as Map;
      for (final entries in groups.values) {
        if (entries is! List) continue;
        for (final entry in entries) {
          if (entry is! Map) continue;
          final paymentEntry = Map<dynamic, dynamic>.from(entry);
          final entryDocNos = _paymentEntryDocNos(paymentEntry);
          if (entryDocNos.isEmpty) continue;
          final status = _hasSlip(paymentEntry['img'])
              ? _BillPaymentStatus.waitingReview
              : _BillPaymentStatus.waitingPayment;
          final existingQrPayment =
              _ExistingQrPayment.fromApi(paymentEntry, entryDocNos);
          for (final docNo in entryDocNos) {
            statuses[docNo] = status;
            if (existingQrPayment.referenceId.isNotEmpty) {
              existingQrPayments[docNo] = existingQrPayment;
            }
          }
        }
      }
      return _PaymentStatusResult(statuses, existingQrPayments);
    } catch (_) {
      return const _PaymentStatusResult.empty();
    }
  }

  List<String> _paymentEntryDocNos(Map<dynamic, dynamic> entry) {
    final docNos = <String>{};

    void addDocNos(dynamic value) {
      if (value is List) {
        for (final item in value) {
          addDocNos(item);
        }
        return;
      }
      final raw = value?.toString().trim() ?? '';
      if (raw.isEmpty || raw == 'null') return;
      for (final item
          in raw.replaceAll('[', '').replaceAll(']', '').split(',')) {
        final docNo = item.replaceAll("'", '').replaceAll('"', '').trim();
        if (docNo.isNotEmpty && docNo != 'null') {
          docNos.add(docNo);
        }
      }
    }

    addDocNos(entry['invoice']);
    addDocNos(entry['invoices']);
    return docNos.toList(growable: false);
  }

  bool _hasSlip(dynamic imageData) {
    if (imageData is List) {
      return imageData.any((image) {
        final value = image?.toString().trim() ?? '';
        return value.isNotEmpty && value != 'null';
      });
    }
    final value = imageData?.toString().trim() ?? '';
    return value.isNotEmpty && value != '[]' && value != 'null';
  }

  _BillPaymentStatus _statusFor(_PaymentBill bill) =>
      _paymentStatuses[bill.docNo] ?? _BillPaymentStatus.outstanding;

  String _pendingPaymentStatusKey(String rentalId, String customerNumber) =>
      'pending_payment_docnos_${rentalId}_$customerNumber';

  Future<void> _markPaymentCreated(List<String> docNos) async {
    final createdDocNos = docNos
        .map((docNo) => docNo.trim())
        .where((docNo) => docNo.isNotEmpty)
        .toSet();
    if (createdDocNos.isEmpty || !mounted) return;

    setState(() {
      _pendingPaymentDocNos.addAll(createdDocNos);
      _paymentStatuses = <String, _BillPaymentStatus>{
        ..._paymentStatuses,
        for (final docNo in createdDocNos)
          docNo: _BillPaymentStatus.waitingPayment,
      };
    });
    final preferences = await SharedPreferences.getInstance();
    final rentalId = preferences.getString('renTalSer') ?? '0';
    final customerNumber = preferences.getString('custno') ?? '';
    if (customerNumber.isNotEmpty) {
      await preferences.setStringList(
        _pendingPaymentStatusKey(rentalId, customerNumber),
        _pendingPaymentDocNos.toList(growable: false),
      );
    }
    await _loadGroups();
  }

  String _statusLabel(_BillPaymentStatus status) {
    switch (status) {
      case _BillPaymentStatus.outstanding:
        return _isEnglish ? 'Outstanding' : 'ค้างชำระ';
      case _BillPaymentStatus.waitingPayment:
        return _isEnglish ? 'Waiting payment' : 'รอชำระ';
      case _BillPaymentStatus.waitingReview:
        return _isEnglish ? 'Waiting review' : 'รอตรวจสอบ';
    }
  }

  Color _statusColor(_BillPaymentStatus status) {
    switch (status) {
      case _BillPaymentStatus.outstanding:
        return const Color(0xFFB45309);
      case _BillPaymentStatus.waitingPayment:
        return const Color(0xFF4059B7);
      case _BillPaymentStatus.waitingReview:
        return const Color(0xFF4059B7);
    }
  }

  Color _statusBackground(_BillPaymentStatus status) {
    switch (status) {
      case _BillPaymentStatus.outstanding:
        return const Color(0xFFFFF7E6);
      case _BillPaymentStatus.waitingPayment:
        return const Color(0xFFF0F3FF);
      case _BillPaymentStatus.waitingReview:
        return const Color(0xFFF0F3FF);
    }
  }

  Widget _buildBankLogo(String bankName, {double size = 38}) {
    final normalizedBankName = bankName.trim();
    Map<String, String>? bankInfo = bankCodeMap[normalizedBankName];
    if (bankInfo == null && normalizedBankName.isNotEmpty) {
      for (final entry in bankCodeMap.entries) {
        if (entry.key.contains(normalizedBankName) ||
            normalizedBankName.contains(entry.key)) {
          bankInfo = entry.value;
          break;
        }
      }
    }
    final logo = bankInfo?['logo'];
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFE9EDFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: logo == null || logo.isEmpty
          ? const Icon(
              Icons.account_balance_outlined,
              color: Color(0xFF3049AA),
            )
          : Image.asset(
              'assets/images/LogoBank/$logo',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.account_balance_outlined,
                color: Color(0xFF3049AA),
              ),
            ),
    );
  }

  bool _isQrExpired(_ExistingQrPayment? payment) {
    final expiresAt = payment?.expiresAt;
    return expiresAt != null && !expiresAt.isAfter(DateTime.now());
  }

  String _shortQrDateTime(DateTime value) {
    final time =
        '${value.hour.toString().padLeft(2, '0')}.${value.minute.toString().padLeft(2, '0')}';
    if (_isEnglish) {
      return '${DateFormat('d MMM', 'en_US').format(value)} $time';
    }
    const months = <String>[
      'ม.ค.',
      'ก.พ.',
      'มี.ค.',
      'เม.ย.',
      'พ.ค.',
      'มิ.ย.',
      'ก.ค.',
      'ส.ค.',
      'ก.ย.',
      'ต.ค.',
      'พ.ย.',
      'ธ.ค.',
    ];
    return '${value.day} ${months[value.month - 1]} $time';
  }

  String _formatDisplayDate(DateTime value) {
    if (_isEnglish) {
      return _date.format(value);
    }
    return '${DateFormat('dd-MM').format(value)}-${value.year + 543}';
  }

  String _qrCreatedLabel(_ExistingQrPayment payment) {
    final createdAt = payment.createdAt;
    if (createdAt == null) return '';
    return _isEnglish
        ? 'Created ${_shortQrDateTime(createdAt)}'
        : 'สร้าง ${_shortQrDateTime(createdAt)}';
  }

  String _qrExpiryLabel(_ExistingQrPayment payment) {
    final expiresAt = payment.expiresAt;
    if (expiresAt == null) return '';
    final remaining = expiresAt.difference(DateTime.now());
    if (remaining.inSeconds <= 0) {
      return _isEnglish
          ? 'QR expired ${_shortQrDateTime(expiresAt)}'
          : 'QR หมดอายุ ${_shortQrDateTime(expiresAt)}';
    }
    final hours = remaining.inHours.toString().padLeft(2, '0');
    final minutes = (remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');
    return _isEnglish
        ? 'Expires ${_shortQrDateTime(expiresAt)} · $hours:$minutes:$seconds left'
        : 'หมดอายุ ${_shortQrDateTime(expiresAt)} · เหลือ $hours:$minutes:$seconds';
  }

  List<_PaymentAccountGroup> _toGroups(
    List<ContractInvoice> contracts,
    Set<String> selectedCids,
  ) {
    final groups = LinkedHashMap<String, _PaymentAccountGroup>();
    for (final contract in contracts) {
      for (final data in contract.data ?? const <Data>[]) {
        final key = '${data.bank ?? ''}|${data.bno ?? ''}|${data.payser ?? ''}';
        final group = groups.putIfAbsent(
          key,
          () => _PaymentAccountGroup(
            key: key,
            bank: data.bank?.trim() ?? '',
            accountNo: data.bno?.trim() ?? '',
            accountName: data.bname?.trim() ?? '',
            paymentName: data.ptname?.trim() ?? '',
            payser: data.payser?.toString(),
            ptser: data.ptser?.toString(),
          ),
        );
        for (final bill in data.bill ?? const <Bill>[]) {
          final docNo = bill.docno?.trim() ?? '';
          final cid = bill.cid?.trim() ?? '';
          if (docNo.isEmpty ||
              (selectedCids.isNotEmpty && !selectedCids.contains(cid))) {
            continue;
          }
          group.bills.add(_PaymentBill.fromApi(bill, data));
        }
      }
    }
    final output =
        groups.values.where((group) => group.bills.isNotEmpty).toList();
    for (final group in output) {
      group.bills.sort((a, b) {
        final dateOrder = a.date.compareTo(b.date);
        return dateOrder == 0 ? a.docNo.compareTo(b.docNo) : dateOrder;
      });
    }
    output.sort((a, b) => a.label.compareTo(b.label));
    return output;
  }

  Future<void> _startPayment(_PaymentAccountGroup group) async {
    final payableBills = group.bills
        .where((bill) => _statusFor(bill) == _BillPaymentStatus.outstanding)
        .toList(growable: false);
    if (payableBills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEnglish
            ? 'No bills available for payment in this account.'
            : 'บัญชีนี้ไม่มีบิลที่เลือกดำเนินการได้'),
      ));
      return;
    }
    final selectedDocNos = payableBills
        .where((bill) => _statusFor(bill) == _BillPaymentStatus.outstanding)
        .map((bill) => bill.docNo)
        .toSet();
    final selectedBills = await showDialog<List<_PaymentBill>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final selectedBills = group.bills
              .where((bill) => selectedDocNos.contains(bill.docNo))
              .toList(growable: false);
          final subtotal =
              selectedBills.fold<double>(0, (sum, bill) => sum + bill.total);
          final fine =
              selectedBills.fold<double>(0, (sum, bill) => sum + bill.fine);
          final total = subtotal + fine;
          final popupBills = _popupBillsFor(group);
          final hasOutstandingSelection = selectedBills.isNotEmpty;
          final dialogHeight = (MediaQuery.sizeOf(context).height * 0.76)
              .clamp(410.0, 650.0)
              .toDouble();

          void updateSelection(_PaymentBill bill, bool selected) {
            setDialogState(() {
              if (selected) {
                selectedDocNos.add(bill.docNo);
              } else {
                selectedDocNos.remove(bill.docNo);
              }
            });
          }

          return Dialog(
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            clipBehavior: Clip.antiAlias,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: SizedBox(
              width: 520,
              height: dialogHeight,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 18, 12, 16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF7F8FF),
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFE4E7F5)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6EAFF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.receipt_long_outlined,
                            color: Color(0xFF344DAD),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isEnglish ? 'Select bills' : 'เลือกรายการชำระ',
                                style: const TextStyle(
                                  fontFamily: 'LINESeed2',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: Color(0xFF17262A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                group.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'LINESeed2',
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          tooltip: _isEnglish ? 'Close' : 'ปิด',
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isEnglish ? 'Amount due' : 'ยอดที่ต้องชำระ',
                                  style: const TextStyle(
                                    fontFamily: 'LINESeed2',
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF3349A5),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _isEnglish
                                      ? '${selectedBills.length} bill(s)'
                                      : 'รวม ${selectedBills.length} รายการ',
                                  style: const TextStyle(
                                    fontFamily: 'LINESeed2',
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${_money.format(total)} ${_isEnglish ? 'THB' : 'บาท'}',
                            style: const TextStyle(
                              fontFamily: 'LINESeed2',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF3349A5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _isEnglish ? 'Bills to be paid' : 'รายการที่ต้องชำระ',
                        style: const TextStyle(
                          fontFamily: 'LINESeed2',
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: Color(0xFF3349A5),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      itemCount: popupBills.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final bill = popupBills[index];
                        final status = _statusFor(bill);
                        final isPayable =
                            status == _BillPaymentStatus.outstanding;
                        final isSelected = selectedDocNos.contains(bill.docNo);
                        final totalWithFine = bill.total + bill.fine;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: isPayable
                                    ? () => updateSelection(bill, !isSelected)
                                    : null,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 160),
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 10, 12, 10),
                                  decoration: BoxDecoration(
                                    color: !isPayable
                                        ? const Color(0xFFF8FAFC)
                                        : isSelected
                                            ? const Color(0xFFF5F6FF)
                                            : Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: !isPayable
                                          ? const Color(0xFFE5EAF1)
                                          : isSelected
                                              ? const Color(0xFF6076D8)
                                              : const Color(0xFFE3E7EF),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      isPayable
                                          ? Checkbox(
                                              value: isSelected,
                                              activeColor:
                                                  const Color(0xFF4059B7),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              onChanged: (value) =>
                                                  updateSelection(
                                                      bill, value ?? false),
                                            )
                                          : const SizedBox(
                                              width: 40,
                                              child: Icon(
                                                Icons.qr_code_rounded,
                                                size: 18,
                                                color: Color(0xFF6076D8),
                                              ),
                                            ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              bill.docNo,
                                              style: const TextStyle(
                                                fontFamily: 'LINESeed2',
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFF17262A),
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              _formatDisplayDate(bill.date),
                                              style: const TextStyle(
                                                fontFamily: 'LINESeed2',
                                                fontSize: 12,
                                                color: Color(0xFF64748B),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            _StatusChip(
                                              label: _statusLabel(status),
                                              color: _statusColor(status),
                                              backgroundColor:
                                                  _statusBackground(status),
                                            ),
                                            /*
                                            if (bill.fine > 0) ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                _isEnglish
                                                    ? 'Fine ${_money.format(bill.fine)} THB'
                                                    : 'ค่าปรับ ${_money.format(bill.fine)} บาท',
                                                style: const TextStyle(
                                                  fontFamily: 'LINESeed2',
                                                  fontSize: 11,
                                                  color: Color(0xFFB45309),
                                                ),
                                              ),
                                            ],
                                            */
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            _money.format(totalWithFine),
                                            style: const TextStyle(
                                              fontFamily: 'LINESeed2',
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF3349A5),
                                            ),
                                          ),
                                          Text(
                                            _isEnglish ? 'Amount due' : 'ยอดที่ต้องชำระ',
                                            style: const TextStyle(
                                              fontFamily: 'LINESeed2',
                                              fontSize: 10,
                                              color: Color(0xFF94A3B8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Color(0xFFE4E7F0))),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Color(0xFFD5DBE8)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(_isEnglish ? 'Cancel' : 'ยกเลิก'),
                          ),
                        ),
                        if (hasOutstandingSelection) ...[
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, selectedBills),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4059B7),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                _isEnglish ? 'Continue' : 'ดำเนินการต่อ',
                                style: const TextStyle(
                                  fontFamily: 'LINESeed2',
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    if (selectedBills == null || selectedBills.isEmpty) return;
    await _continueToPayment(selectedBills);
  }

  List<_PaymentBill> _popupBillsFor(_PaymentAccountGroup group) {
    final bills = group.bills
        .where((bill) => _statusFor(bill) == _BillPaymentStatus.outstanding)
        .toList();
    bills.sort((first, second) {
      final dateOrder = first.date.compareTo(second.date);
      return dateOrder == 0 ? first.docNo.compareTo(second.docNo) : dateOrder;
    });
    return bills;
  }

  Future<void> _continueToPayment(List<_PaymentBill> bills) async {
    final waitingPaymentBills = bills
        .where((bill) => _statusFor(bill) == _BillPaymentStatus.waitingPayment)
        .toList(growable: false);
    if (waitingPaymentBills.isNotEmpty) {
      final existingQrPayment = _existingQrPaymentFor(waitingPaymentBills);
      if (waitingPaymentBills.length != bills.length ||
          existingQrPayment == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isEnglish
              ? 'Select bills from one existing QR payment only.'
              : 'บิลรอชำระต้องเลือกเฉพาะบิลที่อยู่ใน QR เดียวกัน'),
        ));
        return;
      }

      final resumeBills = _groups
          .expand((group) => group.bills)
          .where((bill) =>
              _existingQrPayments[bill.docNo]?.referenceId ==
              existingQrPayment.referenceId)
          .toList(growable: false);
      await _openPayment(
        resumeBills.isEmpty ? bills : resumeBills,
        existingQrPayment: existingQrPayment,
      );
      return;
    }

    await _openPayment(bills);
  }

  _ExistingQrPayment? _existingQrPaymentFor(List<_PaymentBill> bills) {
    final payments = bills
        .map((bill) => _existingQrPayments[bill.docNo])
        .whereType<_ExistingQrPayment>()
        .toList(growable: false);
    if (payments.length != bills.length || payments.isEmpty) return null;
    final referenceIds = payments
        .map((payment) => payment.referenceId)
        .where((referenceId) => referenceId.isNotEmpty)
        .toSet();
    return referenceIds.length == 1 ? payments.first : null;
  }

  Future<void> _openPayment(
    List<_PaymentBill> bills, {
    _ExistingQrPayment? existingQrPayment,
  }) async {
    final invoices =
        bills.map((bill) => bill.toInvoice()).toList(growable: false);
    final invoiceAll =
        invoices.map((invoice) => "'${invoice.docno}'").join(',');
    if (existingQrPayment == null && widget.onContinueToPayment != null) {
      await widget.onContinueToPayment!(invoices, invoiceAll);
      return;
    }
    final existingQrPayload = existingQrPayment == null
        ? null
        : _existingQrPayload(existingQrPayment, bills);
    if (existingQrPayment != null && existingQrPayload == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEnglish
            ? 'QR information is incomplete. Please reload and try again.'
            : 'ข้อมูล QR ไม่ครบ กรุณาโหลดหน้าใหม่แล้วลองอีกครั้ง'),
      ));
      return;
    }
    final isWaitingPayment = ValueNotifier<bool>(
      existingQrPayment != null && !_hasSlip(existingQrPayment.image),
    );
    try {
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: const Color(0xFFF2F3F8),
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 3,
            shadowColor: const Color(0x663A5160),
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              color: const Color(0xFF17262A),
            ),
            titleSpacing: 0,
            title: Row(
              children: [
                const CircleAvatar(
                  backgroundImage: AssetImage('assets/images/Icon-chao.png'),
                  radius: 16,
                  backgroundColor: Colors.transparent,
                ),
                const SizedBox(width: 10),
                Text(
                  _isEnglish ? 'Payment' : 'ชำระเงิน',
                  style: const TextStyle(
                    fontFamily: 'LINESeed2',
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: Color(0xFF17262A),
                  ),
                ),
              ],
            ),
            actions: [
              ValueListenableBuilder<bool>(
                valueListenable: isWaitingPayment,
                builder: (context, isWaiting, child) => isWaiting
                    ? const _SystemClosingCountdown()
                    : const SizedBox.shrink(),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: PayBillscreenChoice(
            mainScreenAnimationController:
                widget.mainScreenAnimationController ??
                    _fallbackAnimationController,
            mainScreenAnimation: widget.mainScreenAnimation ??
                const AlwaysStoppedAnimation<double>(1),
            teNantModel: widget.teNantModel,
            cuslang: widget.cuslang,
            ref_new: existingQrPayment == null ? '1' : '0',
            get_qr_img: existingQrPayload,
            get_refapi: existingQrPayment?.referenceId,
            get_img: existingQrPayment?.image,
            invoiceAll: existingQrPayment?.invoiceAll.isNotEmpty == true
                ? existingQrPayment!.invoiceAll
                : invoiceAll,
            invoicePayModels2: const <InvoiceModel>[],
            selectedInvoiceModels: invoices,
            invoiceFineAmounts: {
              for (final bill in bills) bill.docNo: bill.fine,
            },
            onPaymentRecordCreated: _markPaymentCreated,
            onWaitingPaymentStarted: () => isWaitingPayment.value = true,
          ),
        ),
      ));
    } finally {
      isWaitingPayment.dispose();
    }
    if (mounted) _loadGroups();
  }

  String? _existingQrPayload(
    _ExistingQrPayment payment,
    List<_PaymentBill> bills,
  ) {
    final cid = payment.cid.isNotEmpty ? payment.cid : bills.first.cid ?? '';
    if (cid.isEmpty || payment.referenceId.isEmpty) return null;
    final amount = payment.amount > 0
        ? payment.amount
        : bills.fold<double>(0, (sum, bill) => sum + bill.total + bill.fine);
    return 'ref_id=${Uri.encodeQueryComponent(payment.referenceId)}'
        '&incid=${Uri.encodeQueryComponent(cid)}'
        '&sum=${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF2F3F8),
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildContent()),
          ],
        ),
      );

  Widget _buildHeader(BuildContext context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF),
          boxShadow: [
            BoxShadow(
              color: Color(0x663A5160),
              offset: Offset(1.1, 1.1),
              blurRadius: 10,
            ),
          ],
        ),
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: MediaQuery.of(context).padding.top,
        ),
        alignment: Alignment.centerLeft,
        child: SizedBox(
          height: kToolbarHeight,
          child: Row(
            children: [
              const CircleAvatar(
                backgroundImage: AssetImage('assets/images/Icon-chao.png'),
                radius: 16,
                backgroundColor: Colors.transparent,
              ),
              const SizedBox(width: 12),
              Text(
                _isEnglish ? 'Payment' : 'ชำระเงิน',
                style: const TextStyle(
                  fontFamily: 'LINESeed2',
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  color: Color(0xFF17262A),
                  letterSpacing: 0.4,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      );

  Widget _buildContent() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return _MessageState(
        icon: Icons.error_outline_rounded,
        message: _isEnglish ? 'Could not load bills.' : 'โหลดรายการไม่สำเร็จ',
        action: _loadGroups,
        actionLabel: _isEnglish ? 'Try again' : 'ลองใหม่',
      );
    }
    if (_groups.isEmpty) {
      return _MessageState(
        icon: Icons.receipt_long_outlined,
        message: _isEnglish ? 'No bills to pay.' : 'ไม่มีรายการที่ต้องชำระ',
        action: _loadGroups,
        actionLabel: _isEnglish ? 'Refresh' : 'รีเฟรช',
      );
    }
    final allBills = _groups.expand((group) => group.bills);
    final billCount = allBills.length;
    double totalForStatus(_BillPaymentStatus status) => allBills
        .where((bill) => _statusFor(bill) == status)
        .fold<double>(0, (sum, bill) => sum + bill.total + bill.fine);
    final outstandingTotal = totalForStatus(_BillPaymentStatus.outstanding);
    final waitingPaymentTotal =
        totalForStatus(_BillPaymentStatus.waitingPayment);
    final waitingReviewTotal = totalForStatus(_BillPaymentStatus.waitingReview);
    return ColoredBox(
      color: const Color(0xFFF2F3F8),
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          18,
          16,
          ((MediaQuery.of(context).size.height * 0.40).clamp(250.0, 520.0) +
                  MediaQuery.of(context).viewPadding.bottom)
              .toDouble(),
        ),
        children: [
          Text(
            _isEnglish ? 'All bill' : 'รายการทั้งหมด',
            style: const TextStyle(
              fontFamily: 'LINESeed2',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF17262A),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            _isEnglish
                ? '$billCount bill(s) across all payment states'
                : '$billCount รายการ ทุกสถานะการชำระ',
            style: const TextStyle(
              fontFamily: 'LINESeed2',
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),
          _buildPaymentAmountSummary(
            outstandingTotal: outstandingTotal,
            waitingPaymentTotal: waitingPaymentTotal,
            waitingReviewTotal: waitingReviewTotal,
          ),
          const SizedBox(height: 14),
          ..._groups.expand(_buildCardsForAccount),
        ],
      ),
    );
  }

  Widget _buildPaymentAmountSummary({
    required double outstandingTotal,
    required double waitingPaymentTotal,
    required double waitingReviewTotal,
  }) {
    final isEn = _isEnglish;
    final compactSummary = isEn
        ? 'Pay now ${_money.format(outstandingTotal)} · Waiting ${_money.format(waitingPaymentTotal)}'
        : 'ต้องชำระ ${_money.format(outstandingTotal)} · รอชำระ ${_money.format(waitingPaymentTotal)}';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE1E6F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() {
              _isPaymentAmountSummaryExpanded =
                  !_isPaymentAmountSummaryExpanded;
            }),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEn ? 'Payment amount summary' : 'สรุปยอดตามสถานะ',
                        style: const TextStyle(
                          fontFamily: 'LINESeed2',
                          color: Color(0xFF17262A),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        compactSummary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'LINESeed2',
                          color: Color(0xFF64748B),
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: _isPaymentAmountSummaryExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          if (_isPaymentAmountSummaryExpanded) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildPaymentAmountMetric(
                    label: isEn ? 'Pay now' : 'ต้องชำระตอนนี้',
                    detail: isEn
                        ? 'Bills not started yet'
                        : 'รายการที่ยังไม่ได้เริ่มดำเนินการ',
                    amount: outstandingTotal,
                    color: const Color(0xFF4059B7),
                  ),
                ),
                Container(
                  width: 1,
                  height: 44,
                  color: const Color(0xFFE1E6F0),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPaymentAmountMetric(
                    label: isEn ? 'Waiting payment' : 'ยอดรอชำระ',
                    detail: isEn
                        ? 'QR created, proof not attached'
                        : 'สร้าง QR แล้ว ยังไม่ได้แนบหลักฐาน',
                    amount: waitingPaymentTotal,
                    color: const Color(0xFF4059B7),
                  ),
                ),
              ],
            ),
            if (waitingReviewTotal > 0) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 11),
                child: Divider(height: 1, color: Color(0xFFE1E6F0)),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.verified_outlined,
                    size: 17,
                    color: Color(0xFF15803D),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      isEn
                          ? 'Under review — proof already attached'
                          : 'รอตรวจสอบ — แนบหลักฐานการชำระแล้ว',
                      style: const TextStyle(
                        fontFamily: 'LINESeed2',
                        color: Color(0xFF15803D),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '${_money.format(waitingReviewTotal)} ${isEn ? 'THB' : 'บาท'}',
                    style: const TextStyle(
                      fontFamily: 'LINESeed2',
                      color: Color(0xFF15803D),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentAmountMetric({
    required String label,
    required String detail,
    required double amount,
    required Color color,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'LINESeed2',
              color: Color(0xFF64748B),
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '${_money.format(amount)} ${_isEnglish ? 'THB' : 'บาท'}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'LINESeed2',
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            detail,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'LINESeed2',
              color: Color(0xFF94A3B8),
              fontSize: 9.5,
            ),
          ),
        ],
      );

  List<Widget> _buildCardsForAccount(_PaymentAccountGroup group) {
    final outstanding = group.bills
        .where((bill) => _statusFor(bill) == _BillPaymentStatus.outstanding)
        .toList(growable: false);
    final waitingPayment = group.bills
        .where((bill) => _statusFor(bill) == _BillPaymentStatus.waitingPayment)
        .toList(growable: false);
    final waitingReview = group.bills
        .where((bill) => _statusFor(bill) == _BillPaymentStatus.waitingReview)
        .toList(growable: false);
    final cards = <Widget>[];
    if (outstanding.isNotEmpty) {
      cards.add(_buildAccountCard(group));
    }
    cards.addAll(_waitingQrGroupsFor(waitingPayment)
        .map((qrGroup) => _buildWaitingQrCard(group, qrGroup)));
    cards.addAll(_waitingQrGroupsFor(waitingReview)
        .map((qrGroup) => _buildWaitingReviewCard(group, qrGroup)));
    return cards;
  }

  List<_ExistingQrBillGroup> _waitingQrGroupsFor(
    List<_PaymentBill> bills,
  ) {
    final qrGroups = LinkedHashMap<String, _ExistingQrBillGroup>();
    for (final bill in bills) {
      final payment = _existingQrPayments[bill.docNo];
      final referenceId = payment?.referenceId ?? '';
      final key = referenceId.isEmpty ? 'pending:${bill.docNo}' : referenceId;
      final qrGroup = qrGroups.putIfAbsent(
        key,
        () => _ExistingQrBillGroup(
          referenceId: referenceId,
          displayRef: payment?.displayRef ?? referenceId,
          payment: payment,
        ),
      );
      qrGroup.bills.add(bill);
    }
    return qrGroups.values.toList(growable: false);
  }

  Widget _buildWaitingQrCard(
    _PaymentAccountGroup account,
    _ExistingQrBillGroup qrGroup,
  ) {
    final total = qrGroup.bills
        .fold<double>(0, (sum, bill) => sum + bill.total + bill.fine);
    final isReady = qrGroup.payment != null && qrGroup.referenceId.isNotEmpty;
    final payment = qrGroup.payment;
    final isExpired = _isQrExpired(payment);
    final canContinue = isReady && !isExpired;
    final createdLabel = payment == null ? '' : _qrCreatedLabel(payment);
    final expiryLabel = payment == null ? '' : _qrExpiryLabel(payment);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC9D2FA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9EDFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    const Icon(Icons.qr_code_rounded, color: Color(0xFF3049AA)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isEnglish
                          ? 'Pay and upload proof'
                          : 'รอชำระและแนบหลักฐาน',
                      style: const TextStyle(
                        fontFamily: 'LINESeed2',
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF17262A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(account.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'LINESeed2',
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        )),
                  ],
                ),
              ),
              _StatusChip(
                label: _statusLabel(_BillPaymentStatus.waitingPayment),
                color: _statusColor(_BillPaymentStatus.waitingPayment),
                backgroundColor:
                    _statusBackground(_BillPaymentStatus.waitingPayment),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  isReady
                      ? (_isEnglish
                          ? 'Ref ID ${qrGroup.displayRef}'
                          : 'รหัสรายการ ${qrGroup.displayRef}')
                      : (_isEnglish
                          ? 'QR data is being updated'
                          : 'กำลังอัปเดตข้อมูล QR'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'LINESeed2',
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              if (createdLabel.isNotEmpty) ...[
                const SizedBox(width: 6),
                Text(
                  '· $createdLabel',
                  style: const TextStyle(
                    fontFamily: 'LINESeed2',
                    fontSize: 10.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ],
          ),
          if (expiryLabel.isNotEmpty) ...[
            const SizedBox(height: 7),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isExpired
                    ? const Color(0xFFFFF1F2)
                    : const Color(0xFFF0F3FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    isExpired
                        ? Icons.error_outline_rounded
                        : Icons.timer_outlined,
                    size: 15,
                    color: isExpired
                        ? const Color(0xFFBE123C)
                        : const Color(0xFF4059B7),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      expiryLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'LINESeed2',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: isExpired
                            ? const Color(0xFFBE123C)
                            : const Color(0xFF4059B7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _Metric(
                    label: _isEnglish ? 'Bills' : 'รายการ',
                    value: '${qrGroup.bills.length}',
                  ),
                ),
                Container(width: 1, height: 34, color: const Color(0xFFE1E6F0)),
                const SizedBox(width: 18),
                Expanded(
                  flex: 2,
                  child: _Metric(
                    label: _isEnglish ? 'QR total' : 'ยอด QR',
                    value:
                        '${_money.format(total)} ${_isEnglish ? 'THB' : 'บาท'}',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
                  canContinue ? () => _continueToPayment(qrGroup.bills) : null,
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: Text(isExpired
                  ? (_isEnglish ? 'QR expired' : 'QR หมดอายุแล้ว')
                  : (_isEnglish ? 'Continue this QR' : 'ดำเนินการต่อ')),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4059B7),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'LINESeed2',
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingReviewCard(
    _PaymentAccountGroup account,
    _ExistingQrBillGroup qrGroup,
  ) {
    final total = qrGroup.bills
        .fold<double>(0, (sum, bill) => sum + bill.total + bill.fine);
    final payment = qrGroup.payment;
    final isReady = payment != null && qrGroup.referenceId.isNotEmpty;
    final createdLabel = payment == null ? '' : _qrCreatedLabel(payment);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: null,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFC9D2FA)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9EDFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.fact_check_outlined,
                      color: Color(0xFF3049AA),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEnglish ? 'Waiting review' : 'รอตรวจสอบ',
                          style: const TextStyle(
                            fontFamily: 'LINESeed2',
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF17262A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          account.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'LINESeed2',
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusChip(
                    label: _statusLabel(_BillPaymentStatus.waitingReview),
                    color: _statusColor(_BillPaymentStatus.waitingReview),
                    backgroundColor:
                        _statusBackground(_BillPaymentStatus.waitingReview),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      isReady
                          ? (_isEnglish
                              ? 'Ref ID ${qrGroup.displayRef}'
                              : 'รหัสรายการ ${qrGroup.displayRef}')
                          : (_isEnglish
                              ? 'Payment reference is being updated'
                              : 'กำลังอัปเดตรหัสรายการ'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'LINESeed2',
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                  if (createdLabel.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Text(
                      '· $createdLabel',
                      style: const TextStyle(
                        fontFamily: 'LINESeed2',
                        fontSize: 10.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 16,
                      color: Color(0xFF15803D),
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'แนบหลักฐานแล้ว รอเจ้าหน้าที่ตรวจสอบ',
                        style: TextStyle(
                          fontFamily: 'LINESeed2',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _Metric(
                        label: _isEnglish ? 'Bills' : 'รายการ',
                        value: '${qrGroup.bills.length}',
                      ),
                    ),
                    Container(
                        width: 1, height: 34, color: const Color(0xFFE1E6F0)),
                    const SizedBox(width: 18),
                    Expanded(
                      flex: 2,
                      child: _Metric(
                        label: _isEnglish ? 'Payment total' : 'ยอดชำระ',
                        value:
                            '${_money.format(total)} ${_isEnglish ? 'THB' : 'บาท'}',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: isReady
                      ? () => _openPayment(
                            qrGroup.bills,
                            existingQrPayment: payment,
                          )
                      : null,
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: Text(
                    _isEnglish ? 'View bill details' : 'ดูรายละเอียดบิล',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4059B7),
                    side: const BorderSide(color: Color(0xFFAEBBEE)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'LINESeed2',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountCard(_PaymentAccountGroup group) {
    final rawPaymentName = group.paymentName.trim();
    final paymentName =
        rawPaymentName.isEmpty || rawPaymentName.toUpperCase() == 'API IMAGE'
            ? (_isEnglish ? 'Not started yet' : 'ยังไม่ได้เริ่มดำเนินการ')
            : rawPaymentName;
    final outstanding = group.bills
        .where((bill) => _statusFor(bill) == _BillPaymentStatus.outstanding)
        .toList(growable: false);
    final outstandingTotal = outstanding.fold<double>(
        0, (sum, bill) => sum + bill.total + bill.fine);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildBankLogo(group.bank),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(group.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'LINESeed2',
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF17262A),
                        )),
                    const SizedBox(height: 2),
                    Text(paymentName,
                        style: const TextStyle(
                          fontFamily: 'LINESeed2',
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        )),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _StatusChip(
                          label:
                              '${_statusLabel(_BillPaymentStatus.outstanding)} ${outstanding.length}',
                          color: _statusColor(_BillPaymentStatus.outstanding),
                          backgroundColor:
                              _statusBackground(_BillPaymentStatus.outstanding),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (outstanding.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _Metric(
                      label: _isEnglish ? 'Outstanding bills' : 'บิลค้างชำระ',
                      value: '${outstanding.length}',
                    ),
                  ),
                  Container(
                      width: 1, height: 34, color: const Color(0xFFE1E6F0)),
                  const SizedBox(width: 18),
                  Expanded(
                    flex: 2,
                    child: _Metric(
                      label: _isEnglish ? 'Outstanding total' : 'ยอดค้างชำระ',
                      value:
                          '${_money.format(outstandingTotal)} ${_isEnglish ? 'THB' : 'บาท'}',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _startPayment(group),
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: Text(_isEnglish ? 'Start payment' : 'เริ่มชำระเงิน'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4059B7),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'LINESeed2',
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SystemClosingCountdown extends StatelessWidget {
  const _SystemClosingCountdown();

  @override
  Widget build(BuildContext context) => StreamBuilder<int>(
        stream: Stream<int>.periodic(
          const Duration(seconds: 1),
          (tick) => tick,
        ),
        initialData: 0,
        builder: (context, snapshot) {
          final now = DateTime.now();
          final closingTime = DateTime(now.year, now.month, now.day, 22, 59);
          final remaining = closingTime.difference(now);
          final duration = remaining.isNegative ? Duration.zero : remaining;
          final hours = duration.inHours.toString().padLeft(2, '0');
          final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
          final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
          final isClosed = duration == Duration.zero;

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 7),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color:
                  isClosed ? const Color(0xFFFFF1F2) : const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isClosed
                    ? const Color(0xFFFECACA)
                    : const Color(0xFFFED7AA),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 15,
                  color: isClosed
                      ? const Color(0xFFBE123C)
                      : const Color(0xFFC2410C),
                ),
                const SizedBox(width: 4),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isClosed ? 'ปิดทำการแล้ว' : 'ชำระภายใน 22:59',
                      style: TextStyle(
                        fontFamily: 'LINESeed2',
                        fontSize: 9.5,
                        height: 1,
                        fontWeight: FontWeight.w700,
                        color: isClosed
                            ? const Color(0xFFBE123C)
                            : const Color(0xFF9A3412),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isClosed ? '--:--:--' : '$hours:$minutes:$seconds',
                      style: TextStyle(
                        fontFamily: 'LINESeed2',
                        fontSize: 12,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        color: isClosed
                            ? const Color(0xFFBE123C)
                            : const Color(0xFFC2410C),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
}

enum _BillPaymentStatus { outstanding, waitingPayment, waitingReview }

class _PaymentStatusResult {
  const _PaymentStatusResult(this.statuses, this.existingQrPayments);

  const _PaymentStatusResult.empty()
      : statuses = const <String, _BillPaymentStatus>{},
        existingQrPayments = const <String, _ExistingQrPayment>{};

  final Map<String, _BillPaymentStatus> statuses;
  final Map<String, _ExistingQrPayment> existingQrPayments;
}

class _ExistingQrPayment {
  const _ExistingQrPayment({
    required this.referenceId,
    required this.displayRef,
    required this.cid,
    required this.amount,
    required this.invoiceAll,
    required this.image,
    required this.createdAt,
    required this.expiresAt,
  });

  factory _ExistingQrPayment.fromApi(
    Map<dynamic, dynamic> entry,
    List<String> docNos,
  ) {
    final imageData = entry['img'];
    final refId = entry['ref_id']?.toString().trim() ?? '';
    final ref1 = entry['ref1']?.toString().trim() ?? '';
    final datex = entry['datex']?.toString().trim() ?? '';
    final timex = entry['timex']?.toString().trim() ?? '';
    final ref2 = entry['ref2']?.toString().trim() ?? '';
    return _ExistingQrPayment(
      referenceId: refId,
      displayRef: ref1.isEmpty || ref1 == 'null' ? refId : ref1,
      cid: entry['cid']?.toString().trim() ?? '',
      amount: _amountFrom(entry['amt'] ?? entry['amount']),
      invoiceAll: docNos.map((docNo) => "'$docNo'").join(','),
      image: imageData is List
          ? jsonEncode(imageData)
          : imageData?.toString() ?? '',
      createdAt: _parseCreatedAt(datex, timex),
      expiresAt: _parseExpiryFromRef2(ref2),
    );
  }

  final String referenceId;
  final String displayRef;
  final String cid;
  final double amount;
  final String invoiceAll;
  final String image;
  final DateTime? createdAt;
  final DateTime? expiresAt;

  static DateTime? _parseCreatedAt(String datex, String timex) {
    if (datex.isEmpty || timex.isEmpty) return null;
    return DateTime.tryParse('$datex $timex');
  }

  static DateTime? _parseExpiryFromRef2(String ref2) {
    final match = RegExp(r'(\d{12})$').firstMatch(ref2);
    if (match == null) return null;
    try {
      return DateFormat('yyyyMMddHHmm').parseStrict(match.group(1)!);
    } catch (_) {
      return null;
    }
  }

  static double _amountFrom(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString().replaceAll(',', '') ?? '') ?? 0;
  }
}

class _ExistingQrBillGroup {
  _ExistingQrBillGroup({
    required this.referenceId,
    required this.displayRef,
    required this.payment,
  });

  final String referenceId;
  final String displayRef;
  final _ExistingQrPayment? payment;
  final List<_PaymentBill> bills = <_PaymentBill>[];
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  final String label;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'LINESeed2',
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      );
}

class _PaymentAccountGroup {
  _PaymentAccountGroup({
    required this.key,
    required this.bank,
    required this.accountNo,
    required this.accountName,
    required this.paymentName,
    required this.payser,
    required this.ptser,
  });

  final String key;
  final String bank;
  final String accountNo;
  final String accountName;
  final String paymentName;
  final String? payser;
  final String? ptser;
  final List<_PaymentBill> bills = <_PaymentBill>[];

  String get label => [bank, accountNo, accountName]
      .where((value) => value.isNotEmpty)
      .join(' · ');
  double get total => bills.fold<double>(0, (sum, bill) => sum + bill.total);
}

class _PaymentBill {
  // Legacy payment-status reference, keyed by bill docno:
  // - ค้างชำระ: ไม่มี payment record ของบิลนี้
  // - รอชำระ: มี payment record แต่ img สลิปยังว่าง
  // - รอตรวจสอบ: มี payment record และ img สลิปแล้ว
  // สถานะถูก join จาก check_genqr_new.php ใน _loadPaymentStatuses().
  const _PaymentBill({
    required this.docNo,
    required this.date,
    required this.cid,
    required this.customerNumber,
    required this.total,
    required this.discount,
    required this.fine,
    required this.pvat,
    required this.vat,
    required this.wht,
    required this.bank,
    required this.accountNo,
    required this.paymentName,
    required this.payser,
    required this.ptser,
  });

  factory _PaymentBill.fromApi(Bill bill, Data data) => _PaymentBill(
        docNo: bill.docno?.trim() ?? '',
        date: DateTime.tryParse(bill.date ?? '') ?? DateTime(9999),
        cid: bill.cid,
        customerNumber: bill.custno,
        total: bill.totalBill ?? 0,
        discount: bill.totalDisendbill ?? 0,
        fine: bill.fineTotal ?? 0,
        pvat: bill.pvatBill ?? bill.totalBill ?? 0,
        vat: bill.vatBill ?? 0,
        wht: bill.whtBill ?? 0,
        bank: data.bank,
        accountNo: data.bno,
        paymentName: data.ptname,
        payser: data.payser?.toString(),
        ptser: data.ptser?.toString(),
      );

  final String docNo;
  final DateTime date;
  final String? cid;
  final String? customerNumber;
  final double total;
  final double discount;
  final double fine;
  final double pvat;
  final double vat;
  final double wht;
  final String? bank;
  final String? accountNo;
  final String? paymentName;
  final String? payser;
  final String? ptser;

  InvoiceModel toInvoice() => InvoiceModel(
        docno: docNo,
        date: date.toIso8601String().substring(0, 10),
        cid: cid,
        custno: customerNumber,
        amtall: total.toString(),
        amt: pvat.toString(),
        pvat: pvat.toString(),
        pvatall: pvat.toString(),
        vat: vat.toString(),
        vatall: vat.toString(),
        wht: wht.toString(),
        whtall: wht.toString(),
        disendbill: discount.toString(),
        bank: bank,
        bno: accountNo,
        ptname: paymentName,
        payser: payser,
        ptser: ptser,
      );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      );
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.message,
    required this.action,
    required this.actionLabel,
  });

  final IconData icon;
  final String message;
  final VoidCallback action;
  final String actionLabel;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: action, child: Text(actionLabel)),
            ],
          ),
        ),
      );
}
