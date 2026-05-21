// // ignore_for_file: deprecated_member_use

// import 'dart:convert';
// import 'dart:io';
// import 'dart:math';
// import 'dart:typed_data';
// import 'dart:ui';
// import 'package:flutter/material.dart';
// // หรือ
// import 'package:flutter/widgets.dart';

// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:chaoperty_user/Model/GetTranBill_string_model.dart';
// import 'package:chaoperty_user/screen/buttonnavbar.dart';
// import 'package:dio/dio.dart';
// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:fl_pin_code/pin_code.dart';
// import 'package:fl_pin_code/styles.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_file_dialog/flutter_file_dialog.dart';
// import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:gallery/gallery.dart';
// import 'package:image_downloader_web/image_downloader_web.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
// import 'package:intl/intl.dart';
// import 'package:loading_indicator/loading_indicator.dart';
// import 'package:mime/mime.dart';
// import 'package:panara_dialogs/panara_dialogs.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:pretty_qr_code/pretty_qr_code.dart';
// import 'package:provider/provider.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:image/image.dart' as img_lib;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:syncfusion_flutter_barcodes/barcodes.dart';
// import '../CRC_16_Prompay/generate_qrcode.dart';
// import '../Constant/Myconstant.dart';
// import '../INSERT_Log/Insert_log.dart';
// import '../Model/GetCFinnancetrans_Model.dart';
// import '../Model/GetContractx_Fine_Model.dart';
// import '../Model/GetInvoice_Model.dart';
// import '../Model/GetInvoice_diapay_Model.dart';
// import '../Model/GetInvoice_history_Model.dart';
// import '../Model/GetInvoice_pay_Model.dart';
// import '../Model/GetPayMent_Model.dart';
// import '../Model/GetRenTal_Model.dart';
// import '../Model/GetTeNant_Model.dart';
// import '../Model/GetTranBill_model.dart';
// import '../Model/GetTrans_Model.dart';
// import '../Model/GetTrans_fine_Model.dart';
// import '../Model/Model_V2/payment_IntentsModel.dart';
// import '../color.dart';
// import '../screen/Screen_new/fitness_app_home_screen.dart';
// import 'package:http/http.dart' as http;
// import 'package:universal_html/html.dart' as html;
// import 'package:share_plus/share_plus.dart';
// import 'dart:ui' as ui;
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:image/image.dart' as img;
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:qr/qr.dart' as qr_lib;

// import 'APIS-V2/payment-intents.dart';
// import 'Model/IntentsContractx_Fine_Model.dart';
// import 'Model/IntentsInv_history_Model.dart';
// import 'bankCodeMap.dart';

// class paymentSubV2InvAll extends StatefulWidget {
//   final AnimationController? mainScreenAnimationController;
//   final Animation<double>? mainScreenAnimation;
//   final List<TeNantModel>? teNantModel;
//   final String? cuslang;
//   final String? serPayment;
//   final String? serptPayment;
//   paymentSubV2InvAll({
//     Key? key,
//     this.mainScreenAnimationController,
//     this.mainScreenAnimation,
//     this.teNantModel,
//     this.cuslang,
//     this.serPayment,
//     this.serptPayment,
//   }) : super(key: key);

//   @override
//   State<paymentSubV2InvAll> createState() => _paymentSubV2InvAllState();
// }

// class _paymentSubV2InvAllState extends State<paymentSubV2InvAll> {
//   var nFormat = NumberFormat("#,##0.00", "en_US");
//   String fmtMoney(num? n) =>
//       '${nFormat.format(double.parse((n ?? 0).toStringAsFixed(2)))}';
//   String fmtInt(num? n) =>
//       '${nFormat.format(double.parse((n ?? 0).toInt().toString()))}';
//   String fmtDate(String? iso) {
//     if (iso == null || iso.isEmpty) return '-';
//     final d = DateTime.tryParse(iso);
//     if (d == null) return iso;
//     return DateFormat('dd-MM-yyyy').format(d);
//   }

//   File? _image;
//   Uint8List webimage = Uint8List(8);

//   final payformkey = GlobalKey<FormState>();

//   DateTime datex = DateTime.now();
//   bool? isChecked = false;
//   bool isLoading = true;
//   bool _isExporting = false;
//   Uint8List? _exportQrBytes;
//   GlobalKey qrImageKey = GlobalKey();
//   GlobalKey qrBlockKey = GlobalKey();
//   final namecontroller = TextEditingController();
//   final datecontroller = TextEditingController();

//   String _platformVersion = 'Unknown';
//   final _galleryPlugin = Gallery();

//   String? rtname,
//       type,
//       typex,
//       renname,
//       bill_name,
//       bill_addr,
//       bill_tax,
//       bill_tel,
//       bill_email,
//       expbill,
//       expbill_name,
//       bill_default,
//       bill_tser,
//       foder,
//       bills_name_,
//       imglogo_,
//       cid_doc,
//       refpay;
//   String? Form_nameshop,
//       Form_typeshop,
//       Form_bussshop,
//       Form_bussscontact,
//       Form_address,
//       Form_tel,
//       Form_email,
//       Form_tax,
//       rental_count_text,
//       Form_area,
//       Form_ln,
//       Form_sdate,
//       Form_ldate,
//       Form_period,
//       Form_rtname,
//       Form_docno,
//       Form_zn,
//       Form_aser,
//       Form_qty,
//       discount_,
//       payment_tser,
//       payment_img,
//       payment_co,
//       payment_bname,
//       payment_bank,
//       invoicePay,
//       invoicePayfine,
//       cid_ren,
//       cid_docqr,
//       refpayup;
//   List<PayMentModel> _PayMentModels = [];
//   List<RenTalModel> renTalModels = [];
//   List<InvoiceModel> _InvoiceModels = [];
//   String? selectedValue;
//   String? numinvoice, paymentSer1, paymentName1, paymentSer2, paymentName2;
//   final Form_payment1 = TextEditingController();
//   final Form_payment2 = TextEditingController();
//   List<TeNantModel> teNantModels = [];
//   List<ContractxFineModel> contractxFineModels = [];
//   List<TransFineModel> transFineModels = [];

//   double sum_pvat = 0.00,
//       sum_vat = 0.00,
//       sum_wht = 0.00,
//       sum_amt = 0.00,
//       sum_dis = 0.00,
//       sum_disamt = 0.00,
//       sum_disp = 0,
//       in_amt = 0,
//       sum_tran_fine = 0,
//       fine_total = 0,
//       sum_tran_fine_in = 0,
//       sum_pvat_in = 0,
//       sum_vat_in = 0,
//       sum_wht_in = 0,
//       sum_amt_in = 0,
//       sum_disamt_in = 0;
//   int tap = 0, select_pay = 0, gopay = 0, show_qr = 0;
//   double dis_sum_Pakan = 0.00;
//   String? cFinn,
//       Value_newDateY = '',
//       Value_newDateD = '',
//       Value_newDateY1 = '',
//       Value_newDateD1 = '';
//   DateTime newDatetime = DateTime.now();
//   List listitem = [];
//   List<InvoicePayModel> invoicePayModels = [];
//   List<TransBillStringModel> _TransBillstring = [];
//   List<InvoiceHistoryModel> _InvoiceHistoryModels = [];
//   List<PaymentIntent> paymentIntents = [];
//   var _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
//   Random _rnd = Random();

//   String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
//       length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

//   String QR_Ref1 = '', QR_Ref2 = '', QR_Ref3 = '', QR_Date15Min = '';

//   // Countdown variables
//   late DateTime expiryUtc;
//   final int _totalSecs = 900; // 15 minutes
//   Uint8List? _uploadedSlipData;
//   bool _expireDialogShown = false;
//   String? custno;
//   String? renTal_user, renTal_name;
//   String? return_qr_refapi1, return_qr_refapi2, return_qr_refapi3;
//   String? qr_expiresAt, qr_softExpiresAt;
//   String? qr_payload;

//   // ================= Helpers for Right Panel =================

//   double _d(dynamic v) {
//     final s = (v ?? '0').toString().trim();
//     return double.tryParse(s.isEmpty ? '0' : s) ?? 0;
//   }

//   String _fmtNum(dynamic v) => nFormat.format(_d(v));

//   String _fmtDate(String? iso) {
//     try {
//       return DateFormat('dd-MM-yyyy')
//           .format(DateTime.parse('${(iso ?? '').trim()} 00:00:00'));
//     } catch (_) {
//       return '';
//     }
//   }

//   // =================  =================
//   @override
//   void initState() {
//     super.initState();

//     checkPreferance().then((value) {
//       Value_newDateY1 = DateFormat('yyyy-MM-dd').format(newDatetime);
//       Value_newDateD1 = DateFormat('dd-MM-yyyy').format(newDatetime);
//       Value_newDateY = DateFormat('yyyy-MM-dd').format(newDatetime);
//       Value_newDateD = DateFormat('dd-MM-yyyy').format(newDatetime);

//       expiryUtc = DateTime.now().toUtc().add(Duration(seconds: _totalSecs));
//       _initData();
//     });
//     initPlatformState();
//   }

//   int _toU16(String? v) =>
//       (int.tryParse((v ?? '0').trim()) ?? 0) +
//       65535; // ✅ 16-bit unsigned (0..65535)
//   Future<void> _initData() async {
//     setState(() {
//       isLoading = true;
//     });
//     if (widget.teNantModel == null) {
//       await read_data();
//     }
//     await generateRandomString();

//     SharedPreferences preferences = await SharedPreferences.getInstance();

//     var custnoPreferences = await preferences.getString('custno');

//     var renPreferences = await preferences.getString('renTalSer');

//     String? custno16Bit = await _toU16('$custnoPreferences').toString();
//     final ren16Bit = await _toU16('$renPreferences');

//     await redPaymentIntents(
//         cusno: custno16Bit, propertyno: ren16Bit.toString() ?? '');

//     await read_GC_rental();
//     await red_payMent();
//     await read_GC_fine();
//     await red_Invoice();

//     print('_InvoiceModels >>>>> ${widget.teNantModel?.length ?? 0}');

//     List<Future> transFutures = [];
//     for (int indexx = 0; indexx < _InvoiceModels.length; indexx++) {
//       transFutures.add(red_Trans_select(indexx));
//     }
//     await Future.wait(transFutures);

//     if (_PayMentModels.isNotEmpty) {
//       _selectPayment(0);
//     } else {
//       setState(() {
//         select_pay = 1;
//       });
//     }
//     await in_Trans_fine_re();
//     Future.delayed(Duration(seconds: 2), () async {
//       await QrGenRef();
//       setState(() {
//         isLoading = false;
//       });
//     });
//   }

//   Future<void> redPaymentIntents(
//       {required String cusno, required String propertyno}) async {
//     if (mounted) {
//       setState(() {
//         paymentIntents.clear();
//       });
//     }
//     // print('🔄 เรียกใช้งาน redPaymentIntents()');
//     final response =
//         await postPaymentIntentsState(cusno: cusno, propertyno: propertyno);
//     final respJson = jsonDecode(response!.body);
//     // print(respJson);
//     try {
//       if (response!.body.isEmpty) {
//         print('❌ response.body ว่าง');
//         return;
//       }

//       final root = json.decode(response.body);

//       if (root is! Map<String, dynamic>) {
//         print('❌ รูปแบบ JSON ไม่ใช่ Map<String, dynamic>');
//         return;
//       }

//       final intentsListRaw = root['data'];

//       final intents = (intentsListRaw is List
//               ? intentsListRaw.whereType<Map<String, dynamic>>()
//               : const <Map<String, dynamic>>[])
//           .map((m) => PaymentIntent.fromJson(m))
//           .toList();

//       if (mounted) {
//         setState(() {
//           paymentIntents = intents;
//         });
//       }

//       print('✅ intents loaded: ${intents.length}');
//     } catch (e, stack) {
//       print('❌ Exception parsing payment intents: $e');
//       print('🧭 StackTrace:\n$stack');
//     }
//   }

//   void _selectPayment(int index) {
//     if (index < 0 || index >= _PayMentModels.length) return;

//     var fine_amt = _PayMentModels[index].fine == '1'
//         ? _PayMentModels[index].fine_c == '0.00'
//             ? double.parse(double.parse(_PayMentModels[index].fine_a!)
//                 .toStringAsFixed(2)
//                 .toString())
//             : double.parse((((sum_amt - sum_disamt - dis_sum_Pakan) *
//                         double.parse(_PayMentModels[index].fine_c!)) /
//                     100)
//                 .toStringAsFixed(2)
//                 .toString())
//         : fine_total;

//     setState(() {
//       fine_total = _PayMentModels[index].fine == '1' ? fine_amt : 0.00;
//       select_pay = 1; // Keep list visible
//       gopay = 1; // Show QR section

//       paymentName1 = _PayMentModels[index].ptname;
//       selectedValue = _PayMentModels[index].bno.toString();
//       paymentSer1 = _PayMentModels[index].ser.toString();

//       payment_tser = _PayMentModels[index].ptser.toString();
//       payment_co = _PayMentModels[index].co.toString();
//       payment_img = _PayMentModels[index].img.toString();
//       payment_bname = _PayMentModels[index].bname.toString();
//       payment_bank = _PayMentModels[index].bank.toString();
//       var timrsta = DateTime.now().millisecondsSinceEpoch;

//       // if (_PayMentModels[index].ptser == '8') {
//       //   refpay = 'GEN$timrsta${getRandomString(5)}';
//       // } else {
//       //   if (widget.teNantModel == null) {
//       //     refpay =
//       //         'WR$cid_doc${DateFormat('ddMM').format(datex)}${(datex.year + 543)}';
//       //   } else {
//       //     refpay = 'WR$cid_doc$timrsta';
//       //   }
//       // }

//       Form_payment1.text = (sum_pvat +
//               sum_tran_fine -
//               dis_sum_Pakan -
//               (sum_disamt + sum_disamt_in) +
//               (sum_amt_in + sum_tran_fine_in) +
//               (fine_total))
//           .toStringAsFixed(2)
//           .toString();
//     });
//   }

//   Future<void> initPlatformState() async {
//     String platformVersion;
//     // Platform messages may fail, so we use a try/catch PlatformException.
//     // We also handle the message potentially returning null.
//     try {
//       platformVersion = await _galleryPlugin.getPlatformVersion() ??
//           'Unknown platform version';
//     } on PlatformException {
//       platformVersion = 'Failed to get platform version.';
//     }

//     // If the widget was removed from the tree while the asynchronous platform
//     // message was in flight, we want to discard the reply rather than calling
//     // setState to update our non-existent appearance.
//     if (!mounted) return;

//     setState(() {
//       _platformVersion = platformVersion;
//     });
//   }

//   String getUuid() {
//     var r = Random();
//     return List.generate(36, (i) {
//       if (i == 8 || i == 13 || i == 18 || i == 23) return '-';
//       if (i == 14) return '4';
//       if (i == 19) return ((r.nextInt(4) + 8).toRadixString(16));
//       return r.nextInt(16).toRadixString(16);
//     }).join();
//   }

//   String stringEncryption(String text, String key) {
//     if (key.isEmpty) return text;
//     String chars =
//         'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
//     String res = '';
//     for (int i = 0; i < text.length; i++) {
//       int charIndex = chars.indexOf(text[i]);
//       if (charIndex == -1) {
//         res += text[i];
//         continue;
//       }
//       int keyChar = key.codeUnitAt(i % key.length);
//       int newIndex = (charIndex + keyChar) % chars.length;
//       res += chars[newIndex];
//     }
//     return res;
//   }

