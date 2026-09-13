import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:chaoperty_user/Model/GetTeNant_Model.dart';
import 'package:chaoperty_user/Model/Model_V2/payment_IntentsModel.dart';
import 'package:chaoperty_user/color.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/models/payment_subv4_models.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/platform/payment_subv4_web_actions.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/viewmodels/payment_subv4_view_model.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/widgets/payment_subv4_header.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/widgets/payment_subv4_tabs.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/widgets/payment_subv4_payment_card.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/widgets/payment_subv4_bank_summary.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/widgets/payment_subv4_intent_card.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/widgets/payment_subv4_invoice_row.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/widgets/payment_subv4_bottom_action.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/widgets/payment_subv4_dialogs.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/widgets/payment_subv4_instructions_card.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/widgets/payment_subv4_countdown_bar.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/widgets/payment_subv4_theme.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/platform/payment_subv4_slip_picker.dart';

/// Entry page รองรับทั้ง Parameter เก่าและใหม่ เพื่อ Parity
class PaymentSubV4Page extends StatelessWidget {
  const PaymentSubV4Page({
    super.key,
    this.mainScreenAnimationController,
    this.mainScreenAnimation,
    this.teNantModel,
    this.cuslang,
    this.serPayment,
    this.serptPayment,
    this.selectedDocNos,
    this.fromIntent = false,
    this.targetIntentUuid,
    this.targetPaymentIntentNo,
    this.viewModelOverride,
  });

  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;
  final List<TeNantModel>? teNantModel;
  final String? cuslang;
  final String? serPayment;
  final String? serptPayment;
  final List<String>? selectedDocNos;
  final bool fromIntent;
  final String? targetIntentUuid;
  final String? targetPaymentIntentNo;

  /// สำหรับ test — เมื่อส่งมา จะไม่สร้าง ViewModel เองและไม่เรียก initialize()
  final PaymentSubV4ViewModel? viewModelOverride;

  @override
  Widget build(BuildContext context) {
    final override = viewModelOverride;
    if (override != null) {
      return ChangeNotifierProvider<PaymentSubV4ViewModel>.value(
        value: override,
        child: _PaymentSubV4View(
          animation: mainScreenAnimation,
          animationController: mainScreenAnimationController,
        ),
      );
    }

    final params = PaymentSubV4Params(
      tenants: teNantModel,
      customerLanguage: cuslang,
      paymentSerial: serPayment,
      paymentTypeSerial: serptPayment,
      selectedDocNos: selectedDocNos,
      fromIntent: fromIntent,
      targetIntentUuid: targetIntentUuid,
      targetPaymentIntentNo: targetPaymentIntentNo,
    );

    return ChangeNotifierProvider(
      create: (_) => PaymentSubV4ViewModel(params: params)..initialize(),
      child: _PaymentSubV4View(
        animation: mainScreenAnimation,
        animationController: mainScreenAnimationController,
      ),
    );
  }
}

class _PaymentSubV4View extends StatefulWidget {
  const _PaymentSubV4View({
    this.animation,
    this.animationController,
  });

  final Animation<double>? animation;
  final AnimationController? animationController;

  @override
  State<_PaymentSubV4View> createState() => _PaymentSubV4ViewState();
}

