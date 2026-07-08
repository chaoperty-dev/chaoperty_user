import 'dart:convert';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaoperty_user/screen/Screen_new/my_diary/water_view.dart';
import 'package:chaoperty_user/screen_Intents/APIS-V2/n10-bill-reference-available-bulk.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../Constant/Myconstant.dart';
import '../../../Model/GetInvoice_Model.dart';
import '../../../Model/GetTeNant_Model.dart';
import '../../../Model/GetTranBill_model.dart';
import '../../../Model/Get_Image_pro_model.dart';
import '../../../Model/Get_Image_text_model.dart';
import '../../../color.dart';

import '../../../Constant/app_markets.dart';
import '../../loginscreen.dart';
import '../../market_select_screen.dart';
import '../../market_service.dart';
import '../fitness_app_home_screen.dart';
import '../fitness_app_theme.dart';
import '../ui_view/body_measurement.dart';
import '../ui_view/dashboard_summary_view.dart';
import '../ui_view/glass_view.dart';
import '../ui_view/mediterranean_diet_view.dart';
import '../ui_view/title_view.dart';
import 'meals_list_view.dart';
import 'package:http/http.dart' as http;

class MyDiaryScreen extends StatefulWidget {
  const MyDiaryScreen({Key? key, this.animationController}) : super(key: key);

  final AnimationController? animationController;
  @override
  _MyDiaryScreenState createState() => _MyDiaryScreenState();
}