//   Future<Null> CreatePaymentItem() async {
//     try {
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (BuildContext context) {
//           return const Center(child: CircularProgressIndicator());
//         },
//       );
//       final prefs = await SharedPreferences.getInstance();
//       final ren = prefs.getString('renTalSer');

//       final ren16Bit = _toU16('$ren').toString();

//       // custno ใช้ตัวเดียว (ทุก invoice ลูกค้าเดียวกัน)
//       final String custnoLocal =
//           _TransModels.isNotEmpty ? '${_TransModels.first.custno ?? ''}' : '';

//       final custno16Bit = _toU16(custnoLocal).toString();
//       final All_lateFee = double.tryParse(Form_fine.text) ?? 0.0;
//       final All_discountAmount = double.tryParse(sum_disamtx.text) ?? 0.0;
//       final All_depositAmount = 0.0;
//       final All_insuranceAmount = 0.0;
//       final All_withholdingAmount = 0.0;

//       // Reset accumulators to prevent double counting on retry
//       setState(() {
//         sum_pvat_in = 0;
//         sum_vat_in = 0;
//         sum_wht_in = 0;
//         sum_amt_in = 0;
//         sum_tran_fine_in = 0;
//         sum_disamt_in = 0;
//       });

//       // ----------
//       List<IntentsInvoiceHistoryModel> _InvoiceHistory = [];
//       List<InvoiceDisPayModel> _InvoiceDisPay = [];
//       List<IntentsContractxFineModel> contractxFine = [];
//       final List<Map<String, dynamic>> invs = [];

//       // 0) Prepare fine data once
//       await read_GC_fine();
//       if (contractxFineModels.isNotEmpty) {
//         await in_Trans_fine_re();
//       }

//       // ---------- dteilData ----------
//       for (var Indexinv = 0; Indexinv < _InvoiceModels.length; Indexinv++) {
//         final rowInv = _InvoiceModels[Indexinv];

//         // Clear history accumulator before fetching for this invoice to avoid duplication
//         setState(() {
//           _InvoiceHistoryModels.clear();
//         });

//         // 1) รอให้โหลด/select เสร็จก่อน
//         await red_Trans_select(Indexinv);

//         // 2) ทำต่อหลัง select เสร็จ (เหมือนใน then)
//         // await in_Trans_dis_inv(rowInv);

//         setState(() {
//           _InvoiceHistory.addAll(_InvoiceHistoryModels);
//           // _InvoiceDisPay.addAll(_InvoiceDisPayModels);
//           contractxFine.addAll(contractxFineModels);
//         });
//         final refnosSelected =
//             _InvoiceHistoryModels.map((m) => m.refno).toSet().join(',');

//         final invFine = await GC_Inv_fine(docno: rowInv.docno.toString());
//         final double fineTotal = (invFine['total'] as num?)?.toDouble() ?? 0.0;

//         final List<Map<String, dynamic>> listFineINV =
//             (invFine['ok'] == true && fineTotal > 0)
//                 ? [
//                     {
//                       "docno": rowInv.docno,
//                       "expser": int.tryParse('${invFine['expser'] ?? 0}') ?? 0,
//                       "expname": invFine['expname'] ?? "ชำระเกินกำหนด",
//                       "no": int.tryParse('${invFine['no'] ?? 0}') ?? 0,
//                       "pvat": (invFine['pvat'] as num?)?.toDouble() ?? 0.0,
//                       "vser": int.tryParse('${invFine['vser'] ?? 0}') ?? 0,
//                       "vtype": invFine['vtype'] ?? '',
//                       "nvat": (invFine['nvat'] as num?)?.toInt() ?? 0,
//                       "vat": (invFine['vat'] as num?)?.toDouble() ?? 0.0,
//                       "wht": (invFine['wht'] as num?)?.toDouble() ?? 0.0,
//                       "total": fineTotal,
//                     }
//                   ]
//                 : [];

//         // ---------- metadata (Use CURRENT invoice history, not accumulated) ----------
//         final List<Map<String, dynamic>> metadataList =
//             _InvoiceHistoryModels.map<Map<String, dynamic>>((b) {
//           final expname = '${b.expname ?? ''}';
//           final totalBill = double.tryParse('${b.total ?? 0}') ?? 0.0;
//           final List<Map<String, dynamic>> listFine = []; // ✅ สำคัญมาก
//           return {
//             'expname': expname,
//             'docno': '${b.refno ?? ''}',
//             'date': (b.date is DateTime)
//                 ? (b.date as DateTime).toIso8601String()
//                 : b.date,
//             'cid': '${b.cid ?? ''}',
//             // 'custno': custno16Bit,
//             // 'st': '${b.st ?? ''}',
//             // 'status': '',
//             'payser': int.tryParse('$paymentSer1') ?? 0,
//             // 'docno_all': refnosSelected,
//             'pri_bill': double.tryParse('${b.pri ?? 0}') ?? 0.0,
//             'pvat_bill': double.tryParse('${b.pvat ?? 0}') ?? 0.0,
//             'vat_bill': double.tryParse('${b.vat ?? 0}') ?? 0.0,
//             'nvat': int.tryParse('${b.nvat ?? 0}') ?? 0.0,
//             'wht_bill': double.tryParse('${b.wht ?? 0}') ?? 0.0,
//             'late_fee': 0,
//             'list_fee': listFine,
//             'total_bill': totalBill,
//             'selected': rowInv.docno,
//           };
//         }).toList();

//         final pvat = _d(rowInv.pvat);
//         final vat = _d(rowInv.vat);
//         final wht = _d(rowInv.wht);
//         final amtnet = (_d(rowInv.amt) + _d(rowInv.vat)) - _d(rowInv.wht);
//         final dis = _d(rowInv.dis);
//         final total = _d(rowInv.amtall);

//         String fineStr = '0';
//         try {
//           final foundFine = invoicePayModels.firstWhere(
//             (m) => m.docno.toString() == rowInv.docno.toString(),
//             orElse: () => InvoicePayModel(fine: '0'),
//           );
//           fineStr = foundFine.fine ?? '0';
//         } catch (e) {
//           fineStr = '0';
//         }
//         final totalfine = _d(fineStr);

//         // ---------- invoices ----------
//         invs.add({
//           "invoice_id": 0,
//           "bill_reference": rowInv.docno,
//           "amount": amtnet,
//           "late_fee": totalfine,
//           "discount_amount": dis,
//           "deposit_amount": 0, // ถ้ามี
//           "insurance_amount": 0, // ถ้ามี
//           "withholding_amount": 0,
//           "total": total,
//           "list_fee": listFineINV, // ✅ ใส่ตรงนี้
//           "metadata": metadataList,
//         });
//       }

//       print({
//         'cusNo': custno16Bit,
//         'propertyNo': ren16Bit,
//         'payedType': "invoice",
//         'payser': int.tryParse('${widget.serPayment}') ?? 0,
//         'typepayser': int.tryParse('${widget.serptPayment}') ?? 0,
//         'requestedAmount':
//             _netPayAmount + _d(sumFineTotalFooter), // ✅ ไม่ใช้ string format
//         'inVoices': invs,
//         'transselect': _InvoiceHistory.map((e) => e.toJson()).toList(),
//       });

//       await PostPaymentIntents(
//         cusNo: custno16Bit,
//         propertyNo: ren16Bit,
//         payedType: "invoice",
//         payser: int.tryParse('$paymentSer1') ?? 0,
//         typepayser: int.tryParse('$payment_ptSer1') ?? 0,
//         requestedAmount:
//             _netPayAmount + _d(sumFineTotalFooter), // ✅ ไม่ใช้ string format
//         lateFee: All_lateFee,
//         discountAmount: All_discountAmount,
//         depositAmount: All_depositAmount,
//         insuranceAmount: All_insuranceAmount,
//         withholdingAmount: All_withholdingAmount,
//         inVoices: invs,
//         transselect: _InvoiceHistory.map((e) => e.toJson()).toList(),
//       );
//       await redPaymentIntents(
//           cusno: custno16Bit, propertyno: ren16Bit.toString() ?? '');
//       await QrGenRef();
//     } catch (e) {
//       print('❌ Error in CreatePaymentItem: $e');
//       if (mounted) {
//         showDialog(
//           context: context,
//           builder: (ctx) => AlertDialog(
//             title: Text('Error', style: TextStyle(fontFamily: Font_.Fonts_T)),
//             content: Text('$e', style: TextStyle(fontFamily: Font_.Fonts_T)),
//             actions: [
//               TextButton(
//                   onPressed: () => Navigator.pop(ctx),
//                   child:
//                       Text('OK', style: TextStyle(fontFamily: Font_.Fonts_T)))
//             ],
//           ),
//         );
//       }
//     } finally {
//       // setState(() {
//       //   selectedPaymentKey = null;
//       //   _expandedInnerGroupKey = null;
//       // });
//       // await _resetToInitialState(targetPage: 1, billAll: false);
//       if (mounted) {
//         Navigator.of(context).pop();
//       }
//     }
//   }

//   Future<void> QrGenRef() async {
//     print("_openQrSheet");
//     String _fmtDT(DateTime? d) =>
//         d == null ? '-' : DateFormat('d-MM-yyyy HH:mm').format(d.toLocal());
//     final String targetUuid = '$numinvoice';

//     final filteredIntents =
//         paymentIntents.where((p) => p.uuid == targetUuid).toList();

//     final firstIntent = filteredIntents.first;

//     final bankId = firstIntent.bankmerchantid ?? 0;
//     final bankItem = _PayMentModels.firstWhere(
//       (p) => p.ser.toString() == '$bankId',
//       orElse: () => PayMentModel(
//         ser: '-',
//         bname: '-',
//         bno: '-',
//       ),
//     );

//     final paybname = bankItem.bname;
//     final paybno = bankItem.bno;
//     final payptser = bankItem.ptser;
//     final payser = bankItem.ser;
//     final payimg = bankItem.img;

//     final intentStatusThai = firstIntent.statusExtended?.statusThai ?? '-';

//     final intentSoftExpireAt = _fmtDT(firstIntent.softExpireAt);
//     final intentCreatedAt = _fmtDT(firstIntent.createdAt);
//     final intentUpdatedAt = _fmtDT(firstIntent.updatedAt);

//     final amountIntents = firstIntent.amount ?? 0;

//     // ✅ ตั้งค่า qr_expiresAt จาก intent ที่มีอยู่ (ถ้ามี) เพื่อป้องกันการสร้าง QR ซ้ำ
//     if (firstIntent.softExpireAt != null) {
//       qr_expiresAt = firstIntent.softExpireAt!.toIso8601String();
//     }

//     // ---------- 0) ถ้ายังไม่มี QR ให้สร้างครั้งแรก ----------
//     final dData = await _DetailsPaymentIntentsReload();

//     // Store uploaded slip data if exists
//     if (dData != null && dData['attaches'] != null) {
//       _uploadedSlipData = dData['attaches'] as Map<String, dynamic>;
//       debugPrint('📎 พบหลักฐานการชำระ: ${_uploadedSlipData!['slip_no']}');
//       debugPrint('📎 ข้อมูล attaches: $_uploadedSlipData');
//     } else {
//       _uploadedSlipData = null;
//       debugPrint('📎 ไม่พบหลักฐานการชำระ');
//     }

//     // ✅ ถ้ามี active_qr_session อยู่แล้ว ให้โหลดข้อมูลมาใช้
//     if (dData != null && dData['active_qr_session'] != null) {
//       debugPrint('🔄 มี active_qr_session → โหลดข้อมูล QR ที่มีอยู่');
//       final qrSession = dData['active_qr_session'] as Map<String, dynamic>;

//       final ref1 = qrSession['ref1'] as String?;
//       final ref2 = qrSession['ref2'] as String?;
//       final ref3 = qrSession['ref3'] as String?;
//       debugPrint('✅ โหลด QR Session: ref1=$ref1, ref2=$ref2, ref3=$ref3');

//       return_qr_refapi1 = ref1;
//       return_qr_refapi2 = ref2;
//       return_qr_refapi3 = ref3;

//       final expiresIso = qrSession['soft_expire_at'] as String?;
//       qr_expiresAt = expiresIso;
//       qr_softExpiresAt = expiresIso;
//     } else {
//       // ไม่มี active session → สร้างใหม่
//       debugPrint('🆕 ยังไม่มี QR → สร้างครั้งแรก');
//       final ok = await _renewQrAndReload();
//       if (!mounted) return;
//       if (!ok) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('สร้าง QR ไม่สำเร็จ กรุณาลองอีกครั้ง'),
//           ),
//         );
//         return;
//       }
//     }
//     // Future<Null> QrGenRef() async {
//     //   DateTime datexQR = DateTime.now();

//     //   var tempInvoicePay = invoicePayModels.map((e) => '${e.docno},').join();
//     //   var tempInvoicePayfine = invoicePayModels.map((e) => '${e.fine},').join();

//     //   setState(() {
//     //     QR_Date15Min = DateFormat('dd-MM-yyyy HH:mm')
//     //         .format(datexQR.add(Duration(minutes: 15)));
//     //     invoicePay = tempInvoicePay;
//     //     invoicePayfine = tempInvoicePayfine;
//     //     if (_InvoiceModels.length == 1) {
//     //       QR_Ref1 = _InvoiceModels[0].docno.toString().replaceAll('-', '');

//     //       DateTime dateObj = DateTime.parse(_InvoiceModels[0].date.toString());
//     //       QR_Ref2 = '${DateFormat('ddMM').format(dateObj)}${datex.year + 543}';

//     //       QR_Ref3 = getRandomString(5);
//     //     } else if (_InvoiceModels.length > 1) {
//     //       var UUIDV4 = getUuid().substring(0, 3);

//     //       var Custno = _InvoiceModels[0].custno.toString().replaceAll('-', '');
//     //       var key = DateTime.now().millisecondsSinceEpoch.toString();
//     //       var encodedUUID = stringEncryption(UUIDV4, key);
//     //       var encodedCustno = stringEncryption(Custno, key);

//     //       QR_Ref1 = encodedCustno + encodedUUID + getRandomString(5);
//     //       QR_Ref2 = '${DateFormat('ddMM').format(datex)}${datex.year + 543}';
//     //       QR_Ref3 = getRandomString(5);
//     //     } else {
//     //       QR_Ref1 = '';
//     //       QR_Ref2 = '';
//     //       QR_Ref3 = '';
//     //     }
//     //     refpay = 'GEN$QR_Ref1$QR_Ref2$QR_Ref3';
//     //     refpayup = refpay;
//     //   });
//     // }

//     // ---------- 1) ตรวจว่า QR หมดอายุหรือไม่ (และขอ Renew ถ้าจำเป็น) ----------
//     final expiresAt =
//         qr_expiresAt != null ? DateTime.tryParse(qr_expiresAt!) : null;
//     final isExpired = expiresAt != null && DateTime.now().isAfter(expiresAt);

//     // ⚠️ ถ้ามีสลิปอัปโหลดแล้ว ไม่ต้อง renew QR เพราะไม่จำเป็นต้องใช้ QR อีกแล้ว
//     final hasUploadedSlip = _uploadedSlipData != null;

//     if (isExpired && !hasUploadedSlip) {
//       debugPrint('❌ QR หมดอายุแล้ว → ขอ renew');
//       final ok =
//           await _renewQrAndReload(); // คุณต้องมีฟังก์ชันนี้ (ดูตัวอย่างในข้อความก่อนหน้า)
//       if (!mounted) return;
//       if (!ok) {
//         // แจ้งผู้ใช้แล้วหยุด
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'ต่ออายุ QR ไม่สำเร็จ กรุณาลองอีกครั้ง',
//             ),
//           ),
//         );
//         return;
//       }
//     } else if (isExpired && hasUploadedSlip) {
//       debugPrint('⚠️ QR หมดอายุ แต่มีสลิปอัปโหลดแล้ว → ข้ามการ renew');
//     }

//     // ---------- 2) ตั้งค่าเวลาหมดอายุ/ตัวช่วยแสดงผล ----------
//     // ใช้ค่าล่าสุด (อาจถูกอัปเดตจาก renew)
//     final String nowExpiresIso = qr_expiresAt?.toString() ?? '';
//     final DateTime expiryLocal =
//         (DateTime.tryParse(nowExpiresIso) ?? DateTime.now()).toLocal();
//     final DateTime expiryUtc = expiryLocal.toUtc();

//     // อายุเต็ม (วินาที) — หากระบบคุณรู้แน่ชัดว่า 5 นาที ให้คง 300
//     // หรือจะคำนวณจาก now→expiry ตอนเปิดก็ได้
//     const int _totalSecs = 300;

//     int secondsUntilExpire() {
//       final nowUtc = DateTime.now().toUtc();
//       final sec = expiryUtc.difference(nowUtc).inSeconds;
//       return sec < 0 ? 0 : sec;
//     }

//     String _hhmmssFromSecs(int secs) {
//       final h = (secs ~/ 3600).toString().padLeft(2, '0');
//       final m = ((secs % 3600) ~/ 60).toString().padLeft(2, '0');
//       final s = (secs % 60).toString().padLeft(2, '0');
//       return '$h:$m:$s';
//     }

//     String _fmtExpireLocal(String? isoUtc) {
//       final d =
//           (isoUtc == null || isoUtc.isEmpty) ? null : DateTime.tryParse(isoUtc);
//       if (d == null) return '-';
//       return DateFormat('d-MM-yyyy HH:mm').format(d.toLocal());
//     }

//     final ref1 = return_qr_refapi1 ?? '-';
//     final ref2 = return_qr_refapi2 ?? '-';
//     final ref3 = return_qr_refapi3 ?? '-';
//     final bno = paybno ?? '-';
//     final bname = paybname ?? '-';
//     final imgUrl = (MyConstant().domain) + (payimg ?? '');
//     final amtStr =
//         nFormat.format(double.tryParse('${amountIntents ?? 0}') ?? 0);
//     final amtRaw =
//         (double.tryParse('${amountIntents ?? 0}') ?? 0).toStringAsFixed(2);
//     final ptser = '${payptser}'; // ช่องทาง
//     final expLbl = _fmtExpireLocal(qr_expiresAt); // แสดงเวลา local

//     // payload สำหรับ QR ตาม ptser
//     debugPrint('💳 Payment Type (ptser): $ptser');
//     debugPrint('💳 ref1: $ref1, ref2: $ref2');
//     debugPrint('💳 Bank No: $bno');
//     debugPrint('💳 Amount Raw: $amtRaw');
//     debugPrint('💳double Amount Raw: ${double.tryParse(amtRaw) ?? 0}');
//     debugPrint('💳 qr_payload: $qr_payload');
//     debugPrint('💳 imgUrl: $imgUrl');

//     final qrData = (ptser == '7')
//         ? qr_payload.toString()
//         : (ptser == '6')
//             ? '|$bno||r$ref1||r$ref2||r${amtRaw.replaceAll('.', '')}'
//             : (ptser == '5')
//                 ? generateQRCode(
//                     promptPayID: bno, amount: double.tryParse(amtRaw) ?? 0)
//                 : (ptser == '2')
//                     ? '${payimg}'
//                     : '';

//     debugPrint('💳 Generated QR Data (length: ${qrData.length}): $qrData');

//     // ---------- 3.5) ตรวจสอบว่า payment type รองรับ QR หรือไม่ ----------
//     if (qrData.isEmpty) {
//       debugPrint(
//           '❌ ไม่สามารถสร้าง QR ได้ - Payment type $ptser ไม่รองรับ QR หรือข้อมูลไม่ครบ');
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             ptser == '1'
//                 ? 'การชำระเงินสดไม่รองรับ QR Code'
//                 : 'ไม่สามารถสร้าง QR Code ได้ ข้อมูลไม่ครบถ้วน',
//           ),
//           backgroundColor: Colors.orange,
//         ),
//       );
//       return;
//     }

//     // ---------- 4) เปิดแผ่น QR ----------
//     final _loadingFuture = Future.delayed(const Duration(seconds: 2));
//     debugPrint('🔵 About to show sticky flexible bottom sheet');
//     debugPrint('QR Data: $qrData');
//     debugPrint('Amount: $amtStr');
//     debugPrint('Bank Name: $bname');
//   }

//   // ----------------------
// // UI layer caller
// // ----------------------
//   int? bankMerchantId;
//   String? ref1 = '', ref2 = '', ref3 = '';
//   Future<void> PostPaymentIntents(
//       {required String cusNo,
//       required String propertyNo,
//       required String payedType,
//       required int payser,
//       required int typepayser,
//       required double requestedAmount,
//       required double lateFee,
//       required double discountAmount,
//       required double depositAmount,
//       required double insuranceAmount,
//       required double withholdingAmount,
//       required List<Map<String, dynamic>> inVoices,
//       required List<Map<String, dynamic>> transselect}) async {
//     debugPrint('🔄 เรียกใช้งาน PostPaymentIntents()');

//     final response = await postPaymentIntents(
//         cusNo: cusNo,
//         propertyNo: propertyNo,
//         payedType: payedType,
//         chanNel: "testerx",
//         requestedAmount: requestedAmount,
//         lateFee: lateFee,
//         discountAmount: discountAmount,
//         depositAmount: depositAmount,
//         insuranceAmount: insuranceAmount,
//         withholdingAmount: withholdingAmount,
//         // createdById: "10101010101010",
//         isAdminCreated: true,
//         bankMerchantId: payser,
//         bankMerchantType: typepayser,
//         descripTion: descripTion.text ?? "",
//         inVoices: inVoices,
//         transSelect: transselect);

//     if (response == null) {
//       debugPrint('❌ ไม่มี response จาก server');
//       return;
//     }

//     try {
//       final jsonRes = json.decode(response.body);
//       debugPrint('🧾 Raw JSON: $jsonRes');

//       // TODO: map ค่าที่ต้องใช้จริงจาก jsonRes
//       setState(() {
//         bankMerchantId = 0;
//         ref1 = '';
//         ref2 = '';
//         ref3 = '';
//       });
//     } catch (e, stack) {
//       debugPrint('❌ Exception parsing payment intents: $e');
//       debugPrint('🧭 StackTrace:\n$stack');
//     }
//   }

//   Future<Null> red_Trans_select(index) async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     var ren = preferences.getString('renTalSer');
//     var user = preferences.getString('ser');
//     var ciddoc = preferences.getString('usercid');
//     var qutser = 1;
//     var docnoin = _InvoiceModels[index].docno;
//     // //print('docnoin>> $docnoin');
//     Map<String, dynamic> queryParams = {
//       'isAdd': 'true',
//       'ren': ren,
//       'user': user,
//       'ciddoc': ciddoc,
//       'docnoin': docnoin,
//     };

//     var uri =
//         Uri.parse('${MyConstant().domain_chao}/GC_bill_invoice_history.php')
//             .replace(queryParameters: queryParams);
//     try {
//       var response = await http.get(uri);

//       var result = json.decode(response.body);

//       if (result.toString() != 'null') {
//         for (var map in result) {
//           InvoiceHistoryModel _InvoiceHistoryModel =
//               InvoiceHistoryModel.fromJson(map);
//           var sum_pvatx = double.parse(_InvoiceHistoryModel.amt!);
//           var sum_vatx = double.parse(_InvoiceHistoryModel.vat!);
//           var sum_whtx = double.parse(_InvoiceHistoryModel.wht!);
//           var sum_amtx = double.parse(_InvoiceHistoryModel.total_t!);
//           var sum_disamtx = double.parse(_InvoiceHistoryModel.disendbill!);
//           var sum_dispx = double.parse(_InvoiceHistoryModel.disendbillper!);
//           setState(() {
//             sum_pvat_in = sum_pvat_in + sum_pvatx;
//             sum_vat_in = sum_vat_in + sum_vatx;
//             sum_wht_in = sum_wht_in + sum_whtx;
//             sum_amt_in = sum_amt_in + sum_amtx;

//             _InvoiceHistoryModels.add(_InvoiceHistoryModel);
//           });
//         }
//       }

//       setState(() {
//         Form_payment1.text = (sum_pvat +
//                 sum_tran_fine -
//                 dis_sum_Pakan -
//                 (sum_disamt + sum_disamt_in) +
//                 (sum_amt_in + sum_tran_fine_in) +
//                 (fine_total))
//             .toStringAsFixed(2)
//             .toString();
//       });
//     } catch (e) {}
//   }

//   Future<Null> in_Trans_fine_re() async {
//     if (invoicePayModels.isNotEmpty) {
//       setState(() {
//         invoicePayModels.clear();
//       });
//     }
//     List<Future<void>> futures =
//         List.generate(_InvoiceModels.length, (index) async {
//       if (contractxFineModels.isNotEmpty) {
//         SharedPreferences preferences = await SharedPreferences.getInstance();
//         var ren = preferences.getString('renTalSer');
//         var user = preferences.getString('ser');
//         var ciddoc = preferences.getString('usercid');
//         var qutser = '1';
//         var tser = _InvoiceModels[index].ser;
//         var tdocno = _InvoiceModels[index].docno;

//         Map<String, dynamic> queryParams = {
//           'isAdd': 'true',
//           'ren': ren,
//           'ciddoc': ciddoc,
//           'qutser': qutser,
//           'tser': tser,
//           'tdocno': tdocno,
//           'user': user,
//         };

//         var uri =
//             Uri.parse('${MyConstant().domain_chao}/In_tran_select_fine_inv.php')
//                 .replace(queryParameters: queryParams);

//         // print('ชำระเกินกำหนด ${_InvoiceModels[index].ser}');
//         // print('ชำระเกินกำหนด ${uri}');
//         try {
//           var response = await http.get(uri);
//           var result = json.decode(response.body);
//           var resultStr = result.toString();
//           var fine_inv = resultStr.indexOf(',');
//           var sum_totalx = 0.0;

//           if (fine_inv != -1) {
//             var fine_Name = resultStr.substring(0, fine_inv);
//             var fine_pri = resultStr.substring(fine_inv + 1);
//             sum_totalx = fine_pri == '' ? 0 : double.parse(fine_pri);
//           }
//           // sum_tran_fine = 0;
//           var in_docnox = _InvoiceModels[index].docno;
//           var in_ser = _InvoiceModels[index].ser;
//           var in_amtall = _InvoiceModels[index].amtall;
//           var in_fine = sum_totalx.toString();
//           var disendbill = _InvoiceModels[index].disendbill.toString();
//           Map<String, dynamic> mapi = Map();
//           mapi['ser'] = in_ser;
//           mapi['docno'] = in_docnox;
//           mapi['amtall'] = in_amtall;
//           mapi['fine'] = in_fine;
//           mapi['discount'] = disendbill;
//           mapi['fine_book'] = in_fine;
//           mapi['discount_book'] = disendbill;

//           InvoicePayModel invoicePayModel = InvoicePayModel.fromJson(mapi);

//           if (mounted) {
//             setState(() {
//               invoicePayModels.add(invoicePayModel);
//               // sum_tran_fine_in = sum_tran_fine_in + sum_totalx;
//               sum_tran_fine_in = sum_tran_fine_in + sum_totalx;
//             });
//           }

//           // print('ชำระเกินกำหนดser ${invoicePayModels.map((e) => e.ser)}');
//         } catch (e) {}
//       } else {
//         Map<String, dynamic> mapi = Map();
//         mapi['ser'] = _InvoiceModels[index].ser;
//         mapi['docno'] = _InvoiceModels[index].docno;
//         mapi['amtall'] = _InvoiceModels[index].amtall;
//         mapi['fine'] = '0';
//         mapi['discount'] = _InvoiceModels[index].disendbill;
//         mapi['fine_book'] = '0';
//         mapi['discount_book'] = _InvoiceModels[index].disendbill;
//         InvoicePayModel invoicePayModel = InvoicePayModel.fromJson(mapi);
//         if (mounted) {
//           setState(() {
//             invoicePayModels.add(invoicePayModel);
//           });
//         }
//       }
//     });

//     await Future.wait(futures);
//     // Populate the fallback source string from the freshly loaded models
//     String newPayFine = '';
//     for (var m in invoicePayModels) {
//       newPayFine += '${m.fine_book ?? '0'},';
//     }
//     setState(() {
//       invoicePayfine = newPayFine;
//     });
//     setState(() {
//       Form_payment1.text = (double.parse(Form_payment1.text) + sum_tran_fine_in)
//           .toStringAsFixed(2)
//           .toString();
//     });
//   }

//   Future<Null> in_Trans_fine(index) async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     var ren = preferences.getString('renTalSer');
//     var user = preferences.getString('ser');
//     var ciddoc = preferences.getString('usercid');
//     var qutser = 1;

//     var tser = _TransBillModels[index].ser;
//     var tdocno = _TransBillModels[index].docno;

//     // //print('object $tdocno');
//     Map<String, dynamic> queryParams = {
//       'isAdd': 'true',
//       'ren': ren,
//       'ciddoc': ciddoc,
//       'qutser': qutser.toString(),
//       'tser': tser,
//       'tdocno': tdocno,
//       'user': user,
//       'pos': '1',
//     };

//     var uri = Uri.parse('${MyConstant().domain_chao}/In_tran_select_fine.php')
//         .replace(queryParameters: queryParams);
//     try {
//       var response = await http.get(uri);

//       var result = json.decode(response.body);
//       // //print('rr>>>>>> $result');
//       if (result.toString() == 'true') {
//         // setState(() {
//         //   red_Trans_select2();
//         // });
//         //print('rrrrrrrrrrrrrr');
//       } else if (result.toString() == 'false') {
//         //  setState(() {
//         //   red_Trans_select2();
//         // });
//         //print('rrrrrrrrrrrrrrfalse');
//       } else {}
//     } catch (e) {}
//     // setState(() {
//     //   red_Trans_select2_fin();
//     // });
//   }

//   Future<Null> read_GC_fine() async {
//     setState(() {
//       contractxFineModels.clear();
//     });
//     SharedPreferences preferences = await SharedPreferences.getInstance();

//     var ren = preferences.getString('renTalSer');
//     // var zone = preferences.getString('zoneSer');
//     if (widget.teNantModel == null) {
//       var ciddoc = preferences.getString('usercid');
//       var qutser = '1';

//       Map<String, dynamic> queryParams = {
//         'isAdd': 'true',
//         'ren': ren,
//         'ciddoc': ciddoc,
//         'qutser': qutser,
//       };

//       var uri = Uri.parse('${MyConstant().domain_chao}/GC_fine.php')
//           .replace(queryParameters: queryParams);

//       try {
//         var response = await http.get(uri);

//         var result = json.decode(response.body);
//         // //print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--------------  $result');

//         if (result.toString() != 'true') {
//           for (var map in result) {
//             ContractxFineModel contractxFineModel =
//                 ContractxFineModel.fromJson(map);

//             setState(() {
//               contractxFineModels.add(contractxFineModel);
//             });
//           }
//         }
//       } catch (e) {}

//       // //print('contractxFineModels>>> ${contractxFineModels.length}');
//     } else {
//       List<Future<void>> futures = widget.teNantModel!.map((e) async {
//         var ciddoc = e.cid;
//         var qutser = '1';
//         Map<String, dynamic> queryParams = {
//           'isAdd': 'true',
//           'ren': ren,
//           'ciddoc': ciddoc,
//           'qutser': qutser,
//         };

//         var uri = Uri.parse('${MyConstant().domain_chao}/GC_fine.php')
//             .replace(queryParameters: queryParams);

//         try {
//           var response = await http.get(uri);

//           var result = json.decode(response.body);
//           // //print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--------------  $result');

//           if (result.toString() != 'true') {
//             for (var map in result) {
//               ContractxFineModel contractxFineModel =
//                   ContractxFineModel.fromJson(map);

//               if (mounted) {
//                 setState(() {
//                   contractxFineModels.add(contractxFineModel);
//                 });
//               }
//             }
//           }
//         } catch (e) {}
//       }).toList();

//       await Future.wait(futures);
//     }
//     //print('contractxFineModels>>> ${contractxFineModels.length}');
//   }

//   Future<Null> red_Invoice() async {
//     setState(() {
//       _InvoiceModels.clear();
//       // invoicePayModels.clear();
//       sum_disamt_in = 0;
//       in_amt = 0;
//       sum_pvat_in = 0;
//       sum_vat_in = 0;
//       sum_wht_in = 0;
//       sum_amt_in = 0;
//       sum_tran_fine_in = 0;
//     });
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     var ren = preferences.getString('renTalSer');
//     var qutser_ = preferences.getString('qutser');
//     if (widget.teNantModel == null) {
//       ////////////////------------------------------------------------------>
//       var ciddoc_ = preferences.getString('usercid');
//       ////////////////------------------------------------------------------>

//       Map<String, dynamic> queryParams = {
//         'isAdd': 'true',
//         'ren': ren,
//         'ciddoc': ciddoc_,
//         'qutser': qutser_,
//       };

//       var uri = Uri.parse('${MyConstant().domain_chao}/GC_bill_invoice.php')
//           .replace(queryParameters: queryParams);
//       // print(uri);
//       try {
//         var response = await http.get(uri);

//         var result = json.decode(response.body);

//         if (result.toString() != 'null') {
//           // _InvoiceModels.clear();
//           for (var map in result) {
//             InvoiceModel _InvoiceModel = InvoiceModel.fromJson(map);
//             final targetUuid = (_InvoiceModel.docno ?? '').trim();

//             final intents = paymentIntents
//                 .where((p) => p.invoices
//                     .any((b) => (b.billReference ?? '').trim() == targetUuid))
//                 .toList();
//             if (intents.isEmpty) {
//               if (intents.isEmpty) {
//                 print('NO MATCH target=$targetUuid');
//               } else {
//                 print(
//                     'MATCH target=$targetUuid -> intentNos=${intents.map((e) => e.bankmerchantid).toList()}');
//               }
//               if (_InvoiceModel.payser.toString() == '${widget.serPayment}') {
//                 var in_amtx = double.parse(_InvoiceModel.amtall!);
//                 var in_docnox = _InvoiceModel.docno;
//                 var in_ser = _InvoiceModel.ser;
//                 var in_amtall = _InvoiceModel.amtall;
//                 var disendbill = double.parse(_InvoiceModel.disendbill!);
//                 // print('>>>_InvoiceModel>>>>> ${_InvoiceModel.refapi}');
//                 setState(() {
//                   sum_disamt_in = sum_disamt_in + disendbill;
//                   in_amt = in_amt + in_amtx;

//                   _InvoiceModels.add(_InvoiceModel);
//                 });
//               }
//             }
//           }
//         }
//       } catch (e) {}
//     } else {
//       ////////////////------------------------------------------------------>
//       List<Future<void>> futures = widget.teNantModel!.map((e) async {
//         var ciddoc_ = e.cid;
//         Map<String, dynamic> queryParams = {
//           'isAdd': 'true',
//           'ren': ren,
//           'ciddoc': ciddoc_,
//           'qutser': qutser_,
//         };

//         var uri = Uri.parse('${MyConstant().domain_chao}/GC_bill_invoice.php')
//             .replace(queryParameters: queryParams);

//         try {
//           var response = await http.get(uri);
//           var result = json.decode(response.body);

//           if (result.toString() != 'null') {
//             for (var map in result) {
//               InvoiceModel _InvoiceModel = InvoiceModel.fromJson(map);
//               final targetUuid = (_InvoiceModel.docno ?? '').trim();

//               final intents = paymentIntents
//                   .where((p) => p.invoices
//                       .any((b) => (b.billReference ?? '').trim() == targetUuid))
//                   .toList();
//               if (intents.isEmpty) {
//                 if (intents.isEmpty) {
//                   print('NO MATCH target=$targetUuid');
//                 } else {
//                   print(
//                       'MATCH target=$targetUuid -> intentNos=${intents.map((e) => e.bankmerchantid).toList()}');
//                 }
//                 if (_InvoiceModel.payser.toString() == '${widget.serPayment}') {
//                   var in_amtx = double.parse(_InvoiceModel.amtall!);
//                   var disendbill = double.parse(_InvoiceModel.disendbill!);

//                   if (mounted) {
//                     setState(() {
//                       sum_disamt_in = sum_disamt_in + disendbill;
//                       in_amt = in_amt + in_amtx;
//                       _InvoiceModels.add(_InvoiceModel);
//                     });
//                   }
//                 }
//               }
//             }
//           }
//         } catch (e) {}
//       }).toList();

//       await Future.wait(futures);
//     }
//   }

//   Future<Null> read_data() async {
//     if (teNantModels.length != 0) {
//       setState(() {
//         teNantModels.clear();
//       });
//     }
//     ////////////////------------------------------------------------------>
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     var ren = preferences.getString('renTalSer');
//     var ciddoc_ = preferences.getString('usercid');
//     var qutser_ = preferences.getString('qutser');
//     ////////////////------------------------------------------------------>

//     String url =
//         '${MyConstant().domain}/GC_tenantlookAS.php?isAdd=true&ren=$ren&ciddoc=$ciddoc_&qutser=$qutser_';
//     try {
//       var response = await http.get(Uri.parse(url));

//       var result = json.decode(response.body);
//       // //print(result);
//       if (result != null) {
//         for (var map in result) {
//           TeNantModel teNantModel = TeNantModel.fromJson(map);
//           setState(() {
//             teNantModels.add(teNantModel);

//             Form_nameshop = teNantModel.sname.toString();
//             Form_typeshop = teNantModel.stype.toString();
//             Form_bussshop = teNantModel.cname.toString();
//             Form_bussscontact = teNantModel.attn.toString();
//             Form_address = teNantModel.addr.toString();
//             Form_tel = teNantModel.tel.toString();
//             Form_email = teNantModel.email.toString();
//             Form_tax =
//                 teNantModel.tax == null ? "-" : teNantModel.tax.toString();
//             Form_area = teNantModel.area.toString();
//             Form_ln = teNantModel.area_c.toString();

//             Form_sdate = DateFormat('dd-MM-yyyy')
//                 .format(DateTime.parse('${teNantModel.sdate} 00:00:00'))
//                 .toString();
//             Form_ldate = DateFormat('dd-MM-yyyy')
//                 .format(DateTime.parse('${teNantModel.ldate} 00:00:00'))
//                 .toString();
//             Form_period = teNantModel.period.toString();
//             Form_rtname = teNantModel.rtname.toString();
//             Form_docno = teNantModel.docno.toString();
//             Form_zn = teNantModel.zn.toString();
//             Form_aser = teNantModel.aser.toString();
//             Form_qty = teNantModel.qty.toString();
//             Form_qty = teNantModel.qty.toString();
//           });
//         }
//       }
//     } catch (e) {}
//   }

//   Future<Null> checkPreferance() async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     var ciddoc_ = preferences.getString('usercid');
//     var qutser_ = preferences.getString('qutser');
//     var custno = preferences.getString('custno');
//     var Message_ = preferences.getString('Message_ToUser');
//     var ren = preferences.getString('renTalSer');
//     setState(() {
//       if (widget.teNantModel == null) {
//         cid_doc = ciddoc_;
//         cid_docqr = ciddoc_;
//       } else {
//         cid_doc = custno;
//         cid_docqr = widget.teNantModel![0].cid;
//       }
//       cid_ren = ren;
//     });
//   }

//   String randomString = '';
//   generateRandomString() {
//     final random = Random();
//     const characters = 'abcdefghijklmnopqrstuvwxyz0123456789';
//     final length = 4; // Change this to the desired length

//     for (int i = 0; i < length; i++) {
//       final index = random.nextInt(characters.length);
//       randomString += characters[index];
//     }

//     // return randomString;
//   }

//   Future<Null> red_payMent() async {
//     if (_PayMentModels.length != 0) {
//       setState(() {
//         _PayMentModels.clear();
//       });
//     }
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     var ren = preferences.getString('renTalSer');

//     String url =
//         '${MyConstant().domain_chao}/GC_payMent.php?isAdd=true&ren=$ren';
//     try {
//       var response = await http.get(Uri.parse(url));

//       var result = json.decode(response.body);
//       // //print(result);
//       if (result.toString() != 'null') {
//         for (var map in result) {
//           PayMentModel _PayMentModel = PayMentModel.fromJson(map);
//           var autox = _PayMentModel.auto;
//           var serx = _PayMentModel.ser;
//           var ptnamex = _PayMentModel.ptname;
//           // if (_PayMentModel.ser_payweb.toString() == '1') {
//           if (_PayMentModel.ser.toString() == '${widget.serPayment}') {
//             setState(() {
//               _PayMentModels.add(_PayMentModel);
//             });
//           } else {}
//         }
//       }
//     } catch (e) {}
//   }

//   Future<Null> read_GC_rental() async {
//     if (renTalModels.isNotEmpty) {
//       renTalModels.clear();
//     }

//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     var ren = preferences.getString('renTalSer');
//     //https://dzentric.com/chao_perty/chao_api/GC_rental_setring.php?isAdd=true&ren=50
//     String url =
//         '${MyConstant().domain}/GC_rental_setring.php?isAdd=true&ren=$ren';
//     //renTal_name = preferences.getString('renTalName');
//     try {
//       var response = await http.get(Uri.parse(url));

//       var result = json.decode(response.body);
//       // //print(result);
//       if (result != null) {
//         for (var map in result) {
//           RenTalModel renTalModel = RenTalModel.fromJson(map);
//           var rtnamex = renTalModel.rtname!.trim();
//           var typexs = renTalModel.type!.trim();
//           var typexx = renTalModel.typex!.trim();
//           var bill_namex = renTalModel.bill_name!.trim();
//           var bill_addrx = renTalModel.bill_addr!.trim();
//           var bill_taxx = renTalModel.bill_tax!.trim();
//           var bill_telx = renTalModel.bill_tel!.trim();
//           var bill_emailx = renTalModel.bill_email!.trim();
//           var bill_defaultx = renTalModel.bill_default;
//           var bill_tserx = renTalModel.tser;
//           var name = renTalModel.pn!.trim();
//           var foderx = renTalModel.dbn;
//           setState(() {
//             foder = foderx;
//             rtname = rtnamex;
//             type = typexs;
//             typex = typexx;
//             renname = name;
//             bill_name = bill_namex;
//             bill_addr = bill_addrx;
//             bill_tax = bill_taxx;
//             bill_tel = bill_telx;
//             bill_email = bill_emailx;
//             bill_default = bill_defaultx;
//             bill_tser = bill_tserx;
//             imglogo_ =
//                 '${MyConstant().domain}/files/$foder/logo/${renTalModel.imglogo!.trim()}';
//             renTalModels.add(renTalModel);
//             if (bill_defaultx == 'P') {
//               bills_name_ = 'บิลธรรมดา';
//             } else {
//               bills_name_ = 'ใบกำกับภาษี';
//             }
//           });
//         }
//       } else {}
//     } catch (e) {}
//   }

// ////////////////////////////////>
//   String? base64_Slip, fileName_Slip;
//   var extension_;
//   var file_;
//   Future<void> uploadFile_Slip() async {
//     final imagePicker = ImagePicker();
//     final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

//     if (pickedFile == null) {
//       return;
//     } else {
//       var imageBytes = await pickedFile.readAsBytes();

//       try {
//         img.Image? originalImage = img.decodeImage(imageBytes);
//         if (originalImage != null) {
//           if (originalImage.width > 800 || originalImage.height > 800) {
//             img.Image resizedImage = img.copyResize(originalImage,
//                 width: originalImage.width > originalImage.height ? 800 : null,
//                 height:
//                     originalImage.height >= originalImage.width ? 800 : null);
//             imageBytes = Uint8List.fromList(img.encodePng(resizedImage));
//           }
//         }
//       } catch (e) {
//         print('Error resizing image: $e');
//       }

//       // 3. Encode the image as a base64 string
//       final base64Image = base64Encode(imageBytes);
//       setState(() {
//         base64_Slip = base64Image;
//         _uploadedSlipData = imageBytes;
//       });
//       // //print(base64_Slip);
//       setState(() {
//         extension_ = 'png';
//         // file_ = file;
//       });
//     }
//   }

//   Future<void> OKuploadFile_Slip(newValuePDFimg) async {
//     String Path_foder = 'slip';
//     String dateTimeNow = DateTime.now().toString();
//     String date = DateFormat('ddMMyyyy')
//         .format(DateTime.parse('${dateTimeNow}'))
//         .toString();
//     final dateTimeNow2 = DateTime.now().toUtc().add(const Duration(hours: 7));
//     final formatter2 = DateFormat('HHmmss');
//     final formattedTime2 = formatter2.format(dateTimeNow2);
//     String Time_ = formattedTime2.toString();

//     ////////////////------------------------------------------------------>
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     var ciddoc_ = widget.teNantModel == null
//         ? preferences.getString('usercid')
//         : preferences.getString('custno');
//     var qutser_ = preferences.getString('qutser');
//     ////////////////------------------------------------------------------>
//     var fileName_Slip_ = 'slip_${ciddoc_}_${date}_$Time_';
//     setState(() {
//       fileName_Slip = 'slip_${ciddoc_}_${date}_$Time_.$extension_';
//     });
//     try {
//       final url =
//           '${MyConstant().domain_chao}/File_uploadSlip_NewEdit.php?name=$fileName_Slip&Foder=$foder&extension=$extension_';

//       final response = await http.post(
//         Uri.parse(url),
//         body: {
//           'image': base64_Slip,
//           'Foder': foder,
//           'name': fileName_Slip,
//           'ex': extension_.toString()
//         },
//       );

//       if (response.statusCode == 200) {
//         // //print('Image uploaded successfully');
//       } else {
//         // //print('Image upload failed');
//       }
//     } catch (e) {
//       // //print('Error during image processing: $e');
//     }
//   }

//   ///----------------------------------------------->
//   double _safeDouble(dynamic value) {
//     if (value == null) return 0.0;
//     if (value is double) return value;
//     if (value is int) return value.toDouble();
//     if (value is String) {
//       if (value.isEmpty) return 0.0;
//       return double.tryParse(value.replaceAll(',', '')) ?? 0.0;
//     }
//     return 0.0;
//   }

//   String _safeString(dynamic value) {
//     if (value == null) return '';
//     return value.toString();
//   }

//   Widget _howToBox() {
//     Widget step(int i, String t) => Padding(
//           padding: const EdgeInsets.symmetric(vertical: 4),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 width: 26,
//                 height: 26,
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                   color: Colors.indigo.withOpacity(.08),
//                   borderRadius: BorderRadius.circular(999),
//                   border: Border.all(
//                       color: Colors.indigo.withOpacity(.25), width: .7),
//                 ),
//                 child: Text('$i',
//                     style: TextStyle(
//                         fontFamily: Font_.Fonts_T,
//                         fontWeight: FontWeight.w900,
//                         color: Colors.indigo.shade700)),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                   child: Text(t,
//                       style: const TextStyle(
//                           fontFamily: Font_.Fonts_T, fontSize: 13.5))),
//             ],
//           ),
//         );

//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.black12, width: .5),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(.04),
//               blurRadius: 12,
//               offset: const Offset(0, 6))
//         ],
//       ),
//       padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(widget.cuslang == 'EN' ? 'Payment method' : 'วิธีชำระเงิน',
//               style: const TextStyle(
//                   fontFamily: Font_.Fonts_T,
//                   fontWeight: FontWeight.w800,
//                   fontSize: 15)),
//           const SizedBox(height: 10),
//           step(
//               1,
//               widget.cuslang == 'EN'
//                   ? 'Verify that the "information" is correct.'
//                   : 'ตรวจสอบ “ข้อมูล”  ว่าถูกต้องหรือไม่'),
//           step(
//               2,
//               widget.cuslang == 'EN'
//                   ? 'Press “Save” the PromptPay QR code image above to your mobile phone.'
//                   : 'กด “บันทึก” รูป QR พร้อมเพย์ด้านบนลงในโทรศัพท์มือถือของคุณ'),
//           step(
//               3,
//               widget.cuslang == 'EN'
//                   ? 'Open your banking application to make a payment.'
//                   : 'เปิดแอปพลิเคชันธนาคารที่คุณมี เพื่อชำระเงิน'),
//           step(
//               4,
//               widget.cuslang == 'EN'
//                   ? 'Go to the "Scan/Scan to Pay" menu and press "Image" to select the saved QR image.'
//                   : 'ไปที่เมนู “สแกน/สแกนจ่าย” แล้วกด “รูปภาพ” เพื่อเลือกรูป QR ที่บันทึกไว้'),
//         ],
//       ),
//     );
//   }

//   void showIOSSaveOverlay(Uint8List bytes, {required bool isEN}) {
//     // remove old overlay if exists
//     html.document.getElementById('qr_save_overlay')?.remove();

//     final base64 = base64Encode(bytes);
//     final dataUrl = 'data:image/png;base64,$base64';

//     final overlay = html.DivElement()
//       ..id = 'qr_save_overlay'
//       ..style.position = 'fixed'
//       ..style.left = '0'
//       ..style.top = '0'
//       ..style.right = '0'
//       ..style.bottom = '0'
//       ..style.backgroundColor = 'rgba(0,0,0,0.9)'
//       ..style.display = 'flex'
//       ..style.flexDirection = 'column'
//       ..style.alignItems = 'center'
//       ..style.justifyContent = 'center'
//       ..style.zIndex = '2147483647' // highest
//       ..style.pointerEvents = 'auto';

//     final img = html.ImageElement(src: dataUrl)
//       ..style.maxWidth = '92vw'
//       ..style.maxHeight = '72vh'
//       ..style.borderRadius = '12px'
//       ..style.pointerEvents = 'auto'
//       ..style.userSelect = 'none';

//     final hint = html.DivElement()
//       ..text = isEN ? 'Long-press the image to Save' : 'กดค้างที่รูปเพื่อบันทึก'
//       ..style.color = '#fff'
//       ..style.fontSize = '16px'
//       ..style.marginTop = '14px'
//       ..style.textAlign = 'center'
//       ..style.padding = '0 16px'
//       ..style.fontFamily =
//           '-apple-system,BlinkMacSystemFont,Segoe UI,Roboto,Arial';

//     final closeBtn = html.ButtonElement()
//       ..text = isEN ? 'Close' : 'ปิด'
//       ..style.marginTop = '14px'
//       ..style.padding = '10px 18px'
//       ..style.borderRadius = '10px'
//       ..style.border = 'none'
//       ..style.fontSize = '16px'
//       ..style.cursor = 'pointer';

//     closeBtn.onClick.listen((_) => overlay.remove());

//     // สำคัญ: อย่าใส่ overlay.onClick ปิดทิ้ง (มันจะไปรบกวน long-press)
//     // และกันไม่ให้ click บนรูปไป trigger อะไร
//     img.onClick.listen((e) => e.stopPropagation());
//     img.onContextMenu.listen((e) {
//       // ปล่อยให้ iOS แสดงเมนู save เอง (ไม่ preventDefault)
//       e.stopPropagation();
//     });

//     overlay.children.addAll([img, hint, closeBtn]);
//     html.document.body?.append(overlay);
//   }

//   Widget _QRBox() {
//     double width = MediaQuery.of(context).size.width;
//     bool isMobile = width < 480;
//     bool isDesktop = width >= 900;
//     double qrSize = isDesktop ? 200 : 160;

//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//       child: Column(
//         children: [
//           Card(
//             color: Colors.white,
//             elevation: 4,
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//             clipBehavior: Clip.antiAlias,
//             child: Column(
//               children: [
//                 // QR Code Area
//                 RepaintBoundary(
//                   key: qrBlockKey,
//                   child: Container(
//                     padding: const EdgeInsets.all(8),
//                     child: Column(
//                       children: [
//                         if (payment_tser == '2') ...[
//                           ClipRRect(
//                             borderRadius: BorderRadius.circular(6),
//                             child: (_expireDialogShown == true)
//                                 ? Container(
//                                     width: double.infinity,
//                                     height: qrSize + qrSize,
//                                     color: Colors.grey.shade200,
//                                     alignment: Alignment.center,
//                                     child: Column(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         Icon(Icons.timer_off,
//                                             color: Colors.redAccent, size: 40),
//                                         SizedBox(height: 8),
//                                         Text(
//                                           widget.cuslang == 'EN'
//                                               ? 'The QR code has expired.'
//                                               : 'QR หมดอายุแล้ว QR ',
//                                           style: TextStyle(
//                                             fontFamily: Font_.Fonts_T,
//                                             color: Colors.black54,
//                                             fontSize: 13,
//                                           ),
//                                         ),
//                                         Padding(
//                                           padding: const EdgeInsets.all(8.0),
//                                           child: InkWell(
//                                             onTap: _renewQrAndReload,
//                                             child: Container(
//                                               padding: const EdgeInsets.all(6),
//                                               decoration: BoxDecoration(
//                                                 color: Colors.black,
//                                                 borderRadius:
//                                                     BorderRadius.circular(10),
//                                                 border: Border.all(
//                                                     color: Colors.grey,
//                                                     width: .7),
//                                               ),
//                                               child: Text(
//                                                 widget.cuslang == 'EN'
//                                                     ? 'Generate another QR code for payment.'
//                                                     : 'สร้าง QR รับชำระอีกครั้ง',
//                                                 style: TextStyle(
//                                                   fontFamily: Font_.Fonts_T,
//                                                   color: Colors.white,
//                                                   fontSize: 13,
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         )
//                                       ],
//                                     ),
//                                   )
//                                 : (_isExporting)
//                                     ? Container(
//                                         width: double.infinity,
//                                         height: qrSize + qrSize,
//                                         color: Colors.white, // Safe placeholder
//                                       )
//                                     : Image.network(
//                                         payment_img!.isNotEmpty &&
//                                                 payment_img != '' &&
//                                                 payment_img != 'null'
//                                             ? '${MyConstant().domain_chao}/files/$foder/payment/$payment_img'
//                                             : '${MyConstant().domain_chao}/Awaitdownload/imagenot.png',
//                                         width: double.infinity,
//                                         height: qrSize + qrSize,
//                                         fit: BoxFit.contain,
//                                         loadingBuilder:
//                                             (context, child, progress) {
//                                           if (progress == null) {
//                                             return child;
//                                           }
//                                           return SizedBox(
//                                             height: qrSize + qrSize,
//                                             child: Center(
//                                               child: CircularProgressIndicator(
//                                                 value: progress
//                                                             .expectedTotalBytes !=
//                                                         null
//                                                     ? progress
//                                                             .cumulativeBytesLoaded /
//                                                         (progress
//                                                                 .expectedTotalBytes ??
//                                                             1)
//                                                     : null,
//                                               ),
//                                             ),
//                                           );
//                                         },
//                                         errorBuilder:
//                                             (context, error, stackTrace) {
//                                           return Container(
//                                             width: double.infinity,
//                                             height: qrSize + qrSize,
//                                             color: Colors.grey.shade200,
//                                             alignment: Alignment.center,
//                                             child: Column(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.center,
//                                               children: [
//                                                 Icon(Icons.error_outline,
//                                                     color: Colors.redAccent,
//                                                     size: 40),
//                                                 SizedBox(height: 8),
//                                                 Text(
//                                                   widget.cuslang == 'EN'
//                                                       ? 'Unable to load QR'
//                                                       : 'ไม่สามารถโหลด QR ได้',
//                                                   style: TextStyle(
//                                                     fontFamily: Font_.Fonts_T,
//                                                     color: Colors.black54,
//                                                     fontSize: 13,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           );
//                                         },
//                                       ),
//                           ),
//                         ] else if (payment_tser == '7' ||
//                             payment_tser == '6' ||
//                             payment_tser == '5') ...[
//                           Image.asset(
//                             'images/thai_qr_payment.png',
//                             width: double.infinity,
//                             fit: BoxFit.contain,
//                           ),
//                           SizedBox(height: isMobile ? 4 : 4),
//                           (_expireDialogShown == true)
//                               ? Container(
//                                   width: double.infinity,
//                                   height: qrSize + qrSize,
//                                   color: Colors.grey.shade200,
//                                   alignment: Alignment.center,
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Icon(Icons.timer_off,
//                                           color: Colors.redAccent, size: 40),
//                                       SizedBox(height: 8),
//                                       Text(
//                                         widget.cuslang == 'EN'
//                                             ? 'The QR code has expired.'
//                                             : 'QR หมดอายุแล้ว QR ',
//                                         style: TextStyle(
//                                           fontFamily: Font_.Fonts_T,
//                                           color: Colors.black54,
//                                           fontSize: 13,
//                                         ),
//                                       ),
//                                       Padding(
//                                         padding: const EdgeInsets.all(8.0),
//                                         child: InkWell(
//                                           onTap: _renewQrAndReload,
//                                           child: Container(
//                                             padding: const EdgeInsets.all(6),
//                                             decoration: BoxDecoration(
//                                               color: Colors.black,
//                                               borderRadius:
//                                                   BorderRadius.circular(10),
//                                               border: Border.all(
//                                                   color: Colors.grey,
//                                                   width: .7),
//                                             ),
//                                             child: Text(
//                                               widget.cuslang == 'EN'
//                                                   ? 'Generate another QR code for payment.'
//                                                   : 'สร้าง QR รับชำระอีกครั้ง',
//                                               style: TextStyle(
//                                                 fontFamily: Font_.Fonts_T,
//                                                 color: Colors.white,
//                                                 fontSize: 13,
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       )
//                                     ],
//                                   ),
//                                 )
//                               : payment_tser == '6'
//                                   ? (_isExporting && _exportQrBytes != null)
//                                       ? Image.memory(_exportQrBytes!,
//                                           width: 150,
//                                           height: 150,
//                                           fit: BoxFit.contain)
//                                       : PrettyQr(
//                                           // typeNumber: 3,
//                                           image: Image.asset(
//                                             'images/icon_thaiqr.png',
//                                           ).image,
//                                           size: 150,
//                                           data:
//                                               '|$selectedValue\r$QR_Ref1\r$QR_Ref2\r${Form_payment1.text.replaceAll('.', '').toString()}\r',
//                                           errorCorrectLevel:
//                                               QrErrorCorrectLevel.M,
//                                           roundEdges: true,
//                                         )
//                                   : (payment_tser == '5' || payment_tser == '6')
//                                       ? (_isExporting && _exportQrBytes != null)
//                                           ? Image.memory(_exportQrBytes!,
//                                               width: 150,
//                                               height: 150,
//                                               fit: BoxFit.contain)
//                                           : PrettyQr(
//                                               size: 150,
//                                               // size: qrSize,
//                                               data: generateQRCode(
//                                                   promptPayID: "$selectedValue",
//                                                   amount: double.parse(
//                                                       Form_payment1.text)),
//                                               image: const AssetImage(
//                                                   'images/icon_thaiqr.png'),
//                                               errorCorrectLevel:
//                                                   QrErrorCorrectLevel.M,
//                                               roundEdges: true,
//                                             )
//                                       : Container(
//                                           width: double.infinity,
//                                           height: qrSize + qrSize,
//                                           color: Colors.grey.shade200,
//                                           alignment: Alignment.center,
//                                           child: Column(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.center,
//                                             children: [
//                                               Icon(Icons.error_outline,
//                                                   color: Colors.redAccent,
//                                                   size: 40),
//                                               SizedBox(height: 8),
//                                               Text(
//                                                 widget.cuslang == 'EN'
//                                                     ? 'Unable to load QR'
//                                                     : 'ไม่สามารถโหลด QR ได้',
//                                                 style: TextStyle(
//                                                   fontFamily: Font_.Fonts_T,
//                                                   color: Colors.black54,
//                                                   fontSize: 13,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                         ] else ...[
//                           Container(
//                             width: double.infinity,
//                             height: qrSize + qrSize,
//                             color: Colors.grey.shade200,
//                             alignment: Alignment.center,
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(Icons.error_outline,
//                                     color: Colors.redAccent, size: 40),
//                                 SizedBox(height: 8),
//                                 Text(
//                                   widget.cuslang == 'EN'
//                                       ? 'Unable to load QR'
//                                       : 'ไม่สามารถโหลด QR ได้',
//                                   style: TextStyle(
//                                     fontFamily: Font_.Fonts_T,
//                                     color: Colors.black54,
//                                     fontSize: 13,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                         SizedBox(height: isMobile ? 4 : 6),
//                         Text(
//                           '฿${nFormat.format(double.parse(Form_payment1.text))}',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontFamily: Font_.Fonts_T,
//                             fontWeight: FontWeight.w700,
//                             fontSize: isDesktop ? 18 : 16,
//                             color: Colors.red.shade900,
//                           ),
//                         ),
//                         const SizedBox(height: 3),
//                         Text(
//                           '$payment_bname',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontFamily: Font_.Fonts_T,
//                             fontWeight: FontWeight.w700,
//                             fontSize: isDesktop ? 16 : 14,
//                             color: Colors.black.withOpacity(.65),
//                           ),
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               '$selectedValue',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 fontFamily: Font_.Fonts_T,
//                                 fontWeight: FontWeight.w700,
//                                 fontSize: isDesktop ? 16 : 14,
//                                 color: Colors.black.withOpacity(.65),
//                               ),
//                             ),
//                             InkWell(
//                                 onTap: () {
//                                   Clipboard.setData(new ClipboardData(
//                                       text: '$selectedValue'));
//                                   Fluttertoast.showToast(
//                                       timeInSecForIosWeb: 3,
//                                       msg: widget.cuslang == 'EN'
//                                           ? 'Copy : $selectedValue'
//                                           : 'คัดลอก : $selectedValue',
//                                       backgroundColor: Colors.black,
//                                       textColor: Colors.white,
//                                       webPosition: "center",
//                                       webBgColor: "#000000",
//                                       toastLength: Toast.LENGTH_SHORT);
//                                 },
//                                 child: Icon(
//                                   Icons.content_copy_outlined,
//                                   size: 14,
//                                 )),
//                           ],
//                         ),
//                         Divider(height: 2, color: Colors.grey.shade600),
//                         // const SizedBox(height: 2),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             CircleAvatar(
//                               radius: 10,
//                               child: Image.asset(
//                                 'images/Icon-chao.png',
//                                 width: double.infinity,
//                                 fit: BoxFit.contain,
//                               ),
//                             ),
//                             const SizedBox(width: 2),
//                             Text(
//                               widget.cuslang == 'EN'
//                                   ? 'Pay within $QR_Date15Min  |  Ref: $QR_Ref1'
//                                   : 'ชำระภายใน $QR_Date15Min  |  Ref: $QR_Ref1',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 fontFamily: Font_.Fonts_T,
//                                 fontWeight: FontWeight.w700,
//                                 fontSize: isDesktop ? 13 : 11,
//                                 color: Colors.black.withOpacity(.65),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 // Divider(),

//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 4.0, vertical: 4.0),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: OutlinedButton.icon(
//                           onPressed: () async {
//                             try {
//                               RenderRepaintBoundary boundary =
//                                   qrBlockKey.currentContext!.findRenderObject()
//                                       as RenderRepaintBoundary;
//                               ui.Image image =
//                                   await boundary.toImage(pixelRatio: 3.0);
//                               ByteData? byteData = await image.toByteData(
//                                   format: ui.ImageByteFormat.png);
//                               Uint8List bytes = byteData!.buffer.asUint8List();

//                               if (kIsWeb) {
//                                 // Check if Web Share API is available (works on mobile browsers)
//                                 if (html.window.navigator.share != null) {
//                                   try {
//                                     html.Blob blob =
//                                         html.Blob([bytes], 'image/png');
//                                     html.File file = html.File(
//                                         [blob],
//                                         'payment_qr.png',
//                                         {'type': 'image/png'});

//                                     await html.window.navigator.share({
//                                       'files': [file],
//                                       'title': 'Payment QR Code',
//                                     });

//                                     Fluttertoast.showToast(
//                                         timeInSecForIosWeb: 3,
//                                         msg: widget.cuslang == 'EN'
//                                             ? "Shared successfully"
//                                             : "แชร์สำเร็จ",
//                                         backgroundColor: Colors.black,
//                                         textColor: Colors.white,
//                                         webPosition: "center",
//                                         webBgColor: "#000000",
//                                         toastLength: Toast.LENGTH_SHORT);
//                                   } catch (e) {
//                                     print('Web Share error: $e');
//                                     Fluttertoast.showToast(
//                                         timeInSecForIosWeb: 3,
//                                         msg: widget.cuslang == 'EN'
//                                             ? "Share cancelled or not supported"
//                                             : "ยกเลิกการแชร์หรือไม่รองรับ",
//                                         backgroundColor: Colors.black,
//                                         textColor: Colors.white,
//                                         webPosition: "center",
//                                         webBgColor: "#000000",
//                                         toastLength: Toast.LENGTH_SHORT);
//                                   }
//                                 } else {
//                                   Fluttertoast.showToast(
//                                       timeInSecForIosWeb: 3,
//                                       msg: widget.cuslang == 'EN'
//                                           ? "Share not supported on this browser"
//                                           : "เบราว์เซอร์นี้ไม่รองรับการแชร์",
//                                       backgroundColor: Colors.black,
//                                       textColor: Colors.white,
//                                       webPosition: "center",
//                                       webBgColor: "#000000",
//                                       toastLength: Toast.LENGTH_SHORT);
//                                 }
//                               } else {
//                                 final directory = await getTemporaryDirectory();
//                                 final file =
//                                     File('${directory.path}/payment_qr.png');
//                                 await file.writeAsBytes(bytes);
//                                 await Share.shareXFiles([XFile(file.path)],
//                                     text: 'Payment QR Code');
//                               }
//                             } catch (e) {
//                               print(e);
//                               Fluttertoast.showToast(
//                                   timeInSecForIosWeb: 3,
//                                   msg: "Failed to share",
//                                   backgroundColor: Colors.black,
//                                   textColor: Colors.white,
//                                   webPosition: "center",
//                                   webBgColor: "#000000",
//                                   toastLength: Toast.LENGTH_SHORT);
//                             }
//                           },
//                           icon: Icon(Icons.share, color: Colors.black),
//                           label: Text(
//                               widget.cuslang == 'EN'
//                                   ? 'Share QR'
//                                   : 'แบ่งปัน QR',
//                               style: TextStyle(color: Colors.black)),
//                           style: OutlinedButton.styleFrom(
//                             padding: EdgeInsets.symmetric(vertical: 4),
//                             side: BorderSide(color: Colors.grey.shade300),
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8)),
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 12),
//                       Expanded(
//                         child: OutlinedButton.icon(
//                           onPressed: () async {
//                             // Save Logic
//                             try {
//                               // Special handling for payment_tser == '2' (network image QR)
//                               // Avoid toImage() issues on iOS Safari by using direct URL
//                               if (kIsWeb &&
//                                   payment_tser == '2' &&
//                                   payment_img != null &&
//                                   payment_img!.isNotEmpty &&
//                                   payment_img != 'null') {
//                                 final imgUrl =
//                                     '${MyConstant().domain_chao}/files/$foder/payment/$payment_img';