class _PaymentSubV4ViewState extends State<_PaymentSubV4View>
    with TickerProviderStateMixin {
  bool _noticeShown = false;
  int? _handledEventSeq;
  final GlobalKey _qrBoundaryKey = GlobalKey();

  /// ใช้เมื่อ caller ไม่ได้ส่ง animation มา (เช่นจาก My Diary)
  late final AnimationController _localController;
  late final Animation<double> _localAnimation;
  late final bool _usingLocalController;

  AnimationController get _controller =>
      _usingLocalController
          ? _localController
          : widget.animationController!;

  Animation<double> get _animation =>
      _usingLocalController ? _localAnimation : widget.animation!;

  @override
  void initState() {
    super.initState();
    _usingLocalController = widget.animationController == null ||
        widget.animation == null;
    if (_usingLocalController) {
      _localController = AnimationController(
        vsync: this,
        value: 1.0, // แสดงทันที ไม่ต้องรอ animation
      );
      _localAnimation = AlwaysStoppedAnimation(1.0);
    }
  }

  @override
  void dispose() {
    if (_usingLocalController) {
      _localController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PaymentSubV4ViewModel>();
    final state = vm.state;
    final isEn = vm.params.customerLanguage == 'EN';
    final payment = state.selectedPaymentModel;
    final hasActivePayment = (state.qrState.intentUuid ?? '').isNotEmpty;
    final isQrChannel = payment?.isQrChannel == true;
    final merchantName = _merchantName(state);

    // แจ้งเตือนให้แนบหลักฐานครั้งแรกที่เข้าหน้า
    if (!_noticeShown && state.pageStatus == PageStatus.ready) {
      _noticeShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        PaymentSubV4Dialogs.showAttachSlipNotice(context, isEn: isEn);
      });
    }

    if (state.pageStatus == PageStatus.loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF2F3F8),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.pageStatus == PageStatus.error) {
      return Scaffold(
        appBar: AppBar(title: const Text('ข้อผิดพลาด')),
        body: Center(
          child: Text(state.errorMessage ?? 'เกิดข้อผิดพลาดในการโหลดข้อมูล'),
        ),
      );
    }

    // ฟัง UI Event เพื่อแสดง SnackBar อัตโนมัติ (กันแสดงซ้ำด้วย seq)
    final event = state.uiEvent;
    if (event != null && _handledEventSeq != event.seq) {
      _handledEventSeq = event.seq;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(event.message),
            backgroundColor: event.isError ? Colors.red : Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        vm.consumeEvent(event.id, seq: event.seq);
      });
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Scaffold(
      backgroundColor: PaymentSubV4Theme.pageBackground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: FadeTransition(
              opacity: _animation,
              child: Transform(
                transform: Matrix4.translationValues(
                    0.0, 30 * (1.0 - _animation.value), 0.0),
                child: Column(
          children: [
            PaymentSubV4Header(
              title: isEn ? 'Payment' : 'การชำระเงิน',
              isConnected: state.authValid,
              onBack: () => Navigator.of(context).pop(),
              onHelp: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isEn
                          ? 'Please contact property support.'
                          : 'กรุณาติดต่อฝ่ายดูแลโครงการ',
                    ),
                  ),
                );
              },
            ),
            PaymentSubV4Tabs(
              selectedTab: state.selectedTab,
              countPayable: state.invoices.length,
              countAwaitingSlip: state.countAwaitingSlip,
              countAwaitingVerify: state.countAwaitingVerify,
              onTabSelected: (tab) => vm.selectTab(tab),
              isEn: isEn,
            ),
            if (state.sectionErrors.isNotEmpty)
              Container(
                width: double.infinity,
                color: Colors.orange.shade50,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 16, color: Colors.orange.shade800),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final msg in state.sectionErrors)
                            Text(
                              msg,
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: Font_.Fonts_T,
                                color: Colors.orange.shade900,
                              ),
                            ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => vm.initialize(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        isEn ? 'Retry' : 'ลองใหม่',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            if (hasActivePayment && state.selectedTab == 1)
              PaymentSubV4CountdownBar(
                qrState: state.qrState,
                totalSeconds: vm.sessionTotalSecs,
                isEn: isEn,
              ),
            if (hasActivePayment)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: state.operation == PaymentOperation.none
                          ? () => _confirmCancelPayment(isEn)
                          : null,
                      icon: const Icon(Icons.cancel_outlined, size: 16),
                      label: Text(
                        isEn ? 'Cancel payment' : 'ยกเลิกรายการชำระ',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontFamily: Font_.Fonts_T,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    if (hasActivePayment)
                      PaymentSubV4PaymentCard(
                        paymentModel: payment,
                        summary: state.summary,
                        qrState: state.qrState,
                        isEn: isEn,
                        merchantName: merchantName,
                        qrBoundaryKey: _qrBoundaryKey,
                        onCopy: (value) => _copyText(value, isEn),
                        onSaveQr: isQrChannel
                            ? () => _saveQrOnWeb(isEn)
                            : null,
                        onRenewQr: isQrChannel
                            ? () => vm.createPaymentIntent()
                            : null,
                      ),
                    if (hasActivePayment) ...[
                      const SizedBox(height: 12),
                      PaymentSubV4InstructionsCard(
                        isEn: isEn,
                        isBankTransfer: payment?.isBankTransfer == true,
                      ),
                    ],
                    if (state.slipState.slipBytes != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                state.slipState.fileName ?? 'แนบสลิปแล้ว',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () => vm.clearSlip(),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    if (state.selectedTab == 1) ...[
                      if (state.invoices.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Text('ไม่มีรายการที่ต้องชำระ'),
                          ),
                        )
                      else ...[
                        ...state.invoices.map((inv) {
                          final docno = (inv.docno ?? '').trim();
                          return PaymentSubV4InvoiceRow(
                            invoice: inv,
                            isEn: isEn,
                            history: state.invoiceHistoryByDocno[docno] ??
                                const [],
                            fine: state.invoiceFineByDocno[docno],
                            isLoadingDetail:
                                state.detailLoadingDocno == docno,
                            onExpand: (d) => vm.loadInvoiceDetail(d),
                          );
                        }),
                        if (!hasActivePayment) ...[
                          const SizedBox(height: 16),
                          PaymentSubV4InstructionsCard(
                            isEn: isEn,
                            isBankTransfer: payment?.isBankTransfer == true,
                          ),
                        ],
                      ],
                    ] else if (state.selectedTab == 2) ...[
                      PaymentSubV4BankSummary(
                        paymentModel: payment,
                        isEn: isEn,
                      ),
                      const SizedBox(height: 10),
                      if (state.countAwaitingSlip == 0)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Text('ไม่มีรายการรอแนบหลักฐาน'),
                          ),
                        )
                      else
                        ...state.paymentIntents
                            .where((p) =>
                                PaymentSubV4State.classifyIntentStatus(p) ==
                                NormalizedIntentStatus.awaitingSlip)
                            .map(
                              (intent) => PaymentSubV4IntentCard(
                                intent: intent,
                                isVerifyTab: false,
                                isEn: isEn,
                                onOpenSlip: () =>
                                    _confirmAndUploadSlip(intent, isEn),
                              ),
                            ),
                    ] else if (state.selectedTab == 3) ...[
                      PaymentSubV4BankSummary(
                        paymentModel: payment,
                        isEn: isEn,
                      ),
                      const SizedBox(height: 10),
                      if (state.countAwaitingVerify == 0)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Text('ไม่มีรายการรอระบบตรวจสอบ'),
                          ),
                        )
                      else
                        ...state.paymentIntents
                            .where((p) =>
                                PaymentSubV4State.classifyIntentStatus(p) ==
                                NormalizedIntentStatus.awaitingVerification)
                            .map(
                              (intent) => PaymentSubV4IntentCard(
                                intent: intent,
                                isVerifyTab: true,
                                isEn: isEn,
                                onOpenSlip: () =>
                                    _confirmAndUploadSlip(intent, isEn),
                              ),
                            ),
                    ],
                  ],
                ),
              ),
            ),
            if (state.selectedTab == 1 && state.invoices.isNotEmpty)
              PaymentSubV4BottomAction(
                summary: state.summary,
                operation: state.operation,
                isEn: isEn,
                enabled: state.summary.grandTotal.isPositive,
                label: hasActivePayment
                    ? (isEn
                        ? 'Attach slip and confirm'
                        : 'กดเพื่อ "แนบหลักฐานและยืนยัน"')
                    : (isEn ? 'Start payment' : 'กดเพื่อ "เริ่มการชำระ"'),
                onActionPressed: () async {
                  if (hasActivePayment) {
                    await _confirmAndUploadSlip(null, isEn);
                  } else {
                    await vm.createPaymentIntent();
                  }
                },
              ),
          ],
        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _merchantName(PaymentSubV4State state) {
    final rental = state.rentalModel;
    final rentalName = (rental?.pn ?? rental?.rtname ?? '').trim();
    if (rentalName.isNotEmpty && rentalName != 'null') return rentalName;

    if (state.tenantModels.isNotEmpty) {
      final tenant = state.tenantModels.first;
      final name = (tenant.sname ?? tenant.cname ?? tenant.rtname ?? '').trim();
      if (name.isNotEmpty && name != 'null') return name;
    }
    return '';
  }

  Future<void> _copyText(String value, bool isEn) async {
    if (value.trim().isEmpty) return;
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEn ? 'Copied' : 'คัดลอกเรียบร้อยแล้ว'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _saveQrOnWeb(bool isEn) async {
    if (!kIsWeb) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEn
                ? 'QR saving is available on Web in this version.'
                : 'เวอร์ชันนี้รองรับการบันทึก QR บน Web',
          ),
        ),
      );
      return;
    }

    try {
      await WidgetsBinding.instance.endOfFrame;
      final boundary = _qrBoundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) throw StateError('QR boundary is unavailable');

      final image = await boundary.toImage(pixelRatio: 3);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) throw StateError('QR image could not be encoded');

      final saved = await savePaymentQrOnWeb(data.buffer.asUint8List());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            saved
                ? (isEn ? 'QR Code saved' : 'บันทึก QR Code แล้ว')
                : (isEn ? 'Could not save QR Code' : 'บันทึก QR Code ไม่สำเร็จ'),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEn ? 'Could not save QR Code' : 'บันทึก QR Code ไม่สำเร็จ',
          ),
        ),
      );
    }
  }

  /// เลือกสลิป → preview → ยืนยันด้วย slide → upload
  /// [intent] ไม่ null = แนบให้ intent ที่กดมาจากแท็บ 2
  Future<void> _confirmAndUploadSlip(PaymentIntent? intent, bool isEn) async {
    final vm = context.read<PaymentSubV4ViewModel>();

    if (intent != null) {
      vm.openIntent(intent);
    }

    final slip = await PaymentSubV4SlipPicker.pickAndCompressImage();
    if (!mounted) return;
    if (slip == null) return;

    vm.setSlip(
      bytes: slip.bytes,
      fileName: slip.fileName,
      mimeType: slip.mimeType,
    );

    if (!mounted) return;
    await PaymentSubV4Dialogs.showPaymentConfirmation(
      context,
      isEn: isEn,
      summary: vm.state.summary,
      slip: vm.state.slipState,
      onConfirm: () async {
        await vm.uploadSlip();
      },
    );
  }

  /// ยืนยันยกเลิกรายการชำระเงิน
  Future<void> _confirmCancelPayment(bool isEn) async {
    final vm = context.read<PaymentSubV4ViewModel>();
    final hasSlip = vm.state.slipState.slipBytes != null;

    await PaymentSubV4Dialogs.showCancelPayment(
      context,
      isEn: isEn,
      hasSlip: hasSlip,
      onConfirmCancel: () async {
        await vm.cancelPayment();
      },
    );
  }
}
