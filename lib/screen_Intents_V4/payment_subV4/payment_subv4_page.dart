import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chaoperty_user/Model/GetTeNant_Model.dart';
import 'package:chaoperty_user/Model/Model_V2/payment_IntentsModel.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/models/payment_subv4_models.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/viewmodels/payment_subv4_view_model.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/widgets/payment_subv4_header.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/widgets/payment_subv4_tabs.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/widgets/payment_subv4_payment_card.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/widgets/payment_subv4_qr_box.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/widgets/payment_subv4_intent_card.dart';
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

  @override
  Widget build(BuildContext context) {
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
      child: const _PaymentSubV4View(),
    );
  }
}

class _PaymentSubV4View extends StatefulWidget {
  const _PaymentSubV4View();

  @override
  State<_PaymentSubV4View> createState() => _PaymentSubV4ViewState();
}

class _PaymentSubV4ViewState extends State<_PaymentSubV4View> {
  bool _noticeShown = false;
  String? _handledEventId;

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

    // ฟัง UI Event เพื่อแสดง SnackBar อัตโนมัติ (กันแสดงซ้ำด้วย event id)
    final event = state.uiEvent;
    if (event != null && _handledEventId != event.id) {
      _handledEventId = event.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(event.message),
            backgroundColor: event.isError ? Colors.red : Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        vm.consumeEvent(event.id);
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
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
            if (state.qrState.status == QrStatus.active ||
                state.qrState.isSessionExpired)
              PaymentSubV4CountdownBar(
                qrState: state.qrState,
                totalSeconds: vm.sessionTotalSecs,
                isEn: isEn,
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
                        ...state.invoices.map(
                          (inv) => Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              title: Text(inv.docno ?? '-'),
                              trailing: Text('${inv.amtall ?? 0} บาท'),
                            ),
                          ),
                        ),
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
}