//                                 String userAgent = html
//                                     .window.navigator.userAgent
//                                     .toLowerCase();
//                                 bool isIOS = userAgent.contains('iphone') ||
//                                     userAgent.contains('ipad') ||
//                                     userAgent.contains('ipod');

//                                 if (isIOS) {
//                                   // iOS: Show overlay with network image
//                                   final overlay = html.DivElement()
//                                     ..style.position = 'fixed'
//                                     ..style.left = '0'
//                                     ..style.top = '0'
//                                     ..style.right = '0'
//                                     ..style.bottom = '0'
//                                     ..style.backgroundColor = 'rgba(0,0,0,0.85)'
//                                     ..style.display = 'flex'
//                                     ..style.flexDirection = 'column'
//                                     ..style.alignItems = 'center'
//                                     ..style.justifyContent = 'center'
//                                     ..style.zIndex = '999999';

//                                   final img = html.ImageElement(src: imgUrl)
//                                     ..style.maxWidth = '95vw'
//                                     ..style.maxHeight = '75vh'
//                                     ..style.borderRadius = '12px';

//                                   final hint = html.DivElement()
//                                     ..text = widget.cuslang == 'EN'
//                                         ? 'Long-press the image to Save'
//                                         : 'กดค้างที่รูปเพื่อบันทึก'
//                                     ..style.color = '#fff'
//                                     ..style.fontSize = '16px'
//                                     ..style.marginTop = '16px'
//                                     ..style.textAlign = 'center';

