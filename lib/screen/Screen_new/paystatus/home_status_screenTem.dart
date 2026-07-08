import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../Beam/webviewPay_beamcheckout.dart';
import '../../../Constant/Myconstant.dart';
import '../../../Man_PDF/Man_Pay_Receipt_PDF.dart';
import '../../../Model/GetContractx_Model.dart';
import '../../../Model/GetCustomer_Model.dart';
import '../../../Model/GetFinnancetrans_Model.dart';
import '../../../Model/GetInvoice_Model.dart';
import '../../../Model/GetRenTal_Model.dart';
import '../../../Model/GetTeNant_Model.dart';
import '../../../Model/GetTrans_Model.dart';
import '../../../Model/trans_re_bill_history_model.dart';
import '../../../Model/trans_re_bill_model.dart';
import '../../../color.dart';
import '../../../main.dart';
import '../../model/electricity_history_model.dart';
import '../fitness_app_theme.dart';
import '../ui_view/area_list_view.dart';
import '../ui_view/running_view.dart';
import '../ui_view/title_view.dart';
import '../ui_view/workout_view.dart';
import 'package:http/http.dart' as http;

class StatusScreen extends StatefulWidget {
  const StatusScreen({Key? key, this.animationController}) : super(key: key);

  final AnimationController? animationController;
  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen>
    with TickerProviderStateMixin {
  Animation<double>? topBarAnimation;
  AnimationController? animationController;
  List<Widget> listViews = <Widget>[];
  List<CustomerModel> customerModels = [];
  List<TeNantModel> teNantModels = [];

  List<TransReBillModel> limitedList_TransReBillModels_ = [];
  List<ContractxModel> _ContractxModels = [];
  List<TransModel> _TransModels = [];
  List<ElectricityHistoryModel> electricityHistoryModels = [];
  List<TransReBillHistoryModel> _TransReBillHistoryModels = [];
  List<FinnancetransModel> finnancetransModels = [];
  List<RenTalModel> renTalModels = [];
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;
  var nFormat = NumberFormat("#,##0.00", "en_US");
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
  String? _celvat,
      _cname,
      _cnamex,
      _cmeter,
      _cser,
      _cunitser,
      _cqty_vat,
      _cunit;
  int sucsess = 0;
  double unit1 = 0,
      unit2 = 0,
      unit3 = 0,
      unit4 = 0,
      unit5 = 0,
      unit6 = 0,
      sum1 = 0,
      sum2 = 0,
      sum3 = 0,
      sum4 = 0,
      sum5 = 0,
      sum6 = 0,
      unit = 0,
      unit1c = 0,
      unit2c = 0,
      unit3c = 0,
      unit4c = 0,
      unit5c = 0,
      unit6c = 0,
      ele_tf = 0.0000,
      ele_other = 0,
      ele_vat = 0,
      ele_one = 0,
      ele_mit_one = 0,
      ele_gob_one = 0,
      ele_two = 0,
      ele_mit_two = 0,
      ele_gob_two = 0,
      ele_three = 0,
      ele_mit_three = 0,
      ele_gob_three = 0,
      ele_tour = 0,
      ele_mit_tour = 0,
      ele_gob_tour = 0,
      ele_five = 0,
      ele_mit_five = 0,
      ele_gob_five = 0,
      ele_six = 0,
      ele_mit_six = 0,
      ele_gob_six = 0,
      sum = 0,
      sum_n = 0,
      sum_f = 0,
      sum_per = 0,
      sum_all = 0;
  String? zone_ser, zone_name, fname_, tem_page_ser, pdate;
  String? rtname,
      type,
      typex,
      renname,
      bill_name,
      bill_addr,
      bill_tax,
      bill_tel,
      bill_email,
      expbill,
      expbill_name,
      bill_default,
      bill_tser,
      foder,
      bills_name_,
      zone_Subser,
      zone_Subname,
      newValuePDFimg_QR;
  String _ReportValue_type = "ไม่ระบุ";

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    super.initState();
    checkPreferance()
        .then((value) => read_GC_rental())
        .then((value) => red_Trans_bill().then((value) {
              topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                      parent: widget.animationController!,
                      curve: Interval(0, 0.5, curve: Curves.fastOutSlowIn)));
              addAllListData();
              // forward animation ครั้งเดียว ไม่ใช่ทุก itemBuilder
              if (widget.animationController?.status ==
                  AnimationStatus.dismissed) {
                widget.animationController?.forward();
              }

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
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
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
    String url =
        '${MyConstant().domain}/Gc_customer_user.php?isAdd=true&ren=$Ser_re&cusno=$custno_';

    var response = await http.get(Uri.parse(url));

    var result = json.decode(response.body);
    for (var map in result) {
      CustomerModel customerModel = CustomerModel.fromJson(map);
      setState(() {
        customerModels.add(customerModel);
      });
    }
  }

  Future<Null> read_GC_rental() async {
    if (renTalModels.isNotEmpty) {
      setState(() {
        renTalModels.clear();
      });
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    String url =
        '${MyConstant().domain_chao}/GC_rental_setring.php?isAdd=true&ren=$ren';
    renTal_name = preferences.getString('renTalName');
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result != null) {
        for (var map in result) {
          RenTalModel renTalModel = RenTalModel.fromJson(map);
          var rtnamex = renTalModel.rtname!.trim();
          var typexs = renTalModel.type!.trim();
          var typexx = renTalModel.typex!.trim();
          var billNamex = renTalModel.bill_name!.trim();
          var billAddrx = renTalModel.bill_addr!.trim();
          var billTaxx = renTalModel.bill_tax!.trim();
          var billTelx = renTalModel.bill_tel!.trim();
          var billEmailx = renTalModel.bill_email!.trim();
          var billDefaultx = renTalModel.bill_default;
          var billTserx = renTalModel.tser;
          var name = renTalModel.pn!.trim();
          var foderx = renTalModel.dbn;
          setState(() {
            _ReportValue_type = (renTalModel.receipt_title! == '0')
                ? 'ไม่ระบุ'
                : (renTalModel.receipt_title! == '1')
                    ? 'ต้นฉบับ'
                    : 'สำเนา';
            foder = foderx;
            rtname = rtnamex;
            type = typexs;
            typex = typexx;
            renname = name;
            bill_name = billNamex;
            bill_addr = billAddrx;
            bill_tax = billTaxx;
            bill_tel = billTelx;
            bill_email = billEmailx;
            bill_default = billDefaultx;
            bill_tser = billTserx;
            tem_page_ser = renTalModel.tem_page!.trim();
            renTalModels.add(renTalModel);
            if (billDefaultx == 'P') {
              bills_name_ = 'บิลธรรมดา';
            } else {
              bills_name_ = 'ใบกำกับภาษี';
            }
          });
        }
      } else {}
    } catch (e) {}
    // print('name>>>>>  $renname');
  }