class _MyDiaryScreenState extends State<MyDiaryScreen>
    with TickerProviderStateMixin {
  Animation<double>? topBarAnimation;
  List<TeNantModel> teNantModels = [];
  List<Widget> listViews = <Widget>[];
  List<TransBillModel> _TransBillModels = [];
  List<InvoiceModel> _InvoiceModels = [];
  int open_set_date = 30;

  List<ImageTextModel> imgList = [];
  List<String> textList = [];
  List<Widget> imageSliders = [];
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;
  DateTime _DateTimeNew = DateTime.now();
  String? Ser_re,
      renTal_user,
      renTal_name,
      Value_cid,
      custno_,
      cus_ser,
      cus_cname,
      cus_sname,
      cus_email,
      cus_photo,
      cus_address,
      cus_contact,
      cus_stype,
      cus_tel,
      cus_tax,
      cus_imglogo_,
      cus_foder,
      cus_username,
      cus_password,
      cus_lintid,
      cus_lang;
  @override
  void initState() {
    super.initState();
    checkPreferance()
        .then((value) => read_GC_tenant())
        .then((value) => read_GC_customer_user())
        .then((value) => red_Trans_bill().then((value) {
              topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                      parent: widget.animationController!,
                      curve: Interval(0, 0.5, curve: Curves.fastOutSlowIn)));
              addAllListData();

              // ✅ แสดง popup แจ้งปัญหาระบบแนบหลักฐาน (ช่วง 25-28 พ.ค. 2569)
              // _showSlipIssuePopup();

              scrollController.addListener(() {
                if (scrollController.offset >= 24) {
                  if (topBarOpacity != 1.0) {
                    setState(() {
                      topBarOpacity = 1.0;
                    });
                  }
                } else if (scrollController.offset <= 24 &&
                    scrollController.offset >= 0) {
                  if (topBarOpacity != scrollController.offset / 24) {
                    setState(() {
                      topBarOpacity = scrollController.offset / 24;
                    });
                  }
                } else if (scrollController.offset <= 0) {
                  if (topBarOpacity != 0.0) {
                    setState(() {
                      topBarOpacity = 0.0;
                    });
                  }
                }
              });
            }));

    // red_Trans_bill();
  }

  Future<Null> checkPreferance() async {
    DateTime currentDate = DateTime.now();
    String new_Url = MyConstant().domain_chao;

    String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? DateLogin;
    setState(() {
      Ser_re = preferences.getString('renTalSer');
      renTal_user = preferences.getString('renTalSer');
      renTal_name = preferences.getString('renTalName');
      custno_ = preferences.getString('custno');
      DateLogin = preferences.getString('Date_Login');
      cus_ser = preferences.getString('ser');
      cus_cname = preferences.getString('cname');
      cus_sname = preferences.getString('sname');
      cus_email = preferences.getString('email');
      cus_photo = preferences.getString('photo');
      cus_address = preferences.getString('address');
      cus_contact = preferences.getString('contact');
      cus_stype = preferences.getString('stype');
      cus_tel = preferences.getString('tel');
      cus_tax = preferences.getString('tax');
      cus_foder = preferences.getString('foder');
      cus_username = preferences.getString('UsernameUSer');
      cus_password = preferences.getString('pass_word');
      cus_lintid = preferences.getString('lintid');
      cus_lang = preferences.getString('lang');
    });
    if (cus_photo != null ||
        cus_photo.toString() != '' ||
        cus_photo.toString() != 'null') {
      cus_imglogo_ = '$new_Url/files/$cus_foder/contract/$cus_photo';
    }
    read_GC_imagepro().then((value) {
      for (var i = 0; i < imgList.length; i++) {
        Widget imageSlider = Container(
          child: Container(
            margin: const EdgeInsets.all(2.0),
            child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                child: Stack(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () async {
                        //////print(imgList[i].url.toString());
                        if (imgList[i].url.toString() != '' &&
                            imgList[i].url != null &&
                            imgList[i].url.toString() != 'null') {
                          Uri url = Uri.parse(imgList[i].url.toString());
                          if (!await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          )) {
                            throw Exception('Could not launch $url');
                          }
                        }
                      },
                      child: Image.network(imgList[i].image.toString(),
                          fit: BoxFit.cover, width: 1500.0),
                    ),
                  ],
                )),
          ),
        );
        setState(() {
          imageSliders.add(imageSlider);
        });
      }
    });
  }

  Future<Null> read_GC_imagepro() async {
    if (imageSliders.isNotEmpty) {
      setState(() {
        imageSliders.clear();
        imgList.clear();
      });
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    String new_Url = MyConstant().domain_chao;
    //  '${Uri.base.toString().substring(0, Uri.base.toString().length - 8)}/chao_api';
    String url = '${MyConstant().domain}/GC_img_pro.php?isAdd=true&ren=$ren';
    try {
      var response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);
      // //////print(result);
      if (result != null) {
        for (var map in result) {
          ImageProModel imageProModel = ImageProModel.fromJson(map);

          setState(() {
            if (imageProModel.type == 'IM') {
              var foderx = '$new_Url/${imageProModel.imgName.toString()}';
              var urlx = imageProModel.url;
              Map<String, dynamic> map = Map();
              map['image'] = foderx;
              map['url'] = urlx;

              ImageTextModel imageTextModel = ImageTextModel.fromJson(map);

              imgList.add(imageTextModel);
            } else {
              var foderx = imageProModel.textPro.toString();
              textList.add(foderx);
            }
          });
        }
      } else {}
    } catch (e) {}
  }

  Future<Null> read_GC_tenant() async {
    if (teNantModels.isNotEmpty) {
      setState(() {
        teNantModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    double total = 0.00;
    var ren = preferences.getString('renTalSer');
    var custno_S = preferences.getString('custno');
    String url =
        '${MyConstant().domain}/GC_tenantAll.php?isAdd=true&ren=$ren&custno=$custno_S';
    //  '${MyConstant().domain}/GC_tenantAll.php?isAdd=true&ren=$ren&zone=$zone';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //print(result);
      if (result != null) {
        for (var map in result) {
          TeNantModel teNantModel = TeNantModel.fromJson(map);
          if (teNantModel.cid != null ||
              teNantModel.cid.toString() != '' ||
              teNantModel.cid.toString() != 'null') {
            setState(() {
              teNantModels.add(teNantModel);
            });
          }
        }
      }
    } catch (e) {}
  }

  Future<Null> read_GC_customer_user() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    String url =
        '${MyConstant().domain}/Gc_customer_user.php?isAdd=true&ren=$ren';
    try {
      var response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);
      if (result != null) {
        for (var map in result) {
          setState(() {
            open_set_date = int.parse(map['open_set_date']);
          });
        }
      }
      if (open_set_date == 0) {
        setState(() {
          open_set_date = 30;
        });
      }
    } catch (e) {}
  }

  /////////////////////////////////////////////////////////////////////
  List<String> total_list = []; // ยอดค้าง (ยังไม่มี payment intent)
  List<String> total_list_paid =
      []; // ยอดที่มี payment intent อยู่แล้ว/ชำระไปแล้ว
  double All_total = 0.00, totaltoday = 0.00;

  // รวมยอดบิล (amtall + vatall) อย่างปลอดภัยแม้ค่าจะเป็น null/empty
  double _billAmount(InvoiceModel inv) =>
      (double.tryParse(inv.amtall ?? '') ?? 0) +
      (double.tryParse(inv.vatall ?? '') ?? 0);

  /// ตรวจสอบสถานะ "ชำระได้" ของบิลแบบกลุ่ม (1 ครั้งต่อสัญญา)
  /// คืนค่า Map<billReference, bool> (true = ชำระได้)
  Future<Map<String, bool>> _fetchBillAvailability({
    required String? custNo,
    required String? ren,
    required List<String> docnos,
  }) async {
    final result = <String, bool>{};
    if (docnos.isEmpty || custNo == null || custNo.isEmpty || ren == null) {
      return result;
    }

    try {
      final response = await postPaymentIntentsBillReferenceAvailableBulk(
        cusno: custNo,
        propertyno: ren,
        billreference: docnos,
      );
      if (response == null ||
          response.statusCode < 200 ||
          response.statusCode >= 300) {
        return result;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['data'] is Map) {
        final data = decoded['data'] as Map;
        data.forEach((key, value) {
          if (value is bool) result[key.toString()] = value;
        });
      }
    } catch (e) {
      debugPrint('_fetchBillAvailability error: $e');
    }
    return result;
  }

  Future<Null> red_Trans_bill() async {
    // รีเซ็ตก่อนโหลดข้อมูลใหม่ (ทำนอก setState เพื่อลดการ rebuild ซ้ำซ้อน)
    _InvoiceModels.clear();
    totaltoday = 0;
    total_list.clear();
    total_list_paid.clear();

    final preferences = await SharedPreferences.getInstance();
    final ren = preferences.getString('renTalSer');
    final custNo = preferences.getString('custno');
    final qutser_ = preferences.getString('qutser');

    if (ren == null) {
      if (mounted) setState(() {});
      return;
    }

    final todayStr = DateFormat('yyyy-MM-dd').format(_DateTimeNew);

    for (int index = 0; index < teNantModels.length; index++) {
      final ciddoc_ = teNantModels[index].cid;
      if (ciddoc_ == null || ciddoc_.isEmpty) {
        total_list.add('0.00');
        continue;
      }

      final url =
          '${MyConstant().domain_chao}/GC_bill_invoice.php?isAdd=true&ren=$ren&ciddoc=$ciddoc_&qutser=$qutser_';

      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode != 200) {
          debugPrint('red_Trans_bill HTTP ${response.statusCode} ($ciddoc_)');
          total_list.add('0.00');
          continue;
        }

        final decoded = json.decode(response.body);
        final invoices = (decoded is List) ? decoded : const <dynamic>[];

        // แปลงเป็นโมเดล + รวมยอด (คำนวณนอก setState ก่อน)
        final parsed = <InvoiceModel>[];
        for (final map in invoices) {
          if (map is! Map<String, dynamic>) continue;
          final inv = InvoiceModel.fromJson(map);
          if (inv.billdate == todayStr) {
            totaltoday += _billAmount(inv);
          }
          parsed.add(inv);
        }

        // เช็ค availability ทีเดียวเป็นกลุ่ม ลดการเรียก network ต่อบิล
        final docnos = parsed
            .map((e) => (e.docno ?? '').toString())
            .where((d) => d.isNotEmpty)
            .toList();
        final availability = await _fetchBillAvailability(
            custNo: custNo, ren: ren, docnos: docnos);

        // แยกยอดเป็น 2 กลุ่ม:
        // - outstandingTotal : บิลที่ "ยังไม่มี payment intent" (ชำระได้/ค้างชำระ)
        // - paidOrPendingTotal : บิลที่ "มี payment intent อยู่แล้ว/ชำระไปแล้ว"
        // หากเช็คไม่ได้ (ไม่มีใน map) ถือว่าเป็นบิลปกติ → นับเข้า outstanding
        double outstandingTotal = 0.00;
        double paidOrPendingTotal = 0.00;
        for (final inv in parsed) {
          final isAvailable = availability[inv.docno?.toString()] ?? true;
          if (isAvailable) {
            outstandingTotal += _billAmount(inv);
          } else {
            paidOrPendingTotal += _billAmount(inv);
          }
        }

        _InvoiceModels.addAll(parsed);
        total_list.add(outstandingTotal.toStringAsFixed(2));
        total_list_paid.add(paidOrPendingTotal.toStringAsFixed(2));
      } catch (e, stack) {
        debugPrint('red_Trans_bill error (tenant $ciddoc_): $e');
        debugPrint('$stack');
        total_list.add('0.00');
      }
    }

    if (mounted) setState(() {});
  }

  void addAllListData() {
    const int count = 9;

    // listViews.add(
    //   TitleView(
    //     titleTxt: cus_lang == 'EN' ? 'Infomation User' : 'ข้อมูลผู้ใช้',
    //     subTxt: cus_lang == 'EN' ? 'Details' : 'รายละเอียด',
    //     animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    //         parent: widget.animationController!,
    //         curve:
    //             Interval((1 / count) * 0, 1.0, curve: Curves.fastOutSlowIn))),
    //     animationController: widget.animationController!,
    //   ),
    // );
    // listViews.add(
    //   MediterranesnDietView(
    //     animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    //         parent: widget.animationController!,
    //         curve:
    //             Interval((1 / count) * 1, 1.0, curve: Curves.fastOutSlowIn))),
    //     animationController: widget.animationController!,
    //     teNantModel: teNantModels,
    //     invoiceModels: _InvoiceModels,
    //     cuslangs: cus_lang,
    //     open_set_date: open_set_date,
    //   ),
    // );

    listViews.add(
      BodyMeasurementView(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve:
                Interval((1 / count) * 5, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
        totaltodays: totaltoday,
        invoiceModels: _InvoiceModels,
        cuslangs: cus_lang,
      ),
    );

    listViews.add(
      DashboardSummaryView(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve:
                Interval((1 / count) * 1, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
        teNantModel: teNantModels,
        invoiceModels: _InvoiceModels,
        totaltodays: totaltoday,
        cuslangs: cus_lang,
        open_set_date: open_set_date,
      ),
    );

    listViews.add(
      _buildQuickActionsRow(),
    );
    listViews.add(
      TitleView(
        titleTxt: cus_lang == 'EN' ? 'Rental contract' : 'สัญญา',
        subTxt: cus_lang == 'EN' ? 'Rental contract All' : 'สัญญาทั้งหมด',
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve:
                Interval((1 / count) * 2, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
      ),
    );

    listViews.add(
      MealsListView(
        mainScreenAnimation: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
                parent: widget.animationController!,
                curve: Interval((1 / count) * 3, 1.0,
                    curve: Curves.fastOutSlowIn))),
        mainScreenAnimationController: widget.animationController,
        teNantModel: teNantModels,
        totallist: total_list,
        totallistPaid: total_list_paid,
        cuslangs: cus_lang,
        open_set_date: open_set_date,
      ),
    );

    // ✅ ตารางสรุปยอดต่อสัญญา (เลขสัญญา / ยอดรอตรวจสอบ / ยอดค้างชำระ)
    listViews.add(
      _buildContractSummaryTable(),
    );

    // ✅ ตารางสรุปสถานะสัญญา
    listViews.add(
      _buildContractStatusTable(),
    );

// ✅ การ์ดสรุป Dashboard รวม (ยอดค้าง + สัญญา + วันนี้ + บิล + ชำระ)
    // listViews.add(
    //   DashboardSummaryView(
    //     animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    //         parent: widget.animationController!,
    //         curve:
    //             Interval((1 / count) * 1, 1.0, curve: Curves.fastOutSlowIn))),
    //     animationController: widget.animationController!,
    //     teNantModel: teNantModels,
    //     invoiceModels: _InvoiceModels,
    //     totaltodays: totaltoday,
    //     cuslangs: cus_lang,
    //     open_set_date: open_set_date,
    //   ),
    // );
    // listViews.add(
    //   TitleView(
    //     titleTxt: cus_lang == 'EN' ? 'Overdue Today' : 'เกินกำหนดชำระ',
    //     subTxt: 'X',
    //     animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    //         parent: widget.animationController!,
    //         curve:
    //             Interval((1 / count) * 4, 1.0, curve: Curves.fastOutSlowIn))),
    //     animationController: widget.animationController!,
    //   ),
    // );

    // listViews.add(
    //   BodyMeasurementView(
    //     animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    //         parent: widget.animationController!,
    //         curve:
    //             Interval((1 / count) * 5, 1.0, curve: Curves.fastOutSlowIn))),
    //     animationController: widget.animationController!,
    //     totaltodays: totaltoday,
    //     invoiceModels: _InvoiceModels,
    //     cuslangs: cus_lang,
    //   ),
    // );
    // listViews.add(
    //   TitleView(
    //     titleTxt: cus_lang == 'EN' ? 'News' : 'ข่าว',
    //     subTxt: 'X',
    //     animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    //         parent: widget.animationController!,
    //         curve:
    //             Interval((1 / count) * 6, 1.0, curve: Curves.fastOutSlowIn))),
    //     animationController: widget.animationController!,
    //   ),
    // );

    // listViews.add(
    //   WaterView(
    //     mainScreenAnimation: Tween<double>(begin: 0.0, end: 1.0).animate(
    //         CurvedAnimation(
    //             parent: widget.animationController!,
    //             curve: Interval((1 / count) * 7, 1.0,
    //                 curve: Curves.fastOutSlowIn))),
    //     mainScreenAnimationController: widget.animationController!,
    //     imgLists: imageSliders,
    //   ),
    // );
    // listViews.add(
    //   GlassView(
    //     animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    //         parent: widget.animationController!,
    //         curve:
    //             Interval((1 / count) * 8, 1.0, curve: Curves.fastOutSlowIn))),
    //     animationController: widget.animationController!,
    //     textLists: textList,
    //   ),
    // );
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    return true;
  }

  /// ตารางสรุปยอดต่อสัญญา (เลขสัญญา / ยอดรอตรวจสอบ / ยอดค้างชำระ)
  Widget _buildContractSummaryTable() {
    final isEN = cus_lang == 'EN';
    final nFormat = NumberFormat("#,##0.00", "en_US");

    // คำนวณยอดรวม
    double totalOutstanding = 0.0;
    double totalPending = 0.0;
    for (int i = 0; i < teNantModels.length; i++) {
      totalOutstanding +=
          double.tryParse(total_list.length > i ? total_list[i] : '0.00') ??
              0.0;
      totalPending += double.tryParse(
              total_list_paid.length > i ? total_list_paid[i] : '0.00') ??
          0.0;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: FitnessAppTheme.grey.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
              decoration: BoxDecoration(
                color: FitnessAppTheme.nearlyDarkBlue.withOpacity(0.06),
                border: Border(
                  bottom: BorderSide(
                      color: FitnessAppTheme.nearlyDarkBlue.withOpacity(0.1),
                      width: 1),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.table_chart_outlined,
                      size: 18, color: FitnessAppTheme.nearlyDarkBlue),
                  const SizedBox(width: 10),
                  Text(
                    isEN ? 'Contract Payment Summary' : 'สรุปยอดชำระต่อสัญญา',
                    style: TextStyle(
                      fontFamily: Font_.Fonts_T,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: FitnessAppTheme.nearlyDarkBlue,
                    ),
                  ),
                ],
              ),
            ),
            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      isEN ? 'Contract No.' : 'เลขสัญญา',
                      style: TextStyle(
                        fontFamily: Font_.Fonts_T,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      isEN ? 'Pending Review' : 'ยอดรอตรวจสอบ',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: Font_.Fonts_T,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      isEN ? 'Outstanding' : 'ยอดค้างชำระ',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: Font_.Fonts_T,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Table Rows
            ...List.generate(teNantModels.length, (index) {
              final tenant = teNantModels[index];
              final outstanding = double.tryParse(
                      total_list.length > index ? total_list[index] : '0.00') ??
                  0.0;
              final pending = double.tryParse(total_list_paid.length > index
                      ? total_list_paid[index]
                      : '0.00') ??
                  0.0;
              final hasAny = outstanding > 0 || pending > 0;

              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: index.isEven ? Colors.white : Colors.grey.shade50,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade100, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        tenant.cid ?? '-',
                        style: TextStyle(
                          fontFamily: Font_.Fonts_T,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: hasAny
                              ? FitnessAppTheme.darkerText
                              : Colors.grey.shade500,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        nFormat.format(pending),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: Font_.Fonts_T,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: pending > 0
                              ? FitnessAppTheme.orange
                              : Colors.grey.shade500,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        nFormat.format(outstanding),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: Font_.Fonts_T,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: outstanding > 0
                              ? FitnessAppTheme.nearlyDarkRed
                              : Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            // Total Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: FitnessAppTheme.nearlyDarkBlue.withOpacity(0.06),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      isEN ? 'Total' : 'รวม',
                      style: TextStyle(
                        fontFamily: Font_.Fonts_T,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: FitnessAppTheme.nearlyDarkBlue,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      nFormat.format(totalPending),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: Font_.Fonts_T,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: totalPending > 0
                            ? FitnessAppTheme.orange
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      nFormat.format(totalOutstanding),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: Font_.Fonts_T,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: totalOutstanding > 0
                            ? FitnessAppTheme.nearlyDarkRed
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// แถวเมนูลัด 4 ปุ่ม (ชำระ, บิล, สแกน, อื่นๆ)
  Widget _buildQuickActionsRow() {
    final isEN = cus_lang == 'EN';
    final actions = [
      _QuickAction(
        icon: Icons.wallet_outlined,
        label: isEN ? 'Pay' : 'ชำระ',
        onTap: () async {
          final preferences = await SharedPreferences.getInstance();
          await preferences.setString('payby', 'PAY');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FitnessAppHomeScreen(pageroot: 'PAY'),
            ),
          );
        },
      ),
      _QuickAction(
        icon: Icons.receipt_long_outlined,
        label: isEN ? 'Bill' : 'บิล',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FitnessAppHomeScreen(pageroot: 'PAYMENT'),
            ),
          );
        },
      ),
      _QuickAction(
        icon: Icons.qr_code_scanner_outlined,
        label: isEN ? 'Scan' : 'สแกน',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FitnessAppHomeScreen(pageroot: 'SCAN'),
            ),
          );
        },
      ),
      _QuickAction(
        icon: Icons.grid_view_outlined,
        label: isEN ? 'More' : 'อื่นๆ',
        onTap: () {
          // TODO: เปิดหน้าเมนูเพิ่มเติม
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEN ? 'Coming soon' : 'เร็วๆ นี้'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
      ),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 4, 24, 8),
      child: Row(
        children: actions.map((action) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: action.onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: FitnessAppTheme.grey.withOpacity(0.1),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: FitnessAppTheme.grey.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: FitnessAppTheme.nearlyDarkBlue
                                .withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            action.icon,
                            size: 22,
                            color: FitnessAppTheme.nearlyDarkBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          action.label,
                          style: TextStyle(
                            fontFamily: Font_.Fonts_T,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: FitnessAppTheme.darkerText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// ตารางสรุปสถานะสัญญา (ปัจจุบัน / หมดสัญญา / ใกล้หมด)
  Widget _buildContractStatusTable() {
    final isEN = cus_lang == 'EN';

    int activeCount = 0;
    int expiredCount = 0;
    int almostCount = 0;

    for (final tenant in teNantModels) {
      if (tenant.quantity == '2' || tenant.quantity == '3') {
        activeCount++;
        continue;
      }
      if (tenant.quantity != '1') continue;

      final lDate = tenant.ldate == null
          ? DateTime(_DateTimeNew.year, _DateTimeNew.month, _DateTimeNew.day)
          : DateTime.tryParse(tenant.ldate.toString()) ?? _DateTimeNew;
      final isExpired = _DateTimeNew.isAfter(lDate);
      final isAlmost =
          _DateTimeNew.isAfter(lDate.subtract(Duration(days: open_set_date)));

      if (isExpired) {
        expiredCount++;
      } else if (isAlmost) {
        almostCount++;
      } else {
        activeCount++;
      }
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: FitnessAppTheme.grey.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
              decoration: BoxDecoration(
                color: FitnessAppTheme.nearlyDarkBlue.withOpacity(0.06),
                border: Border(
                  bottom: BorderSide(
                      color: FitnessAppTheme.nearlyDarkBlue.withOpacity(0.1),
                      width: 1),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.pie_chart_outline,
                      size: 18, color: FitnessAppTheme.nearlyDarkBlue),
                  const SizedBox(width: 10),
                  Text(
                    isEN ? 'Contract Status Summary' : 'สรุปสถานะสัญญา',
                    style: TextStyle(
                      fontFamily: Font_.Fonts_T,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: FitnessAppTheme.nearlyDarkBlue,
                    ),
                  ),
                ],
              ),
            ),
            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      isEN ? 'Status' : 'สถานะ',
                      style: TextStyle(
                        fontFamily: Font_.Fonts_T,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      isEN ? 'Count' : 'จำนวน',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: Font_.Fonts_T,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Active row
            _statusRow(
              isEN ? 'Active' : 'ปัจจุบัน',
              activeCount,
              FitnessAppTheme.nearlyDarkBlue,
              true,
            ),
            // Expired row
            _statusRow(
              isEN ? 'Expired' : 'หมดสัญญา',
              expiredCount,
              FitnessAppTheme.nearlyDarkRed,
              false,
            ),
            // Almost expired row
            _statusRow(
              isEN ? 'Almost Expired' : 'ใกล้หมดสัญญา',
              almostCount,
              FitnessAppTheme.orange,
              true,
            ),
            // Total row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: FitnessAppTheme.nearlyDarkBlue.withOpacity(0.06),
                border: Border(
                  top: BorderSide(
                      color: FitnessAppTheme.nearlyDarkBlue.withOpacity(0.15),
                      width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      isEN ? 'Total Contracts' : 'สัญญาทั้งหมด',
                      style: TextStyle(
                        fontFamily: Font_.Fonts_T,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: FitnessAppTheme.nearlyDarkBlue,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '${teNantModels.length}',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: Font_.Fonts_T,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: FitnessAppTheme.nearlyDarkBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusRow(String label, int count, Color color, bool isEven) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: isEven ? Colors.white : Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: Font_.Fonts_T,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: FitnessAppTheme.darkerText,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '$count',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: Font_.Fonts_T,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: count > 0 ? color : Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ แสดง popup แจ้งปัญหาระบบแนบหลักฐานการชำระ (ช่วง 25-28 พ.ค. 2569)
  void _showSlipIssuePopup() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final isEN = cus_lang == 'EN';

      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.85,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header สีส้ม
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.warning_amber_rounded,
                                        size: 32,
                                        color: Colors.orange.shade700),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      isEN
                                          ? 'Notice: Payment Evidence System Issue'
                                          : 'ขออภัย ระบบการแนบหลักฐานการชำระมีปัญหา',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: Font_.Fonts_T,
                                        color: Colors.orange.shade900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Body
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isEN
                                        ? 'Users who attached payment evidence between May 25-28, 2026, please verify your submitted evidence.'
                                        : 'ผู้ใช้ที่แนบหลักฐานการชำระตั้งแต่ช่วงวันที่ 25 ถึง 28 พฤษภาคม 2569 กรุณาเข้าไปตรวจสอบหลักฐานที่ท่านแนบ',
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontFamily: Font_.Fonts_T,
                                      color: Colors.black87,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: Colors.red.shade100),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(Icons.info_outline,
                                            size: 20,
                                            color: Colors.red.shade400),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            isEN
                                                ? 'If your evidence is not showing, please re-upload it so staff can verify correctly.'
                                                : 'หากพบว่าหลักฐานไม่แสดง ขอความกรุณาอัพหลักฐานใหม่อีกครั้ง เพื่อให้เจ้าหน้าที่ตรวจสอบได้ถูกต้อง',
                                            style: TextStyle(
                                              fontSize: 13.5,
                                              fontFamily: Font_.Fonts_T,
                                              color: Colors.red.shade700,
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Buttons
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                              child: Row(
                                children: [
                                  // ปุ่มปิด
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          side: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                      ),
                                      child: Text(
                                        isEN ? 'Close' : 'ปิด',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                          fontFamily: Font_.Fonts_T,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // ปุ่มไปตรวจสอบหลักฐาน
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.orange.shade600,
                                            Colors.orange.shade400,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.orange.withOpacity(0.3),
                                            blurRadius: 5,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.pop(
                                                ctx); // ปิด popup ก่อน
                                            // นำไปยังหน้า Payment receipt (home_status_screen)
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    FitnessAppHomeScreen(
                                                  pageroot: 'PAYMENT',
                                                ),
                                              ),
                                            );
                                          },
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.receipt_long,
                                                    size: 18,
                                                    color: Colors.white),
                                                const SizedBox(width: 8),
                                                Text(
                                                  isEN
                                                      ? 'Check Evidence'
                                                      : 'ตรวจสอบหลักฐาน',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white,
                                                    fontFamily: Font_.Fonts_T,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )))));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FitnessAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: listViews.length == 0
            ? Center(
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
              )
            : ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                }),
                child: Stack(
                  children: <Widget>[
                    getMainListViewUI(),
                    getAppBarUI(),
                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom,
                    )
                  ],
                ),
              ),
      ),
    );
  }

  Widget getMainListViewUI() {
    return FutureBuilder<bool>(
      future: getData(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        } else {
          return ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.only(
              top: AppBar().preferredSize.height +
                  MediaQuery.of(context).padding.top +
                  24,
              bottom: 100 + MediaQuery.of(context).padding.bottom,
            ),
            itemCount: listViews.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              widget.animationController?.forward();
              return listViews[index];
            },
          );
        }
      },
    );
  }

  Widget getAppBarUI() {
    return Column(
      children: <Widget>[
        AnimatedBuilder(
          animation: widget.animationController!,
          builder: (BuildContext context, Widget? child) {
            return FadeTransition(
              opacity: topBarAnimation!,
              child: Transform(
                transform: Matrix4.translationValues(
                    0.0, 30 * (1.0 - topBarAnimation!.value), 0.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: FitnessAppTheme.white.withOpacity(topBarOpacity),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(0.0),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: FitnessAppTheme.grey
                              .withOpacity(0.4 * topBarOpacity),
                          offset: const Offset(1.1, 1.1),
                          blurRadius: 10.0),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).padding.top,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16 - 8.0 * topBarOpacity,
                            bottom: 12 - 8.0 * topBarOpacity),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: FitnessAppTheme.nearlyWhite,
                                        shape: BoxShape.circle,
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                              color: FitnessAppTheme.grey
                                                  .withOpacity(0.4),
                                              offset: const Offset(2.0, 2.0),
                                              blurRadius: 8.0),
                                        ],
                                      ),
                                      child: CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.transparent,
                                        backgroundImage: null,
                                        child: Icon(Icons.person,
                                            color: FitnessAppTheme.grey,
                                            size: 28),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // Text(
                                        //   '$renTal_name ยินดีต้อนรับ',
                                        //   style: TextStyle(
                                        //     fontFamily: Font_.Fonts_T,
                                        //     fontSize: 10,
                                        //     color: FitnessAppTheme.grey,
                                        //   ),
                                        // ),

                                        AutoSizeText(
                                          minFontSize: 8,
                                          maxFontSize: 12,
                                          maxLines: 1,
                                          '$renTal_name ยินดีต้อนรับ',
                                          textAlign: TextAlign.left,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: Font_.Fonts_T,
                                            fontSize:
                                                12 + 6 - 6 * topBarOpacity,
                                            letterSpacing: 1.2,
                                            color: FitnessAppTheme.grey,
                                          ),
                                        ),
                                        AutoSizeText(
                                          minFontSize: 10,
                                          maxFontSize: 16,
                                          maxLines: 1,
                                          '$cus_cname',
                                          textAlign: TextAlign.left,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: Font_.Fonts_T,
                                            fontWeight: FontWeight.w700,
                                            fontSize:
                                                16 + 6 - 6 * topBarOpacity,
                                            letterSpacing: 1.2,
                                            color: FitnessAppTheme.darkerText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                InkWell(
                                  onTap: () async {
                                    SharedPreferences preferences =
                                        await SharedPreferences.getInstance();
                                    var cuslang =
                                        cus_lang == 'EN' ? 'TH' : 'EN';
                                    String url =
                                        '${MyConstant().domain_chao}/UP_THEN.php?isAdd=true&cus_ser=$cus_ser&cuslang=$cuslang';
                                    try {
                                      var response =
                                          await http.get(Uri.parse(url));

                                      var result = json.decode(response.body);

                                      if (result.toString() != 'false') {
                                        preferences.setString(
                                            'lang', cuslang.toString());
                                        MaterialPageRoute route =
                                            MaterialPageRoute(
                                          builder: (context) =>
                                              FitnessAppHomeScreen(
                                                  pageroot: null),
                                        );
                                        Navigator.push(context, route);
                                      }
                                    } catch (e) {}
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: FitnessAppTheme.nearlyWhite,
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                            color: FitnessAppTheme.grey
                                                .withOpacity(0.2),
                                            offset: const Offset(1.1, 1.1),
                                            blurRadius: 8.0),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          cus_lang ?? 'TH',
                                          style: TextStyle(
                                            fontFamily: Font_.Fonts_T,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade900,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(Icons.language,
                                            size: 16,
                                            color: FitnessAppTheme.grey),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                if (AppMarkets.markets.length > 1)
                                  InkWell(
                                    borderRadius: BorderRadius.circular(32.0),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => MarketSelectScreen(
                                            markets: AppMarkets.markets,
                                            onSelect: (selected) =>
                                                MarketService.applyMarket(
                                                    context, selected),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: FitnessAppTheme.nearlyWhite,
                                        borderRadius: BorderRadius.circular(18),
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                              color: FitnessAppTheme.grey
                                                  .withValues(alpha: 0.2),
                                              offset: const Offset(1.1, 1.1),
                                              blurRadius: 8.0),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.swap_horiz_rounded,
                                              size: 16,
                                              color: FitnessAppTheme.orange),
                                          SizedBox(width: 4),
                                          Text(
                                            cus_lang == 'EN'
                                                ? 'Switch'
                                                : 'ตลาด',
                                            style: TextStyle(
                                              fontFamily: Font_.Fonts_T,
                                              fontWeight: FontWeight.bold,
                                              color: FitnessAppTheme.orange,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                SizedBox(width: 12),
                                InkWell(
                                  borderRadius: BorderRadius.circular(32.0),
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            elevation: 0,
                                            backgroundColor: Colors.transparent,
                                            child: Center(
                                              child: Container(
                                                constraints:
                                                    const BoxConstraints(
                                                        maxWidth: 400),
                                                padding:
                                                    const EdgeInsets.all(20),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.rectangle,
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Colors.black26,
                                                      blurRadius: 10,
                                                      offset: Offset(0, 10),
                                                    ),
                                                  ],
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: <Widget>[
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              15),
                                                      decoration: BoxDecoration(
                                                        color: FitnessAppTheme
                                                            .nearlyDarkRed
                                                            .withOpacity(0.1),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        Icons.logout,
                                                        size: 40,
                                                        color: FitnessAppTheme
                                                            .nearlyDarkRed,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 20),
                                                    const Text(
                                                      "Logout",
                                                      style: TextStyle(
                                                        fontSize: 22,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontFamily:
                                                            Font_.Fonts_T,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Text(
                                                      cus_lang == 'EN'
                                                          ? "Are you sure you want to logout?"
                                                          : "คุณต้องการออกจากระบบหรือไม่?",
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey,
                                                        fontFamily:
                                                            Font_.Fonts_T,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    const SizedBox(height: 25),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            style: TextButton
                                                                .styleFrom(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          12),
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                side: BorderSide(
                                                                    color: Colors
                                                                        .grey
                                                                        .shade300),
                                                              ),
                                                            ),
                                                            child: Text(
                                                              cus_lang == 'EN'
                                                                  ? "Cancel"
                                                                  : "ยกเลิก",
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .grey
                                                                    .shade700,
                                                                fontFamily: Font_
                                                                    .Fonts_T,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 15),
                                                        Expanded(
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              gradient:
                                                                  LinearGradient(
                                                                colors: [
                                                                  FitnessAppTheme
                                                                      .nearlyDarkRed,
                                                                  const Color(
                                                                      0xFFFF6B6B),
                                                                ],
                                                                begin: Alignment
                                                                    .topLeft,
                                                                end: Alignment
                                                                    .bottomRight,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: FitnessAppTheme
                                                                      .nearlyDarkRed
                                                                      .withOpacity(
                                                                          0.3),
                                                                  blurRadius: 5,
                                                                  offset:
                                                                      const Offset(
                                                                          0, 3),
                                                                ),
                                                              ],
                                                            ),
                                                            child: Material(
                                                              color: Colors
                                                                  .transparent,
                                                              child: InkWell(
                                                                onTap:
                                                                    () async {
                                                                  SharedPreferences
                                                                      preferences =
                                                                      await SharedPreferences
                                                                          .getInstance();
                                                                  await preferences
                                                                      .clear();
                                                                  MaterialPageRoute
                                                                      route =
                                                                      MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            const LoginScreen(),
                                                                  );
                                                                  Navigator.pushAndRemoveUntil(
                                                                      context,
                                                                      route,
                                                                      (route) =>
                                                                          false);
                                                                },
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          12),
                                                                  child: Center(
                                                                    child: Text(
                                                                      cus_lang ==
                                                                              'EN'
                                                                          ? "Logout"
                                                                          : "ยืนยัน",
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        color: Colors
                                                                            .white,
                                                                        fontFamily:
                                                                            Font_.Fonts_T,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ));
                                      },
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: FitnessAppTheme.nearlyWhite,
                                      shape: BoxShape.circle,
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                            color: FitnessAppTheme.grey
                                                .withOpacity(0.2),
                                            offset: const Offset(1.1, 1.1),
                                            blurRadius: 8.0),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.logout,
                                      color: FitnessAppTheme.grey,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        )
      ],
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}