//                                   final closeBtn = html.ButtonElement()
//                                     ..text =
//                                         widget.cuslang == 'EN' ? 'Close' : 'ปิด'
//                                     ..style.marginTop = '14px'
//                                     ..style.padding = '10px 16px'
//                                     ..style.borderRadius = '10px'
//                                     ..style.border = 'none';

//                                   closeBtn.onClick
//                                       .listen((_) => overlay.remove());
//                                   // Don't add overlay.onClick - it interferes with long-press
//                                   img.onClick
//                                       .listen((e) => e.stopPropagation());

//                                   overlay.children
//                                       .addAll([img, hint, closeBtn]);
//                                   html.document.body?.append(overlay);
//                                 } else {
//                                   // Desktop/Android: Open in new tab
//                                   html.window.open(imgUrl, '_blank');
//                                   Fluttertoast.showToast(
//                                       msg: widget.cuslang == 'EN'
//                                           ? "Opening QR image"
//                                           : "เปิดรูป QR",
//                                       backgroundColor: Colors.black,
//                                       textColor: Colors.white,
//                                       webPosition: "center",
//                                       webBgColor: "#000000",
//                                       toastLength: Toast.LENGTH_SHORT);
//                                 }
//                                 return;
//                               }

//                               // Special handling for PrettyQR (payment_tser '5' and '6')
//                               // Generate PNG directly from QR data (avoid toImage() issues on iOS Safari)
//                               if (kIsWeb &&
//                                   (payment_tser == '5' ||
//                                       payment_tser == '6')) {
//                                 final ua = html.window.navigator.userAgent
//                                     .toLowerCase();
//                                 final isIOS = ua.contains('iphone') ||
//                                     ua.contains('ipad') ||
//                                     ua.contains('ipod');

//                                 // FINAL SAFE MODE: Direct CPU Generation (No Text)
//                                 // Avoids all Capture/Canvas issues on iOS Web.
//                                 try {
//                                   // Gen QR Data
//                                   final qrData = (payment_tser == '6')
//                                       ? '|$selectedValue\r$QR_Ref1\r$QR_Ref2\r${Form_payment1.text.replaceAll('.', '')}\r'
//                                       : generateQRCode(
//                                           promptPayID: "$selectedValue",
//                                           amount: double.parse(
//                                               Form_payment1.text.isEmpty
//                                                   ? "0"
//                                                   : Form_payment1.text));

//                                   // Gen Image (CPU) - 100% Safe (QR + Logos)
//                                   // Note: Text drawing disabled to avoid errors.
//                                   final cpuQrBytes =
//                                       await buildQrPngWithCenterLogo(
//                                     data: qrData,
//                                     assetLogoPath: 'images/icon_thaiqr.png',
//                                     sizePx: 800,
//                                     bottomText:
//                                         '฿${nFormat.format(double.parse(Form_payment1.text))}',
//                                     bottomname: '$payment_bname',
//                                     bottombankno: '$selectedValue',
//                                     bottomRef: widget.cuslang == 'EN'
//                                         ? 'Pay within $QR_Date15Min  |  Ref: $QR_Ref1'
//                                         : 'ชำระภายใน $QR_Date15Min  |  Ref: $QR_Ref1',
//                                   );

//                                   // Save
//                                   if (isIOS) {
//                                     showIOSSaveOverlay(cpuQrBytes,
//                                         isEN: widget.cuslang == 'EN');
//                                   } else {
//                                     final blob =
//                                         html.Blob([cpuQrBytes], 'image/png');
//                                     final url =
//                                         html.Url.createObjectUrlFromBlob(blob);
//                                     final a = html.AnchorElement(href: url)
//                                       ..download = "payment_qr.png";
//                                     html.document.body?.append(a);
//                                     a.click();
//                                     a.remove();
//                                     html.Url.revokeObjectUrl(url);
//                                   }

