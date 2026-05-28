import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Constant/Myconstant.dart';
import '../Model/GetInvoice_Model.dart';
import '../Model/GetInvoice_pay_Model.dart';
import '../Model/GetTeNant_Model.dart';
import '../color.dart';
import '../main.dart';
import 'Screen_new/fitness_app_home_screen.dart';
import 'Screen_new/fitness_app_theme.dart';
import 'Screen_new/training/training_pay_screen.dart';
import 'pay_bill_screen_Choice.dart';

class PaybillMainScreenChoice extends StatefulWidget {
  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;
  final List<TeNantModel>? teNantModel;
  final String? cuslang;
  const PaybillMainScreenChoice(
      {super.key,
      this.mainScreenAnimationController,
      this.mainScreenAnimation,
      this.teNantModel,
      this.cuslang});

  @override
  State<PaybillMainScreenChoice> createState() =>
      _PaybillMainScreenChoiceState();
}

class _PaybillMainScreenChoiceState extends State<PaybillMainScreenChoice> {
  var nFormat = NumberFormat("#,##0.00", "en_US");
  DateTime datex = DateTime.now();
  int tap_pay = 0;
  ////--------------------->
  List<InvoicePayModel> invoicePayModels = [];
  List<InvoiceModel> _InvoiceModels = [];
  List<InvoiceModel> invoicePayModels2 = [];
  List<dynamic> InvoicePay = [];
  ////--------------------->
  double sum_pvat = 0.00,
      sum_vat = 0.00,
      sum_wht = 0.00,
      sum_amt = 0.00,
      sum_dis = 0.00,
      sum_disamt = 0.00,
      sum_disp = 0,
      in_amt = 0,
      sum_tran_fine = 0,
      fine_total = 0,
      sum_tran_fine_in = 0,
      sum_pvat_in = 0,
      sum_vat_in = 0,
      sum_wht_in = 0,
      sum_amt_in = 0,
      sum_disamt_in = 0;
  int ref_new = 0;
  String? return_qr_img, invoiceAll, return_qr_refapi, return_img;
  bool _isLoading = true;
  Timer? _timer;
  String countdownText = '';
  ////--------------------->
  @override
  void initState() {
    red_Invoice().then((value) => Check_genref_pay());
    Check_time();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Make sure to cancel the timer when widget is disposed
    super.dispose();
  }

  Future<Null> Check_time() async {
    final now = DateTime.now();
    print('เช็คว่าเวลาปัจจุบัน ${now.hour}:${now.minute}');

    // เช็คว่าเวลาปัจจุบันอยู่ในช่วง 23:00 - 01:00
    if (now.hour == 23 || now.hour == 0) {
      Future.delayed(const Duration(milliseconds: 200), () {
        PanaraInfoDialog.showAnimatedGrow(
          context,
          title: "Oops",
          message: widget.cuslang == 'EN'
              ? 'Transactions cannot be made between 11:00 PM and 1:00 AM.'
              : "ไม่สามารถทำรายการได้ในช่วงเวลา 23.00 ถึง 01.00",
          buttonText: widget.cuslang == 'EN' ? 'OK' : "รับทราบ",
          onTapDismiss: () async {
            SharedPreferences preferences =
                await SharedPreferences.getInstance();
            var custno = preferences.getString('custno');
            Navigator.of(
              context,
              rootNavigator: true,
            ).pop();
            Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (context) {
              return FitnessAppHomeScreen(custno_s: custno);
            }), (route) => false);
          },
          panaraDialogType: PanaraDialogType.error,
          barrierDismissible: false,
        );
      });
    }
  }

  Future<Null> Check_genref_pay() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer') ?? '0';
    var user = preferences.getString('ser');
    String? custno = preferences.getString('custno');
    setState(() {
      InvoicePay.clear();
      invoicePayModels2.clear();
    });

    // สร้าง String ที่เป็น docno ที่มีค่า จาก _InvoiceModels
    String formattedDocnos =
        _InvoiceModels.where((e) => e.docno != null && e.docno!.isNotEmpty)
            .map((e) => "'${e.docno}'")
            .join(',');

    print('Check_genref_inv1');
    print('$custno invs: $formattedDocnos');

    // หากไม่มี docno เลย จะไม่ยิง API
    if (formattedDocnos.isEmpty) {
      print('No invoice docno found, skipping API call.');
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });
      });
      return;
    }

    String url = '${MyConstant().domain_chaoV2}/check_genqr_new.php';
    // 'http://192.168.1.227/test_chao/chao_api/v2/check_genqr_new.php';
    // print('API URL >>>> $url');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "isAdd": true,
          "ren": ren,
          "invoice": formattedDocnos,
          "custno": custno,
        }),
      );

      print("=== Response Status Code: ${response.statusCode} ===");
      // print("=== Response Body: ${response.body} ===");

      // ตรวจสอบว่าได้ response 200 และมีข้อมูลไม่ว่าง
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final result = json.decode(response.body);

        if (result["data"] != null && result["data"] is Map<String, dynamic>) {
          (result["data"] as Map<String, dynamic>).forEach((key, value) {
            // print("Invoice Group Key: $key");

            for (var entry in value) {
              // print("IMG Debug: ${entry["img"]}");

              Map<String, dynamic> map = {
                'ser': entry["ser"]?.toString() ?? '',
                'docno': entry["invoice"]?.toString() ?? '',
                'refapi': entry["ref_id"]?.toString() ?? '',
                'amtall': entry["amt"]?.toString() ?? '',
                'cid': entry["cid"]?.toString() ?? '',
                'custno': entry["custno"]?.toString() ?? '',
                'datex': entry["datex"]?.toString() ?? '',
                'ser_user': entry["ser_user"]?.toString() ?? '',
                'note': entry["name"]?.toString() ?? '',

                // ✅ แก้ตรงนี้ให้เป็น String จาก List ด้วย jsonEncode
                'billno': (entry["invoices"] is List)
                    ? jsonEncode(entry["invoices"])
                    : entry["invoices"]?.toString() ?? '',

                'img': (entry["img"] is List)
                    ? jsonEncode(entry["img"])
                    : entry["img"]?.toString() ?? '',

                'date': entry["datex"]?.toString() ?? '',
              };

              final model = InvoiceModel.fromJson(map);

              setState(() {
                invoicePayModels2.add(model);
              });
            }
          });
        } else {
          print("⚠️ result['data'] ไม่ใช่ Map<String, dynamic>");
        }
      } else {
        print(
            "${_InvoiceModels.length} ❌ ไม่ได้ข้อมูลจาก server หรือ statusCode ไม่ใช่ 200");
      }
    } catch (e) {
      print("Check_genref_pay error: $e");
    }

    // print("invoicePayModels2 length: ${invoicePayModels2.length}");

    // Sort: เอาที่ไม่มีใน pay list ขึ้นก่อน
    try {
      _InvoiceModels.sort((a, b) {
        final aInPayList = invoicePayModels2
            .any((e) => e.docno.toString() == a.docno.toString());
        final bInPayList = invoicePayModels2
            .any((e) => e.docno.toString() == b.docno.toString());

        if (aInPayList != bInPayList) {
          return aInPayList ? 1 : -1; // เอาอันที่ไม่มีอยู่ใน pay list ไว้บนสุด
        } else {
          final aDoc = a.docno ?? '';
          final bDoc = b.docno ?? '';
          return aDoc.compareTo(bDoc); // จัดเรียงตามชื่อ docno ปกติ
        }
      });
    } catch (e) {}
