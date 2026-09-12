import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chaoperty_user/Model/GetTeNant_Model.dart';
import 'package:chaoperty_user/Model/Model_V2/payment_IntentsModel.dart';
import 'package:chaoperty_user/color.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/models/payment_subv4_models.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/viewmodels/payment_subv4_view_model.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/widgets/payment_subv4_header.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/widgets/payment_subv4_tabs.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/widgets/payment_subv4_payment_card.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/widgets/payment_subv4_qr_box.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/widgets/payment_subv4_intent_card.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/widgets/payment_subv4_invoice_row.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/widgets/payment_subv4_bottom_action.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/widgets/payment_subv4_dialogs.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/widgets/payment_subv4_instructions_card.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/widgets/payment_subv4_countdown_bar.dart';
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
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: FadeTransition(
          opacity: _animation,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - _animation.value), 0.0),
            child: Column(
          children: [
            PaymentSubV4Header(
              title: vm.params.customerLanguage == 'EN' ? 'Payment' : 'การชำระ',
              onBack: () => Navigator.of(context).pop(),
            ),
            PaymentSubV4Tabs(
              selectedTab: state.selectedTab,
              countPayable: state.invoices.length,
              countAwaitingSlip: state.countAwaitingSlip,
              countAwaitingVerify: state.countAwaitingVerify,
              onTabSelected: (tab) => vm.selectTab(tab),
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
            if (state.qrState.status == QrStatus.active ||
                state.qrState.isSessionExpired)
              PaymentSubV4CountdownBar(
                qrState: state.qrState,
                totalSeconds: vm.sessionTotalSecs,
                isEn: isEn,
              ),
            if (state.qrState.status == QrStatus.active)
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
                    PaymentSubV4PaymentCard(
                      paymentModel: state.selectedPaymentModel,
                      summary: state.summary,
                      qrState: state.qrState,
                    ),
                    if (state.qrState.status == QrStatus.active)
                      PaymentSubV4QrBox(
                        qrState: state.qrState,
                        summary: state.summary,
                        onRenewQr: () => vm.createPaymentIntent(),
                      ),
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
                        const SizedBox(height: 16),
                        PaymentSubV4InstructionsCard(
                          isEn: isEn,
                          isBankTransfer:
                              state.selectedPaymentModel?.ptser == '2',
                        ),
                      ],
                    ] else if (state.selectedTab == 2) ...[
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
                                onAttachSlip: () =>
                                    _confirmAndUploadSlip(intent, isEn),
                              ),
                            ),
                    ] else if (state.selectedTab == 3) ...[
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
                label: state.qrState.status == QrStatus.active
                    ? (isEn
                        ? 'Attach slip and confirm'
                        : 'กดเพื่อ "แนบหลักฐานและยืนยัน"')
                    : (isEn
                        ? 'Start payment'
                        : 'กดเพื่อ "เริ่มการชำระ"'),
                onActionPressed: () async {
                  if (vm.state.qrState.status == QrStatus.active) {
                    await _confirmAndUploadSlip(null, isEn);
                  } else {
                    // ยังไม่มี QR → สร้าง intent + QR
                    // หากล้มเหลว ViewModel จะส่ง uiEvent ให้แสดง SnackBar เอง
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
    );
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