//                                   // Notify User
//                                   if (isIOS) {
//                                     Fluttertoast.showToast(
//                                         msg: widget.cuslang == 'EN'
//                                             ? "Saved (Text not supported on iOS Web)"
//                                             : "บันทึกแล้ว (ไม่รองรับข้อความบน iOS Web)",
//                                         toastLength: Toast.LENGTH_LONG);
//                                   }
//                                 } catch (e) {
//                                   debugPrint("CPU SAVE FAIL: $e");
//                                   Fluttertoast.showToast(msg: "Save Error: $e");
//                                 } finally {
//                                   // Cleanup
//                                   if (mounted) {
//                                     setState(() {
//                                       _isExporting = false;
//                                       _exportQrBytes = null;
//                                     });
//                                   }
//                                 }
//                                 return;
//                               }

//                               // Fallback: For other cases, use screenshot with iOS-safe approach
//                               // Wait for frames to ensure fully rendered (critical for iOS Safari)
//                               await Future.delayed(
//                                   const Duration(milliseconds: 120));
//                               await WidgetsBinding.instance.endOfFrame;
//                               await Future.delayed(
//                                   const Duration(milliseconds: 50));

//                               RenderRepaintBoundary boundary =
//                                   qrBlockKey.currentContext!.findRenderObject()
//                                       as RenderRepaintBoundary;

//                               // Use pixelRatio 2.0 on iOS to reduce memory usage and avoid crashes
//                               double pixelRatio = 3.0;
//                               if (kIsWeb) {
//                                 String ua = html.window.navigator.userAgent
//                                     .toLowerCase();
//                                 bool isiOS = ua.contains('iphone') ||
//                                     ua.contains('ipad') ||
//                                     ua.contains('ipod');
//                                 if (isiOS) {
//                                   pixelRatio = 2.0;
//                                 }
//                               }

//                               ui.Image image = await boundary.toImage(
//                                   pixelRatio: pixelRatio);
//                               ByteData? byteData = await image.toByteData(
//                                   format: ui.ImageByteFormat.png);

//                               // Critical null check for iOS Safari
//                               if (byteData == null) {
//                                 throw Exception(
//                                     'Failed to convert QR to image (byteData is null)');
//                               }

//                               Uint8List bytes = byteData.buffer.asUint8List();

//                               if (kIsWeb) {
//                                 // Detect platform from user agent
//                                 String userAgent = html
//                                     .window.navigator.userAgent
//                                     .toLowerCase();
//                                 bool isIOS = userAgent.contains('iphone') ||
//                                     userAgent.contains('ipad') ||
//                                     userAgent.contains('ipod');
//                                 bool isMobileWeb = isIOS ||
//                                     userAgent.contains('android') ||
//                                     userAgent.contains('mobile');

//                                 // iOS: Use overlay to avoid popup blocker
//                                 if (isIOS) {
//                                   showIOSSaveOverlay(bytes,
//                                       isEN: widget.cuslang == 'EN');
//                                   return;
//                                 }

//                                 // Android/Other Mobile: Use data URL (same as iOS for consistent behavior)
//                                 if (isMobileWeb) {
//                                   String base64 = base64Encode(bytes);
//                                   String dataUrl =
//                                       'data:image/png;base64,$base64';
//                                   html.window.open(dataUrl, '_blank');
//                                   Fluttertoast.showToast(
//                                       timeInSecForIosWeb: 5,
//                                       msg: widget.cuslang == 'EN'
//                                           ? "Long press image to save"
//                                           : "กดค้างที่รูปเพื่อบันทึก",
//                                       backgroundColor: Colors.black,
//                                       textColor: Colors.white,
//                                       webPosition: "center",
//                                       webBgColor: "#000000",
//                                       toastLength: Toast.LENGTH_LONG);
//                                   return;
//                                 }

//                                 // Desktop web: Direct download using blob URL with download attribute
//                                 html.Blob blob =
//                                     html.Blob([bytes], 'image/png');
//                                 String url =
//                                     html.Url.createObjectUrlFromBlob(blob);
//                                 html.AnchorElement(href: url)
//                                   ..setAttribute("download", "payment_qr.png")
//                                   ..click();
//                                 html.Url.revokeObjectUrl(url);
//                                 Fluttertoast.showToast(
//                                     timeInSecForIosWeb: 3,
//                                     msg: widget.cuslang == 'EN'
//                                         ? "QR Code downloaded"
//                                         : "ดาวน์โหลด QR แล้ว",
//                                     backgroundColor: Colors.black,
//                                     textColor: Colors.white,
//                                     webPosition: "center",
//                                     webBgColor: "#000000",
//                                     toastLength: Toast.LENGTH_SHORT);
//                                 return;
//                               } else if (Platform.isWindows) {
//                                 String? outputFile =
//                                     await FlutterFileDialog.saveFile(
//                                   params: SaveFileDialogParams(
//                                     data: bytes,
//                                     fileName: "payment_qr.png",
//                                   ),
//                                 );
//                                 if (outputFile != null) {
//                                   Fluttertoast.showToast(
//                                       timeInSecForIosWeb: 3,
//                                       msg: widget.cuslang == 'EN'
//                                           ? "Saved QR Code"
//                                           : "บันทึกเรียบร้อย",
//                                       backgroundColor: Colors.black,
//                                       textColor: Colors.white,
//                                       webPosition: "center",
//                                       webBgColor: "#000000",
//                                       toastLength: Toast.LENGTH_SHORT);
//                                 }
//                               } else {
//                                 var status = await Permission.storage.status;
//                                 if (!status.isGranted) {
//                                   status = await Permission.storage.request();
//                                 }

//                                 if (status.isGranted) {
//                                   final result =
//                                       await ImageGallerySaver.saveImage(bytes,
//                                           name: "payment_qr");
//                                   if (result['isSuccess'] == true) {
//                                     Fluttertoast.showToast(
//                                         timeInSecForIosWeb: 3,
//                                         msg: widget.cuslang == 'EN'
//                                             ? "Saved to Gallery"
//                                             : "บันทึกในอัลบั้มแล้ว",
//                                         backgroundColor: Colors.black,
//                                         textColor: Colors.white,
//                                         webPosition: "center",
//                                         webBgColor: "#000000",
//                                         toastLength: Toast.LENGTH_SHORT);
//                                   } else {
//                                     Fluttertoast.showToast(
//                                         timeInSecForIosWeb: 3,
//                                         msg: widget.cuslang == 'EN'
//                                             ? "Failed to save"
//                                             : "บันทึกในอัลบั้มไม่สำเร็จ",
//                                         backgroundColor: Colors.black,
//                                         textColor: Colors.white,
//                                         webPosition: "center",
//                                         webBgColor: "#000000",
//                                         toastLength: Toast.LENGTH_SHORT);
//                                   }
//                                 } else {
//                                   // Permission denied
//                                   Fluttertoast.showToast(
//                                       timeInSecForIosWeb: 3,
//                                       msg: widget.cuslang == 'EN'
//                                           ? "Permission denied"
//                                           : "ไม่ได้รับอนุญาตให้เข้าถึงอัลบั้ม",
//                                       backgroundColor: Colors.black,
//                                       textColor: Colors.white,
//                                       webPosition: "center",
//                                       webBgColor: "#000000",
//                                       toastLength: Toast.LENGTH_SHORT);
//                                 }
//                               }
//                             } catch (e, st) {
//                               debugPrint("SAVE ERROR: $e");
//                               debugPrint("$st");

//                               if (kIsWeb) {
//                                 Fluttertoast.showToast(
//                                     timeInSecForIosWeb: 4,
//                                     msg: widget.cuslang == 'EN'
//                                         ? "Failed to generate image (Safari iOS)"
//                                         : "สร้างรูปไม่สำเร็จ (Safari iOS)",
//                                     backgroundColor: Colors.black,
//                                     textColor: Colors.white,
//                                     webPosition: "center",
//                                     webBgColor: "#000000",
//                                     toastLength: Toast.LENGTH_SHORT);
//                               } else {
//                                 Fluttertoast.showToast(
//                                     timeInSecForIosWeb: 3,
//                                     msg: widget.cuslang == 'EN'
//                                         ? "Failed to save"
//                                         : "บันทึกในอัลบั้มไม่สำเร็จ",
//                                     backgroundColor: Colors.black,
//                                     textColor: Colors.white,
//                                     toastLength: Toast.LENGTH_SHORT);
//                               }
//                             }
//                           },
//                           icon: Icon(Icons.download, color: Colors.black),
//                           label: Text(
//                               widget.cuslang == 'EN' ? 'Save QR' : 'บันทึก QR',
//                               style: TextStyle(color: Colors.black)),
//                           style: OutlinedButton.styleFrom(
//                             padding: EdgeInsets.symmetric(vertical: 4),
//                             side: BorderSide(color: Colors.grey.shade300),
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8)),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 SizedBox(height: 2),

//                 // Footer: Trouble Paying?
//                 // Container(
//                 //   width: double.infinity,
//                 //   margin: EdgeInsets.all(8),
//                 //   decoration: BoxDecoration(
//                 //     color: Colors.grey.shade100,
//                 //     borderRadius: BorderRadius.circular(8),
//                 //   ),
//                 //   child: ListTile(
//                 //     title: Text(
//                 //         widget.cuslang == 'EN'
//                 //             ? "Trouble with payment?"
//                 //             : "มีปัญหาในการชำระเงินใช่ไหม?",
//                 //         style: TextStyle(
//                 //             fontWeight: FontWeight.bold, fontSize: 14)),
//                 //     trailing: Icon(Icons.chevron_right),
//                 //     onTap: () {
//                 //       print("Open slip upload");

//                 //       Fluttertoast.showToast(msg: "Please upload slip below");
//                 //     },
//                 //   ),
//                 // ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _groupTile() {
//     Widget chip(String text, Color bg, Color fg) => Container(
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//           decoration: BoxDecoration(
//             color: bg,
//             borderRadius: BorderRadius.circular(999),
//             border: Border.all(color: fg.withOpacity(.25), width: .7),
//           ),
//           child: Text(
//             text,
//             style: TextStyle(
//               fontFamily: Font_.Fonts_T,
//               fontWeight: FontWeight.w700,
//               fontSize: 11.5,
//               color: fg,
//             ),
//           ),
//         );

//     Widget _sectionHeader(String titleEn, String titleTh) {
//       return Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         decoration: BoxDecoration(
//           color: Colors.grey.shade100,
//           border: Border(
//             top: BorderSide(color: Colors.grey.shade300, width: 1),
//             bottom: BorderSide(color: Colors.grey.shade300, width: 1),
//           ),
//         ),
//         child: Text(
//           widget.cuslang == 'EN' ? titleEn : titleTh,
//           style: const TextStyle(
//             fontSize: 13,
//             fontWeight: FontWeight.bold,
//             color: Colors.black54,
//             fontFamily: Font_.Fonts_T,
//           ),
//         ),
//       );
//     }

//     final bank =
//         _PayMentModels.isNotEmpty ? (_PayMentModels[0].bank ?? '') : '';
//     final bno = _PayMentModels.isNotEmpty ? (_PayMentModels[0].bno ?? '') : '';
//     final bname =
//         _PayMentModels.isNotEmpty ? (_PayMentModels[0].bname ?? '') : '';
//     Widget _invoiceItem({
//       required int index,
//       required String docNo,
//       required double amount,
//       required String date,
//       required bool isSelected,
//       required VoidCallback onTap,
//       double fine = 0,
//       bool showCheckbox = true,
//     }) {
//       return Container(
//         // margin: const EdgeInsets.only(bottom: 12, left: 2, right: 2),
//         // decoration: BoxDecoration(
//         //   color: Colors.white,
//         //   borderRadius: BorderRadius.circular(12),
//         //   border: isSelected
//         //       ? Border.all(color: Colors.green.shade500, width: 1.5)
//         //       : Border.all(color: Colors.grey.shade200, width: 1),
//         //   boxShadow: [
//         //     BoxShadow(
//         //       color: Colors.grey.withOpacity(0.08),
//         //       spreadRadius: 0,
//         //       blurRadius: 4,
//         //       offset: const Offset(0, 2),
//         //     ),
//         //   ],
//         // ),
//         margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//         // padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//         decoration: BoxDecoration(
//           color: Colors.grey.shade50,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.black12, width: .4),
//         ),
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(12),
//           child: Padding(
//             padding: const EdgeInsets.all(6),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Top Row: DocNo + Amount
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     SizedBox(
//                       child: Padding(
//                         padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
//                         child: Icon(
//                           isSelected
//                               ? Icons.check_circle_outline
//                               : Icons.highlight_off_outlined,
//                           color: isSelected ? Colors.green : Colors.grey,
//                           size: 18,
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       child: Text(
//                         docNo,
//                         style: const TextStyle(
//                           fontFamily: Font_.Fonts_T,
//                           fontWeight: FontWeight.w700,
//                           fontSize: 15,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     ),
//                     Text(
//                       '${nFormat.format(amount)}',
//                       style: const TextStyle(
//                         fontFamily: Font_.Fonts_T,
//                         fontWeight: FontWeight.w700,
//                         fontSize: 15,
//                         color: Colors.black87,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 10),
//                 // Divider line if desired, or just spacing
//                 // Bottom Info Row
//                 Row(
//                   children: [
//                     // Contract / Ref Logic (Placeholder with Icon)
//                     // Row(
//                     //   children: [
//                     //     Icon(Icons.business,
//                     //         size: 14, color: Colors.grey.shade500),
//                     //     const SizedBox(width: 4),
//                     //     Text(
//                     //       '10029-11-2025', // Placeholder for contract ID or dynamic field
//                     //       style: TextStyle(
//                     //         fontFamily: Font_.Fonts_T,
//                     //         fontSize: 12.5,
//                     //         color: Colors.grey.shade600,
//                     //       ),
//                     //     ),
//                     //   ],
//                     // ),
//                     // const SizedBox(width: 12),
//                     // Date Logic
//                     Row(
//                       children: [
//                         Icon(Icons.calendar_today,
//                             size: 14, color: Colors.grey.shade500),
//                         const SizedBox(width: 4),
//                         Text(
//                           DateFormat('dd-MM-yyyy').format(
//                               DateTime.tryParse(date) ?? DateTime.now()),
//                           style: TextStyle(
//                             fontFamily: Font_.Fonts_T,
//                             fontSize: 12.5,
//                             color: Colors.grey.shade600,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const Spacer(),
//                     // Status Tag
//                     if (fine > 0)
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 10, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: Colors.red.shade50,
//                           borderRadius: BorderRadius.circular(20),
//                           border: Border.all(color: Colors.red.shade100),
//                         ),
//                         child: Text(
//                           '${widget.cuslang == 'EN' ? 'Fine' : 'ค่าปรับ'}: ${nFormat.format(fine)}',
//                           style: TextStyle(
//                             fontFamily: Font_.Fonts_T,
//                             fontSize: 11,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.red.shade700,
//                           ),
//                         ),
//                       )
//                     else
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 10, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFE0F2F1), // Light teal
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Text(
//                           widget.cuslang == 'EN'
//                               ? 'Current Contract'
//                               : 'สัญญาปัจจุบัน',
//                           style: TextStyle(
//                             fontFamily: Font_.Fonts_T,
//                             fontSize: 11,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.teal.shade800,
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }

//     final vatBill = sum_vat + sum_vat_in;
//     final whtBill = sum_wht + sum_wht_in;
//     final totalBill = sum_pvat +
//         sum_tran_fine -
//         dis_sum_Pakan -
//         (sum_disamt + sum_disamt_in) +
//         (sum_amt_in + sum_tran_fine_in) +
//         (fine_total);

//     final bankInfo = bankCodeMap[bank];
//     final logoFile = bankInfo?['logo'];
//     final bankCode = bankInfo?['code'];
//     final bankEn = bankInfo?['en'];

//     return Card(
//       elevation: 0.4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//       child: Theme(
//         data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
//         child: ExpansionTile(
//           tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
//           childrenPadding: const EdgeInsets.only(left: 6, right: 6, bottom: 12),
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//           onExpansionChanged: (value) async {
//             setState(() {
//               invoicePay = invoicePayModels.map((e) => '${e.docno},').join();
//               invoicePayfine = invoicePayModels.map((e) => '${e.fine},').join();
//             });
//             // print(
//             //     '<<<${double.parse(Form_payment1.text).toStringAsFixed(2)}<<< ${nFormat.format((sum_pvat + sum_tran_fine) - (sum_disamt + sum_disamt_in) + (sum_amt_in + sum_tran_fine_in))}');
//           },
//           title: Row(
//             children: [
//               CircleAvatar(
//                 radius: 18,
//                 backgroundColor: Colors.white,
//                 child: logoFile != null
//                     ? Image.asset(
//                         'assets/images/LogoBank/$logoFile',
//                         height: 26,
//                         errorBuilder: (_, __, ___) => const Icon(
//                             Icons.account_balance,
//                             size: 20,
//                             color: Colors.grey),
//                       )
//                     : const Icon(Icons.account_balance,
//                         size: 20, color: Colors.grey),
//               ),
//               const SizedBox(width: 6),
//               Expanded(
//                 child: Text(
//                     widget.cuslang == 'EN'
//                         ? (bankEn ?? bank) + ' (${bankCode ?? ""})'
//                         : bank + ' (${bankCode ?? ""})',
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                         fontFamily: Font_.Fonts_T,
//                         fontWeight: FontWeight.w700,
//                         fontSize: 15.5)),
//               ),
//               const SizedBox(width: 4),
//               chip(widget.cuslang == 'EN' ? 'Bills' : 'ใบแจ้งหนี้',
//                   Colors.indigo.withOpacity(.08), Colors.indigo.shade700),
//             ],
//           ),
//           subtitle: Padding(
//             padding: const EdgeInsets.only(top: 4),
//             child: Wrap(
//               spacing: 12,
//               runSpacing: 6,
//               crossAxisAlignment: WrapCrossAlignment.center,
//               children: [
//                 if (bno.isNotEmpty)
//                   Row(mainAxisSize: MainAxisSize.min, children: [
//                     const Icon(Icons.account_balance,
//                         size: 15, color: Colors.black54),
//                     const SizedBox(width: 6),
//                     Text(bno,
//                         style: const TextStyle(
//                             fontFamily: Font_.Fonts_T, fontSize: 12.5)),
//                   ]),
//                 if (bname.isNotEmpty)
//                   Row(mainAxisSize: MainAxisSize.min, children: [
//                     const Icon(Icons.note, size: 15, color: Colors.black54),
//                     const SizedBox(width: 6),
//                     Text(bname,
//                         style: const TextStyle(
//                             fontFamily: Font_.Fonts_T, fontSize: 12.5)),
//                   ]),
//                 // 1. Fine
//                 if ((sum_tran_fine + sum_tran_fine_in) > 0)
//                   Row(mainAxisSize: MainAxisSize.min, children: [
//                     const Icon(Icons.warning_amber_rounded,
//                         size: 15, color: Colors.red),
//                     const SizedBox(width: 6),
//                     Text(
//                         '${widget.cuslang == "EN" ? "Fine" : "ค่าปรับ"}: ${nFormat.format(sum_tran_fine + sum_tran_fine_in)}',
//                         style: const TextStyle(
//                             fontFamily: Font_.Fonts_T,
//                             fontSize: 12.5,
//                             color: Colors.red)),
//                   ]),
//                 // 2. Service Charge
//                 if ((sum_pvat + sum_pvat_in) > 0)
//                   Row(mainAxisSize: MainAxisSize.min, children: [
//                     const Icon(Icons.room_service,
//                         size: 15, color: Colors.black54),
//                     const SizedBox(width: 6),
//                     Text(
//                         '${widget.cuslang == "EN" ? "Service Chg" : "ค่าบริการ"}: ${nFormat.format(sum_pvat + sum_pvat_in)}',
//                         style: const TextStyle(
//                             fontFamily: Font_.Fonts_T, fontSize: 12.5)),
//                   ]),
//                 // 3. Total (Baht) - (PVAT + Fine)
//                 Row(mainAxisSize: MainAxisSize.min, children: [
//                   const Icon(Icons.monetization_on_outlined,
//                       size: 15, color: Colors.black54),
//                   const SizedBox(width: 6),
//                   Text(
//                       '${widget.cuslang == "EN" ? "Total(Baht)" : "รวม(บาท)"}: ${nFormat.format((sum_pvat + sum_tran_fine) + (sum_pvat_in + sum_tran_fine_in))}',
//                       style: const TextStyle(
//                           fontFamily: Font_.Fonts_T, fontSize: 12.5)),
//                 ]),
//                 // 4. VAT
//                 Row(mainAxisSize: MainAxisSize.min, children: [
//                   const Icon(Icons.percent, size: 15, color: Colors.black54),
//                   const SizedBox(width: 6),
//                   Text('VAT: ${fmtMoney(vatBill)}',
//                       style: const TextStyle(
//                           fontFamily: Font_.Fonts_T, fontSize: 12.5)),
//                 ]),
//                 // 5. WHT
//                 Row(mainAxisSize: MainAxisSize.min, children: [
//                   const Icon(Icons.money_off_csred_outlined,
//                       size: 15, color: Colors.black54),
//                   const SizedBox(width: 6),
//                   Text('WHT: ${fmtInt(whtBill)}',
//                       style: const TextStyle(
//                           fontFamily: Font_.Fonts_T, fontSize: 12.5)),
//                 ]),
//                 // 6. Discount
//                 if ((sum_disamt + sum_disamt_in) > 0)
//                   Row(mainAxisSize: MainAxisSize.min, children: [
//                     const Icon(Icons.discount, size: 15, color: Colors.green),
//                     const SizedBox(width: 6),
//                     Text(
//                         '${widget.cuslang == "EN" ? "Discount" : "ส่วนลด"}: ${nFormat.format(sum_disamt + sum_disamt_in)}',
//                         style: const TextStyle(
//                             fontFamily: Font_.Fonts_T,
//                             fontSize: 12.5,
//                             color: Colors.green)),
//                   ]),
//                 // 7. Total (Net)
//                 // Row(mainAxisSize: MainAxisSize.min, children: [
//                 //   const Icon(Icons.calculate, size: 15, color: Colors.black54),
//                 //   const SizedBox(width: 6),
//                 //   Text(
//                 //       '${widget.cuslang == "EN" ? "Net Total" : "ยอดรวม"}: ${nFormat.format((sum_pvat + sum_tran_fine) - (sum_disamt + sum_disamt_in) + (sum_amt_in + sum_tran_fine_in))}',
//                 //       style: const TextStyle(
//                 //           fontFamily: Font_.Fonts_T, fontSize: 12.5)),
//                 // ]),
//                 // 8. Charge (Fee)
//                 if (fine_total > 0)
//                   Row(mainAxisSize: MainAxisSize.min, children: [
//                     const Icon(Icons.add_card, size: 15, color: Colors.red),
//                     const SizedBox(width: 6),
//                     Text(
//                         '${widget.cuslang == "EN" ? "Charge" : "ค่าธรรมเนียม"}: ${nFormat.format(fine_total)}',
//                         style: const TextStyle(
//                             fontFamily: Font_.Fonts_T,
//                             fontSize: 12.5,
//                             color: Colors.red)),
//                   ]),
//                 // 9. Payment Amount (Final)
//                 Row(mainAxisSize: MainAxisSize.min, children: [
//                   const Icon(Icons.payments, size: 15, color: Colors.black87),
//                   const SizedBox(width: 6),
//                   Text(
//                       '${widget.cuslang == "EN" ? "Payment Amount" : "ยอดชำระสุทธิ"}: ${fmtMoney(totalBill)}',
//                       style: const TextStyle(
//                           fontFamily: Font_.Fonts_T,
//                           fontSize: 13.5,
//                           fontWeight: FontWeight.w800)),
//                 ]),
//               ],
//             ),
//           ),
//           children: [
//             // Divider
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16),
//               child: Divider(thickness: 0.5, height: 24),
//             ),
//             // 1. Invoice List
//             if (_InvoiceModels.isNotEmpty) ...[
//               for (int index_in = 0;
//                   index_in < _InvoiceModels.length;
//                   index_in++)
//                 Builder(builder: (context) {
//                   final model = _InvoiceModels[index_in];
//                   final isSelected = invoicePayModels
//                           .elementAtOrNull(index_in)
//                           ?.ser
//                           .toString() ==
//                       model.ser;
//                   final amt = _safeDouble(model.amtall);
//                   final finesList = _safeString(invoicePayfine).split(',');
//                   double itemFine = 0.0;
//                   if (invoicePayfine != null &&
//                       invoicePayfine!.isNotEmpty &&
//                       index_in < finesList.length) {
//                     itemFine = _safeDouble(finesList[index_in]);
//                   }
//                   return _invoiceItem(
//                     index: index_in + 1,
//                     docNo: model.docno ?? '-',
//                     amount: amt,
//                     date: model.date ?? '',
//                     isSelected: isSelected,
//                     fine: itemFine,
//                     onTap: () {},
//                   );
//                 }),
//             ],
//             // 2. Unpaid Items (TransBill)
//             if (_TransBillModels.isNotEmpty) ...[
//               for (int index = 0; index < _TransBillModels.length; index++)
//                 Builder(builder: (context) {
//                   final model = _TransBillModels[index];
//                   final isSelected = _TransBillstring.elementAtOrNull(index)
//                           ?.docno
//                           .toString() ==
//                       model.docno;
//                   final amt = _safeDouble(model.total);