// 🔽 Sort: 1) ไม่มีใน pay list ขึ้นก่อน  2) ไม่มีรูปขึ้นก่อน  3) เรียงตาม docno
    print('ก่อนเรียง:');
    // _InvoiceModels.forEach((e) => print('${e.docno} ${e.img}'));

    // _InvoiceModels.sort((a, b) {
    //   final aInPayList = invoicePayModels2.any((e) => e.docno == a.docno);
    //   final bInPayList = invoicePayModels2.any((e) => e.docno == b.docno);

    //   if (aInPayList != bInPayList) return aInPayList ? 1 : -1;

    //   final aHasImg = a.img is List && (a.img as List).isNotEmpty;
    //   final bHasImg = b.img is List && (b.img as List).isNotEmpty;

    //   if (aHasImg != bHasImg) return aHasImg ? 1 : -1;

    //   return (a.docno ?? '').compareTo(b.docno ?? '');
    // });

    // print('หลังเรียง:');
    // _InvoiceModels.forEach((e) => print('${e.docno} ${e.img}'));

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<Null> red_Invoice() async {
    setState(() {
      _InvoiceModels.clear();
      // invoicePayModels.clear();
      sum_disamt_in = 0;
      in_amt = 0;
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var qutser_ = preferences.getString('qutser');
    if (widget.teNantModel == null) {
      ////////////////------------------------------------------------------>
      var ciddoc_ = preferences.getString('usercid');
      ////////////////------------------------------------------------------>

      String url =
          '${MyConstant().domain_chao}/GC_bill_invoice.php?isAdd=true&ren=$ren&ciddoc=$ciddoc_&qutser=$qutser_';
      // print(url);
      try {
        var response = await http.get(Uri.parse(url));

        var result = json.decode(response.body);

        if (result.toString() != 'null') {
          // _InvoiceModels.clear();
          for (var map in result) {
            InvoiceModel _InvoiceModel = InvoiceModel.fromJson(map);
            var in_amtx = double.parse(_InvoiceModel.amtall!);
            var in_docnox = _InvoiceModel.docno;
            var in_ser = _InvoiceModel.ser;
            var in_amtall = _InvoiceModel.amtall;
            var disendbill = double.parse(_InvoiceModel.disendbill!);
            // print('>>>_InvoiceModel>>>>> ${_InvoiceModel.refapi}');
            setState(() {
              sum_disamt_in = sum_disamt_in + disendbill;
              in_amt = in_amt + in_amtx;
              // invoicePayModels.add(invoicePayModel);
              _InvoiceModels.add(_InvoiceModel);
            });
          }
        }
      } catch (e) {}
      // _InvoiceModels.sort((a, b) {
      //   final aDoc = a.docno ?? '';
      //   final bDoc = b.docno ?? '';
      //   return aDoc.compareTo(bDoc);
      // });

      // //print(
      //     'setState >>>> ${(sum_pvat + sum_tran_fine - dis_sum_Pakan - (sum_disamt + sum_disamt_in) + (sum_pvat_in + sum_tran_fine_in) + (fine_total))}');
    } else {
      ////////////////------------------------------------------------------>
      for (var i = 0; i < widget.teNantModel!.length; i++) {
        var ciddoc_ = widget.teNantModel![i].cid;
        // //print(ciddoc_);
        String url =
            '${MyConstant().domain_chao}/GC_bill_invoice.php?isAdd=true&ren=$ren&ciddoc=$ciddoc_&qutser=$qutser_';
        // print(url);
        try {
          var response = await http.get(Uri.parse(url));

          var result = json.decode(response.body);

          if (result.toString() != 'null') {
            // sum_disamt_in = 0;
            // in_amt = 0;
            // _InvoiceModels.clear();
            for (var map in result) {
              InvoiceModel _InvoiceModel = InvoiceModel.fromJson(map);
              var in_amtx = double.parse(_InvoiceModel.amtall!);
              var in_docnox = _InvoiceModel.docno;
              var in_ser = _InvoiceModel.ser;
              var in_amtall = _InvoiceModel.amtall;
              var disendbill = double.parse(_InvoiceModel.disendbill!);

              setState(() {
                sum_disamt_in = sum_disamt_in + disendbill;
                in_amt = in_amt + in_amtx;
                // invoicePayModels.add(invoicePayModel);
                _InvoiceModels.add(_InvoiceModel);
              });
            }
            print('_InvoiceModels >> ${_InvoiceModels.length}');
          }
        } catch (e) {}
      }

      // _InvoiceModels.sort((a, b) {
      //   final aDoc = a.docno ?? '';
      //   final bDoc = b.docno ?? '';
      //   return aDoc.compareTo(bDoc);
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    return (tap_pay == 1)
        ? PayBillscreenChoice(
            mainScreenAnimation: widget.mainScreenAnimation,
            mainScreenAnimationController:
                widget.mainScreenAnimationController!,
            teNantModel: widget.teNantModel,
            cuslang: widget.cuslang,
            ref_new: ref_new.toString(),
            get_qr_img: return_qr_img.toString(),
            invoiceAll: invoiceAll.toString(),
            invoicePayModels2: invoicePayModels2,
            get_refapi: return_qr_refapi.toString(),
            get_img: return_img.toString(),
            totalinvoicePayModels: _InvoiceModels,
          )
        : _isLoading
            ? Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.85,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 30, // ปรับขนาดของ CircleAvatar
                          backgroundImage:
                              AssetImage('assets/images/Icon-chao.png'),
                        ),
                      ),
                      LoadingAnimationWidget.inkDrop(
                        color: Colors.indigo,
                        size: 70,
                      ),
                    ],
                  ),
                ),
              )
            : (_InvoiceModels.length == 0 && !_isLoading)
                ? Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.85,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            radius: 60, // ปรับขนาดของ CircleAvatar
                            backgroundImage:
                                AssetImage('assets/fitness_app/area2x.png'),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.only(right: 20.0, left: 20.0),
                            child: Text(
                              widget.cuslang == 'EN'
                                  ? 'No information or no items to be paid'
                                  : 'ไม่มีข้อมูลหรือไม่มีรายการที่ต้องชำระ',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontFamily: Font_.Fonts_T,
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.only(right: 8.0, left: 8.0),
                            child: Text(
                              widget.cuslang == 'EN'
                                  ? '( Attach proof of past transfer. Please go to the payment history menu. )'
                                  : '( แนบหลักฐานการโอนย้อนหลัง กรุณาไปที่เมนูประวัติชำระ. )',
                              maxLines: 2,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontFamily: Font_.Fonts_T,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : AnimatedBuilder(
                    animation: widget.mainScreenAnimationController!,
                    builder: (BuildContext context, Widget? child) {
                      return FadeTransition(
                          opacity: widget.mainScreenAnimation!,
                          child: Transform(
                              transform: Matrix4.translationValues(
                                  0.0,
                                  30 *
                                      (1.0 - widget.mainScreenAnimation!.value),
                                  0.0),
                              child: ScrollConfiguration(
                                  behavior: ScrollConfiguration.of(context)
                                      .copyWith(dragDevices: {
                                    PointerDeviceKind.touch,
                                    PointerDeviceKind.mouse,
                                  }),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8, right: 8, top: 2, bottom: 100),
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        int crossAxisCount = 1;
                                        double aspectRatio = 5.0;
                                        double padding = 2;
                                        double bottom_x = 20;
                                        double width_x = 100;
                                        double height_x = 50;

                                        if (kIsWeb) {
                                          // เฉพาะบน Web/Desktop
                                          if (constraints.maxWidth >= 1400) {
                                            crossAxisCount = 4;
                                            aspectRatio = 3.85;
                                            padding = 2;
                                            width_x = 70;
                                            height_x = 50;
                                          } else if (constraints.maxWidth >=
                                              1000) {
                                            crossAxisCount = 3;
                                            aspectRatio = 3.9;
                                            padding = 2;
                                            bottom_x = 20;
                                            width_x = 70;
                                            height_x = 50;
                                          } else if (constraints.maxWidth >=
                                              800) {
                                            crossAxisCount = 2;
                                            aspectRatio = 3.0;
                                            bottom_x = 40;
                                            width_x = 80;
                                            height_x = 50;
                                          } else if (constraints.maxWidth >=
                                              400) {
                                            crossAxisCount = 1;
                                            aspectRatio = 8.0;
                                            bottom_x = 40;
                                            width_x = 80;
                                            height_x = 50;
                                          }
                                        }
                                        // เช็คว่าหน้าจอกว้างพอที่จะเป็น 2 คอลัมน์ไหม
                                        final isWideScreen =
                                            constraints.maxWidth > 600;

                                        return GridView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: _InvoiceModels.length,
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: crossAxisCount,
                                            mainAxisSpacing: 1.0,
                                            crossAxisSpacing: 1.0,
                                            childAspectRatio: aspectRatio,
                                          ),
                                          itemBuilder: (context, index) {
                                            final isPaid =
                                                invoicePayModels2.any(
                                              (e) =>
                                                  e.docno.toString() ==
                                                  _InvoiceModels[index]
                                                      .docno
                                                      .toString(),
                                            );
                                            InvoiceModel? matched;
                                            try {
                                              matched =
                                                  invoicePayModels2.firstWhere(
                                                (e) =>
                                                    e.docno.toString() ==
                                                    _InvoiceModels[index]
                                                        .docno
                                                        .toString(),
                                              );
                                            } catch (e) {
                                              matched = null;
                                            }

                                            final images_x = matched?.img ?? [];
                                            final idate_x = matched?.date ?? '';

                                            // final isPaid = invoicePayModels2.any(
                                            //     (e) =>
                                            //         e.docno.toString() ==
                                            //         _InvoiceModels[index]
                                            //             .docno
                                            //             .toString());
                                            // final images_x = invoicePayModels2
                                            //     .firstWhere((e) =>
                                            //         e.docno.toString() ==
                                            //         _InvoiceModels[index]
                                            //             .docno
                                            //             .toString())
                                            //     .img;
                                            // final idate_x = invoicePayModels2
                                            //     .firstWhere((e) =>
                                            //         e.docno.toString() ==
                                            //         _InvoiceModels[index]
                                            //             .docno
                                            //             .toString())
                                            //     .date;

                                            return SizedBox(
                                              width: double.infinity,
                                              child: Stack(
                                                children: <Widget>[
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 5,
                                                            left: 8,
                                                            right: 8,
                                                            bottom: 5),
                                                    child: InkWell(
                                                      onTap: () async {
                                                        String? billno,
                                                            ref_id,
                                                            amt,
                                                            cid,
                                                            custno,
                                                            name,
                                                            images;
                                                        try {
                                                          billno = invoicePayModels2
                                                              .firstWhere((e) =>
                                                                  e.docno
                                                                      .toString() ==
                                                                  _InvoiceModels[
                                                                          index]
                                                                      .docno
                                                                      .toString())
                                                              .billno;

                                                          ref_id = invoicePayModels2
                                                              .firstWhere((e) =>
                                                                  e.docno
                                                                      .toString() ==
                                                                  _InvoiceModels[
                                                                          index]
                                                                      .docno
                                                                      .toString())
                                                              .refapi;
                                                          cid = invoicePayModels2
                                                              .firstWhere((e) =>
                                                                  e.docno
                                                                      .toString() ==
                                                                  _InvoiceModels[
                                                                          index]
                                                                      .docno
                                                                      .toString())
                                                              .cid;
                                                          custno = invoicePayModels2
                                                              .firstWhere((e) =>
                                                                  e.docno
                                                                      .toString() ==
                                                                  _InvoiceModels[
                                                                          index]
                                                                      .docno
                                                                      .toString())
                                                              .custno;
                                                          amt = invoicePayModels2
                                                              .firstWhere((e) =>
                                                                  e.docno
                                                                      .toString() ==
                                                                  _InvoiceModels[
                                                                          index]
                                                                      .docno
                                                                      .toString())
                                                              .amtall;
                                                          images = invoicePayModels2
                                                              .firstWhere((e) =>
                                                                  e.docno
                                                                      .toString() ==
                                                                  _InvoiceModels[
                                                                          index]
                                                                      .docno
                                                                      .toString())
                                                              .img;
                                                        } catch (e) {
                                                          billno = null;
                                                        }

                                                        String formattedBillno =
                                                            '';

                                                        if (billno != null &&
                                                            billno.isNotEmpty) {
                                                          // เคลียร์ [ ] ถ้ามี
                                                          String clean = billno
                                                              .replaceAll(
                                                                  '[', '')
                                                              .replaceAll(
                                                                  ']', '');

                                                          // แยกเป็นลิสต์ และ trim ช่องว่าง
                                                          List<String>
                                                              billList = clean
                                                                  .split(',')
                                                                  .map((e) =>
                                                                      e.trim())
                                                                  .toList();

                                                          // แปลงเป็น "'xxx', 'yyy'"
                                                          formattedBillno =
                                                              billList
                                                                  .map((e) =>
                                                                      "'$e'")
                                                                  .join(',');
                                                        }

                                                        print(formattedBillno);

                                                        print(formattedBillno);
                                                        print(index);
                                                        print(billno);
                                                        print(ref_id);

                                                        setState(() {
                                                          if (billno
                                                                  .toString() !=
                                                              'null') {
                                                            return_qr_img =
                                                                'ref_id=$ref_id&incid=$cid&sum=${double.tryParse(amt.toString())}';

                                                            ref_new = 0;
                                                          } else {
                                                            ref_new = 1;
                                                            return_qr_img =
                                                                'ref_id=$ref_id&incid=$cid&sum=${amt}';
                                                          }
                                                          tap_pay = 1;

                                                          invoiceAll =
                                                              formattedBillno;
                                                          return_qr_refapi =
                                                              ref_id;
                                                          return_img = images;
                                                        });
                                                        print(return_img);
                                                        // MaterialPageRoute route =
                                                        //     MaterialPageRoute(
                                                        //   builder: (context) =>
                                                        //       FitnessAppHomeScreen(
                                                        //           pageroot: 'INVOICE'),
                                                        // );
                                                        // Navigator.pushAndRemoveUntil(
                                                        //     context, route, (route) => false);
                                                        // MaterialPageRoute route =
                                                        //     MaterialPageRoute(
                                                        //   builder: (context) =>
                                                        //       PayBillscreenChoice(),
                                                        // );
                                                        // Navigator.pushAndRemoveUntil(
                                                        //     context, route, (route) => false);
                                                      },
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          boxShadow: <BoxShadow>[
                                                            BoxShadow(
                                                                color: Colors
                                                                    .grey
                                                                    .withOpacity(
                                                                        0.5),
                                                                //  HexColor(
                                                                //         '#FBF3D5')
                                                                //     .withOpacity(
                                                                //         0.6),
                                                                offset:
                                                                    const Offset(
                                                                        1.1,
                                                                        2.0),
                                                                blurRadius:
                                                                    4.0),
                                                          ],
                                                          gradient: LinearGradient(
                                                              begin: Alignment
                                                                  .topLeft,
                                                              end: Alignment
                                                                  .bottomRight,
                                                              colors: <HexColor>[
                                                                HexColor(
                                                                    '#ECE3CE'),
                                                                HexColor(
                                                                    '#F3EEEA'),
                                                                // HexColor('#FFBE98'),
                                                                // HexColor('#F6995C')
                                                              ]),
                                                          // gradient: (!isPaid)
                                                          //     ? LinearGradient(
                                                          //         colors: <HexColor>[
                                                          //           HexColor(
                                                          //               '#FF8080'),
                                                          //           HexColor(
                                                          //               '#EF4B4B'),
                                                          //         ],
                                                          //         begin: Alignment
                                                          //             .topLeft,
                                                          //         end: Alignment
                                                          //             .bottomRight,
                                                          //       )
                                                          //     : LinearGradient(
                                                          //         colors: <HexColor>[
                                                          //           HexColor(
                                                          //               '#6B7AA1'),
                                                          //           HexColor(
                                                          //               '#354259'),
                                                          //         ],
                                                          //         begin: Alignment
                                                          //             .topLeft,
                                                          //         end: Alignment
                                                          //             .bottomRight,
                                                          //       ),
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .only(
                                                            bottomRight:
                                                                Radius.circular(
                                                                    8.0),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    8.0),
                                                            topLeft:
                                                                Radius.circular(
                                                                    8.0),
                                                            topRight:
                                                                Radius.circular(
                                                                    8.0),
                                                          ),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              flex: 3,
                                                              child: InkWell(
                                                                onTap:
                                                                    () async {},
                                                                child:
                                                                    Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    boxShadow: <BoxShadow>[
                                                                      BoxShadow(
                                                                          color: HexColor('#FBF3D5').withOpacity(
                                                                              0.6),
                                                                          offset: const Offset(
                                                                              1.1,
                                                                              4.0),
                                                                          blurRadius:
                                                                              8.0),
                                                                    ],
                                                                    gradient: (!isPaid)
                                                                        ? LinearGradient(
                                                                            colors: <HexColor>[
                                                                              HexColor('#FF8080'),
                                                                              HexColor('#EF4B4B'),
                                                                            ],
                                                                            begin:
                                                                                Alignment.topLeft,
                                                                            end:
                                                                                Alignment.bottomRight,
                                                                          )
                                                                        : LinearGradient(
                                                                            colors: <HexColor>[
                                                                              HexColor('#6B7AA1'),
                                                                              HexColor('#354259'),
                                                                            ],
                                                                            begin:
                                                                                Alignment.topLeft,
                                                                            end:
                                                                                Alignment.bottomRight,
                                                                          ),
                                                                    borderRadius:
                                                                        const BorderRadius
                                                                            .only(
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              8.0),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              8.0),
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              8.0),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              54.0),
                                                                    ),
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        top: 20,
                                                                        left:
                                                                            16,
                                                                        right:
                                                                            16,
                                                                        bottom:
                                                                            8),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: <Widget>[
                                                                        Expanded(
                                                                          child:
                                                                              Text(
                                                                            '${_InvoiceModels[index].cid}',
                                                                            textAlign:
                                                                                TextAlign.start,
                                                                            maxLines:
                                                                                1,
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 10,
                                                                              fontFamily: FitnessAppTheme.fontName,
                                                                              fontWeight: FontWeight.bold,
                                                                              // fontSize: 16,
                                                                              letterSpacing: 0.2,
                                                                              color: FitnessAppTheme.white,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 6,
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Expanded(
                                                                        flex: 4,
                                                                        child:
                                                                            Padding(
                                                                          padding: EdgeInsets.only(
                                                                              right: 8.0,
                                                                              left: 8.0),
                                                                          child:
                                                                              Text(
                                                                            '${_InvoiceModels[index].docno}',
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 14,
                                                                              color: Colors.black,
                                                                              fontFamily: Font_.Fonts_T,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 2,
                                                                        child:
                                                                            Text(
                                                                          (isPaid)
                                                                              ? ''
                                                                              : (_InvoiceModels[index].total_bill == null)
                                                                                  ? '0.00'
                                                                                  : '${nFormat.format(double.parse(_InvoiceModels[index].total_bill!))}',
                                                                          textAlign:
                                                                              TextAlign.end,
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            color:
                                                                                Colors.black,
                                                                            fontFamily:
                                                                                Font_.Fonts_T,
                                                                          ),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Expanded(
                                                                        flex: 4,
                                                                        child:
                                                                            Padding(
                                                                          padding: EdgeInsets.only(
                                                                              right: 8.0,
                                                                              left: 8.0),
                                                                          child:
                                                                              Text(
                                                                            (() {
                                                                              DateTime? targetDate;

// เช็ควันที่เป้าหมาย จากสถานะ isPaid
                                                                              if (!isPaid) {
                                                                                if (_InvoiceModels[index].date != null && _InvoiceModels[index].date.toString().isNotEmpty) {
                                                                                  targetDate = DateTime.tryParse(_InvoiceModels[index].date!);
                                                                                }
                                                                              } else {
                                                                                if (idate_x != null && idate_x.toString().isNotEmpty) {
                                                                                  targetDate = DateTime.tryParse(idate_x.toString());
                                                                                }
                                                                              }

// ถ้าไม่มี targetDate ให้คืนค่าว่าง
                                                                              if (targetDate == null)
                                                                                return '';

// เปรียบเทียบเฉพาะวันที่เท่านั้น
                                                                              final now = DateTime.now();
                                                                              final nowDateOnly = DateTime(now.year, now.month, now.day);
                                                                              final targetDateOnly = DateTime(targetDate.year, targetDate.month, targetDate.day);
                                                                              final difference = targetDateOnly.difference(nowDateOnly);

// ถ้าเลยกำหนด
                                                                              if (difference.isNegative) {
                                                                                return (!isPaid)
                                                                                    ? widget.cuslang == 'EN'
                                                                                        ? 'Overdue.'
                                                                                        : 'เกินกำหนดชำระ'
                                                                                    : DateFormat('dd-MM-yyyy').format(nowDateOnly);
                                                                              }

// เหลือเวลากี่วัน ชม. นาที
                                                                              final daysLeft = difference.inDays;
                                                                              final hoursLeft = difference.inHours % 24;
                                                                              final minutesLeft = difference.inMinutes % 60;

                                                                              return (daysLeft == 0 && hoursLeft == 0 && minutesLeft == 0)
                                                                                  ? widget.cuslang == 'EN'
                                                                                      ? 'Due today.'
                                                                                      : 'ครบกำหนดวันนี้'
                                                                                  : widget.cuslang == 'EN'
                                                                                      ? '${daysLeft} day ${hoursLeft} hours ${minutesLeft} minutes left.'
                                                                                      : 'เหลืออีก ${daysLeft} วัน ${hoursLeft} ชม. ${minutesLeft} นาที';
                                                                            })(),
                                                                            maxLines:
                                                                                1,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 12,
                                                                              color: (!isPaid)
                                                                                  ? Colors.black
                                                                                  : (images_x == null || images_x.toString() == '[]')
                                                                                      ? Colors.yellow.shade900
                                                                                      : Colors.blue.shade900,
                                                                              // color:
                                                                              //     Colors.black,
                                                                              fontFamily: FitnessAppTheme.fontName,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 2,
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .fromLTRB(
                                                                              0,
                                                                              0,
                                                                              4,
                                                                              0),
                                                                          child:
                                                                              Text(
                                                                            (!isPaid)
                                                                                ? widget.cuslang == 'EN'
                                                                                    ? 'overdue.'
                                                                                    : 'ค้างชำระ'
                                                                                : (images_x == null || images_x.toString() == '[]')
                                                                                    ? widget.cuslang == 'EN'
                                                                                        ? 'Waiting for payment.'
                                                                                        : 'รอชำระ'
                                                                                    : widget.cuslang == 'EN'
                                                                                        ? 'Waiting to check.'
                                                                                        : 'รอตรวจสอบ',
                                                                            textAlign:
                                                                                TextAlign.end,
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 14,
                                                                              color: (!isPaid)
                                                                                  ? Colors.red.shade900
                                                                                  : (images_x == null || images_x.toString() == '[]')
                                                                                      ? Colors.yellow.shade900
                                                                                      : Colors.blue.shade900,
                                                                              fontFamily: FitnessAppTheme.fontName,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      // limitedList_TransReBillModels_[
                                                                      //                 index]
                                                                      //             .pos ==
                                                                      //         '1'
                                                                      //     ? SizedBox()
                                                                      //     : Expanded(
                                                                      //         flex: 1,
                                                                      //         child: GestureDetector(
                                                                      //           onTap: () {
                                                                      //             red_Trans_select(
                                                                      //                     index)
                                                                      //                 .then((value) {
                                                                      //               List
                                                                      //                   newValuePDFimg =
                                                                      //                   [];
                                                                      //               for (int index =
                                                                      //                       0;
                                                                      //                   index < 1;
                                                                      //                   index++) {
                                                                      //                 if (renTalModels[
                                                                      //                             0]
                                                                      //                         .imglogo!
                                                                      //                         .trim() ==
                                                                      //                     '') {
                                                                      //                   // newValuePDFimg.add(
                                                                      //                   //     'https://png.pngtree.com/png-vector/20190820/ourmid/pngtree-no-image-vector-illustration-isolated-png-image_1694547.jpg');
                                                                      //                 } else {
                                                                      //                   newValuePDFimg
                                                                      //                       .add(
                                                                      //                           '${MyConstant().domain_chao}/files/$foder/logo/${renTalModels[0].imglogo!.trim()}');
                                                                      //                 }
                                                                      //               }
                                                                      //               final tableData00 =
                                                                      //                   [
                                                                      //                 for (int index =
                                                                      //                         0;
                                                                      //                     index <
                                                                      //                         _TransReBillHistoryModels
                                                                      //                             .length;
                                                                      //                     index++)
                                                                      //                   [
                                                                      //                     '${index + 1}',
                                                                      //                     '${_TransReBillHistoryModels[index].date}',
                                                                      //                     '${_TransReBillHistoryModels[index].expname}',
                                                                      //                     '${nFormat.format(double.parse(_TransReBillHistoryModels[index].nvat!))}',
                                                                      //                     '${nFormat.format(double.parse(_TransReBillHistoryModels[index].wht!))}',
                                                                      //                     '${nFormat.format(double.parse(_TransReBillHistoryModels[index].amt!))}',
                                                                      //                     '${nFormat.format(double.parse(_TransReBillHistoryModels[index].total!))}',
                                                                      //                   ],
                                                                      //               ];

                                                                      //               String sname = limitedList_TransReBillModels_[
                                                                      //                               index]
                                                                      //                           .sname ==
                                                                      //                       null
                                                                      //                   ? '${limitedList_TransReBillModels_[index].remark}'
                                                                      //                   : '${limitedList_TransReBillModels_[index].sname}';
                                                                      //               String cname =
                                                                      //                   '${limitedList_TransReBillModels_[index].cname}';
                                                                      //               String addr =
                                                                      //                   '${limitedList_TransReBillModels_[index].addr}';
                                                                      //               String tax =
                                                                      //                   '${limitedList_TransReBillModels_[index].tax}';
                                                                      //               String
                                                                      //                   room_number_BillHistory =
                                                                      //                   '${limitedList_TransReBillModels_[index].room_number}';
                                                                      //               print(
                                                                      //                   'room_number ------> ${limitedList_TransReBillModels_[index].room_number}');

                                                                      //               // _showMyDialog_SAVE(
                                                                      //               //     tableData00,
                                                                      //               //     newValuePDFimg,
                                                                      //               //     sname,
                                                                      //               //     cname,
                                                                      //               //     addr,
                                                                      //               //     tax,
                                                                      //               //     room_number_BillHistory);
                                                                      //               var TitleType_Default_Receipt_Name =
                                                                      //                   null;
                                                                      //               Receipt_his_statusbill(
                                                                      //                   tableData00,
                                                                      //                   newValuePDFimg,
                                                                      //                   sname,
                                                                      //                   cname,
                                                                      //                   addr,
                                                                      //                   tax,
                                                                      //                   room_number_BillHistory,
                                                                      //                   TitleType_Default_Receipt_Name);
                                                                      //             });
                                                                      //           },
                                                                      //           child: Icon(
                                                                      //               Icons.download),
                                                                      //         ),
                                                                      //       )
                                                                    ],
                                                                  ),
                                                                  // Row(
                                                                  //   children: [
                                                                  //     Expanded(
                                                                  //       child: Padding(
                                                                  //         padding: EdgeInsets.only(
                                                                  //             right: 8.0,
                                                                  //             left: 8.0,
                                                                  //             bottom: 8.0),
                                                                  //         child: Text(
                                                                  //           limitedList_TransReBillModels_[
                                                                  //                           index]
                                                                  //                       .shopno ==
                                                                  //                   '1'
                                                                  //               ? 'ออนไลน์'
                                                                  //               : 'เจ้าหน้าที่',
                                                                  //           textAlign: TextAlign.end,
                                                                  //           style: TextStyle(
                                                                  //             fontSize: 12,
                                                                  //             color: Color.fromRGBO(
                                                                  //                 100, 108, 110, 1),
                                                                  //             fontFamily:
                                                                  //                 Font_.Fonts_T,
                                                                  //           ),
                                                                  //         ),
                                                                  //       ),
                                                                  //     ),
                                                                  //   ],
                                                                  // ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  // Positioned(
                                                  //   top: 0,
                                                  //   left: 0,
                                                  //   bottom: 25,
                                                  //   child: Container(
                                                  //     width: 60,
                                                  //     height: 60,
                                                  //     decoration: BoxDecoration(
                                                  //       color: FitnessAppTheme.nearlyWhite
                                                  //           .withOpacity(0.2),
                                                  //       shape: BoxShape.circle,
                                                  //     ),
                                                  //   ),
                                                  // ),
                                                  // Positioned(
                                                  //   top: 20,
                                                  //   left: 20,
                                                  //   child: Container(
                                                  //     width: 250,
                                                  //     height: 60,
                                                  //     decoration: BoxDecoration(
                                                  //       color: FitnessAppTheme
                                                  //           .nearlyWhite
                                                  //           .withOpacity(0.2),
                                                  //       shape: BoxShape.circle,
                                                  //     ),
                                                  //   ),
                                                  // ),

                                                  //   Positioned(
                                                  //     top: 20,
                                                  //     left: 20,
                                                  //     child: Container(
                                                  //         width: 250,
                                                  //         height: 60,
                                                  //         child: Icon(Icons.receipt_outlined)),
                                                  //   ),
                                                  // Positioned(
                                                  //   top: 0,
                                                  //   left: 8,
                                                  //   child: SizedBox(
                                                  //     width: 60,
                                                  //     height: 60,
                                                  //     child: SfBarcodeGenerator(
                                                  //       value: teNantModels[index].docno == null
                                                  //           ? teNantModels[index].cid == null
                                                  //               ? ''
                                                  //               : '${teNantModels[index].cid}'
                                                  //           : '${teNantModels[index].docno}',
                                                  //       symbology: QRCode(),
                                                  //       showValue: false,
                                                  //     ),
                                                  //     // Image.asset(mealsListData!.imagePath),
                                                  //   ),
                                                  // )
                                                ],
                                              ),
                                            );

                                            // Stack(
                                            //   children: [
                                            //     Padding(
                                            //       padding:
                                            //           const EdgeInsets.all(10.0),
                                            //       child: InkWell(
                                            //         onTap: () async {
                                            //           String? billno,
                                            //               ref_id,
                                            //               amt,
                                            //               cid,
                                            //               custno,
                                            //               name,
                                            //               images;
                                            //           try {
                                            //             billno = invoicePayModels2
                                            //                 .firstWhere((e) =>
                                            //                     e.docno
                                            //                         .toString() ==
                                            //                     _InvoiceModels[
                                            //                             index]
                                            //                         .docno
                                            //                         .toString())
                                            //                 .billno;

                                            //             ref_id = invoicePayModels2
                                            //                 .firstWhere((e) =>
                                            //                     e.docno
                                            //                         .toString() ==
                                            //                     _InvoiceModels[
                                            //                             index]
                                            //                         .docno
                                            //                         .toString())
                                            //                 .refapi;
                                            //             cid = invoicePayModels2
                                            //                 .firstWhere((e) =>
                                            //                     e.docno
                                            //                         .toString() ==
                                            //                     _InvoiceModels[
                                            //                             index]
                                            //                         .docno
                                            //                         .toString())
                                            //                 .cid;
                                            //             custno = invoicePayModels2
                                            //                 .firstWhere((e) =>
                                            //                     e.docno
                                            //                         .toString() ==
                                            //                     _InvoiceModels[
                                            //                             index]
                                            //                         .docno
                                            //                         .toString())
                                            //                 .custno;
                                            //             amt = invoicePayModels2
                                            //                 .firstWhere((e) =>
                                            //                     e.docno
                                            //                         .toString() ==
                                            //                     _InvoiceModels[
                                            //                             index]
                                            //                         .docno
                                            //                         .toString())
                                            //                 .amtall;
                                            //             images = invoicePayModels2
                                            //                 .firstWhere((e) =>
                                            //                     e.docno
                                            //                         .toString() ==
                                            //                     _InvoiceModels[
                                            //                             index]
                                            //                         .docno
                                            //                         .toString())
                                            //                 .img;
                                            //           } catch (e) {
                                            //             billno = null;
                                            //           }

                                            //           String formattedBillno = '';

                                            //           if (billno != null &&
                                            //               billno.isNotEmpty) {
                                            //             // เคลียร์ [ ] ถ้ามี
                                            //             String clean = billno
                                            //                 .replaceAll('[', '')
                                            //                 .replaceAll(']', '');

                                            //             // แยกเป็นลิสต์ และ trim ช่องว่าง
                                            //             List<String> billList =
                                            //                 clean
                                            //                     .split(',')
                                            //                     .map(
                                            //                         (e) => e.trim())
                                            //                     .toList();

                                            //             // แปลงเป็น "'xxx', 'yyy'"
                                            //             formattedBillno = billList
                                            //                 .map((e) => "'$e'")
                                            //                 .join(',');
                                            //           }

                                            //           print(formattedBillno);

                                            //           print(formattedBillno);
                                            //           print(index);
                                            //           print(billno);
                                            //           print(ref_id);

                                            //           setState(() {
                                            //             if (billno.toString() !=
                                            //                 'null') {
                                            //               ref_new = 0;
                                            //             } else {
                                            //               ref_new = 1;
                                            //             }
                                            //             tap_pay = 1;
                                            //             return_qr_img =
                                            //                 'ref_id=$ref_id&incid=$cid&sum=$amt';
                                            //             invoiceAll =
                                            //                 formattedBillno;
                                            //             return_qr_refapi = ref_id;
                                            //             return_img = images;
                                            //           });
                                            //           print(return_img);
                                            //           // MaterialPageRoute route =
                                            //           //     MaterialPageRoute(
                                            //           //   builder: (context) =>
                                            //           //       FitnessAppHomeScreen(
                                            //           //           pageroot: 'INVOICE'),
                                            //           // );
                                            //           // Navigator.pushAndRemoveUntil(
                                            //           //     context, route, (route) => false);
                                            //           // MaterialPageRoute route =
                                            //           //     MaterialPageRoute(
                                            //           //   builder: (context) =>
                                            //           //       PayBillscreenChoice(),
                                            //           // );
                                            //           // Navigator.pushAndRemoveUntil(
                                            //           //     context, route, (route) => false);
                                            //         },
                                            //         child:

                                            //         Container(
                                            //           height: 60,
                                            //           decoration: BoxDecoration(
                                            //             boxShadow: <BoxShadow>[
                                            //               BoxShadow(
                                            //                 color: HexColor(
                                            //                         '#537188')
                                            //                     .withOpacity(0.6),
                                            //                 offset: const Offset(
                                            //                     1.1, 4.0),
                                            //                 blurRadius: 8.0,
                                            //               ),
                                            //             ],
                                            //             gradient: (!isPaid)
                                            //                 ? LinearGradient(
                                            //                     colors: <HexColor>[
                                            //                       HexColor(
                                            //                           '#FF8080'),
                                            //                       HexColor(
                                            //                           '#EF4B4B'),
                                            //                     ],
                                            //                     begin: Alignment
                                            //                         .topLeft,
                                            //                     end: Alignment
                                            //                         .bottomRight,
                                            //                   )
                                            //                 : LinearGradient(
                                            //                     colors: <HexColor>[
                                            //                       HexColor(
                                            //                           '#6B7AA1'),
                                            //                       HexColor(
                                            //                           '#354259'),
                                            //                     ],
                                            //                     begin: Alignment
                                            //                         .topLeft,
                                            //                     end: Alignment
                                            //                         .bottomRight,
                                            //                   ),
                                            //             borderRadius:
                                            //                 const BorderRadius.only(
                                            //               bottomRight:
                                            //                   Radius.circular(8.0),
                                            //               bottomLeft:
                                            //                   Radius.circular(8.0),
                                            //               topLeft:
                                            //                   Radius.circular(8.0),
                                            //               topRight:
                                            //                   Radius.circular(8.0),
                                            //               // topRight:
                                            //               //     Radius.circular(54.0),
                                            //             ),
                                            //           ),
                                            //           child: Row(
                                            //             crossAxisAlignment:
                                            //                 CrossAxisAlignment.end,
                                            //             children: [
                                            //               (!isPaid)
                                            //                   ? SizedBox(
                                            //                       width: 70,
                                            //                     )
                                            //                   : Padding(
                                            //                       padding:
                                            //                           const EdgeInsets
                                            //                                   .fromLTRB(
                                            //                               8,
                                            //                               0,
                                            //                               2,
                                            //                               4),
                                            //                       child: Text(
                                            //                         widget.cuslang ==
                                            //                                 'EN'
                                            //                             ? 'Waiting to check.'
                                            //                             : 'รอตรวจสอบ',
                                            //                         maxLines: 1,
                                            //                         overflow:
                                            //                             TextOverflow
                                            //                                 .ellipsis,
                                            //                         style:
                                            //                             TextStyle(
                                            //                           fontFamily:
                                            //                               FitnessAppTheme
                                            //                                   .fontName,
                                            //                           fontWeight:
                                            //                               FontWeight
                                            //                                   .bold,
                                            //                           fontSize:
                                            //                               widget.cuslang ==
                                            //                                       'EN'
                                            //                                   ? 11
                                            //                                   : 13,
                                            //                           letterSpacing:
                                            //                               0.2,
                                            //                           color: Colors
                                            //                                   .orange[
                                            //                               600],
                                            //                         ),
                                            //                       ),
                                            //                     ),
                                            //               Expanded(
                                            //                 child: Align(
                                            //                   alignment:
                                            //                       Alignment.center,
                                            //                   child: Text(
                                            //                     '${_InvoiceModels[index].docno}',
                                            //                     style: TextStyle(
                                            //                       fontFamily:
                                            //                           FitnessAppTheme
                                            //                               .fontName,
                                            //                       fontWeight:
                                            //                           FontWeight
                                            //                               .w500,
                                            //                       fontSize: 14,
                                            //                       letterSpacing:
                                            //                           0.2,
                                            //                       color:
                                            //                           FitnessAppTheme
                                            //                               .white,
                                            //                     ),
                                            //                   ),
                                            //                 ),
                                            //               ),
                                            //             ],
                                            //           ),
                                            //         ),
                                            //       ),
                                            //     ),
                                            //     Positioned(
                                            //       top: 0,
                                            //       left: 0,
                                            //       child: Container(
                                            //         width: 110,
                                            //         height: 80,
                                            //         decoration: BoxDecoration(
                                            //           color: isPaid
                                            //               ? FitnessAppTheme
                                            //                   .nearlyWhite
                                            //                   .withOpacity(0.1)
                                            //               : FitnessAppTheme
                                            //                   .nearlyWhite
                                            //                   .withOpacity(0.2),
                                            //           shape: BoxShape.circle,
                                            //         ),
                                            //       ),
                                            //     ),
                                            //     Positioned(
                                            //       top: -10,
                                            //       left: 0,
                                            //       child: SizedBox(
                                            //         width: width_x,
                                            //         height: height_x,
                                            //         child: isPaid
                                            //             ? Icon(
                                            //                 Icons
                                            //                     .history_toggle_off_outlined,
                                            //                 color:
                                            //                     Colors.orange[700],
                                            //                 size: 25,
                                            //               )
                                            //             : GestureDetector(
                                            //                 onTap: () async {},
                                            //                 child: Image.asset(
                                            //                   "assets/fitness_app/giphy7.gif",
                                            //                 ),
                                            //               ),
                                            //       ),
                                            //     ),
                                            //     // if (isPaid)
                                            //     //   Positioned(
                                            //     //     bottom: bottom_x,
                                            //     //     left: 15,
                                            //     //     child: SizedBox(
                                            //     //       width: 100,
                                            //     //       height: 20,
                                            //     //       child: Text(
                                            //     //         widget.cuslang == 'EN'
                                            //     //             ? 'Waiting to check.'
                                            //     //             : 'รอตรวจสอบ',
                                            //     //         maxLines: 1,
                                            //     //         overflow: TextOverflow.ellipsis,
                                            //     //         style: TextStyle(
                                            //     //           fontFamily:
                                            //     //               FitnessAppTheme.fontName,
                                            //     //           fontWeight: FontWeight.bold,
                                            //     //           fontSize:
                                            //     //               widget.cuslang == 'EN'
                                            //     //                   ? 11
                                            //     //                   : 14,
                                            //     //           letterSpacing: 0.2,
                                            //     //           color: Colors.orange[600],
                                            //     //         ),
                                            //     //       ),
                                            //     //     ),
                                            //     //   ),
                                            //   ],
                                            // );
                                          },
                                        );
                                      },
                                    ),
                                  )

                                  // Padding(
                                  //     padding: const EdgeInsets.only(
                                  //         left: 8, right: 8, top: 2),
                                  //     child: Column(
                                  //       children: [
                                  //         for (int index = 0;
                                  //             index < _InvoiceModels.length;
                                  //             index++)
                                  //           Stack(children: [
                                  //             Padding(
                                  //               padding: const EdgeInsets.only(
                                  //                   top: 25,
                                  //                   left: 8,
                                  //                   right: 8,
                                  //                   bottom: 16),
                                  //               child: InkWell(
                                  //                 onTap: () async {
                                  //                   String? billno,
                                  //                       ref_id,
                                  //                       amt,
                                  //                       cid,
                                  //                       custno,
                                  //                       name,
                                  //                       images;
                                  //                   try {
                                  //                     billno = invoicePayModels2
                                  //                         .firstWhere((e) =>
                                  //                             e.docno.toString() ==
                                  //                             _InvoiceModels[index]
                                  //                                 .docno
                                  //                                 .toString())
                                  //                         .billno;

                                  //                     ref_id = invoicePayModels2
                                  //                         .firstWhere((e) =>
                                  //                             e.docno.toString() ==
                                  //                             _InvoiceModels[index]
                                  //                                 .docno
                                  //                                 .toString())
                                  //                         .refapi;
                                  //                     cid = invoicePayModels2
                                  //                         .firstWhere((e) =>
                                  //                             e.docno.toString() ==
                                  //                             _InvoiceModels[index]
                                  //                                 .docno
                                  //                                 .toString())
                                  //                         .cid;
                                  //                     custno = invoicePayModels2
                                  //                         .firstWhere((e) =>
                                  //                             e.docno.toString() ==
                                  //                             _InvoiceModels[index]
                                  //                                 .docno
                                  //                                 .toString())
                                  //                         .custno;
                                  //                     amt = invoicePayModels2
                                  //                         .firstWhere((e) =>
                                  //                             e.docno.toString() ==
                                  //                             _InvoiceModels[index]
                                  //                                 .docno
                                  //                                 .toString())
                                  //                         .amtall;
                                  //                     images = invoicePayModels2
                                  //                         .firstWhere((e) =>
                                  //                             e.docno.toString() ==
                                  //                             _InvoiceModels[index]
                                  //                                 .docno
                                  //                                 .toString())
                                  //                         .img;
                                  //                   } catch (e) {
                                  //                     billno = null;
                                  //                   }

                                  //                   String formattedBillno = '';

                                  //                   if (billno != null &&
                                  //                       billno.isNotEmpty) {
                                  //                     // เคลียร์ [ ] ถ้ามี
                                  //                     String clean = billno
                                  //                         .replaceAll('[', '')
                                  //                         .replaceAll(']', '');

                                  //                     // แยกเป็นลิสต์ และ trim ช่องว่าง
                                  //                     List<String> billList = clean
                                  //                         .split(',')
                                  //                         .map((e) => e.trim())
                                  //                         .toList();

                                  //                     // แปลงเป็น "'xxx', 'yyy'"
                                  //                     formattedBillno = billList
                                  //                         .map((e) => "'$e'")
                                  //                         .join(',');
                                  //                   }

                                  //                   print(formattedBillno);

                                  //                   print(formattedBillno);
                                  //                   print(index);
                                  //                   print(billno);
                                  //                   print(ref_id);

                                  //                   setState(() {
                                  //                     if (billno.toString() != 'null') {
                                  //                       ref_new = 0;
                                  //                     } else {
                                  //                       ref_new = 1;
                                  //                     }
                                  //                     tap_pay = 1;
                                  //                     return_qr_img =
                                  //                         'ref_id=$ref_id&incid=$cid&sum=$amt';
                                  //                     invoiceAll = formattedBillno;
                                  //                     return_qr_refapi = ref_id;
                                  //                     return_img = images;
                                  //                   });
                                  //                   print(return_img);
                                  //                   // MaterialPageRoute route =
                                  //                   //     MaterialPageRoute(
                                  //                   //   builder: (context) =>
                                  //                   //       FitnessAppHomeScreen(
                                  //                   //           pageroot: 'INVOICE'),
                                  //                   // );
                                  //                   // Navigator.pushAndRemoveUntil(
                                  //                   //     context, route, (route) => false);
                                  //                   // MaterialPageRoute route =
                                  //                   //     MaterialPageRoute(
                                  //                   //   builder: (context) =>
                                  //                   //       PayBillscreenChoice(),
                                  //                   // );
                                  //                   // Navigator.pushAndRemoveUntil(
                                  //                   //     context, route, (route) => false);
                                  //                 },
                                  //                 child: Container(
                                  //                   height: 55,
                                  //                   decoration: BoxDecoration(
                                  //                     boxShadow: <BoxShadow>[
                                  //                       BoxShadow(
                                  //                           color: HexColor('#537188')
                                  //                               .withOpacity(0.6),
                                  //                           offset:
                                  //                               const Offset(1.1, 4.0),
                                  //                           blurRadius: 8.0),
                                  //                     ],
                                  //                     gradient: LinearGradient(
                                  //                       colors: <HexColor>[
                                  //                         // หมด : เช่าอยู่ : เสนอ

                                  //                         HexColor('#4F6F52'),
                                  //                         HexColor('#537188'),
                                  //                       ],
                                  //                       begin: Alignment.topLeft,
                                  //                       end: Alignment.bottomRight,
                                  //                     ),
                                  //                     borderRadius:
                                  //                         const BorderRadius.only(
                                  //                       bottomRight:
                                  //                           Radius.circular(8.0),
                                  //                       bottomLeft:
                                  //                           Radius.circular(8.0),
                                  //                       topLeft: Radius.circular(8.0),
                                  //                       topRight: Radius.circular(54.0),
                                  //                     ),
                                  //                   ),
                                  //                   child: Center(
                                  //                       child: Text(
                                  //                     '${_InvoiceModels[index].docno}',
                                  //                     style: TextStyle(
                                  //                       fontFamily:
                                  //                           FitnessAppTheme.fontName,
                                  //                       fontWeight: FontWeight.w500,
                                  //                       fontSize: 15,
                                  //                       letterSpacing: 0.2,
                                  //                       color: FitnessAppTheme.white,
                                  //                     ),
                                  //                   )),
                                  //                 ),
                                  //               ),
                                  //             ),
                                  //             Positioned(
                                  //               top: 0,
                                  //               left: 0,
                                  //               child: Container(
                                  //                 width: 84,
                                  //                 height: 80,
                                  //                 decoration: BoxDecoration(
                                  //                   color: (invoicePayModels2.any((e) =>
                                  //                           e.docno.toString() ==
                                  //                           _InvoiceModels[index]
                                  //                               .docno
                                  //                               .toString()))
                                  //                       ? FitnessAppTheme.nearlyWhite
                                  //                           .withOpacity(0.1)
                                  //                       : FitnessAppTheme.nearlyWhite
                                  //                           .withOpacity(0.2),
                                  //                   shape: BoxShape.circle,
                                  //                 ),
                                  //               ),
                                  //             ),
                                  //             Positioned(
                                  //               top: -3,
                                  //               left: 0,
                                  //               child: SizedBox(
                                  //                 width: 100,
                                  //                 height: 50,
                                  //                 child: (invoicePayModels2.any((e) =>
                                  //                         e.docno.toString() ==
                                  //                         _InvoiceModels[index]
                                  //                             .docno
                                  //                             .toString()))
                                  //                     ? Icon(
                                  //                         Icons
                                  //                             .history_toggle_off_outlined,
                                  //                         color: Colors.orange[700],
                                  //                         size: 45,
                                  //                       )
                                  //                     : GestureDetector(
                                  //                         onTap: () async {},
                                  //                         child: Image.asset(
                                  //                           "assets/fitness_app/giphy7.gif",
                                  //                         )),
                                  //                 // Image.asset("assets/fitness_app/giphy6.gif")
                                  //               ),
                                  //             ),
                                  //             if (invoicePayModels2.any((e) =>
                                  //                 e.docno.toString() ==
                                  //                 _InvoiceModels[index]
                                  //                     .docno
                                  //                     .toString()))
                                  //               Positioned(
                                  //                 bottom: 25,
                                  //                 left: 15,
                                  //                 child: Container(
                                  //                   width: 100,
                                  //                   height: 20,
                                  //                   // decoration: BoxDecoration(
                                  //                   //   color: FitnessAppTheme.nearlyWhite
                                  //                   //       .withOpacity(0.2),
                                  //                   //   shape: BoxShape.circle,
                                  //                   // ),_InvoiceModels
                                  //                   child: Text(
                                  //                     widget.cuslang == 'EN'
                                  //                         ? 'Waiting to check.'
                                  //                         : 'รอตรวจสอบ',
                                  //                     maxLines: 1,
                                  //                     overflow: TextOverflow.ellipsis,
                                  //                     style: TextStyle(
                                  //                       fontFamily:
                                  //                           FitnessAppTheme.fontName,
                                  //                       fontWeight: FontWeight.bold,
                                  //                       fontSize: widget.cuslang == 'EN'
                                  //                           ? 11
                                  //                           : 14,
                                  //                       letterSpacing: 0.2,
                                  //                       color: Colors.orange[600],
                                  //                     ),
                                  //                   ),
                                  //                 ),
                                  //               ),
                                  //           ])
                                  //       ],
                                  //     ))
                                  )));
                    });
  }
}