  Future<Null> red_Invoice(index) async {
    if (finnancetransModels.length != 0) {
      setState(() {
        finnancetransModels.clear();
        sum_disamt = 0;
        sum_disp = 0;
        dis_sum_Matjum = 0.00;
        sum_duesbill = 0.00;
      });
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var ciddoc = limitedList_TransReBillModels_[index].cid;
    var qutser = limitedList_TransReBillModels_[index].ser_in;
    var docnoin =
        limitedList_TransReBillModels_[index].docno; //.toString().trim()
    print('>>>>>>>>>>>dd>>> in d  $docnoin');

    String url =
        '${MyConstant().domain_chao}/GC_bill_pay_amt.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&docnoin=$docnoin';
    try {
      var response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);
      print('BBBBBBBBBBBBBBBB>>>> $result');
      if (result.toString() != 'null') {
        for (var map in result) {
          FinnancetransModel finnancetransModel =
              FinnancetransModel.fromJson(map);

          var sidamt = double.parse(finnancetransModel.amt!);
          var siddisper = double.parse(finnancetransModel.disper!);
          var pdatex = finnancetransModel.pdate;

          setState(() {
            Slip_history = finnancetransModel.slip.toString();
            pdate = pdatex;
            if (int.parse(finnancetransModel.receiptSer!) != 0) {
              finnancetransModels.add(finnancetransModel);
            } else {
              if (finnancetransModel.type!.trim() == 'DISCOUNT') {
                sum_disamt = sidamt;
                sum_disp = siddisper;
              }
            }
          });
          print('>>pdate>>> $pdate');
          if (finnancetransModel.dtype! == 'MM') {
            setState(() {
              dis_sum_Matjum =
                  dis_sum_Matjum + double.parse(finnancetransModel.amt!);
            });
          }

          if (finnancetransModel.dtype! == 'FTA') {
            setState(() {
              sum_duesbill = double.parse(finnancetransModel.amt!);
            });
          }
          print(
              '>>>>> ${finnancetransModel.slip}>>>>>>dd>>> in $sidamt $siddisper  ');
        }
      }
    } catch (e) {}
  }