//                   return _invoiceItem(
//                     index: _InvoiceModels.length + (index + 1),
//                     docNo: model.expname ?? '-',
//                     amount: amt,
//                     date: model.date ?? '',
//                     isSelected: isSelected,
//                     fine: 0,
//                     onTap: () {},
//                   );
//                 }),
//             ]
//           ],
//         ),
//       ),
//     );
//   }

//   int secondsUntilExpire() {
//     final nowUtc = DateTime.now().toUtc();
//     final sec = expiryUtc.difference(nowUtc).inSeconds;
//     return sec < 0 ? 0 : sec;
//   }

//   String _hhmmssFromSecs(int secs) {
//     final h = (secs ~/ 3600).toString().padLeft(2, '0');
//     final m = ((secs % 3600) ~/ 60).toString().padLeft(2, '0');
//     final s = (secs % 60).toString().padLeft(2, '0');
//     return '$h:$m:$s';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//         animation: widget.mainScreenAnimationController!,
//         builder: (BuildContext context, Widget? child) {
//           final double width = MediaQuery.of(context).size.width;
//           final bool isMobile = width < 768;
//           final bool isDesktop = width >= 900;
//           final double qrSize = 140.0;
//           return Scaffold(
//             appBar: AppBar(
//                 backgroundColor: Colors.white,
//                 elevation: 0,
//                 centerTitle: true,
//                 leading: IconButton(
//                   icon: Icon(Icons.arrow_back_ios, color: Colors.black),
//                   onPressed: () {
//                     PanaraConfirmDialog.showAnimatedGrow(
//                       context,
//                       title: widget.cuslang == 'EN' ? "Warning" : "แจ้งเตือน",
//                       message: widget.cuslang == 'EN'
//                           ? "If paid, please attach proof and confirm. Or close to pay later."
//                           : "หากชำระแล้วอย่าลืมแนบหลักฐานและยืนยัน หรือปิดไว้ชำระอีกครั้งภายหลัง",
//                       confirmButtonText: widget.cuslang == 'EN'
//                           ? "Attach Proof"
//                           : "แนบหลักฐาน",
//                       cancelButtonText: widget.cuslang == 'EN'
//                           ? "Pay Later"
//                           : "ปิดไว้ชำระภายหลัง",
//                       onTapConfirm: () {
//                         Navigator.pop(context); // Close dialog
//                         _showPaymentConfirmationSheet(context);
//                       },
//                       onTapCancel: () {
//                         Navigator.pop(context); // Close dialog
//                         Navigator.pop(context); // Close screen
//                       },
//                       panaraDialogType: PanaraDialogType.warning,
//                       barrierDismissible: true,
//                     );
//                   },
//                 ),
//                 title: ListTile(
//                   dense: true,
//                   contentPadding:
//                       const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                   title: Text(
//                     widget.cuslang == 'EN' ? 'Payment' : 'ชำระเงิน',
//                     style: TextStyle(
//                         color: Colors.black,
//                         fontFamily: Font_.Fonts_T,
//                         fontWeight: FontWeight.bold),
//                   ),
//                   subtitle: Row(
//                     children: [
//                       // Text(
//                       //   'chao-$QR_Ref1',
//                       //   style: TextStyle(
//                       //     color: Colors.grey,
//                       //     fontFamily: Font_.Fonts_T,
//                       //   ),
//                       // ),
//                       // const SizedBox(width: 6),
//                       // Countdown + Progress (อ้างอิงวินาทีเดียว)
//                       Expanded(
//                         child: StreamBuilder<int>(
//                           stream: Stream.periodic(
//                             const Duration(seconds: 1),
//                             (_) => secondsUntilExpire(),
//                           ),
//                           initialData: secondsUntilExpire(),
//                           builder: (_, snap) {
//                             final secs = (snap.data ?? 0);
//                             final clamped = secs < 0 ? 0 : secs;
//                             final prog = (clamped / _totalSecs).clamp(0.0, 1.0);

//                             final label = widget.cuslang == 'EN'
//                                 ? (clamped == 0
//                                     ? 'Expired'
//                                     : 'Expired ${_hhmmssFromSecs(clamped)}')
//                                 : (clamped == 0
//                                     ? 'หมดอายุแล้ว'
//                                     : 'หมดอายุ ${_hhmmssFromSecs(clamped)}');

//                             // ถ้าหมดอายุแล้ว – ปิดแผ่น + เสนอให้ต่ออายุ
//                             // แต่ถ้ามีสลิปแล้ว (uploadedSlipData != null) ไม่ต้องปิด
//                             if (clamped == 0 &&
//                                 _uploadedSlipData == null &&
//                                 !_expireDialogShown) {
//                               Future.microtask(() async {
//                                 if (!mounted) return;
//                                 setState(() => _expireDialogShown = true);
//                                 PanaraConfirmDialog.showAnimatedGrow(
//                                   context,
//                                   title: widget.cuslang == 'EN'
//                                       ? "Expired"
//                                       : "หมดเวลา",
//                                   message: widget.cuslang == 'EN'
//                                       ? "Payment time expired. If paid, please attach proof. If not, please renew QR."
//                                       : "หมดเวลาการชำระแล้ว หากชำระแล้วกรุณาแนบหลักฐานและชำระและยืนยัน หรือยังไม่ได้ชำระกรุณากดแสดง QR อีกครั้ง",
//                                   confirmButtonText: widget.cuslang == 'EN'
//                                       ? "Attach Proof"
//                                       : "แนบหลักฐาน",
//                                   cancelButtonText:
//                                       widget.cuslang == 'EN' ? "Close" : "ปิด",
//                                   onTapConfirm: () {
//                                     Navigator.pop(context);
//                                     _showPaymentConfirmationSheet(context);
//                                   },
//                                   onTapCancel: () {
//                                     Navigator.pop(context);
//                                   },
//                                   panaraDialogType: PanaraDialogType.warning,
//                                   barrierDismissible: true,
//                                 );
//                               });
//                             }

//                             return Row(
//                               children: [
//                                 Icon(
//                                   clamped == 0 ? Icons.timer_off : Icons.timer,
//                                   size: 16,
//                                   color: Colors.red,
//                                 ),
//                                 const SizedBox(width: 6),
//                                 Text(
//                                   label,
//                                   style: const TextStyle(
//                                     fontFamily: Font_.Fonts_T,
//                                     color: Colors.red,
//                                     fontWeight: FontWeight.w700,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Expanded(
//                                   child: ClipRRect(
//                                     borderRadius: BorderRadius.circular(6),
//                                     child: LinearProgressIndicator(
//                                       value: prog,
//                                       minHeight: 6,
//                                       backgroundColor: Colors.white24,
//                                       valueColor: AlwaysStoppedAnimation(
//                                         clamped == 0
//                                             ? Colors.redAccent
//                                             : Colors.amber,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 )),
// // FAB Removed
//             // backgroundColor: Colors.white,
//             body: Stack(
//               children: [
//                 FadeTransition(
//                   opacity: widget.mainScreenAnimation!,
//                   child: Transform(
//                     transform: Matrix4.translationValues(0.0,
//                         30 * (1.0 - widget.mainScreenAnimation!.value), 0.0),
//                     child: ScrollConfiguration(
//                       behavior: ScrollConfiguration.of(context)
//                           .copyWith(dragDevices: {
//                         PointerDeviceKind.touch,
//                         PointerDeviceKind.mouse,
//                       }),
//                       child: Padding(
//                         padding:
//                             const EdgeInsets.only(left: 8, right: 8, top: 2),
//                         child: SingleChildScrollView(
//                           child: Column(
//                             children: [
//                               // const SizedBox(
//                               //   height: 5,
//                               // ),

//                               // Padding(
//                               //   padding: const EdgeInsets.all(8.0),
//                               //   child: Text(
//                               //     widget.cuslang == 'EN'
//                               //         ? 'Details'
//                               //         : "รายละเอียด",
//                               //     textAlign: TextAlign.start,
//                               //     style: TextStyle(
//                               //       fontWeight: FontWeight.bold,
//                               //       fontSize: 14,
//                               //     ),
//                               //   ),
//                               // ),
//                               // _groupTile(),

//                               LayoutBuilder(
//                                 builder: (context, constraints) {
//                                   final maxW = constraints.maxWidth;
//                                   // Conditions to display QR Box
//                                   final showQR =
//                                       paymentSer1 != null && gopay != 0;

//                                   // Determine if we should use Row (Desktop) or Column (Mobile)
//                                   if (maxW >= 900) {
//                                     return Row(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         if (showQR) ...[
//                                           Expanded(flex: 1, child: _QRBox()),
//                                           // const SizedBox(width: 16),
//                                         ],
//                                         Expanded(
//                                           flex: 2,
//                                           child: Center(
//                                               child: Padding(
//                                             padding: const EdgeInsets.fromLTRB(
//                                                 0, 10, 0, 0),
//                                             child: Column(
//                                               children: [
//                                                 _groupTile(),
//                                                 const SizedBox(height: 16),
//                                                 _howToBox(),
//                                               ],
//                                             ),
//                                           )),
//                                         ),
//                                       ],
//                                     );
//                                   } else {
//                                     return Column(
//                                       children: [
//                                         _groupTile(),
//                                         const SizedBox(height: 2),
//                                         if (showQR) ...[
//                                           _QRBox(),
//                                           const SizedBox(height: 4),
//                                         ],
//                                         Center(
//                                           child: ConstrainedBox(
//                                             constraints: BoxConstraints(
//                                                 maxWidth: maxW >= 480
//                                                     ? 560
//                                                     : double.infinity),
//                                             child: _howToBox(),
//                                           ),
//                                         ),
//                                       ],
//                                     );
//                                   }
//                                 },
//                               ),

//                               const SizedBox(height: 30),
//                               // SizedBox(
//                               //   height: 20,
//                               // ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 if (isLoading)
//                   Container(
//                     color: Colors.black.withOpacity(0.5),
//                     child: const Center(
//                       child: CircularProgressIndicator(
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//             bottomNavigationBar: Container(
//               padding: EdgeInsets.all(16.0),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.withOpacity(0.3),
//                     spreadRadius: 1,
//                     blurRadius: 10,
//                     offset: Offset(0, -2),
//                   ),
//                 ],
//               ),
//               child: SafeArea(
//                 child: SizedBox(
//                   height: 50,
//                   child: ElevatedButton(
//                     onPressed: (invoicePayModels.length == 0)
//                         ? () {
//                             PanaraInfoDialog.showAnimatedGrow(
//                               context,
//                               title: "Oops",
//                               message: widget.cuslang == 'EN'
//                                   ? "No payment amount!!!"
//                                   : "ไม่มียอดชำระ !!!",
//                               buttonText: widget.cuslang == 'EN'
//                                   ? "acknowledge"
//                                   : "รับทราบ",
//                               onTapDismiss: () async {
//                                 Navigator.of(
//                                   context,
//                                   rootNavigator: true,
//                                 ).pop();
//                               },
//                               panaraDialogType: PanaraDialogType.error,
//                               barrierDismissible: false,
//                             );
//                           }
//                         : () async {
//                             await CreatePaymentItem();
//                             // await QrGenRef(); // CreatePaymentItem calls QrGenRef now or we call it here?
//                             // Plan said chain them. I put QrGenRef in CreatePaymentItem above to be safe and ensure sequence?
//                             // Or keep them separate.
//                             // User request: "...ทำ CreatePaymentItem() ... เมื่อทำเสร็จจะทำ QrGenRef()..."
//                             // If I call QrGenRef() inside CreatePaymentItem(), it handles the sequence.
//                             // But CreatePaymentItem() is closed function.
//                             // I added QrGenRef() at the end of CreatePaymentItem() in the chunk above?
//                             // Wait, I added it in chunk 2. "await QrGenRef();" inside CreatePaymentItem.
//                             // So here I just call CreatePaymentItem().
//                             // But wait, the previous logic had "CreatePaymentItem" blindly? No, it wasn't called before.
//                             // The button called _showPaymentConfirmationSheet.
//                             // So calling CreatePaymentItem() is correct.
//                             return;
//                           },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: select_pay == 0
//                           ? Colors.black87 // Colors.green.shade900
//                           : (QR_Ref1 == null ||
//                                   QR_Ref1 == 'null' ||
//                                   QR_Ref1 == '' ||
//                                   selectedValue == null ||
//                                   selectedValue == 'null' ||
//                                   selectedValue == '')
//                               ? Colors.grey
//                               : Colors.black87,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     child: Text(
//                       select_pay == 0
//                           ? (widget.cuslang == 'EN'
//                               ? 'Payment Next'
//                               : 'ชำระเงินต่อไป')
//                           : (widget.cuslang == 'EN'
//                               ? 'Start Payment'
//                               : 'เริ่มการชำระ'),
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         fontFamily: Font_.Fonts_T,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           );
//         });
//   }

//   _saveNetworkImage(String imageUrl) async {
//     var response = await Dio()
//         .get(imageUrl, options: Options(responseType: ResponseType.bytes));
//     final result = await ImageGallerySaver.saveImage(
//         Uint8List.fromList(response.data),
//         quality: 60,
//         name: "hello");

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//           backgroundColor: Colors.black,
//           content: Text('$result',
//               style:
//                   TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T))),
//     );
//   }

//   Future<void> saveImage(String imageUrl) async {
//     Uint8List image =
//         (await NetworkAssetBundle(Uri.parse(imageUrl)).load(imageUrl))
//             .buffer
//             .asUint8List();
//     try {
//       if (Platform.isIOS) {
//         PermissionStatus permission = await Permission.photos.status;
//         if (permission == PermissionStatus.granted) {
//         } else {
//           openAppSettings();
//           throw 'denied';
//         }
//       } else if (Platform.isAndroid) {
//         PermissionStatus permission = await Permission.storage.status;
//         if (permission == PermissionStatus.granted) {
//         } else {
//           openAppSettings();
//           throw 'denied';
//         }
//       }
//       await ImageGallerySaver.saveImage(image);
//     } catch (e) {
//       throw e;
//     }
//   }

//   Future<void> downloadImage(String imageUrl) async {
//     try {
//       // first we make a request to the url like you did
//       // in the android and ios version
//       final http.Response r = await http.get(
//         Uri.parse(imageUrl),
//       );

//       // we get the bytes from the body
//       final data = r.bodyBytes;
//       // and encode them to base64
//       final base64data = base64Encode(data);

//       // then we create and AnchorElement with the html package
//       final a = html.AnchorElement(href: 'data:image/jpeg;base64,$base64data');

//       // set the name of the file we want the image to get
//       // downloaded to
//       a.download = 'Load_QR_$refpay.jpg';

//       // and we click the AnchorElement which downloads the image
//       a.click();
//       // finally we remove the AnchorElement
//       a.remove();
//     } catch (e) {
//       // print(e);
//     }
//   }

//   Future<void> _showMyDialogPay_Error(text) {
//     return showDialog<void>(
//         context: context,
//         barrierDismissible: false, // user must tap button!
//         builder: (BuildContext context) {
//           return AlertDialog(
//             shape: const RoundedRectangleBorder(
//                 borderRadius: BorderRadius.all(Radius.circular(20.0))),
//             // title: const Text('AlertDialog Title'),
//             content: SingleChildScrollView(
//               child: ListBody(
//                 children: <Widget>[
//                   Center(
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text(
//                         '$text',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                             // color: PeopleChaoScreen_Color.Colors_Text1_,
//                             fontWeight: FontWeight.bold,
//                             fontFamily: FontWeight_.Fonts_T
//                             //fontFamily: FontWeight_.Fonts_T
//                             //fontSize: 10.0
//                             ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             actions: <Widget>[
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: InkWell(
//                         child: Container(
//                             width: 100,
//                             decoration: const BoxDecoration(
//                               color: Colors.black,
//                               borderRadius: BorderRadius.only(
//                                   topLeft: Radius.circular(10),
//                                   topRight: Radius.circular(10),
//                                   bottomLeft: Radius.circular(10),
//                                   bottomRight: Radius.circular(10)),
//                               // border: Border.all(color: Colors.white, width: 1),
//                             ),
//                             padding: const EdgeInsets.all(8.0),
//                             child: Center(
//                                 child: Text(
//                               widget.cuslang == 'EN' ? 'Close' : 'ปิด',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                   fontFamily: FontWeight_.Fonts_T
//                                   //  fontFamily: FontWeight_.Fonts_T
//                                   //fontSize: 10.0
//                                   ),
//                             ))),
//                         onTap: () {
//                           Navigator.of(context).pop();
//                         },
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           );
//         });
//   }

//   List<TransBillModel> _TransBillModels = [];
//   List<TransModel> _TransModels = [];
//   ////////////////------------------------------------------------------>SHOPNO ==1 ผ่านเว็ป

//   Future<Null> in_Trans_select(index) async {
//     ////////////////------------------------------------------------------>SHOPNO ==1 ผ่านเว็ป
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     var ciddoc_ = preferences.getString('usercid');
//     var qutser_ = preferences.getString('qutser');
//     ////////////////------------------------------------------------------>
//     var ren = preferences.getString('renTalSer');
//     var user = preferences.getString('ser');
//     var ciddoc = ciddoc_;
//     var qutser = qutser_;
//     var shopno = '1';
//     var pos = '1';
//     var tser = '${_TransBillModels[index].ser}';
//     //_TransBillModels[index].ser;
//     var tdocno = '${_TransBillModels[index].docno}';
//     //_TransBillModels[index].docno;

//     // //print('object $tdocno');
//     Map<String, dynamic> queryParams = {
//       'isAdd': 'true',
//       'ren': ren,
//       'ciddoc': ciddoc,
//       'qutser': qutser,
//       'tser': tser,
//       'tdocno': tdocno,
//       'user': user,
//       'shopno': shopno,
//       'pos': pos,
//     };

//     var uri =
//         Uri.parse('${MyConstant().domain_chao}/In_tran_select_Chao_user.php')
//             .replace(queryParameters: queryParams);

//     try {
//       var response = await http.get(uri);

//       var result = json.decode(response.body);
//       // //print('rr>>>>>> $result');
//       if (result.toString() == 'true') {
//         setState(() {
//           red_Trans_select2();
//         });
//         // //print('rrrrrrrrrrrrrr');
//       } else if (result.toString() == 'false') {
//         setState(() {
//           red_Trans_select2();
//         });
//         // //print('rrrrrrrrrrrrrrfalse');
//       } else {
//         setState(() {
//           red_Trans_select2();
//         });
//       }
//     } catch (e) {}
//   }

//   Future<Null> de_Trans_select(index) async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     var ren = preferences.getString('renTalSer');
//     var user = preferences.getString('ser');
//     var ciddoc = preferences.getString('usercid');
//     var qutser = preferences.getString('qutser');

//     var tser = _TransBillModels[index].ser;
//     var tdocno = _TransBillModels[index].docno;

//     //print('tser >>.> $tser>>. $tdocno');

//     Map<String, dynamic> queryParams = {
//       'isAdd': 'true',
//       'ren': ren,
//       'ciddoc': ciddoc,
//       'qutser': qutser,
//       'tser': tser,
//       'tdocno': tdocno,
//       'user': user,
//     };

//     var uri =
//         Uri.parse('${MyConstant().domain_chao}/D_tran_select_ser_User.php')
//             .replace(queryParameters: queryParams);

//     try {
//       var response = await http.get(uri);

//       var result = json.decode(response.body);
//       // //print(result);
//       if (result.toString() == 'true') {
//         setState(() {
//           red_Trans_select2();
//         });
//         //print('rrrrrrrrrrrrrr');
//       }
//     } catch (e) {}
//   }

//   Future<Null> red_Trans_select2() async {
//     if (_TransModels.isNotEmpty) {
//       setState(() {
//         _TransModels.clear();
//       });
//     }
//     ////////////////------------------------------------------------------> SHOPNO ==1 ผ่านเว็ป // Pos = 1 รออนุมัติ
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     var ciddoc_ = preferences.getString('usercid');
//     var qutser_ = preferences.getString('qutser');
//     ////////////////------------------------------------------------------>
//     var ren = preferences.getString('renTalSer');
//     var user = preferences.getString('ser');
//     if (widget.teNantModel == null) {
//       var ciddoc = ciddoc_;
//       var qutser = qutser_;

//       Map<String, dynamic> queryParams = {
//         'isAdd': 'true',
//         'ren': ren,
//         'user': user,
//         'ciddoc': ciddoc,
//       };

//       var uri = Uri.parse('${MyConstant().domain_chao}/GC_tran_select.php')
//           .replace(queryParameters: queryParams);
//       try {
//         var response = await http.get(uri);

//         var result = json.decode(response.body);
//         // //print(result);
//         if (result.toString() != 'null') {
//           setState(() {
//             _TransModels.clear();
//             sum_pvat = 0;
//             sum_vat = 0;
//             sum_wht = 0;
//             sum_amt = 0;
//           });
//           for (var map in result) {
//             TransModel _TransModel = TransModel.fromJson(map);

//             var sum_pvatx = double.parse(_TransModel.pvat!);
//             var sum_vatx = double.parse(_TransModel.vat!);
//             var sum_whtx = double.parse(_TransModel.wht!);
//             var sum_amtx = double.parse(_TransModel.total!);
//             setState(() {
//               sum_pvat = sum_pvat + sum_pvatx;
//               sum_vat = sum_vat + sum_vatx;
//               sum_wht = sum_wht + sum_whtx;
//               sum_amt = sum_amt + sum_amtx;
//               _TransModels.add(_TransModel);
//             });
//           }
//         }

//         setState(() {
//           red_Trans_select2_fin();
//           sum_pvat = sum_pvat + sum_tran_fine;
//           sum_amt = sum_amt + sum_tran_fine;
//           Form_payment1.text = (sum_pvat +
//                   sum_tran_fine -
//                   dis_sum_Pakan -
//                   (sum_disamt + sum_disamt_in) +
//                   (sum_amt_in + sum_tran_fine_in) +
//                   (fine_total))
//               .toStringAsFixed(2)
//               .toString();
//           // Form_payment1.text = (sum_amt - sum_disamt - dis_sum_Pakan)
//           //     .toStringAsFixed(2)
//           //     .toString();
//         });
//       } catch (e) {}
//     } else {
//       for (var i = 0; i < widget.teNantModel!.length; i++) {
//         var ciddoc = widget.teNantModel![i].cid;
//         var qutser = qutser_;

//         Map<String, dynamic> queryParams = {
//           'isAdd': 'true',
//           'ren': ren,
//           'user': user,
//           'ciddoc': ciddoc,
//         };

//         var uri = Uri.parse('${MyConstant().domain_chao}/GC_tran_select.php')
//             .replace(queryParameters: queryParams);
//         try {
//           var response = await http.get(uri);

//           var result = json.decode(response.body);
//           // //print(result);
//           if (result.toString() != 'null') {
//             setState(() {
//               _TransModels.clear();
//               sum_pvat = 0;
//               sum_vat = 0;
//               sum_wht = 0;
//               sum_amt = 0;
//             });
//             for (var map in result) {
//               TransModel _TransModel = TransModel.fromJson(map);

//               var sum_pvatx = double.parse(_TransModel.pvat!);
//               var sum_vatx = double.parse(_TransModel.vat!);
//               var sum_whtx = double.parse(_TransModel.wht!);
//               var sum_amtx = double.parse(_TransModel.total!);
//               setState(() {
//                 sum_pvat = sum_pvat + sum_pvatx;
//                 sum_vat = sum_vat + sum_vatx;
//                 sum_wht = sum_wht + sum_whtx;
//                 sum_amt = sum_amt + sum_amtx;
//                 _TransModels.add(_TransModel);
//               });
//             }
//           }

//           setState(() {
//             red_Trans_select2_fin();
//             sum_pvat = sum_pvat + sum_tran_fine;
//             sum_amt = sum_amt + sum_tran_fine;
//             Form_payment1.text = (sum_pvat +
//                     sum_tran_fine -
//                     dis_sum_Pakan -
//                     (sum_disamt + sum_disamt_in) +
//                     (sum_amt_in + sum_tran_fine_in) +
//                     (fine_total))
//                 .toStringAsFixed(2)
//                 .toString();
//             // Form_payment1.text = (sum_amt - sum_disamt - dis_sum_Pakan)
//             //     .toStringAsFixed(2)
//             //     .toString();
//           });
//         } catch (e) {}
//       }
//     }
//   }

//   Future<Null> red_Trans_select2_fin() async {
//     if (transFineModels.isNotEmpty) {
//       setState(() {
//         transFineModels.clear();
//         sum_tran_fine = 0;
//       });
//     }
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     var ren = preferences.getString('renTalSer');
//     var user = preferences.getString('ser');
//     if (widget.teNantModel == null) {
//       var ciddoc = preferences.getString('usercid');
//       var qutser = 1;

//       Map<String, dynamic> queryParams = {
//         'isAdd': 'true',
//         'ren': ren,
//         'user': user,
//         'ciddoc': ciddoc,
//       };

//       var uri = Uri.parse('${MyConstant().domain_chao}/GC_tran_select_fin.php')
//           .replace(queryParameters: queryParams);

//       try {
//         var response = await http.get(uri);

//         var result = json.decode(response.body);
//         // //print(result);
//         if (result.toString() != 'null') {
//           transFineModels.clear();
//           sum_tran_fine = 0;
//           for (var map in result) {
//             TransFineModel transFineModel = TransFineModel.fromJson(map);

//             var sum_totalx = double.parse(transFineModel.total!);
//             setState(() {
//               // sum_pvat = sum_pvat + sum_totalx;
//               // sum_amt = sum_amt + sum_totalx;

//               sum_tran_fine = sum_tran_fine + sum_totalx;
//               transFineModels.add(transFineModel);
//             });
//           }
//         }
//       } catch (e) {}
//     } else {
//       for (var i = 0; i < widget.teNantModel!.length; i++) {
//         var ciddoc = widget.teNantModel![i].cid;
//         var qutser = 1;

//         Map<String, dynamic> queryParams = {
//           'isAdd': 'true',
//           'ren': ren,
//           'user': user,
//           'ciddoc': ciddoc,
//         };

//         var uri =
//             Uri.parse('${MyConstant().domain_chao}/GC_tran_select_fin.php')
//                 .replace(queryParameters: queryParams);

//         try {
//           var response = await http.get(uri);

//           var result = json.decode(response.body);
//           // //print(result);
//           if (result.toString() != 'null') {
//             transFineModels.clear();
//             sum_tran_fine = 0;
//             for (var map in result) {
//               TransFineModel transFineModel = TransFineModel.fromJson(map);

//               var sum_totalx = double.parse(transFineModel.total!);
//               setState(() {
//                 // sum_pvat = sum_pvat + sum_totalx;
//                 // sum_amt = sum_amt + sum_totalx;

//                 sum_tran_fine = sum_tran_fine + sum_totalx;
//                 transFineModels.add(transFineModel);
//               });
//             }
//           }
//         } catch (e) {}
//       }
//     }

//     setState(() {
//       Form_payment1.text = (sum_pvat +
//               sum_tran_fine -
//               dis_sum_Pakan -
//               (sum_disamt + sum_disamt_in) +
//               (sum_amt_in + sum_tran_fine_in) +
//               (fine_total))
//           .toStringAsFixed(2)
//           .toString();
//     });
//   }

//   Future<String> in_Trans_invoice_genqr() async {
//     List newValuePDFimg = [];
//     for (int index = 0; index < 1; index++) {
//       if (renTalModels[0].imglogo!.trim() == '') {
//       } else {
//         newValuePDFimg.add(
//             '${MyConstant().domain_chao}/files/$foder/logo/${renTalModels[0].imglogo!.trim()}');
//       }
//     }
//     DateTime now = DateTime.now();
//     int hour = now.hour;
//     int minute = now.minute;
//     int second = now.second;

//     /////////------------------->
//     String? fileName_Slip_ = fileName_Slip.toString().trim();
//     ////////////////------------------------------------------------------>
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     var custno = preferences.getString('custno');
//     var qutser_ = preferences.getString('qutser');

//     var ciddoc_ = preferences.getString('usercid');
//     var paybyselect = preferences.getString('payby');
//     var ren = preferences.getString('renTalSer');
//     var user = preferences.getString('ser');
//     var user_bill = _InvoiceModels[0].user;
//     var ciddoc = widget.teNantModel!.length != 1 ? '0' : ciddoc_;
//     var qutser = 1;
//     var sumdis = (sum_disamt + sum_disamt_in).toStringAsFixed(2).toString();
//     var sumdisp = '0.00'.toString();
//     var dateY = Value_newDateY;
//     var dateY1 = Value_newDateY1;
//     var time = '$hour:$minute:$second';
//     var bill = bills_name_ == 'บิลธรรมดา' ? 'P' : 'F';
//     var dis_akan = dis_sum_Pakan.toString();
//     //pamentpage == 0
//     var payment1 = Form_payment1.text.toString();
//     var payment2 = Form_payment2.text.toString();
//     var pSer1 = paymentSer1;
//     var pSer2 = paymentSer2;
//     var sum_whta = (sum_wht + sum_wht_in).toString();
//     var comment = '';
//     var shopno = '1';
//     var pos = '1';
//     var fine_total_tt = fine_total;
//     var tran_fine = (sum_tran_fine + sum_tran_fine_in).toString();
//     var pamentpage = 0;
//     var Slip_status = 0;

//     var io2 = invoicePay == null || invoicePay == ''
//         ? '0'
//         : invoicePay!.substring(0, invoicePay!.length - 1); // string
//     var io4 = invoicePayfine == null || invoicePayfine == ''
//         ? '0'
//         : invoicePayfine!.substring(0, invoicePayfine!.length - 1); // string

//     var payby = 'U';
//     var paybywidget = '0'; // paybyselect == 'PAYCONTACT' ? '0' : custno;

//     // print(
//     //     '$invoicePay ..... $invoicePayfine ...... i $ciddoc i $paybywidget ii $io2 >>>>444>>>$io4>>>$tran_fine');

//     Map<String, dynamic> queryParams = {
//       'isAdd': 'true',
//       'ren': ren,
//       'ciddoc': ciddoc,
//       'qutser': qutser.toString(),
//       'user': user,
//       'sumdis': sumdis,
//       'sumdisp': sumdisp,
//       'dateY': dateY,
//       'dateY1': dateY1,
//       'time': time,
//       'payment1': payment1,
//       'payment2': payment2,
//       'pSer1': pSer1,
//       'pSer2': pSer2,
//       'sum_whta': sum_whta,
//       'bill': bill,
//       'fileNameSlip': fileName_Slip_,
//       'comment': comment,
//       'dis_Pakan': dis_akan,
//       'shopno': shopno,
//       'pos': pos,
//       'fine_total_amt': fine_total_tt.toString(),
//       'tran_fine': tran_fine,
//       'invoice': io2,
//       'fin_in': io4,
//       'ref': refpay,
//       'payby': payby,
//       'paybywidget': paybywidget,
//       'user_bill': user_bill,
//     };

//     var uri = Uri.parse('${MyConstant().domain_chao}/In_tran_financet_User.php')
//         .replace(queryParameters: queryParams);

//     // print('Generated URL: $uri');
//     return uri.toString();
//   }

//   Future<Null> in_Trans_invoice(newValuePDFimg) async {
//     setState(() {
//       isLoading = true;
//     });
//     DateTime now = DateTime.now();
//     int hour = now.hour;
//     int minute = now.minute;
//     int second = now.second;

//     /////////------------------->
//     String? fileName_Slip_ = fileName_Slip.toString().trim();
//     ////////////////------------------------------------------------------>
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     var custno = preferences.getString('custno');

//     ////////////////------------------------------------------------------>
//     // if (widget.teNantModel == null) {
//     var ciddoc_ = preferences.getString('usercid');
//     var ren = preferences.getString('renTalSer');
//     var user = preferences.getString('ser');
//     var user_bill = _InvoiceModels[0].user;
//     var ciddoc = widget.teNantModel!.length != 1 ? '0' : ciddoc_;
//     var qutser = 1;
//     var sumdis = (sum_disamt + sum_disamt_in).toStringAsFixed(2).toString();
//     var sumdisp = '0.00'.toString();
//     var dateY = Value_newDateY;
//     var dateY1 = Value_newDateY1;
//     var time = '$hour:$minute:$second';
//     var bill = bills_name_ == 'บิลธรรมดา' ? 'P' : 'F';
//     var dis_akan = dis_sum_Pakan.toString();
//     //pamentpage == 0
//     var payment1 = Form_payment1.text.toString();
//     var payment2 = Form_payment2.text.toString();
//     var pSer1 = paymentSer1;
//     var pSer2 = paymentSer2;
//     var sum_whta = (sum_wht + sum_wht_in).toString();
//     var comment = '';
//     var shopno = '1';
//     var pos = '1';
//     var fine_total_tt = fine_total;
//     var tran_fine = (sum_tran_fine + sum_tran_fine_in).toString();

//     var pamentpage = 0;
//     var Slip_status = 0;

//     var io2 = invoicePay == null || invoicePay == ''
//         ? '0'
//         : invoicePay!.substring(0, invoicePay!.length - 1); // string
//     var io4 = invoicePayfine == null || invoicePayfine == ''
//         ? '0'
//         : invoicePayfine!.substring(0, invoicePayfine!.length - 1); // string

//     var payby = 'U';
//     var paybywidget = '0'; // paybyselect == 'PAYCONTACT' ? '0' : custno;

//     // print(
//     //     '$invoicePay ..... $invoicePayfine ...... i $ciddoc i $paybywidget ii $io2 >>>>444>>>$io4>>>$tran_fine');

//     Map<String, dynamic> queryParams = {
//       'isAdd': 'true',
//       'ren': ren,
//       'ciddoc': ciddoc,
//       'qutser': qutser.toString(),
//       'user': user,
//       'sumdis': sumdis,
//       'sumdisp': sumdisp,
//       'dateY': dateY,
//       'dateY1': dateY1,
//       'time': time,
//       'payment1': payment1,
//       'payment2': payment2,
//       'pSer1': pSer1,
//       'pSer2': pSer2,
//       'sum_whta': sum_whta,
//       'bill': bill,
//       'fileNameSlip': fileName_Slip_,
//       'comment': comment,
//       'dis_Pakan': dis_akan,
//       'shopno': shopno,
//       'pos': pos,
//       'fine_total_amt': fine_total_tt.toString(),
//       'tran_fine': tran_fine,
//       'invoice': io2,
//       'fin_in': io4,
//       'ref': refpay,
//       'payby': payby,
//       'paybywidget': paybywidget,
//       'user_bill': user_bill,
//     };

//     var uri = Uri.parse('${MyConstant().domain_chao}/In_tran_financet_User.php')
//         .replace(queryParameters: queryParams);

//     // print('$paybyselect url $uri ');

//     try {
//       var response = await http.get(uri);

//       var result = json.decode(response.body);

//       if (result.toString() != 'No') {
//         for (var map in result) {
//           CFinnancetransModel cFinnancetransModel =
//               CFinnancetransModel.fromJson(map);
//           setState(() {
//             cFinn = cFinnancetransModel.docno;
//             listitem.clear();
//             base64_Slip = null;
//             fileName_Slip = null;
//             extension_ = null;
//             file_ = null;
//             selectedValue = null;
//           });
//         }

//         var custno = preferences.getString('custno');
//         Insert_log.Insert_logs('ชำระ', ' $ciddoc ($cFinn)');
//       }
//     } catch (e) {
//       // //print('$e');
//     } finally {
//       if (mounted) {
//         await sucress(onDismiss: () {
//           Navigator.pushAndRemoveUntil(context,
//               MaterialPageRoute(builder: (context) {
//             return FitnessAppHomeScreen(custno_s: custno);
//           }), (route) => false);
//         });
//       }
//     }
//   }

//   // void generateRandomString() {
//   //   setState(() {
//   //     QR_Ref1 = getRandomString(18);
//   //     QR_Ref2 = getRandomString(18);
//   //     QR_Ref3 = getRandomString(18);
//   //   });
//   // }

//   Future<void> _processPaymentConfirmation(BuildContext ctx) async {
//     Navigator.of(ctx).pop(); // Close the dialog
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     List newValuePDFimg = [];
//     for (int index = 0; index < 1; index++) {
//       if (renTalModels[0].imglogo!.trim() != '') {
//         newValuePDFimg.add(
//             '${MyConstant().domain_chao}/files/$foder/logo/${renTalModels[0].imglogo!.trim()}');
//       }
//     }
//     try {
//       sucress(onDismiss: () {
//         Navigator.pushAndRemoveUntil(context,
//             MaterialPageRoute(builder: (context) {
//           return FitnessAppHomeScreen(
//               custno_s: preferences.getString('custno'));
//         }), (route) => false);
//       });
//       OKuploadFile_Slip(newValuePDFimg)
//           .then((value) => in_Trans_invoice(newValuePDFimg));
//     } catch (e) {
//       _showMyDialogPay_Error(widget.cuslang == 'EN'
//           ? "An error occurred. Please check the information. Please try again!"
//           : 'เกิดข้อผิดพลาด ตรวจสอบความถูกต้อง กรุณาลองอีกครั้ง!');
//     }
//   }

//   void _showSlideConfirmDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: true,
//       builder: (BuildContext ctx) {
//         return AlertDialog(
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           contentPadding: EdgeInsets.zero,
//           content: Container(
//             width: double.maxFinite,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         widget.cuslang == 'EN'
//                             ? 'Confirm Payment'
//                             : 'ยืนยันการชำระเงิน',
//                         style: TextStyle(
//                             fontFamily: Font_.Fonts_T,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold),
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.close, color: Colors.grey),
//                         onPressed: () => Navigator.pop(ctx),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Divider(height: 1),
//                 SizedBox(height: 10),
//                 if (_uploadedSlipData != null)
//                   Container(
//                     height: 250,
//                     width: double.infinity,
//                     color: Colors.black12,
//                     child: InteractiveViewer(
//                       panEnabled: true,
//                       minScale: 0.1,
//                       maxScale: 4.0,
//                       child: Image.memory(
//                         _uploadedSlipData!,
//                         fit: BoxFit.contain,
//                       ),
//                     ),
//                   ),
//                 SizedBox(height: 16),
//                 Padding(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   child: _SlideToConfirm(
//                     label: widget.cuslang == 'EN'
//                         ? 'Slide to Confirm'
//                         : 'เลื่อนเพื่อยืนยัน',
//                     enabled: true,
//                     onConfirmation: () {
//                       _processPaymentConfirmation(ctx);
//                     },
//                   ),
//                 ),
//                 SizedBox(height: 8),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Future<Map<String, dynamic>?> _DetailsPaymentIntentsReload() async {
//     // This function mimics fetching payment details or intent status
//     // In a real scenario, this would call an API
//     // For now, we return null or mock data as appropriate based on current state
//     // If you have a specific API endpoint, please insert it here.

//     // Assuming it returns a Map with 'active_qr_session' and 'attaches' keys
//     // which are used in QrGenRef.
//     // If _InvoiceHistoryModels is empty, maybe return null.

//     // Placeholder implementation:
//     return null;
//   }

//   Future<void> _renewQrAndReload() async {
//     setState(() {
//       _uploadedSlipData = null;
//       base64_Slip = null;
//       fileName_Slip = null;
//       expiryUtc = DateTime.now().toUtc().add(Duration(seconds: _totalSecs));
//       _expireDialogShown = false;
//     });
//     // Reload data as if entering the page for the first time
//     await _initData();
//   }

//   Future<dynamic> sucress({VoidCallback? onDismiss}) async {
//     if (!mounted) return;
//     return PanaraInfoDialog.show(
//       context,
//       title: widget.cuslang == 'EN' ? 'Completed' : "ดำเนินการเสร็จสิ้น",
//       message: widget.cuslang == 'EN'
//           ? 'You can check your payment within 1-3 business days.'
//           : "สามารถตรวจสอบการชำระภายใน 1-3 วันทำการ",
//       buttonText: widget.cuslang == 'EN' ? 'OK' : "ตกลง",
//       onTapDismiss: () {
//         Navigator.pop(context);
//         if (onDismiss != null) onDismiss();
//       },
//       panaraDialogType: PanaraDialogType.success,
//       barrierDismissible: true,
//     );
//   }

//   void _showPaymentConfirmationSheet(BuildContext context) {
//     showModalBottomSheet(
//         isDismissible: false,
//         context: context,
//         isScrollControlled: true,
//         backgroundColor: Colors.transparent,
//         builder: (BuildContext context) {
//           return StatefulBuilder(
//               builder: (BuildContext context, StateSetter setStateSheet) {
//             return Container(
//               height: MediaQuery.of(context).size.height * 0.85,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//               ),
//               child: Column(
//                 children: [
//                   // Header
//                   Padding(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 16.0, vertical: 12.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           widget.cuslang == 'EN'
//                               ? 'Payment Confirmation'
//                               : 'ยืนยันการชำระเงิน',
//                           style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               fontFamily: Font_.Fonts_T),
//                         ),
//                         IconButton(
//                           icon: Icon(Icons.close, color: Colors.grey),
//                           onPressed: () => Navigator.pop(context),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Divider(height: 1),