  /////////////////////////////////////////////////////////////////////
  List<String> total_list = [];
  double All_total = 0.00, totaltoday = 0.00;

  Future<Null> red_Trans_bill() async {
    if (limitedList_TransReBillModels_.length != 0) {
      setState(() {
        limitedList_TransReBillModels_.clear();
      });
    }
    ////////////////------------------------------------------------------>
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var custno_S = preferences.getString('custno');

    String url =
        '${MyConstant().domain}/GC_bill_pay_BC_Verifi_cid.php?isAdd=true&ren=$ren&custno=$custno_S';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('result $ciddoc');
      if (result.toString() != 'null') {
        for (var map in result) {
          TransReBillModel transReBillModel = TransReBillModel.fromJson(map);
          var sess = int.parse(transReBillModel.pos!);
          setState(() {
            sucsess = sucsess + sess;
            limitedList_TransReBillModels_.add(transReBillModel);
          });
        }
      }
    } catch (e) {}
  }

  /////------------------------------------->
  String? base64_Slip, fileName_Slip;
  var extension_;
  var file_;
  Future<void> uploadFile_Slip(context, docnox) async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 100, maxWidth: 100);

    if (pickedFile == null) {
      // //print('User canceled image selection');
      return;
    } else {
      // 2. Read the image as bytes
      final imageBytes = await pickedFile.readAsBytes();
      // Define the target width and height
      final int targetWidth = 100;
      final int targetHeight = 100;

      // Resize the image to the target width and height
      // final img.Image resizedImage = img.copyResize(
      //   img.decodeImage(imageBytes)!,
      //   width: targetWidth,
      //   height: targetHeight,
      // );
      // 3. Encode the resized image as a base64 string
      //  final base64Image = base64Encode(img.encodePng(resizedImage));

      // 3. Encode the image as a base64 string
      final base64Image = base64Encode(imageBytes);
      setState(() {
        base64_Slip = base64Image;
      });
      // //print(base64_Slip);
      setState(() {
        extension_ = 'png';
        // file_ = file;
      });
      // //print(extension_);
      // //print(extension_);
    }

    OKuploadFile_Slip(context, docnox);
  }

  Future<void> OKuploadFile_Slip(context, docnox) async {
    String Path_foder = 'slip';
    String dateTimeNow = DateTime.now().toString();
    String date = DateFormat('ddMMyyyy')
        .format(DateTime.parse('${dateTimeNow}'))
        .toString();
    final dateTimeNow2 = DateTime.now().toUtc().add(const Duration(hours: 7));
    final formatter2 = DateFormat('HHmmss');
    final formattedTime2 = formatter2.format(dateTimeNow2);
    String Time_ = formattedTime2.toString();
    String date_MM =
        DateFormat('MM').format(DateTime.parse('${date}')).toString();
    String date_YY =
        DateFormat('yyyy').format(DateTime.parse('${date}')).toString();
    String dates = DateFormat('ddMMyyyy')
        .format(DateTime.parse('${dateTimeNow}'))
        .toString();
    ////////////////------------------------------------------------------>
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var qutser_ = preferences.getString('qutser');
    var ren = preferences.getString('renTalSer');
    var custno_S = preferences.getString('custno');
    ////////////////------------------------------------------------------>
    var fileName_Slip_ = 'slip_${docnox}_${date}_$Time_';
    setState(() {
      fileName_Slip = 'slip_${docnox}_${date}_$Time_.$extension_';
    });
    try {
      final url =
          '${MyConstant().domain_chao}/File_uploadSlip_NewEdit.php?name=$fileName_Slip&Foder=$foder&extension=$extension_';

      final response = await http.post(
        Uri.parse(url),
        body: {
          'image': base64_Slip,
          'Foder': foder,
          'name': fileName_Slip,
          'ex': extension_.toString()
        },
      );

      if (response.statusCode == 200) {
        print('Image uploaded successfully');
        try {
          final url =
              '${MyConstant().domain_chao}/File_uploadSlip_Again.php?name=$fileName_Slip&Foder=$foder&extension=$extension_';

          final response = await http.post(
            Uri.parse(url),
            body: {
              'ren': '$ren',
              'image': base64_Slip,
              'Foder': foder,
              'name': fileName_Slip,
              'ex': extension_.toString(),
              'month': date_MM.toString(),
              'year': date_YY.toString(),
              'docno': docnox.toString(),
              'slip_del': ''
            }, // Send the image as a form field named 'image'
          );
          Navigator.pop(context);
          setState(() {
            red_Trans_bill();
          });
        } catch (e) {}
      } else {
        print('Image upload failed');
      }
    } catch (e) {
      print('Error during image processing: $e');
    }
  }

  void addAllListData() {
    const int count = 5;
    // listViews.add(
    //   TitleView(
    //     titleTxt: cus_lang == 'EN' ? 'Contract' : 'สัญญา',
    //     subTxt: 'X',
    //     animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    //         parent: widget.animationController!,
    //         curve:
    //             Interval((1 / count) * 2, 1.0, curve: Curves.fastOutSlowIn))),
    //     animationController: widget.animationController!,
    //   ),
    // );
    listViews.add(
      TitleView(
        titleTxt: cus_lang == 'EN'
            ? 'Pending $sucsess bill'
            : 'รอดำเนินการ $sucsess บิล',
        subTxt: 'X',
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve:
                Interval((1 / count) * 2, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
      ),
    );
    listViews.add(
      Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
            }),
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 100),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = 1;
                  double aspectRatio = 5.0;
                  double padding = 2;
                  double bottom_x = 20;
                  double width_x = 100;
                  double height_x = 50;

                  crossAxisCount = 1;
                  aspectRatio = 3.2;
                  bottom_x = 40;
                  width_x = 80;
                  height_x = 50;
                  // เช็คว่าหน้าจอกว้างพอที่จะเป็น 2 คอลัมน์ไหม
                  final isWideScreen = constraints.maxWidth > 600;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: limitedList_TransReBillModels_.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 1.0,
                      crossAxisSpacing: 1.0,
                      childAspectRatio: aspectRatio,
                    ),
                    itemBuilder: (context, index) {
                      return SizedBox(
                        width: double.infinity,
                        child: Stack(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 5, left: 8, right: 8, bottom: 5),
                              child: InkWell(
                                onTap: () async {
                                  setState(() {
                                    base64_Slip = null;
                                    Slip_history = null;
                                  });

                                  red_Invoice(index).then((value) {
                                    print(
                                        '${MyConstant().domain_chao}/files/$foder/slip/$Slip_history');

                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20.0))),
                                        backgroundColor:
                                            AppbackgroundColor.Sub_Abg_Colors,
                                        titlePadding: const EdgeInsets.all(0.0),
                                        contentPadding:
                                            const EdgeInsets.all(10.0),
                                        actionsPadding:
                                            const EdgeInsets.all(6.0),
                                        title: Center(
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4.0),
                                                      child: Icon(
                                                          Icons.highlight_off,
                                                          size: 30,
                                                          color:
                                                              Colors.red[700]),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                '${limitedList_TransReBillModels_[index].docno} ',
                                                maxLines: 1,
                                                textAlign: TextAlign.start,
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T,
                                                    fontSize: 12.0),
                                              ),
                                            ],
                                          ),
                                        ),
                                        content: (limitedList_TransReBillModels_[
                                                            index]
                                                        .slip ==
                                                    null ||
                                                limitedList_TransReBillModels_[
                                                            index]
                                                        .slip
                                                        .toString() ==
                                                    'null' ||
                                                limitedList_TransReBillModels_[
                                                            index]
                                                        .slip
                                                        .toString() ==
                                                    '')
                                            ? Container(
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 10,
                                                      left: 10,
                                                      bottom: 10),
                                                  child: Container(
                                                      padding:
                                                          EdgeInsets.all(20),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                      ),
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.85,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          uploadFile_Slip(
                                                              context,
                                                              limitedList_TransReBillModels_[
                                                                      index]
                                                                  .docno);
                                                        },
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius: BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        5),
                                                                topRight: Radius
                                                                    .circular(
                                                                        5),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        5),
                                                                bottomRight:
                                                                    Radius
                                                                        .circular(
                                                                            5)),
                                                            border: Border.all(
                                                                color: Colors
                                                                    .grey
                                                                    .shade50,
                                                                width: 1),
                                                          ),
                                                          padding:
                                                              EdgeInsets.all(
                                                                  10),
                                                          child:
                                                              base64_Slip ==
                                                                      null
                                                                  ? Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Row(
                                                                          children: [
                                                                            Expanded(
                                                                                child: Icon(
                                                                              Icons.system_update_alt_outlined,
                                                                              size: 65,
                                                                              color: Colors.grey,
                                                                            ))
                                                                          ],
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            Expanded(
                                                                              child: Text(
                                                                                "คลิกหรือกด เพื่อเลือกไฟล์",
                                                                                textAlign: TextAlign.center,
                                                                                style: TextStyle(fontSize: 16, color: Colors.grey, fontFamily: Font_.Fonts_T, fontWeight: FontWeight.bold),
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            Expanded(
                                                                              child: Text(
                                                                                "รองรับไฟล์ภาพ JPG หรือ PNG",
                                                                                textAlign: TextAlign.center,
                                                                                style: TextStyle(
                                                                                  fontSize: 12,
                                                                                  color: Colors.grey,
                                                                                  fontFamily: Font_.Fonts_T,
                                                                                ),
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            Expanded(
                                                                              child: Text(
                                                                                "ขนาดไฟล์สูงสุด: 10MB",
                                                                                textAlign: TextAlign.center,
                                                                                style: TextStyle(
                                                                                  fontSize: 8,
                                                                                  color: Colors.grey,
                                                                                  fontFamily: Font_.Fonts_T,
                                                                                ),
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    )
                                                                  : Image
                                                                      .memory(
                                                                      base64Decode(
                                                                          base64_Slip
                                                                              .toString()),
                                                                      // height: 200,
                                                                      // fit: BoxFit.cover,
                                                                    ),
                                                        ),
                                                      )),
                                                ),
                                              )
                                            : SizedBox(
                                                // height: MediaQuery.of(context)
                                                //         .size
                                                //         .height *
                                                //     0.75,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Image.network(
                                                    '${MyConstant().domain_chao}/files/$foder/slip/$Slip_history',
                                                    fit: BoxFit.fill,
                                                    cacheWidth: 500,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Container(
                                                        color: Colors.grey[300],
                                                        alignment:
                                                            Alignment.center,
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Icon(Icons
                                                                  .image_not_supported),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                cus_lang == 'EN'
                                                                    ? 'An error occurred. Please try again.'
                                                                    : 'เกิดข้อผิดพลาดกรุณาลองใหม่อีกครั้ง',
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      FitnessAppTheme
                                                                          .fontName,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 15,
                                                                  letterSpacing:
                                                                      0.2,
                                                                  color: Colors
                                                                      .black45,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                        // Stack(
                                        //   alignment: Alignment.center,
                                        //   children: <Widget>[
                                        //     Image.network(
                                        //         '${MyConstant().domain_chao}/files/$foder/slip/$Slip_history')
                                        //   ],
                                        // ),
                                        actions: (limitedList_TransReBillModels_[
                                                            index]
                                                        .slip ==
                                                    null ||
                                                limitedList_TransReBillModels_[
                                                            index]
                                                        .slip
                                                        .toString() ==
                                                    'null' ||
                                                limitedList_TransReBillModels_[
                                                            index]
                                                        .slip
                                                        .toString() ==
                                                    '')
                                            ? null
                                            : [
                                                Center(
                                                  child: Container(
                                                    width: 200,
                                                    padding: EdgeInsets.all(2),
                                                    child: Center(
                                                      child: ElevatedButton(
                                                        style: ButtonStyle(
                                                            backgroundColor:
                                                                MaterialStateProperty
                                                                    .all<Color>(
                                                              Colors.black,
                                                            ),
                                                            shape: MaterialStateProperty.all<
                                                                    RoundedRectangleBorder>(
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                            ))),
                                                        onPressed: () async {
                                                          uploadFile_Slip(
                                                              context,
                                                              limitedList_TransReBillModels_[
                                                                      index]
                                                                  .docno);
                                                        },
                                                        child: Text(
                                                          cus_lang == 'EN'
                                                              ? 'Upload again.'
                                                              : 'อัพโหลดอีกครั้ง',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                FitnessAppTheme
                                                                    .fontName,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 15,
                                                            letterSpacing: 0.2,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                      ),
                                    );
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          //  HexColor(
                                          //         '#FBF3D5')
                                          //     .withOpacity(
                                          //         0.6),
                                          offset: const Offset(1.1, 2.0),
                                          blurRadius: 4.0),
                                    ],
                                    gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: <HexColor>[
                                          HexColor('#ECE3CE'),
                                          HexColor('#F3EEEA'),
                                          // HexColor('#FFBE98'),
                                          // HexColor('#F6995C')
                                        ]),
                                    borderRadius: const BorderRadius.only(
                                      bottomRight: Radius.circular(8.0),
                                      bottomLeft: Radius.circular(8.0),
                                      topLeft: Radius.circular(8.0),
                                      topRight: Radius.circular(8.0),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: InkWell(
                                          onTap: () async {},
                                          child: Container(
                                            decoration: BoxDecoration(
                                              boxShadow: <BoxShadow>[
                                                BoxShadow(
                                                    color: HexColor('#FBF3D5')
                                                        .withOpacity(0.6),
                                                    offset:
                                                        const Offset(1.1, 4.0),
                                                    blurRadius: 8.0),
                                              ],
                                              gradient: LinearGradient(
                                                colors: <HexColor>[
                                                  limitedList_TransReBillModels_[
                                                                  index]
                                                              .pos ==
                                                          '1'
                                                      ? HexColor('#FFBE98')
                                                      : HexColor('#4F6F52'),
                                                  limitedList_TransReBillModels_[
                                                                  index]
                                                              .pos ==
                                                          '1'
                                                      ? HexColor('#F6995C')
                                                      : HexColor('#3A4D39'),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius:
                                                  const BorderRadius.only(
                                                bottomRight:
                                                    Radius.circular(8.0),
                                                bottomLeft:
                                                    Radius.circular(8.0),
                                                topLeft: Radius.circular(8.0),
                                                topRight: Radius.circular(54.0),
                                              ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 0,
                                                  left: 0,
                                                  right: 0,
                                                  bottom: 0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          '${limitedList_TransReBillModels_[index].cid}',
                                                          textAlign:
                                                              TextAlign.start,
                                                          maxLines: 1,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 10,
                                                            fontFamily:
                                                                FitnessAppTheme
                                                                    .fontName,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            // fontSize: 16,
                                                            letterSpacing: 0.2,
                                                            color:
                                                                FitnessAppTheme
                                                                    .white,
                                                          ),
                                                        ),
                                                        Text(
                                                          (limitedList_TransReBillModels_[
                                                                              index]
                                                                          .slip ==
                                                                      null ||
                                                                  limitedList_TransReBillModels_[
                                                                              index]
                                                                          .slip
                                                                          .toString() ==
                                                                      'null' ||
                                                                  limitedList_TransReBillModels_[
                                                                              index]
                                                                          .slip
                                                                          .toString() ==
                                                                      '')
                                                              ? cus_lang == 'EN'
                                                                  ? 'No proof.'
                                                                  : '( ไม่พบหลักฐาน )'
                                                              : cus_lang == 'EN'
                                                                  ? 'Proof found.'
                                                                  : '( พบหลักฐาน )',
                                                          textAlign:
                                                              TextAlign.start,
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            fontFamily:
                                                                FitnessAppTheme
                                                                    .fontName,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            // fontSize: 16,
                                                            letterSpacing: 0.2,
                                                            color:
                                                                FitnessAppTheme
                                                                    .white,
                                                          ),
                                                        ),
                                                      ],
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
                                              MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  flex: 4,
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 4.0, left: 4.0),
                                                    child: Text(
                                                      '${limitedList_TransReBillModels_[index].docno}',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black,
                                                        fontFamily:
                                                            Font_.Fonts_T,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            2.0),
                                                    child: Text(
                                                      (limitedList_TransReBillModels_[
                                                                      index]
                                                                  .total_bill ==
                                                              null)
                                                          ? '0.00'
                                                          : '${nFormat.format(double.parse(limitedList_TransReBillModels_[index].total_bill!))}',
                                                      textAlign: TextAlign.end,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black,
                                                        fontFamily:
                                                            Font_.Fonts_T,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  flex: 4,
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 4.0, left: 4.0),
                                                    child: Text(
                                                      (limitedList_TransReBillModels_[
                                                                      index]
                                                                  .dateacc ==
                                                              null)
                                                          ? '??'
                                                          : cus_lang == 'EN'
                                                              ? '${DateFormat('dd-MM-yyyy').format((DateTime.parse('${limitedList_TransReBillModels_[index].dateacc} 00:00:00')))}'
                                                              : '${DateFormat('dd-MM').format((DateTime.parse('${limitedList_TransReBillModels_[index].dateacc} 00:00:00')))}-${DateTime.parse('${limitedList_TransReBillModels_[index].dateacc} 00:00:00').year + 0}',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.black,
                                                        fontFamily:
                                                            Font_.Fonts_T,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(0, 0, 4, 0),
                                                    child: Text(
                                                      limitedList_TransReBillModels_[
                                                                      index]
                                                                  .pos ==
                                                              '1'
                                                          ? 'กำลังดำเนิดการ'
                                                          : 'ชำระเสร็จสิ้น',
                                                      textAlign: TextAlign.end,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            limitedList_TransReBillModels_[
                                                                            index]
                                                                        .pos ==
                                                                    '1'
                                                                ? Colors.orange
                                                                    .shade900
                                                                : Colors.green
                                                                    .shade900,
                                                        fontFamily:
                                                            Font_.Fonts_T,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          )),
    );
  }

  double sum_pvat = 0.00,
      sum_vat = 0.00,
      sum_wht = 0.00,
      sum_amt = 0.00,
      sum_dis = 0.00,
      sum_disamt = 0.00,
      sum_disp = 0,
      dis_sum_Matjum = 0.00,
      sum_duesbill = 0.00;
  String? numinvoice, numdoctax, Slip_history;

  Future<Null> red_Trans_select(index) async {
    if (_TransReBillHistoryModels.length != 0) {
      setState(() {
        _TransReBillHistoryModels.clear();
        sum_pvat = 0;
        sum_vat = 0;
        sum_wht = 0;
        sum_amt = 0;
        // sum_disamt = 0;
        // sum_disp = 0;
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = limitedList_TransReBillModels_[index].ser;
    var qutser = limitedList_TransReBillModels_[index].ser_in;
    var docnoin = limitedList_TransReBillModels_[index].docno;
    String url =
        '${MyConstant().domain_chao}/GC_bill_pay_history.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc&docnoin=$docnoin';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      print('1230>>>> $result');
      if (result.toString() != 'null') {
        for (var map in result) {
          TransReBillHistoryModel _TransReBillHistoryModel =
              TransReBillHistoryModel.fromJson(map);
          var dtypeinvoiceent = _TransReBillHistoryModel.dtype;
          var numinvoiceent = _TransReBillHistoryModel.docno;

          var sum_pvatx = dtypeinvoiceent == 'KP' || dtypeinvoiceent == '!Z'
              ? double.parse(_TransReBillHistoryModel.pvat!)
              : 0.0;
          var sum_vatx = dtypeinvoiceent == 'KP' || dtypeinvoiceent == '!Z'
              ? double.parse(_TransReBillHistoryModel.vat!)
              : 0.0;
          var sum_whtx = dtypeinvoiceent == 'KP' || dtypeinvoiceent == '!Z'
              ? double.parse(_TransReBillHistoryModel.wht!)
              : 0.0;
          var sum_amtx = dtypeinvoiceent == 'KP' || dtypeinvoiceent == '!Z'
              ? double.parse(_TransReBillHistoryModel.total!)
              : 0.0;

          setState(() {
            if (dtypeinvoiceent == 'KP') {
              sum_pvat = sum_pvat + sum_pvatx;
              sum_vat = sum_vat + sum_vatx;
              sum_wht = sum_wht + sum_whtx;
              sum_amt = sum_amt + sum_amtx;
              // sum_disamt = sum_disamtx;
              // sum_disp = sum_dispx;
              numinvoice = _TransReBillHistoryModel.docno;
              numdoctax = _TransReBillHistoryModel.doctax;
              _TransReBillHistoryModels.add(_TransReBillHistoryModel);
            } else if (dtypeinvoiceent == '!Z') {
              sum_pvat = sum_pvat + sum_pvatx;
              sum_vat = sum_vat + sum_vatx;
              sum_wht = sum_wht + sum_whtx;
              sum_amt = sum_amt + sum_amtx;
              // sum_disamt = sum_disamtx;
              // sum_disp = sum_dispx;
              numinvoice = _TransReBillHistoryModel.docno;
              numdoctax = _TransReBillHistoryModel.doctax;
              _TransReBillHistoryModels.add(_TransReBillHistoryModel);
            } else {
              // total_amt = total_amt + total_amtx;
              _TransReBillHistoryModels.add(_TransReBillHistoryModel);
            }
          });
        }
      }
      // setState(() {
      //   red_Invoice(index);
      // });
    } catch (e) {}
  }

  Future<Null> Receipt_his_statusbill(
      tableData00,
      newValuePDFimg,
      sname,
      cname,
      addr,
      tax,
      room_number_BillHistory,
      TitleType_Default_Receipt_Name) async {
    ManPay_Receipt_PDF.ManPayReceipt_PDF(
        numinvoice,
        context,
        foder,
        renTal_name,
        // sname,
        // cname,
        // addr,
        // tax,
        bill_addr,
        bill_email,
        bill_tel,
        bill_tax,
        bill_name,
        newValuePDFimg,
        TitleType_Default_Receipt_Name,
        tem_page_ser,
        bills_name_,
        '0');
    // ManPay_Receipt_PDF.ManPayReceipt_PDF(
    //     numinvoice,
    //     context,
    //     foder,
    //     renTal_name,
    //     // sname,
    //     // cname,
    //     // addr,
    //     // tax,
    //     bill_addr,
    //     bill_email,
    //     bill_tel,
    //     bill_tax,
    //     bill_name,
    //     newValuePDFimg,
    //     TitleType_Default_Receipt_Name,
    //     tem_page_ser,
    //     bills_name_);
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    return true;
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
            : Stack(
                children: <Widget>[
                  getMainListViewUI(),
                  getAppBarUI(),
                  SizedBox(
                    height: MediaQuery.of(context).padding.bottom,
                  )
                ],
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
              bottom: 62 + MediaQuery.of(context).padding.bottom,
            ),
            itemCount: listViews.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
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
                      bottomLeft: Radius.circular(32.0),
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  cus_lang == 'EN'
                                      ? 'Payment status '
                                      : 'สถานะการชำระ',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: FitnessAppTheme.fontName,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 22 + 6 - 6 * topBarOpacity,
                                    letterSpacing: 1.2,
                                    color: FitnessAppTheme.darkerText,
                                  ),
                                ),
                              ),
                            ),
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