//                   Flexible(
//                     child: SingleChildScrollView(
//                       padding: EdgeInsets.all(16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Instructions
//                           Container(
//                             padding: EdgeInsets.all(12),
//                             decoration: BoxDecoration(
//                               color: Colors.orange.shade50,
//                               borderRadius: BorderRadius.circular(8),
//                               border: Border.all(color: Colors.orange.shade200),
//                             ),
//                             child: Column(
//                               children: [
//                                 Row(
//                                   children: [
//                                     Icon(Icons.info_outline,
//                                         color: Colors.orange.shade800),
//                                     SizedBox(width: 10),
//                                     Expanded(
//                                       child: Text(
//                                         widget.cuslang == 'EN'
//                                             ? "Please upload proof of payment to complete the transaction."
//                                             : "กรุณาแนบหลักฐานการโอนเงินเพื่อดำเนินการให้เสร็จสมบูรณ์",
//                                         style: TextStyle(
//                                             color: Colors.orange.shade900,
//                                             fontFamily: Font_.Fonts_T,
//                                             fontWeight: FontWeight.bold),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                           SizedBox(height: 20),

//                           // Upload Section Check
//                           Text(
//                             widget.cuslang == 'EN'
//                                 ? "Upload Slip"
//                                 : "อัปโหลดสลิป",
//                             style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontFamily: Font_.Fonts_T,
//                                 fontSize: 16),
//                           ),
//                           SizedBox(height: 10),

//                           GestureDetector(
//                             onTap: () async {
//                               await uploadFile_Slip();
//                               // Force rebuild of the sheet to show the image
//                               setStateSheet(() {});

//                               // Show auto dialog removed - using Slider instead
//                               if (base64_Slip != null) {
//                                 _showSlideConfirmDialog(context);
//                               }
//                             },
//                             child: Container(
//                               width: double.infinity,
//                               height: 250,
//                               decoration: BoxDecoration(
//                                 color: Colors.grey.shade50,
//                                 borderRadius: BorderRadius.circular(12),
//                                 border: Border.all(
//                                     color: Colors.grey.shade300, width: 2),
//                               ),
//                               child: base64_Slip == null
//                                   ? Column(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         Icon(
//                                           Icons.cloud_upload_outlined,
//                                           size: 60,
//                                           color: Colors.blue.shade300,
//                                         ),
//                                         SizedBox(height: 10),
//                                         Text(
//                                           widget.cuslang == 'EN'
//                                               ? "Tap to upload payment slip"
//                                               : "กดเพื่ออัปโหลดสลิป",
//                                           style: TextStyle(
//                                               color: Colors.grey.shade600,
//                                               fontFamily: Font_.Fonts_T,
//                                               fontWeight: FontWeight.bold),
//                                         ),
//                                         Text(
//                                           "JPG, PNG (Max 10MB)",
//                                           style: TextStyle(
//                                               color: Colors.grey.shade400,
//                                               fontSize: 12),
//                                         ),
//                                       ],
//                                     )
//                                   : ClipRRect(
//                                       borderRadius: BorderRadius.circular(10),
//                                       child: Stack(
//                                         fit: StackFit.expand,
//                                         children: [
//                                           InteractiveViewer(
//                                             panEnabled: true,
//                                             minScale: 0.1,
//                                             maxScale: 4.0,
//                                             child: Image.memory(
//                                               base64Decode(
//                                                   base64_Slip.toString()),
//                                               fit: BoxFit.cover,
//                                             ),
//                                           ),
//                                           Container(
//                                             color:
//                                                 Colors.black.withOpacity(0.3),
//                                             child: Center(
//                                               child: Container(
//                                                 padding: EdgeInsets.symmetric(
//                                                     horizontal: 16,
//                                                     vertical: 8),
//                                                 decoration: BoxDecoration(
//                                                     color: Colors.white
//                                                         .withOpacity(0.8),
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             20)),
//                                                 child: Row(
//                                                   mainAxisSize:
//                                                       MainAxisSize.min,
//                                                   children: [
//                                                     Icon(Icons.edit, size: 16),
//                                                     SizedBox(width: 4),
//                                                     Text(
//                                                       widget.cuslang == 'EN'
//                                                           ? "Change"
//                                                           : "เปลี่ยนรูป",
//                                                       style: TextStyle(
//                                                           fontWeight:
//                                                               FontWeight.bold,
//                                                           fontFamily:
//                                                               Font_.Fonts_T),
//                                                     )
//                                                   ],
//                                                 ),
//                                               ),
//                                             ),
//                                           )
//                                         ],
//                                       ),
//                                     ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//                   // Footer Action
//                   Container(
//                     padding: EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withOpacity(0.1),
//                           spreadRadius: 1,
//                           blurRadius: 5,
//                           offset: Offset(0, -3),
//                         ),
//                       ],
//                     ),
//                     child: SizedBox(
//                       width: double.infinity,
//                       height: 60,
//                       child: Center(
//                         child: _SlideToConfirm(
//                           label: widget.cuslang == 'EN'
//                               ? 'Slide to Confirm'
//                               : 'เลื่อนเพื่อยืนยันการชำระเงิน',
//                           enabled: base64_Slip != null,
//                           onConfirmation: () async {
//                             // Confirm Logic
//                             List newValuePDFimg = [];
//                             for (int index = 0; index < 1; index++) {
//                               if (renTalModels[0].imglogo!.trim() != '') {
//                                 newValuePDFimg.add(
//                                     '${MyConstant().domain_chao}/files/$foder/logo/${renTalModels[0].imglogo!.trim()}');
//                               }
//                             }
//                             try {
//                               sucress();
//                               OKuploadFile_Slip(newValuePDFimg).then(
//                                   (value) => in_Trans_invoice(newValuePDFimg));
//                               Navigator.pop(
//                                   context); // Close sheet after success
//                             } catch (e) {
//                               _showMyDialogPay_Error(widget.cuslang == 'EN'
//                                   ? "An error occurred. Please check the information. Please try again!"
//                                   : 'เกิดข้อผิดพลาด ตรวจสอบความถูกต้อง กรุณาลองอีกครั้ง!');
//                             }
//                           },
//                         ),
//                       ),
//                     ),
//                   )
//                 ],
//               ),
//             );
//           });
//         });
//   }
// }

// // Custom Slide to Confirm Widget
// class _SlideToConfirm extends StatefulWidget {
//   final VoidCallback onConfirmation;
//   final String label;
//   final Color color;
//   final bool enabled;

//   const _SlideToConfirm({
//     Key? key,
//     required this.onConfirmation,
//     required this.label,
//     this.color = Colors.green,
//     this.enabled = true,
//   }) : super(key: key);

//   @override
//   __SlideToConfirmState createState() => __SlideToConfirmState();
// }

// class __SlideToConfirmState extends State<_SlideToConfirm> {
//   double _position = 0.0;
//   bool _confirmed = false;
//   final double _height = 55.0;
//   final double _handleWidth = 55.0;

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final maxWidth = constraints.maxWidth;
//         final maxDrag = maxWidth - _handleWidth;

//         return Container(
//           height: _height,
//           width: maxWidth,
//           decoration: BoxDecoration(
//             color: widget.enabled
//                 ? widget.color.withOpacity(0.2)
//                 : Colors.grey.shade300,
//             borderRadius: BorderRadius.circular(30),
//           ),
//           child: Stack(
//             children: [
//               Center(
//                 child: Text(
//                   widget.label,
//                   style: TextStyle(
//                     color: widget.enabled ? widget.color : Colors.grey,
//                     fontWeight: FontWeight.bold,
//                     fontFamily: Font_.Fonts_T,
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//               if (!_confirmed)
//                 Positioned(
//                   left: _position,
//                   child: GestureDetector(
//                     onHorizontalDragUpdate: (details) {
//                       if (!widget.enabled) return;
//                       setState(() {
//                         _position += details.delta.dx;
//                         _position = _position.clamp(0.0, maxDrag);
//                       });
//                     },
//                     onHorizontalDragEnd: (details) {
//                       if (!widget.enabled) return;
//                       if (_position >= maxDrag * 0.85) {
//                         setState(() {
//                           _position = maxDrag;
//                           _confirmed = true;
//                         });
//                         widget.onConfirmation();
//                       } else {
//                         setState(() {
//                           _position = 0.0;
//                         });
//                       }
//                     },
//                     child: Container(
//                       height: _height,
//                       width: _handleWidth,
//                       decoration: BoxDecoration(
//                         color: widget.enabled ? widget.color : Colors.grey,
//                         shape: BoxShape.circle,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black26,
//                             blurRadius: 4,
//                             offset: Offset(2, 2),
//                           )
//                         ],
//                       ),
//                       child: Icon(
//                         Icons.chevron_right,
//                         color: Colors.white,
//                         size: 30,
//                       ),
//                     ),
//                   ),
//                 ),
//               if (_confirmed)
//                 Positioned(
//                   right: 0,
//                   child: Container(
//                     height: _height,
//                     width: _height,
//                     decoration: BoxDecoration(
//                       color: widget.color,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(Icons.check, color: Colors.white),
//                   ),
//                 )
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// Future<Uint8List> buildQrPngWithCenterLogo({
//   required String data,
//   required String assetLogoPath,
//   String? bottomText, // Price
//   String? bottomname, // name
//   String? bottombankno, // bankno
//   String? bottomRef, // Ref
//   int sizePx = 1000,
// }) async {
//   // 1) QR matrix
//   final qrCode = qr_lib.QrCode(10, qr_lib.QrErrorCorrectLevel.M);
//   qrCode.addData(data);
//   // qrCode.make(); // ✅ สำคัญมาก
//   final qrImage = qr_lib.QrImage(qrCode);

//   final moduleCount = qrImage.moduleCount;
//   const int quietModule = 4;
//   final int totalModules = moduleCount + (quietModule * 2);

//   int scale = (sizePx / totalModules).floor();
//   if (scale < 1) scale = 1;
//   final int qrSize = totalModules * scale;

//   // (ถ้าจะไม่ใช้ footer จริง ๆ ตัด height ให้เท่า qrSize ก็ได้)
//   final int footerHeight = (qrSize * 0.40).round();
//   final int totalHeight = qrSize + footerHeight;

//   // 2) base image
//   final img = img_lib.Image(width: qrSize, height: totalHeight, numChannels: 4);
//   img_lib.fill(img, color: img_lib.ColorRgba8(255, 255, 255, 255));
//   final black = img_lib.ColorRgba8(0, 0, 0, 255);

//   // 3) draw modules
//   for (int y = 0; y < moduleCount; y++) {
//     for (int x = 0; x < moduleCount; x++) {
//       if (qrImage.isDark(y, x)) {
//         final xPos = (quietModule + x) * scale;
//         final yPos = (quietModule + y) * scale;
//         img_lib.fillRect(
//           img,
//           x1: xPos,
//           y1: yPos,
//           x2: xPos + scale - 1, // ✅ กันล้น
//           y2: yPos + scale - 1, // ✅ กันล้น
//           color: black,
//         );
//       }
//     }
//   }

//   // 4) center logo
//   try {
//     final bytes = await rootBundle.load(assetLogoPath);
//     final logoInput = img_lib.decodePng(bytes.buffer.asUint8List());
//     if (logoInput != null) {
//       final int logoW = (qrSize * 0.22).round();
//       final logoResized =
//           img_lib.copyResize(logoInput, width: logoW, height: logoW);

//       final int qrCenter = (qrSize / 2).round();
//       final int half = (logoW / 2).round();
//       final int bgPad = (logoW * 0.10).round();

//       img_lib.fillRect(
//         img,
//         x1: qrCenter - half - bgPad,
//         y1: qrCenter - half - bgPad,
//         x2: qrCenter + half + bgPad,
//         y2: qrCenter + half + bgPad,
//         color: img_lib.ColorRgba8(255, 255, 255, 255),
//       );

//       img_lib.compositeImage(img, logoResized,
//           dstX: qrCenter - half, dstY: qrCenter - half);
//     }
//   } catch (e) {
//     debugPrint("Logo CPU Error: $e");
//   }

//   // 5) Draw Footer (Pure CPU - English/Num Only)
//   try {
//     // Note: Image Lib v4 doesn't support TTF directly without external packages.
//     // Using built-in Arial font (Supports English & Numbers only).

//     // Positioning
//     int textY = qrSize + 40;

//     // Helper to draw text Centered
//     // void drawCpuText(String text, {required bool isLarge}) {
//     //   if (text.isEmpty) return;

//     //   // Auto-Translate Thai -> English
//     //   String safeText = text.replaceAll('฿', 'THB ');
//     //   safeText = safeText.replaceAll('ชำระภายใน', 'Pay within');
//     //   safeText = safeText.replaceAll('สัญญาปัจจุบัน', 'Contract');
//     //   safeText = safeText.replaceAll('ค่าปรับ', 'Fine');

//     //   // Select Font (Use Arial 48 for everything to be readable)
//     //   // If arial48 is not available in some versions, fallback to arial24.
//     //   // But typically v4 has arial48.
//     //   final font = img_lib.arial48;

//     //   // Estimate Text Width for Centering (Arial 48 is approx 24-30px width avg per char)
//     //   // This is a rough estimate but better than left align.
//     //   final estimatedCharWidth = 24;
//     //   final textWidth = safeText.length * estimatedCharWidth;
//     //   final xPos = (img.width - textWidth) ~/ 2;

//     //   img_lib.drawString(img, safeText,
//     //       font: font,
//     //       x: xPos > 0 ? xPos : 10, // Ensure not negative
//     //       y: textY,
//     //       color: img_lib.ColorRgba8(0, 0, 0, 255));

//     //   // Increase spacing for larger font
//     //   textY += 70;
//     // }

//     // // Draw Lines
//     // if (bottomText != null) drawCpuText(bottomText, isLarge: true);
//     // // if (bottomname != null) drawCpuText(bottomname, isLarge: false);
//     // if (bottombankno != null)
//     //   drawCpuText(bottombankno, isLarge: false); // Account No
//     // if (bottomRef != null) drawCpuText(bottomRef, isLarge: false); // Ref Line

//     // B. Draw Chao Logo (CPU Composite)
//     final chaoBytes = await rootBundle.load('images/Icon-chao.png');
//     final chaoImg = img_lib.decodePng(chaoBytes.buffer.asUint8List());
//     if (chaoImg != null) {
//       final int chaoW = (qrSize * 0.12).round();
//       final chaoResized =
//           img_lib.copyResize(chaoImg, width: chaoW, height: chaoW);
//       final int xPos = (qrSize - chaoW) ~/ 2;
//       final int yPos = totalHeight - chaoW - 20;
//       img_lib.compositeImage(img, chaoResized, dstX: xPos, dstY: yPos);
//     }
//   } catch (e) {
//     debugPrint("Footer CPU Error: $e");
//   }

//   return img_lib.encodePng(img);
// }

// // Future<Uint8List> buildQrPngWithCenterLogo({
// //   required String data,
// //   required String assetLogoPath,
// //   String? bottomText, // Price
// //   String? bottomRef, // Ref
// //   int sizePx = 1000,
// // }) async {
// //   // 1. Generate QR Matrix
// //   final qrCode = qr_lib.QrCode(10, qr_lib.QrErrorCorrectLevel.M);
// //   qrCode.addData(data);
// //   final qrImage = qr_lib.QrImage(qrCode);

// //   final moduleCount = qrImage.moduleCount;
// //   int quietModule = 4;
// //   int totalModules = moduleCount + (quietModule * 2);

// //   int scale = (sizePx / totalModules).round();
// //   if (scale < 1) scale = 1;
// //   int qrSize = totalModules * scale;

// //   // Footer: 40% of QR Height
// //   int footerHeight = (qrSize * 0.40).round();
// //   int totalHeight = qrSize + footerHeight;

// //   // 2. Create Base Image (CPU)
// //   final image =
// //       img_lib.Image(width: qrSize, height: totalHeight, numChannels: 4);
// //   img_lib.fill(image, color: img_lib.ColorRgba8(255, 255, 255, 255));

// //   final colorBlack = img_lib.ColorRgba8(0, 0, 0, 255);

// //   // 3. Draw Modules
// //   for (int y = 0; y < moduleCount; y++) {
// //     for (int x = 0; x < moduleCount; x++) {
// //       if (qrImage.isDark(y, x)) {
// //         int xPos = (quietModule + x) * scale;
// //         int yPos = (quietModule + y) * scale;
// //         img_lib.fillRect(image,
// //             x1: xPos,
// //             y1: yPos,
// //             x2: xPos + scale,
// //             y2: yPos + scale,
// //             color: colorBlack);
// //       }
// //     }
// //   }

// //   // 4. Draw Center Logo (Thai QR)
// //   try {
// //     final bytes = await rootBundle.load(assetLogoPath);
// //     final logoInput = img_lib.decodePng(bytes.buffer.asUint8List());
// //     if (logoInput != null) {
// //       int logoW = (qrSize * 0.22).round();
// //       final logoResized =
// //           img_lib.copyResize(logoInput, width: logoW, height: logoW);

// //       int qrCenter = (qrSize / 2).round();
// //       int half = (logoW / 2).round();
// //       int bgPad = (logoW * 0.1).round();

// //       // White Background Pad
// //       img_lib.fillRect(image,
// //           x1: qrCenter - half - bgPad,
// //           y1: qrCenter - half - bgPad,
// //           x2: qrCenter + half + bgPad,
// //           y2: qrCenter + half + bgPad,
// //           color: img_lib.ColorRgba8(255, 255, 255, 255));
// //       // Logo
// //       img_lib.compositeImage(image, logoResized,
// //           dstX: qrCenter - half, dstY: qrCenter - half);
// //     }
// //   } catch (e) {
// //     debugPrint("Logo CPU Error: $e");
// //   }

// //   // 5. Draw Footer (Text + Chao Logo)
// //   try {
// //     // Text Info (Price / Ref) - Disabled (Screen Capture will provide text)
// //     /*
// //     try {
// //       int textY = qrSize + 20;
// //       if (bottomText != null) {
// //          // img_lib.drawString(image, bottomText, font: img_lib.arial_14, x: 40, y: textY, color: colorBlack);
// //          textY += 30;
// //       }
// //       if (bottomRef != null) {
// //          // img_lib.drawString(image, bottomRef, font: img_lib.arial_14, x: 40, y: textY, color: colorBlack);
// //       }
// //     } catch (e) {
// //        debugPrint("Text Draw Error: $e");
// //     }
// //     */

// //     // Chao Logo (Bottom Center)
// //     final chaoBytes = await rootBundle.load('images/Icon-chao.png');
// //     final chaoImg = img_lib.decodePng(chaoBytes.buffer.asUint8List());
// //     if (chaoImg != null) {
// //       int chaoW = (qrSize * 0.12).round();
// //       final chaoResized = img_lib.copyResize(chaoImg,
// //           width: chaoW, height: chaoW); // Square logo
// //       int xPos = (qrSize / 2).round() - (chaoW / 2).round();
// //       int yPos = totalHeight - chaoW - 20;
// //       img_lib.compositeImage(image, chaoResized, dstX: xPos, dstY: yPos);
// //     }
// //   } catch (e) {
// //     debugPrint("Footer CPU Error: $e");
// //   }

// //   return img_lib.encodePng(image);
// // }

// void showIOSSaveOverlay(Uint8List bytes, {required bool isEN}) {
//   html.document.getElementById('qr_save_overlay')?.remove();

//   final base64 = base64Encode(bytes);
//   final dataUrl = 'data:image/png;base64,$base64';

//   final overlay = html.DivElement()
//     ..id = 'qr_save_overlay'
//     ..style.position = 'fixed'
//     ..style.left = '0'
//     ..style.top = '0'
//     ..style.right = '0'
//     ..style.bottom = '0'
//     ..style.backgroundColor = 'rgba(0,0,0,0.9)'
//     ..style.display = 'flex'
//     ..style.flexDirection = 'column'
//     ..style.alignItems = 'center'
//     ..style.justifyContent = 'center'
//     ..style.zIndex = '2147483647';

//   final img = html.ImageElement(src: dataUrl)
//     ..style.maxWidth = '85vw'
//     ..style.maxHeight = '65vh'
//     ..style.borderRadius = '12px'
//     ..style.backgroundColor = '#FFFFFF' // ✅ เพิ่มพื้นขาวให้ QR
//     ..style.padding = '16px' // ✅ เพิ่ม padding รอบ QR
//     ..style.boxShadow = '0 4px 20px rgba(0,0,0,0.3)' // เพิ่มเงาให้สวย
//     // ✅ บังคับให้ iOS แสดงเมนู Save เมื่อกดค้าง
//     ..style.setProperty('-webkit-touch-callout', 'default')
//     ..style.pointerEvents = 'auto';

//   final hint = html.DivElement()
//     ..text = isEN ? 'Long-press the image to Save' : 'กดค้างที่รูปเพื่อบันทึก'
//     ..style.color = '#fff'
//     ..style.fontSize = '16px'
//     ..style.marginTop = '20px'
//     ..style.textAlign = 'center'
//     ..style.padding = '0 16px';

//   final closeBtn = html.ButtonElement()
//     ..text = isEN ? 'Close' : 'ปิด'
//     ..style.marginTop = '14px'
//     ..style.padding = '10px 18px'
//     ..style.borderRadius = '10px'
//     ..style.border = 'none'
//     ..style.backgroundColor = '#FFFFFF'
//     ..style.color = '#000000'
//     ..style.fontSize = '16px'
//     ..style.cursor = 'pointer';

//   closeBtn.onClick.listen((_) => overlay.remove());
//   img.onClick.listen((e) => e.stopPropagation());

//   overlay.children.addAll([img, hint, closeBtn]);
//   html.document.body?.append(overlay);
// }
