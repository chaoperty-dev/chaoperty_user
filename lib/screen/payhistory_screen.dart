import 'dart:convert';
// ignore: unused_import
import 'dart:math';
import 'dart:ui';

// ignore: unused_import
import 'package:auto_size_text/auto_size_text.dart';
// ignore: unnecessary_import
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
// ignore: unused_import
import 'package:intl/number_symbols_data.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Constant/Myconstant.dart';
import '../INSERT_Log/Insert_log.dart';
import '../Model/GetFinnancetrans_Model.dart';
import '../Model/GetRenTal_Model.dart';
import '../Model/trans_re_bill_history_model.dart';
import '../Model/trans_re_bill_model.dart';
import '../Responsive/responsive.dart';
import '../color.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

import 'box/contentbox.dart';

class PayHistoryScreen extends StatefulWidget {
  const PayHistoryScreen({super.key});

  @override
  State<PayHistoryScreen> createState() => _PayHistoryScreenState();
}

class _PayHistoryScreenState extends State<PayHistoryScreen> {
  // Get the current date

  String? day_now;
  var nFormat = NumberFormat("#,##0.00", "en_US");
  List<TransReBillModel> _TransReBillModels = [];
  List<TransReBillModel> _TransReBillModels_AwatStatus = [];
  List<TransReBillModel> _TransReBillModels_CancelStatus = [];
  List<FinnancetransModel> finnancetransModels = [];
  List<RenTalModel> renTalModels = [];
  List<TransReBillHistoryModel> _TransReBillHistoryModels = [];
  bool? isChecked = false;
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
      imglogo_,
      pdate,
      numinvoice;
  double sum_pvat = 0.00,
      sum_vat = 0.00,
      sum_wht = 0.00,
      sum_amt = 0.00,
      sum_dis = 0.00,
      sum_disamt = 0.00,
      sum_disp = 0;
  int ser_tap = 1;
  @override
  void initState() {
    super.initState();

    red_Trans_bill();
    read_GC_rental();
    // sum_disamtx.text = '0.00';
  }

  String Slip_history = "";
  List<Color> _kDefaultRainbowColors = const [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
  ];

  Future<Null> read_GC_rental() async {
    if (renTalModels.isNotEmpty) {
      renTalModels.clear();
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    //https://dzentric.com/chao_perty/chao_api/GC_rental_setring.php?isAdd=true&ren=50
    String url =
        '${MyConstant().domain}/GC_rental_setring.php?isAdd=true&ren=$ren';
    //renTal_name = preferences.getString('renTalName');
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
          var bill_namex = renTalModel.bill_name!.trim();
          var bill_addrx = renTalModel.bill_addr!.trim();
          var bill_taxx = renTalModel.bill_tax!.trim();
          var bill_telx = renTalModel.bill_tel!.trim();
          var bill_emailx = renTalModel.bill_email!.trim();
          var bill_defaultx = renTalModel.bill_default;
          var bill_tserx = renTalModel.tser;
          var name = renTalModel.pn!.trim();
          var foderx = renTalModel.dbn;
          setState(() {
            foder = foderx;
            rtname = rtnamex;
            type = typexs;
            typex = typexx;
            renname = name;
            bill_name = bill_namex;
            bill_addr = bill_addrx;
            bill_tax = bill_taxx;
            bill_tel = bill_telx;
            bill_email = bill_emailx;
            bill_default = bill_defaultx;
            bill_tser = bill_tserx;
            imglogo_ =
                '${MyConstant().domain}/files/$foder/logo/${renTalModel.imglogo!.trim()}';
            renTalModels.add(renTalModel);
            if (bill_defaultx == 'P') {
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

  // Future<Null> red_Trans_bill() async {
  //   if (_TransReBillModels.length != 0) {
  //     setState(() {
  //       _TransReBillModels.clear();
  //     });
  //   }
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   var ren = preferences.getString('renTalSer');

  //   var user = preferences.getString('user');
  //   var ciddoc = preferences.getString('usercid');
  //   var qutser = preferences.getString('qutser');

  //   String url =
  //       '${MyConstant().domain_chao}/GC_bill_pay_BC.php?isAdd=true&ren=$ren';
  //   try {
  //     var response = await http.get(Uri.parse(url));

  //     var result = json.decode(response.body);
  //     // print('result $ciddoc');
  //     if (result.toString() != 'null') {
  //       for (var map in result) {
  //         TransReBillModel transReBillModel = TransReBillModel.fromJson(map);
  //         if (ciddoc.toString().trim() ==
  //             transReBillModel.cid.toString().trim()) {
  //           setState(() {
  //             _TransReBillModels.add(transReBillModel);

  //             // _TransBillModels.add(_TransBillModel);
  //           });
  //         } else {}
  //       }
  //       setState(() {
  //         // TransReBillModels_ = _TransReBillModels;
  //       });
  //       print('result ${_TransReBillModels.length}');
  //     }
  //   } catch (e) {}
  // }

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
    var ciddoc = _TransReBillModels[index].ser;
    var qutser = _TransReBillModels[index].ser_in;
    var docnoin = _TransReBillModels[index].docno;
    String url =
        '${MyConstant().domain_chao}/GC_bill_pay_history.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc&docnoin=$docnoin';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() != 'null') {
        for (var map in result) {
          TransReBillHistoryModel _TransReBillHistoryModel =
              TransReBillHistoryModel.fromJson(map);

          var sumPvatx = double.parse(_TransReBillHistoryModel.pvat!);
          var sumVatx = double.parse(_TransReBillHistoryModel.vat!);
          var sumWhtx = double.parse(_TransReBillHistoryModel.wht!);
          var sumAmtx = double.parse(_TransReBillHistoryModel.total!);
          // var sum_disamtx = double.parse(_InvoiceHistoryModel.disendbill!);
          // var sum_dispx = double.parse(_InvoiceHistoryModel.disendbillper!);
          var numinvoiceent = _TransReBillHistoryModel.docno;
          setState(() {
            sum_pvat = sum_pvat + sumPvatx;
            sum_vat = sum_vat + sumVatx;
            sum_wht = sum_wht + sumWhtx;
            sum_amt = sum_amt + sumAmtx;
            // sum_disamt = sum_disamtx;
            // sum_disp = sum_dispx;
            numinvoice = _TransReBillHistoryModel.docno;
            _TransReBillHistoryModels.add(_TransReBillHistoryModel);
          });
        }
      }
      // setState(() {
      //   red_Invoice(index);
      // });
    } catch (e) {}
  }

  Future<Null> red_Invoice(index) async {
    if (finnancetransModels.length != 0) {
      setState(() {
        finnancetransModels.clear();
        sum_disamt = 0;
        sum_disp = 0;
      });
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var ciddoc = _TransReBillModels[index].ser;
    var qutser = _TransReBillModels[index].ser_in;
    var docnoin = _TransReBillModels[index].docno; //.toString().trim()
    // print('>>>>>>>>>>>dd>>> in d  $docnoin');

    String url =
        '${MyConstant().domain_chao}/GC_bill_pay_amt.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&docnoin=$docnoin';
    try {
      var response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);
      // print('BBBBBBBBBBBBBBBB>>>> $result');
      if (result.toString() != 'null') {
        for (var map in result) {
          FinnancetransModel finnancetransModel =
              FinnancetransModel.fromJson(map);

          var sidamt = double.parse(finnancetransModel.amt!);
          var siddisper = double.parse(finnancetransModel.disper!);
          var pdatex = finnancetransModel.pdate;

          setState(() {
            Slip_history = finnancetransModel.slip.toString();
            if (int.parse(finnancetransModel.receiptSer!) != 0) {
              finnancetransModels.add(finnancetransModel);
              pdate = pdatex;
            } else {
              if (finnancetransModel.type!.trim() == 'DISCOUNT') {
                sum_disamt = sidamt;
                sum_disp = siddisper;
              }
            }
          });
          // print(
          //     '>>>>> ${finnancetransModel.slip}>>>>>>dd>>> in $sidamt $siddisper  ');
        }
      }
      finnancetransModels.sort((a, b) => b.type!.compareTo(a.type!));
    } catch (e) {}
  }

  Future<String> red_Invoice_text(index) async {
    String sumtype = '';

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var ciddoc = _TransReBillModels[index].ser;
    var qutser = _TransReBillModels[index].ser_in;
    var docnoin = _TransReBillModels[index].docno; //.toString().trim()
    // print('>>>>>>>>>>>dd>>> in d  $docnoin');
    int in_dex = 0;
    String url =
        '${MyConstant().domain_chao}/GC_bill_pay_amt.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&docnoin=$docnoin';
    try {
      var response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);
      // print('BBBBBBBBBBBBBBBB>>>> $result');
      if (result.toString() != 'null') {
        for (var map in result) {
          FinnancetransModel finnancetransModel =
              FinnancetransModel.fromJson(map);
          if (int.parse(finnancetransModel.receiptSer!) != 0) {
            if (in_dex == 0) {
              sumtype = sumtype + '${finnancetransModel.type}';
            } else {
              sumtype = sumtype + ',${finnancetransModel.type}';
            }

            in_dex++;
          }
        }
      }
    } catch (e) {
      // Handle any errors here
    }
    List<String> valueList = sumtype.split(',');
    valueList.sort((a, b) => b.compareTo(a));
    sumtype = valueList.join(',');

    // Return sumtype as a Future<String>
    return sumtype;
  }

  Future<Null> red_Trans_bill() async {
    DateTime currentDate = DateTime.now();

    // Format the date as 'YYYY-MM-DD'
    String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
    // _showSingleAnimationDialog(
    //   context,
    //   Indicator.values[30],
    //   false,
    // );
    setState(() {
      day_now = formattedDate;
      _TransReBillModels.clear();
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    // var ren = 65;
    // var ciddoc = 'LE000063';
    // var qutser = '';
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('user');
    var ciddoc = preferences.getString('usercid');
    var qutser = preferences.getString('qutser');

    String url =
        '${MyConstant().domain}/GC_bill_pay.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('result $ciddoc');
      if (result.toString() != 'null') {
        for (var map in result) {
          TransReBillModel transReBillModel = TransReBillModel.fromJson(map);
          setState(() {
            _TransReBillModels.add(transReBillModel);

            // _TransBillModels.add(_TransBillModel);
          });
        }

        // print('result ${_TransReBillModels.length}');
      }
    } catch (e) {}
  }

  Future<Null> red_Trans_bill_StatauAwat() async {
    setState(() {
      _TransReBillModels_AwatStatus.clear();
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('user');
    var ciddoc = preferences.getString('usercid');
    var qutser = preferences.getString('qutser');

    String url =
        '${MyConstant().domain}/GC_bill_pay.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('result $ciddoc');
      if (result.toString() != 'null') {
        for (var map in result) {
          TransReBillModel transReBillModel = TransReBillModel.fromJson(map);

          if (transReBillModel.pos.toString().trim() == '1') {
            setState(() {
              _TransReBillModels_AwatStatus.add(transReBillModel);
            });
          }
        }

        // print('result ${_TransReBillModels_AwatStatus.length}');
      }
    } catch (e) {}
  }

  Future<Null> red_Trans_bill_CancelAwat() async {
    setState(() {
      _TransReBillModels_CancelStatus.clear();
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('user');
    var ciddoc = preferences.getString('usercid');
    var qutser = preferences.getString('qutser');

    String url =
        '${MyConstant().domain}/GC_bill_pay.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('result $ciddoc');
      if (result.toString() != 'null') {
        for (var map in result) {
          TransReBillModel transReBillModel = TransReBillModel.fromJson(map);

          if (transReBillModel.dtype.toString().trim() == '!Z') {
            setState(() {
              _TransReBillModels_CancelStatus.add(transReBillModel);
            });
          }
        }

        // print('result ${_TransReBillModels_CancelStatus.length}');
      }
    } catch (e) {}
  }

///////---------------------------------------------->
  String? base64_Slip, fileName_Slip;
  var extension_;
  var file_;
  Future<void> uploadFile_Slip(context, docnos) async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 100, maxWidth: 100);

    if (pickedFile == null) {
      // print('User canceled image selection');
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
      // print(base64_Slip);
      setState(() {
        extension_ = 'png';
        // file_ = file;
      });
      // print(extension_);
      // print(extension_);
      Dialog_Slip(context, docnos);
    }
  }

  Future<void> Dialog_Slip(context, docnos) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '$docnos',
                maxLines: 1,
                textAlign: TextAlign.start,
                style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0),
              ),
              Text(
                'ยืนการแก้ไขหลักฐานการชำระ .. ?? ',
                maxLines: 1,
                textAlign: TextAlign.start,
                style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontFamily: FontWeight_.Fonts_T,
                    fontSize: 18.0),
              ),
            ],
          ),
          content: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              SizedBox(
                width: 300,
                height: 300,
                child: Image.memory(
                  base64Decode(base64_Slip.toString()),
                  // height: 200,
                  // fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 100,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10)),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                      onPressed: () async {
                        OKuploadFile_Slip(context, docnos);
                        // downloadImage2();
                        // downloadImage(Url);
                        // Navigator.pop(
                        //     context, 'OK');
                      },
                      child: const Text(
                        'ยืนยัน',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: FontWeight_.Fonts_T,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 100,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10)),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, 'OK'),
                      child: const Text(
                        'ยกเลิก',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: FontWeight_.Fonts_T,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ]),
    );
  }

  Future<void> OKuploadFile_Slip(context, docnos) async {
    String Path_foder = 'slip';
    String dateTimeNow = DateTime.now().toString();
    String date = DateFormat('ddMMyyyy')
        .format(DateTime.parse('${dateTimeNow}'))
        .toString();
    final dateTimeNow2 = DateTime.now().toUtc().add(const Duration(hours: 7));
    final formatter2 = DateFormat('HHmmss');
    final formattedTime2 = formatter2.format(dateTimeNow2);
    String Time_ = formattedTime2.toString();

    ////////////////------------------------------------------------------>
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('user');
    var ciddoc = preferences.getString('usercid');
    var qutser_ = preferences.getString('qutser');
    ////////////////------------------------------------------------------>
    var fileName_Slip_ = 'slip_${ciddoc}_${date}_$Time_';
    setState(() {
      fileName_Slip = 'slip_${ciddoc}_${date}_$Time_.$extension_';
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
        // Navigator.pop(context, 'OK');

        OKuploadFile_Slip_Sql(context, docnos);
        // print('Image uploaded successfully');
      } else {
        // print('Image upload failed');
      }
    } catch (e) {
      // print('Error during image processing: $e');
    }
  }

  Future<Null> OKuploadFile_Slip_Sql(context, docnos) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');

    String url =
        '${MyConstant().domain_chao}/newSlip_chaoUser.php?isAdd=true&ren=$ren&docno=$docnos&fileName=$fileName_Slip';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);

      if (result.toString() == 'true') {
        // print('true');
        Insert_log.Insert_logs(
            'ประวัติชำระ', 'แก้ไขหลักฐาน $docnos ($fileName_Slip)');
        deleteFile(context);
      } else {}
    } catch (e) {
      // print(e);
    }
  }

  Future<void> deleteFile(context) async {
    String url =
        '${MyConstant().domain_chao}/File_Deleted_slipchaoUser.php?name=$Slip_history&Foder=$foder';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      if (response.statusCode == 200) {
        final responseBody = response.body;

        if (responseBody == 'File deleted successfully.') {
          // print('File deleted successfully!');
        } else {
          // print('Failed to delete file: $responseBody');
        }
      } else {
        // print('Failed to delete file. Status code: ${response.statusCode}');
      }
    } catch (e) {
      //  print('An error occurred: $e');
    }
    setState(() {
      base64_Slip = null;
      fileName_Slip = null;
      extension_ = null;
      file_ = null;
    });

    Navigator.pop(context, 'OK');
    Navigator.pop(context, 'OK');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          backgroundColor: Colors.green,
          content: Text('ทำรายการเสร็จสิ้น ...!!',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ))),
    );
  }

  ///--------------------------------------------------------->
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ประวัติชำระ ',
              style: const TextStyle(
                  fontSize: 25,
                  color: Colors.black,
                  fontFamily: FontWeight_.Fonts_T,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              (ser_tap == 1)
                  ? '${_TransReBillModels.length} รายการ'
                  : (ser_tap == 2)
                      ? '${_TransReBillModels_AwatStatus.length} รายการ'
                      : '${_TransReBillModels_CancelStatus.length} รายการ',
              style: const TextStyle(
                  fontSize: 25,
                  color: Colors.black,
                  fontFamily: FontWeight_.Fonts_T,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Color.fromARGB(255, 184, 198, 133),
      ),
      body: Container(
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    child: Container(
                      decoration: BoxDecoration(
                        color: (ser_tap == 1) ? Colors.blue : Colors.blue[300],
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)),
                        border: (ser_tap == 1)
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        maxLines: 1,
                        'ทั้งหมด',
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color:
                                (ser_tap == 1) ? Colors.black : Colors.grey[50],
                            fontFamily: FontWeight_.Fonts_T,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    onTap: () async {
                      setState(() {
                        ser_tap = 1;
                      });
                      red_Trans_bill();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            (ser_tap == 2) ? Colors.amber : Colors.amber[300],
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)),
                        border: (ser_tap == 2)
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        maxLines: 1,
                        'รอตรวจสอบ',
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color:
                                (ser_tap == 2) ? Colors.black : Colors.grey[50],
                            fontFamily: FontWeight_.Fonts_T,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    onTap: () async {
                      setState(() {
                        ser_tap = 2;
                      });
                      red_Trans_bill_StatauAwat();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    child: Container(
                      decoration: BoxDecoration(
                        color: (ser_tap == 3) ? Colors.red : Colors.red[300],
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)),
                        border: (ser_tap == 3)
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        maxLines: 1,
                        'ถูกปฏิเสธ',
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color:
                                (ser_tap == 3) ? Colors.black : Colors.grey[50],
                            fontSize: 16,
                            fontFamily: FontWeight_.Fonts_T,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    onTap: () async {
                      setState(() {
                        ser_tap = 3;
                      });
                      red_Trans_bill_CancelAwat();
                    },
                  ),
                ),
              ],
            ),
            ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
              }),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                dragStartBehavior: DragStartBehavior.start,
                child: Row(
                  children: [
                    Container(
                      width: (Responsive.isDesktop(context))
                          ? MediaQuery.of(context).size.width
                          : 900,
                      height: MediaQuery.of(context).size.height * 0.70,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 8, right: 8, bottom: 8, top: 8),
                        child: Container(
                          clipBehavior: Clip.hardEdge,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 0))
                            ],
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.white,
                          ),
                          // decoration: BoxDecoration(
                          //   boxShadow: [
                          //     BoxShadow(
                          //         color: Colors.grey.withOpacity(0.5),
                          //         spreadRadius: 2,
                          //         blurRadius: 5,
                          //         offset: const Offset(0, 5))
                          //   ],
                          //   borderRadius: BorderRadius.circular(20),
                          //   color: Colors.white,
                          // ),
                          child: SizedBox(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    // height: 50,
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 201, 196, 186),
                                      borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                          bottomLeft: Radius.circular(0),
                                          bottomRight: Radius.circular(0)),
                                    ),
                                    padding: EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              20, 2, 2, 5),
                                          child: Container(
                                            // padding: EdgeInsets.all(6.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  width: 100,
                                                  padding: EdgeInsets.all(2.0),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    10),
                                                            topRight:
                                                                Radius.circular(
                                                                    10),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    10),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    10)),
                                                    color: (ser_tap == 1)
                                                        ? Colors.blue[300]
                                                        : (ser_tap == 2)
                                                            ? Colors.orange[300]
                                                            : Colors.red[300],
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      maxLines: 1,
                                                      (ser_tap == 1)
                                                          ? 'ทั้งหมด'
                                                          : (ser_tap == 2)
                                                              ? 'รอตรวจสอบ'
                                                              : 'ถูกฏิเสธ',
                                                      textAlign:
                                                          TextAlign.start,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          fontFamily:
                                                              Font_.Fonts_T,
                                                          fontSize: 12,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  2.0),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius: const BorderRadius
                                                                .only(
                                                                topLeft:
                                                                    Radius
                                                                        .circular(
                                                                            10),
                                                                topRight: Radius
                                                                    .circular(
                                                                        0),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        10),
                                                                bottomRight:
                                                                    Radius
                                                                        .circular(
                                                                            0)),
                                                            color: Colors.white,
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                maxLines: 1,
                                                                'เงินสด ',
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: const TextStyle(
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T,
                                                                    fontSize:
                                                                        10),
                                                              ),
                                                              Icon(
                                                                Icons.paid,
                                                                color: Colors
                                                                    .grey[600],
                                                                size: 14,
                                                              ),
                                                            ],
                                                          )),
                                                      Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  2.0),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius: const BorderRadius
                                                                .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        0),
                                                                topRight: Radius
                                                                    .circular(
                                                                        0),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        0),
                                                                bottomRight:
                                                                    Radius
                                                                        .circular(
                                                                            0)),
                                                            color: Colors.white,
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                maxLines: 1,
                                                                'เงินโอน ',
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: const TextStyle(
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T,
                                                                    fontSize:
                                                                        10),
                                                              ),
                                                              Icon(
                                                                Icons
                                                                    .account_balance,
                                                                color: Colors
                                                                    .grey[600],
                                                                size: 14,
                                                              ),
                                                            ],
                                                          )),
                                                      Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  2.0),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius: const BorderRadius
                                                                .only(
                                                                topLeft:
                                                                    Radius
                                                                        .circular(
                                                                            0),
                                                                topRight: Radius
                                                                    .circular(
                                                                        10),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        0),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        10)),
                                                            color: Colors.white,
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                maxLines: 1,
                                                                'อื่นๆ ',
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: const TextStyle(
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T,
                                                                    fontSize:
                                                                        10),
                                                              ),
                                                              Icon(
                                                                Icons
                                                                    .all_inclusive,
                                                                color: Colors
                                                                    .grey[600],
                                                                size: 14,
                                                              ),
                                                            ],
                                                          ))
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                'เลขที่ใบเสร็จ',
                                                maxLines: 1,
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Text(
                                                'วันที่ทำรายการ',
                                                maxLines: 1,
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Text(
                                                'วันที่รับชำระ',
                                                maxLines: 1,
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                            // Expanded(
                                            //   flex: 1,
                                            //   child: Text(
                                            //     'เลขที่ใบวางบิล',
                                            //     textAlign: TextAlign.start,
                                            //     style: TextStyle(
                                            //       fontWeight: FontWeight.bold,

                                            //       //fontSize: 10.0
                                            //     ),
                                            //   ),
                                            // ),
                                            Expanded(
                                              flex: 1,
                                              child: Align(
                                                alignment: Alignment.bottomLeft,
                                                child: Text(
                                                  'ทำรายการ',
                                                  maxLines: 1,
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  'จำนวนเงิน',
                                                  maxLines: 1,
                                                  textAlign: TextAlign.end,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  'สถานะ',
                                                  maxLines: 1,
                                                  textAlign: TextAlign.end,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  'เหตุผล',
                                                  maxLines: 1,
                                                  textAlign: TextAlign.end,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // Expanded(
                                            //   flex: 1,
                                            //   child: Text(
                                            //     'สถานะ',
                                            //     textAlign: TextAlign.end,
                                            //     style: TextStyle(
                                            //       fontWeight: FontWeight.bold,
                                            //     ),
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                (ser_tap == 1)
                                    ? Expanded(child: BodyStatusAll_Web())
                                    : (ser_tap == 2)
                                        ? Expanded(child: BodyStatusAwat_Web())
                                        : Expanded(
                                            child: BodyStatusCancel_Web()),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget BodyStatusAll_Web() {
    return _TransReBillModels.isEmpty
        ? SizedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 50,
                  width: 50,
                  child: LoadingIndicator(
                    indicatorType: Indicator.values[30],
                    colors: _kDefaultRainbowColors,
                    strokeWidth: 4.0,
                    // pathBackgroundColor:
                    //     showPathBackground ? Colors.black45 : null,
                  ),
                ),
                StreamBuilder(
                  stream: Stream.periodic(
                      const Duration(milliseconds: 25), (i) => i),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Text('');
                    double elapsed =
                        double.parse(snapshot.data.toString()) * 0.05;
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: (elapsed > 8.00)
                          ? const Text(
                              '',
                              style: TextStyle(

                                  //fontSize: 10.0
                                  ),
                            )
                          : Text(
                              'ดาวน์โหลด : ${elapsed.toStringAsFixed(2)} s.',
                              // 'Time : ${elapsed.toStringAsFixed(2)} seconds',
                              style: const TextStyle(
                                fontFamily: Font_.Fonts_T,
                                //fontSize: 10.0
                              ),
                            ),
                    );
                  },
                ),
              ],
            ),
          )
        : ListView.builder(

            // itemExtent: 50,
            physics: const AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _TransReBillModels.length,
            itemBuilder: (BuildContext context, int index) {
              return Material(
                child: Container(
                  // color: tappedIndex_ ==
                  //         index.toString()
                  //     ? tappedIndex_Color
                  //         .tappedIndex_Colors
                  //         .withOpacity(0.5)
                  //     : null,
                  child: ListTile(
                      onTap: () async {
                        setState(() {
                          red_Trans_select(index);
                          red_Invoice(index);
                        });

                        // print('objecnort ${_TransReBillModels[index].docno}');
                        // String Url =
                        //     await '${MyConstant().domain}/files/$foder/slip/${Slip_history}';
                        Future.delayed(const Duration(milliseconds: 300),
                            () async {
                          checkshowDialog(
                              index,
                              _TransReBillModels[index].daterec,
                              _TransReBillModels[index].dtype,
                              _TransReBillModels[index].pos,
                              _TransReBillModels[index].shopno,
                              _TransReBillModels[index].docno);
                        });
                      },
                      title: Container(
                        decoration: BoxDecoration(
                          color: _TransReBillModels[index].dtype == '!Z'
                              ? Colors.red[50]!.withOpacity(0.5)
                              : null,
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.black12,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Tooltip(
                                richMessage: TextSpan(
                                  text: _TransReBillModels[index].dtype == '!Z'
                                      ? _TransReBillModels[index].doctax == ''
                                          ? '${_TransReBillModels[index].docno} (ยกเลิก)'
                                          : '${_TransReBillModels[index].doctax} (ยกเลิก)'
                                      : _TransReBillModels[index].doctax == ''
                                          ? '${_TransReBillModels[index].docno}'
                                          : '${_TransReBillModels[index].doctax}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: FontWeight_.Fonts_T,

                                    //fontSize: 10.0
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.black54,
                                ),
                                child: FutureBuilder<String>(
                                  future: red_Invoice_text(index),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      // Return a loading indicator or some placeholder text while waiting.
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                              height: 15,
                                              width: 15,
                                              child:
                                                  CircularProgressIndicator()),
                                        ],
                                      ); // Example loading indicator.
                                    } else if (snapshot.hasError) {
                                      // Handle errors if necessary.
                                      return AutoSizeText(
                                        minFontSize: 8,
                                        maxFontSize: 14,
                                        maxLines: 1,
                                        _TransReBillModels[index].dtype == '!Z'
                                            ? _TransReBillModels[index]
                                                        .doctax ==
                                                    ''
                                                ? '${_TransReBillModels[index].docno} (ยกเลิก)'
                                                : '${_TransReBillModels[index].doctax} (ยกเลิก)'
                                            : _TransReBillModels[index]
                                                        .doctax ==
                                                    ''
                                                ? '${_TransReBillModels[index].docno}'
                                                : '${_TransReBillModels[index].doctax}',
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontFamily: Font_.Fonts_T,
                                        ),
                                      );
                                    } else {
                                      // Display the result when it's available.
                                      return Row(
                                        children: [
                                          (snapshot.data.toString() ==
                                                      'CASH,OP' ||
                                                  snapshot.data.toString() ==
                                                      'CASH,AC')
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          0, 0, 4, 0),
                                                  child: Icon(
                                                    Icons.all_inclusive,
                                                    color: Colors.grey[600],
                                                    size: 15,
                                                  ),
                                                )
                                              : (snapshot.data.toString() ==
                                                          'OP' ||
                                                      snapshot.data
                                                              .toString() ==
                                                          'AC')
                                                  ? Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(0, 0, 4, 0),
                                                      child: Icon(
                                                        Icons.account_balance,
                                                        color: Colors.grey[600],
                                                        size: 15,
                                                      ),
                                                    )
                                                  : Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(0, 0, 4, 0),
                                                      child: Icon(
                                                        Icons.paid,
                                                        color: Colors.grey[600],
                                                        size: 15,
                                                      ),
                                                    ),
                                          Expanded(
                                            child: AutoSizeText(
                                              minFontSize: 8,
                                              maxFontSize: 14,
                                              maxLines: 1,
                                              _TransReBillModels[index].dtype ==
                                                      '!Z'
                                                  ? _TransReBillModels[index]
                                                              .doctax ==
                                                          ''
                                                      ? '${_TransReBillModels[index].docno} (ยกเลิก)'
                                                      : '${_TransReBillModels[index].doctax} (ยกเลิก)'
                                                  : _TransReBillModels[index]
                                                              .doctax ==
                                                          ''
                                                      ? '${_TransReBillModels[index].docno}'
                                                      : '${_TransReBillModels[index].doctax}',
                                              textAlign: TextAlign.start,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontFamily: Font_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                  },
                                ),

                                //  Row(
                                //   children: [
                                //     // (_TransReBillModels[index].type == 'AC' ||
                                //     //         _TransReBillModels[index].type ==
                                //     //             'OP')
                                //     //     ? Padding(
                                //     //         padding: const EdgeInsets.fromLTRB(
                                //     //             0, 0, 4, 0),
                                //     //         child: Icon(
                                //     //           Icons.account_balance,
                                //     //           color: Colors.grey[600],
                                //     //           size: 15,
                                //     //         ),
                                //     //       )
                                //     //     : Padding(
                                //     //         padding: const EdgeInsets.fromLTRB(
                                //     //             0, 0, 4, 0),
                                //     //         child: Icon(
                                //     //           Icons.paid,
                                //     //           color: Colors.grey[600],
                                //     //           size: 15,
                                //     //         ),
                                //     //       ),
                                //     Expanded(
                                //       child:
                                // AutoSizeText(
                                //         minFontSize: 10,
                                //         maxFontSize: 25,
                                //         maxLines: 1,
                                //         _TransReBillModels[index].dtype == '!Z'
                                //             ? _TransReBillModels[index]
                                //                         .doctax ==
                                //                     ''
                                //                 ? '${_TransReBillModels[index].docno} (ยกเลิก)'
                                //                 : '${_TransReBillModels[index].doctax} (ยกเลิก)'
                                //             : _TransReBillModels[index]
                                //                         .doctax ==
                                //                     ''
                                //                 ? '${_TransReBillModels[index].docno}'
                                //                 : '${_TransReBillModels[index].doctax}',
                                //         textAlign: TextAlign.start,
                                //         overflow: TextOverflow.ellipsis,
                                //         style: const TextStyle(),
                                //       ),
                                //     ),
                                //   ],
                                // ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Tooltip(
                                  richMessage: const TextSpan(
                                    text: '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,

                                      //fontSize: 10.0
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.grey[200],
                                  ),
                                  child: AutoSizeText(
                                    minFontSize: 8,
                                    maxFontSize: 14,
                                    maxLines: 1,
                                    '${DateFormat('dd-MM').format(DateTime.parse('${_TransReBillModels[index].daterec}'))}-${int.parse('${DateFormat('yyyy').format(DateTime.parse('${_TransReBillModels[index].daterec}'))}') + 543}',
                                    //  '${_TransReBillModels[index].daterec}',
                                    //'${DateFormat('dd-MM').format(DateTime.parse('${_TransReBillModels[index].daterec} '))}-${DateTime.parse('${_TransReBillModels[index].daterec} ').year + 543}',
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: Font_.Fonts_T,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Tooltip(
                                richMessage: const TextSpan(
                                  text: '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,

                                    //fontSize: 10.0
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.grey[200],
                                ),
                                child: AutoSizeText(
                                  minFontSize: 8,
                                  maxFontSize: 14,
                                  maxLines: 1,
                                  '${DateFormat('dd-MM').format(DateTime.parse('${_TransReBillModels[index].pdate}'))}-${int.parse('${DateFormat('yyyy').format(DateTime.parse('${_TransReBillModels[index].pdate}'))}') + 543}',
                                  // '${_TransReBillModels[index].pdate}',

                                  /// '${DateFormat('dd-MM').format(DateTime.parse('${_TransReBillModels[index].pdate} 00:00:00'))}-${DateTime.parse('${_TransReBillModels[index].pdate} 00:00:00').year + 543}',
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: Font_.Fonts_T,
                                  ),
                                ),
                              ),
                            ),
                            // Expanded(
                            //   flex: 1,
                            //   child: Padding(
                            //     padding: const EdgeInsets.all(8.0),
                            //     child: Tooltip(
                            //       richMessage: TextSpan(
                            //         text: '${_TransReBillModels[index].inv}',
                            //         style: const TextStyle(
                            //           fontWeight: FontWeight.bold,

                            //           //fontSize: 10.0
                            //         ),
                            //       ),
                            //       decoration: BoxDecoration(
                            //         borderRadius: BorderRadius.circular(5),
                            //         color: Colors.grey[200],
                            //       ),
                            //       child: AutoSizeText(
                            //         minFontSize: 10,
                            //         maxFontSize: 25,
                            //         maxLines: 1,
                            //         _TransReBillModels[index].inv == ''
                            //             ? '-'
                            //             : '${_TransReBillModels[index].inv}',
                            //         textAlign: TextAlign.start,
                            //         overflow: TextOverflow.ellipsis,
                            //         style: const TextStyle(),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            // Expanded(
                            //   flex: 1,
                            //   child: Tooltip(
                            //     richMessage: const TextSpan(
                            //       text: '',
                            //       style: TextStyle(
                            //         fontWeight: FontWeight.bold,

                            //         //fontSize: 10.0
                            //       ),
                            //     ),
                            //     decoration: BoxDecoration(
                            //       borderRadius: BorderRadius.circular(5),
                            //       color: Colors.grey[200],
                            //     ),
                            //     child: AutoSizeText(
                            //       minFontSize: 10,
                            //       maxFontSize: 25,
                            //       maxLines: 1,
                            //       '${_TransReBillModels[index].date}',
                            //       //'${DateFormat('dd-MM').format(DateTime.parse('${_TransReBillModels[index].date} 00:00:00'))}-${DateTime.parse('${_TransReBillModels[index].date} 00:00:00').year + 543}',
                            //       textAlign: TextAlign.start,
                            //       style: const TextStyle(),
                            //     ),
                            //   ),
                            // ),
                            Expanded(
                              flex: 1,
                              child: Tooltip(
                                richMessage: const TextSpan(
                                  text: '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,

                                    //fontSize: 10.0
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.grey[200],
                                ),
                                child: AutoSizeText(
                                  minFontSize: 8,
                                  maxFontSize: 14,
                                  maxLines: 1,
                                  _TransReBillModels[index]
                                              .shopno
                                              .toString()
                                              .toUpperCase() ==
                                          '1'
                                      ? 'ด้วยตนเองผ่านเว็ป'
                                      : 'ผ่านเจ้าหน้า',
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: Font_.Fonts_T,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Tooltip(
                                richMessage: const TextSpan(
                                  text: '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,

                                    //fontSize: 10.0
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.grey[200],
                                ),
                                child: AutoSizeText(
                                  minFontSize: 8,
                                  maxFontSize: 14,
                                  maxLines: 1,
                                  _TransReBillModels[index].total_dis == null
                                      ? '${nFormat.format(double.parse(_TransReBillModels[index].total_bill!))}'
                                      : '${nFormat.format(double.parse(_TransReBillModels[index].total_dis!))}',
                                  textAlign: TextAlign.end,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: Font_.Fonts_T,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Tooltip(
                                richMessage: const TextSpan(
                                  text: '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,

                                    //fontSize: 10.0
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.grey[200],
                                ),
                                child: AutoSizeText(
                                  minFontSize: 8,
                                  maxFontSize: 14,
                                  maxLines: 1,
                                  (_TransReBillModels[index]
                                                  .pos
                                                  .toString()
                                                  .trim() ==
                                              '1' &&
                                          _TransReBillModels[index]
                                                  .shopno
                                                  .toString()
                                                  .trim() ==
                                              '1' &&
                                          _TransReBillModels[index].dtype !=
                                              '!Z')
                                      ? 'รอตรวจสอบ'
                                      : (_TransReBillModels[index]
                                                      .pos
                                                      .toString()
                                                      .trim() ==
                                                  '0' &&
                                              _TransReBillModels[index].dtype ==
                                                  '!Z')
                                          ? 'ถูกปฏิเสธ'
                                          : 'ชำระสำเร็จ',
                                  textAlign: TextAlign.end,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontFamily: Font_.Fonts_T,
                                      color: (_TransReBillModels[index]
                                                      .pos
                                                      .toString()
                                                      .trim() ==
                                                  '1' &&
                                              _TransReBillModels[index]
                                                      .shopno
                                                      .toString()
                                                      .trim() ==
                                                  '1' &&
                                              _TransReBillModels[index].dtype !=
                                                  '!Z')
                                          ? Colors.orange
                                          : (_TransReBillModels[index]
                                                          .pos
                                                          .toString()
                                                          .trim() ==
                                                      '0' &&
                                                  _TransReBillModels[index]
                                                          .dtype ==
                                                      '!Z')
                                              ? Colors.red
                                              : Colors.green),
                                ),
                              ),
                            ),
                            Expanded(
                                flex: 1,
                                child: StreamBuilder(
                                    stream: Stream.periodic(
                                        const Duration(seconds: 0)),
                                    builder: (context, snapshot) {
                                      return Align(
                                        alignment: Alignment.centerRight,
                                        child: (_TransReBillModels[index]
                                                    .dtype !=
                                                '!Z')
                                            ? Text('')
                                            : PopupMenuButton(
                                                child: Icon(
                                                  Icons.info,
                                                  color: Colors.grey,
                                                  size: 25,
                                                ),
                                                itemBuilder:
                                                    (BuildContext context) => [
                                                          PopupMenuItem(
                                                            child: Container(
                                                                child: Text(
                                                              '${_TransReBillModels[index].remark}',
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              // overflow:
                                                              //     TextOverflow
                                                              //         .ellipsis,
                                                              style: TextStyle(
                                                                  fontFamily: Font_
                                                                      .Fonts_T,
                                                                  color: Colors
                                                                      .black),
                                                            )),
                                                          ),
                                                        ]),
                                      );
                                    })),
                            // Expanded(
                            //   flex: 1,
                            //   child: Tooltip(
                            //     richMessage: const TextSpan(
                            //       text: '',
                            //       style: TextStyle(
                            //         fontWeight: FontWeight.bold,

                            //         //fontSize: 10.0
                            //       ),
                            //     ),
                            //     decoration: BoxDecoration(
                            //       borderRadius: BorderRadius.circular(5),
                            //       color: Colors.grey[200],
                            //     ),
                            //     child: FutureBuilder<String>(
                            //       future: red_Invoice_text(index),
                            //       builder: (context, snapshot) {
                            //         if (snapshot.connectionState ==
                            //             ConnectionState.waiting) {
                            //           // Return a loading indicator or some placeholder text while waiting.
                            //           return Row(
                            //             mainAxisAlignment:
                            //                 MainAxisAlignment.end,
                            //             children: [
                            //               SizedBox(
                            //                   height: 15,
                            //                   width: 15,
                            //                   child:
                            //                       CircularProgressIndicator()),
                            //             ],
                            //           ); // Example loading indicator.
                            //         } else if (snapshot.hasError) {
                            //           // Handle errors if necessary.
                            //           return Text("");
                            //         } else {
                            //           // Display the result when it's available.
                            //           return Text(
                            //             '${snapshot.data}' ??
                            //                 '', // Use ?? '' to handle null values
                            //             textAlign: TextAlign.end,
                            //             style: const TextStyle(),
                            //           );
                            //         }
                            //       },
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      )),
                ),
              );
            });
  }

  /////////--------------------------------------------------->
  Widget BodyStatusAwat_Web() {
    return _TransReBillModels_AwatStatus.isEmpty
        ? SizedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 50,
                  width: 50,
                  child: LoadingIndicator(
                    indicatorType: Indicator.values[30],
                    colors: _kDefaultRainbowColors,
                    strokeWidth: 4.0,
                    // pathBackgroundColor:
                    //     showPathBackground ? Colors.black45 : null,
                  ),
                ),
                StreamBuilder(
                  stream: Stream.periodic(
                      const Duration(milliseconds: 25), (i) => i),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Text('');
                    double elapsed =
                        double.parse(snapshot.data.toString()) * 0.05;
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: (elapsed > 8.00)
                          ? const Text(
                              '',
                              style: TextStyle(

                                  //fontSize: 10.0
                                  ),
                            )
                          : Text(
                              'ดาวน์โหลด : ${elapsed.toStringAsFixed(2)} s.',
                              // 'Time : ${elapsed.toStringAsFixed(2)} seconds',
                              style: const TextStyle(
                                fontFamily: Font_.Fonts_T,
                                //fontSize: 10.0
                              ),
                            ),
                    );
                  },
                ),
              ],
            ),
          )
        : ListView.builder(

            // itemExtent: 50,
            physics: const AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _TransReBillModels_AwatStatus.length,
            itemBuilder: (BuildContext context, int index) {
              return Material(
                child: Container(
                  // color: tappedIndex_ ==
                  //         index.toString()
                  //     ? tappedIndex_Color
                  //         .tappedIndex_Colors
                  //         .withOpacity(0.5)
                  //     : null,
                  child: ListTile(
                      onTap: () async {
                        setState(() {
                          red_Trans_select(index);
                          red_Invoice(index);
                        });

                        // print(
                        //     'objecnort ${_TransReBillModels_AwatStatus[index].docno}');
                        // String Url =
                        //     await '${MyConstant().domain}/files/$foder/slip/${Slip_history}';
                        Future.delayed(const Duration(milliseconds: 300),
                            () async {
                          checkshowDialog(
                              index,
                              _TransReBillModels_AwatStatus[index].daterec,
                              _TransReBillModels_AwatStatus[index].dtype,
                              _TransReBillModels_AwatStatus[index].pos,
                              _TransReBillModels_AwatStatus[index].shopno,
                              _TransReBillModels_AwatStatus[index].docno);
                        });
                      },
                      title: Container(
                        decoration: BoxDecoration(
                          color:
                              _TransReBillModels_AwatStatus[index].dtype == '!Z'
                                  ? Colors.red[50]!.withOpacity(0.5)
                                  : null,
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.black12,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Tooltip(
                                richMessage: TextSpan(
                                  text: _TransReBillModels_AwatStatus[index]
                                              .dtype ==
                                          '!Z'
                                      ? _TransReBillModels_AwatStatus[index]
                                                  .doctax ==
                                              ''
                                          ? '${_TransReBillModels_AwatStatus[index].docno} (ยกเลิก)'
                                          : '${_TransReBillModels_AwatStatus[index].doctax} (ยกเลิก)'
                                      : _TransReBillModels_AwatStatus[index]
                                                  .doctax ==
                                              ''
                                          ? '${_TransReBillModels_AwatStatus[index].docno}'
                                          : '${_TransReBillModels_AwatStatus[index].doctax}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: Font_.Fonts_T,
                                    //fontSize: 10.0
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.black54,
                                ),
                                child: FutureBuilder<String>(
                                  future: red_Invoice_text(index),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      // Return a loading indicator or some placeholder text while waiting.
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                              height: 15,
                                              width: 15,
                                              child:
                                                  CircularProgressIndicator()),
                                        ],
                                      ); // Example loading indicator.
                                    } else if (snapshot.hasError) {
                                      // Handle errors if necessary.
                                      return AutoSizeText(
                                        minFontSize: 8,
                                        maxFontSize: 14,
                                        maxLines: 1,
                                        _TransReBillModels_AwatStatus[index]
                                                    .dtype ==
                                                '!Z'
                                            ? _TransReBillModels_AwatStatus[
                                                            index]
                                                        .doctax ==
                                                    ''
                                                ? '${_TransReBillModels_AwatStatus[index].docno} (ยกเลิก)'
                                                : '${_TransReBillModels_AwatStatus[index].doctax} (ยกเลิก)'
                                            : _TransReBillModels_AwatStatus[
                                                            index]
                                                        .doctax ==
                                                    ''
                                                ? '${_TransReBillModels_AwatStatus[index].docno}'
                                                : '${_TransReBillModels_AwatStatus[index].doctax}',
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontFamily: Font_.Fonts_T,
                                        ),
                                      );
                                    } else {
                                      // Display the result when it's available.
                                      return Row(
                                        children: [
                                          (snapshot.data.toString() ==
                                                      'CASH,OP' ||
                                                  snapshot.data.toString() ==
                                                      'CASH,AC')
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          0, 0, 4, 0),
                                                  child: Icon(
                                                    Icons.all_inclusive,
                                                    color: Colors.grey[600],
                                                    size: 15,
                                                  ),
                                                )
                                              : (snapshot.data.toString() ==
                                                          'OP' ||
                                                      snapshot.data
                                                              .toString() ==
                                                          'AC')
                                                  ? Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(0, 0, 4, 0),
                                                      child: Icon(
                                                        Icons.account_balance,
                                                        color: Colors.grey[600],
                                                        size: 15,
                                                      ),
                                                    )
                                                  : Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(0, 0, 4, 0),
                                                      child: Icon(
                                                        Icons.paid,
                                                        color: Colors.grey[600],
                                                        size: 15,
                                                      ),
                                                    ),
                                          Expanded(
                                            child: AutoSizeText(
                                              minFontSize: 8,
                                              maxFontSize: 14,
                                              maxLines: 1,
                                              _TransReBillModels_AwatStatus[
                                                              index]
                                                          .dtype ==
                                                      '!Z'
                                                  ? _TransReBillModels_AwatStatus[
                                                                  index]
                                                              .doctax ==
                                                          ''
                                                      ? '${_TransReBillModels_AwatStatus[index].docno} (ยกเลิก)'
                                                      : '${_TransReBillModels_AwatStatus[index].doctax} (ยกเลิก)'
                                                  : _TransReBillModels_AwatStatus[
                                                                  index]
                                                              .doctax ==
                                                          ''
                                                      ? '${_TransReBillModels_AwatStatus[index].docno}'
                                                      : '${_TransReBillModels_AwatStatus[index].doctax}',
                                              textAlign: TextAlign.start,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontFamily: Font_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                  },
                                ),

                                //  Row(
                                //   children: [
                                //     // (_TransReBillModels[index].type == 'AC' ||
                                //     //         _TransReBillModels[index].type ==
                                //     //             'OP')
                                //     //     ? Padding(
                                //     //         padding: const EdgeInsets.fromLTRB(
                                //     //             0, 0, 4, 0),
                                //     //         child: Icon(
                                //     //           Icons.account_balance,
                                //     //           color: Colors.grey[600],
                                //     //           size: 15,
                                //     //         ),
                                //     //       )
                                //     //     : Padding(
                                //     //         padding: const EdgeInsets.fromLTRB(
                                //     //             0, 0, 4, 0),
                                //     //         child: Icon(
                                //     //           Icons.paid,
                                //     //           color: Colors.grey[600],
                                //     //           size: 15,
                                //     //         ),
                                //     //       ),
                                //     Expanded(
                                //       child:
                                // AutoSizeText(
                                //         minFontSize: 10,
                                //         maxFontSize: 25,
                                //         maxLines: 1,
                                //         _TransReBillModels[index].dtype == '!Z'
                                //             ? _TransReBillModels[index]
                                //                         .doctax ==
                                //                     ''
                                //                 ? '${_TransReBillModels[index].docno} (ยกเลิก)'
                                //                 : '${_TransReBillModels[index].doctax} (ยกเลิก)'
                                //             : _TransReBillModels[index]
                                //                         .doctax ==
                                //                     ''
                                //                 ? '${_TransReBillModels[index].docno}'
                                //                 : '${_TransReBillModels[index].doctax}',
                                //         textAlign: TextAlign.start,
                                //         overflow: TextOverflow.ellipsis,
                                //         style: const TextStyle(),
                                //       ),
                                //     ),
                                //   ],
                                // ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Tooltip(
                                  richMessage: const TextSpan(
                                    text: '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,

                                      //fontSize: 10.0
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.grey[200],
                                  ),
                                  child: AutoSizeText(
                                    minFontSize: 8,
                                    maxFontSize: 14,
                                    maxLines: 1,
                                    '${DateFormat('dd-MM').format(DateTime.parse('${_TransReBillModels_AwatStatus[index].daterec}'))}-${int.parse('${DateFormat('yyyy').format(DateTime.parse('${_TransReBillModels_AwatStatus[index].daterec}'))}') + 543}',
                                    //  '${_TransReBillModels[index].daterec}',
                                    //'${DateFormat('dd-MM').format(DateTime.parse('${_TransReBillModels[index].daterec} '))}-${DateTime.parse('${_TransReBillModels[index].daterec} ').year + 543}',
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: Font_.Fonts_T,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Tooltip(
                                richMessage: const TextSpan(
                                  text: '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,

                                    //fontSize: 10.0
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.grey[200],
                                ),
                                child: AutoSizeText(
                                  minFontSize: 8,
                                  maxFontSize: 14,
                                  maxLines: 1,
                                  '${DateFormat('dd-MM').format(DateTime.parse('${_TransReBillModels_AwatStatus[index].pdate}'))}-${int.parse('${DateFormat('yyyy').format(DateTime.parse('${_TransReBillModels_AwatStatus[index].pdate}'))}') + 543}',
                                  // '${_TransReBillModels[index].pdate}',

                                  /// '${DateFormat('dd-MM').format(DateTime.parse('${_TransReBillModels[index].pdate} 00:00:00'))}-${DateTime.parse('${_TransReBillModels[index].pdate} 00:00:00').year + 543}',
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: Font_.Fonts_T,
                                  ),
                                ),
                              ),
                            ),
                            // Expanded(
                            //   flex: 1,
                            //   child: Padding(
                            //     padding: const EdgeInsets.all(8.0),
                            //     child: Tooltip(
                            //       richMessage: TextSpan(
                            //         text: '${_TransReBillModels[index].inv}',
                            //         style: const TextStyle(
                            //           fontWeight: FontWeight.bold,

                            //           //fontSize: 10.0
                            //         ),
                            //       ),
                            //       decoration: BoxDecoration(
                            //         borderRadius: BorderRadius.circular(5),
                            //         color: Colors.grey[200],
                            //       ),
                            //       child: AutoSizeText(
                            //         minFontSize: 10,
                            //         maxFontSize: 25,
                            //         maxLines: 1,
                            //         _TransReBillModels[index].inv == ''
                            //             ? '-'
                            //             : '${_TransReBillModels[index].inv}',
                            //         textAlign: TextAlign.start,
                            //         overflow: TextOverflow.ellipsis,
                            //         style: const TextStyle(),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            // Expanded(
                            //   flex: 1,
                            //   child: Tooltip(
                            //     richMessage: const TextSpan(
                            //       text: '',
                            //       style: TextStyle(
                            //         fontWeight: FontWeight.bold,

                            //         //fontSize: 10.0
                            //       ),
                            //     ),
                            //     decoration: BoxDecoration(
                            //       borderRadius: BorderRadius.circular(5),
                            //       color: Colors.grey[200],
                            //     ),
                            //     child: AutoSizeText(
                            //       minFontSize: 10,
                            //       maxFontSize: 25,
                            //       maxLines: 1,
                            //       '${_TransReBillModels[index].date}',
                            //       //'${DateFormat('dd-MM').format(DateTime.parse('${_TransReBillModels[index].date} 00:00:00'))}-${DateTime.parse('${_TransReBillModels[index].date} 00:00:00').year + 543}',
                            //       textAlign: TextAlign.start,
                            //       style: const TextStyle(),
                            //     ),
                            //   ),
                            // ),
                            Expanded(
                              flex: 1,
                              child: Tooltip(
                                richMessage: const TextSpan(
                                  text: '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,

                                    //fontSize: 10.0
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.grey[200],
                                ),
                                child: AutoSizeText(
                                  minFontSize: 8,
                                  maxFontSize: 14,
                                  maxLines: 1,
                                  _TransReBillModels[index]
                                              .shopno
                                              .toString()
                                              .toUpperCase() ==
                                          '1'
                                      ? 'ด้วยตนเองผ่านเว็ป'
                                      : 'ผ่านเจ้าหน้า',
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: Font_.Fonts_T,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Tooltip(
                                richMessage: const TextSpan(
                                  text: '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,

                                    //fontSize: 10.0
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.grey[200],
                                ),
                                child: AutoSizeText(
                                  minFontSize: 8,
                                  maxFontSize: 14,
                                  maxLines: 1,
                                  _TransReBillModels_AwatStatus[index]
                                              .total_dis ==
                                          null
                                      ? '${nFormat.format(double.parse(_TransReBillModels_AwatStatus[index].total_bill!))}'
                                      : '${nFormat.format(double.parse(_TransReBillModels_AwatStatus[index].total_dis!))}',
                                  textAlign: TextAlign.end,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: Font_.Fonts_T,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Tooltip(
                                richMessage: const TextSpan(
                                  text: '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,

                                    //fontSize: 10.0
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.grey[200],
                                ),
                                child: AutoSizeText(
                                  minFontSize: 8,
                                  maxFontSize: 14,
                                  maxLines: 1,
                                  (_TransReBillModels_AwatStatus[index]
                                                  .pos
                                                  .toString()
                                                  .trim() ==
                                              '1' &&
                                          _TransReBillModels_AwatStatus[index]
                                                  .shopno
                                                  .toString()
                                                  .trim() ==
                                              '1' &&
                                          _TransReBillModels_AwatStatus[
                                                      index]
                                                  .dtype !=
                                              '!Z')
                                      ? 'รอตรวจสอบ'
                                      : (_TransReBillModels_AwatStatus[
                                                          index]
                                                      .pos
                                                      .toString()
                                                      .trim() ==
                                                  '0' &&
                                              _TransReBillModels_AwatStatus[
                                                          index]
                                                      .shopno
                                                      .toString()
                                                      .trim() ==
                                                  '1' &&
                                              _TransReBillModels_AwatStatus[
                                                          index]
                                                      .dtype ==
                                                  '!Z')
                                          ? 'ถูกปฏิเสธ'
                                          : 'ชำระสำเร็จ',
                                  textAlign: TextAlign.end,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontFamily: Font_.Fonts_T,
                                      color: (_TransReBillModels_AwatStatus[
                                                          index]
                                                      .pos
                                                      .toString()
                                                      .trim() ==
                                                  '1' &&
                                              _TransReBillModels_AwatStatus[
                                                          index]
                                                      .shopno
                                                      .toString()
                                                      .trim() ==
                                                  '1')
                                          ? Colors.orange
                                          : (_TransReBillModels_AwatStatus[
                                                              index]
                                                          .pos
                                                          .toString()
                                                          .trim() ==
                                                      '0' &&
                                                  _TransReBillModels_AwatStatus[
                                                              index]
                                                          .shopno
                                                          .toString()
                                                          .trim() ==
                                                      '1' &&
                                                  _TransReBillModels_AwatStatus[
                                                              index]
                                                          .dtype ==
                                                      '!Z')
                                              ? Colors.red
                                              : Colors.green),
                                ),
                              ),
                            ),
                            Expanded(
                                flex: 1,
                                child: StreamBuilder(
                                    stream: Stream.periodic(
                                        const Duration(seconds: 0)),
                                    builder: (context, snapshot) {
                                      return Align(
                                        alignment: Alignment.centerRight,
                                        child: (_TransReBillModels_AwatStatus[
                                                        index]
                                                    .dtype !=
                                                '!Z')
                                            ? Text('')
                                            : PopupMenuButton(
                                                child: Icon(
                                                  Icons.info,
                                                  color: Colors.red,
                                                  size: 20,
                                                ),
                                                itemBuilder:
                                                    (BuildContext context) => [
                                                          PopupMenuItem(
                                                            child: Container(
                                                                child: Text(
                                                              '${_TransReBillModels_AwatStatus[index].remark}',
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              // overflow:
                                                              //     TextOverflow
                                                              //         .ellipsis,
                                                              style: TextStyle(
                                                                  fontFamily: Font_
                                                                      .Fonts_T,
                                                                  color: Colors
                                                                      .black),
                                                            )),
                                                          ),
                                                        ]),
                                      );
                                    })),

                            // Expanded(
                            //   flex: 1,
                            //   child: Tooltip(
                            //     richMessage: const TextSpan(
                            //       text: '',
                            //       style: TextStyle(
                            //         fontWeight: FontWeight.bold,

                            //         //fontSize: 10.0
                            //       ),
                            //     ),
                            //     decoration: BoxDecoration(
                            //       borderRadius: BorderRadius.circular(5),
                            //       color: Colors.grey[200],
                            //     ),
                            //     child: FutureBuilder<String>(
                            //       future: red_Invoice_text(index),
                            //       builder: (context, snapshot) {
                            //         if (snapshot.connectionState ==
                            //             ConnectionState.waiting) {
                            //           // Return a loading indicator or some placeholder text while waiting.
                            //           return Row(
                            //             mainAxisAlignment:
                            //                 MainAxisAlignment.end,
                            //             children: [
                            //               SizedBox(
                            //                   height: 15,
                            //                   width: 15,
                            //                   child:
                            //                       CircularProgressIndicator()),
                            //             ],
                            //           ); // Example loading indicator.
                            //         } else if (snapshot.hasError) {
                            //           // Handle errors if necessary.
                            //           return Text("");
                            //         } else {
                            //           // Display the result when it's available.
                            //           return Text(
                            //             '${snapshot.data}' ??
                            //                 '', // Use ?? '' to handle null values
                            //             textAlign: TextAlign.end,
                            //             style: const TextStyle(),
                            //           );
                            //         }
                            //       },
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      )),
                ),
              );
            });
  }

  /////////--------------------------------------------------->
  Widget BodyStatusCancel_Web() {
    return _TransReBillModels_CancelStatus.isEmpty
        ? SizedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 50,
                  width: 50,
                  child: LoadingIndicator(
                    indicatorType: Indicator.values[30],
                    colors: _kDefaultRainbowColors,
                    strokeWidth: 4.0,
                    // pathBackgroundColor:
                    //     showPathBackground ? Colors.black45 : null,
                  ),
                ),
                StreamBuilder(
                  stream: Stream.periodic(
                      const Duration(milliseconds: 25), (i) => i),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Text('');
                    double elapsed =
                        double.parse(snapshot.data.toString()) * 0.05;
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: (elapsed > 8.00)
                          ? const Text(
                              '',
                              style: TextStyle(

                                  //fontSize: 10.0
                                  ),
                            )
                          : Text(
                              'ดาวน์โหลด : ${elapsed.toStringAsFixed(2)} s.',
                              // 'Time : ${elapsed.toStringAsFixed(2)} seconds',
                              style: const TextStyle(
                                fontFamily: Font_.Fonts_T,
                                //fontSize: 10.0
                              ),
                            ),
                    );
                  },
                ),
              ],
            ),
          )
        : ListView.builder(

            // itemExtent: 50,
            physics: const AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _TransReBillModels_CancelStatus.length,
            itemBuilder: (BuildContext context, int index) {
              return Material(
                child: Container(
                  // color: tappedIndex_ ==
                  //         index.toString()
                  //     ? tappedIndex_Color
                  //         .tappedIndex_Colors
                  //         .withOpacity(0.5)
                  //     : null,
                  child: ListTile(
                      onTap: () async {
                        setState(() {
                          red_Trans_select(index);
                          red_Invoice(index);
                        });

                        // print(
                        //     'objecnort ${_TransReBillModels_CancelStatus[index].docno}');
                        // String Url =
                        //     await '${MyConstant().domain}/files/$foder/slip/${Slip_history}';
                        Future.delayed(const Duration(milliseconds: 300),
                            () async {
                          checkshowDialog(
                              index,
                              _TransReBillModels_CancelStatus[index].daterec,
                              _TransReBillModels_CancelStatus[index].dtype,
                              _TransReBillModels_CancelStatus[index].pos,
                              _TransReBillModels_CancelStatus[index].shopno,
                              _TransReBillModels_CancelStatus[index].docno);
                        });
                      },
                      title: Container(
                        decoration: BoxDecoration(
                          color: _TransReBillModels_CancelStatus[index].dtype ==
                                  '!Z'
                              ? Colors.red[50]!.withOpacity(0.5)
                              : null,
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.black12,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Tooltip(
                                richMessage: TextSpan(
                                  text: _TransReBillModels_CancelStatus[index]
                                              .dtype ==
                                          '!Z'
                                      ? _TransReBillModels_CancelStatus[index]
                                                  .doctax ==
                                              ''
                                          ? '${_TransReBillModels_CancelStatus[index].docno} (ยกเลิก)'
                                          : '${_TransReBillModels_CancelStatus[index].doctax} (ยกเลิก)'
                                      : _TransReBillModels_CancelStatus[index]
                                                  .doctax ==
                                              ''
                                          ? '${_TransReBillModels_CancelStatus[index].docno}'
                                          : '${_TransReBillModels_CancelStatus[index].doctax}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: Font_.Fonts_T,

                                    //fontSize: 10.0
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.black54,
                                ),
                                child: FutureBuilder<String>(
                                  future: red_Invoice_text(index),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      // Return a loading indicator or some placeholder text while waiting.
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                              height: 15,
                                              width: 15,
                                              child:
                                                  CircularProgressIndicator()),
                                        ],
                                      ); // Example loading indicator.
                                    } else if (snapshot.hasError) {
                                      // Handle errors if necessary.
                                      return AutoSizeText(
                                        minFontSize: 8,
                                        maxFontSize: 14,
                                        maxLines: 1,
                                        _TransReBillModels_CancelStatus[index]
                                                    .dtype ==
                                                '!Z'
                                            ? _TransReBillModels_CancelStatus[
                                                            index]
                                                        .doctax ==
                                                    ''
                                                ? '${_TransReBillModels_CancelStatus[index].docno} (ยกเลิก)'
                                                : '${_TransReBillModels_CancelStatus[index].doctax} (ยกเลิก)'
                                            : _TransReBillModels_CancelStatus[
                                                            index]
                                                        .doctax ==
                                                    ''
                                                ? '${_TransReBillModels_CancelStatus[index].docno}'
                                                : '${_TransReBillModels_CancelStatus[index].doctax}',
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontFamily: Font_.Fonts_T,
                                        ),
                                      );
                                    } else {
                                      // Display the result when it's available.
                                      return Row(
                                        children: [
                                          (snapshot.data.toString() ==
                                                      'CASH,OP' ||
                                                  snapshot.data.toString() ==
                                                      'CASH,AC')
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          0, 0, 4, 0),
                                                  child: Icon(
                                                    Icons.all_inclusive,
                                                    color: Colors.grey[600],
                                                    size: 15,
                                                  ),
                                                )
                                              : (snapshot.data.toString() ==
                                                          'OP' ||
                                                      snapshot.data
                                                              .toString() ==
                                                          'AC')
                                                  ? Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(0, 0, 4, 0),
                                                      child: Icon(
                                                        Icons.account_balance,
                                                        color: Colors.grey[600],
                                                        size: 15,
                                                      ),
                                                    )
                                                  : Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(0, 0, 4, 0),
                                                      child: Icon(
                                                        Icons.paid,
                                                        color: Colors.grey[600],
                                                        size: 15,
                                                      ),
                                                    ),
                                          Expanded(
                                            child: AutoSizeText(
                                              minFontSize: 8,
                                              maxFontSize: 14,
                                              maxLines: 1,
                                              _TransReBillModels_CancelStatus[
                                                              index]
                                                          .dtype ==
                                                      '!Z'
                                                  ? _TransReBillModels_CancelStatus[
                                                                  index]
                                                              .doctax ==
                                                          ''
                                                      ? '${_TransReBillModels_CancelStatus[index].docno} (ยกเลิก)'
                                                      : '${_TransReBillModels_CancelStatus[index].doctax} (ยกเลิก)'
                                                  : _TransReBillModels_CancelStatus[
                                                                  index]
                                                              .doctax ==
                                                          ''
                                                      ? '${_TransReBillModels_CancelStatus[index].docno}'
                                                      : '${_TransReBillModels_CancelStatus[index].doctax}',
                                              textAlign: TextAlign.start,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontFamily: Font_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                  },
                                ),

                                //  Row(
                                //   children: [
                                //     // (_TransReBillModels[index].type == 'AC' ||
                                //     //         _TransReBillModels[index].type ==
                                //     //             'OP')
                                //     //     ? Padding(
                                //     //         padding: const EdgeInsets.fromLTRB(
                                //     //             0, 0, 4, 0),
                                //     //         child: Icon(
                                //     //           Icons.account_balance,
                                //     //           color: Colors.grey[600],
                                //     //           size: 15,
                                //     //         ),
                                //     //       )
                                //     //     : Padding(
                                //     //         padding: const EdgeInsets.fromLTRB(
                                //     //             0, 0, 4, 0),
                                //     //         child: Icon(
                                //     //           Icons.paid,
                                //     //           color: Colors.grey[600],
                                //     //           size: 15,
                                //     //         ),
                                //     //       ),
                                //     Expanded(
                                //       child:
                                // AutoSizeText(
                                //         minFontSize: 10,
                                //         maxFontSize: 25,
                                //         maxLines: 1,
                                //         _TransReBillModels[index].dtype == '!Z'
                                //             ? _TransReBillModels[index]
                                //                         .doctax ==
                                //                     ''
                                //                 ? '${_TransReBillModels[index].docno} (ยกเลิก)'
                                //                 : '${_TransReBillModels[index].doctax} (ยกเลิก)'
                                //             : _TransReBillModels[index]
                                //                         .doctax ==
                                //                     ''
                                //                 ? '${_TransReBillModels[index].docno}'
                                //                 : '${_TransReBillModels[index].doctax}',
                                //         textAlign: TextAlign.start,
                                //         overflow: TextOverflow.ellipsis,
                                //         style: const TextStyle(),
                                //       ),
                                //     ),
                                //   ],
                                // ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Tooltip(
                                  richMessage: const TextSpan(
                                    text: '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,

                                      //fontSize: 10.0
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.grey[200],
                                  ),
                                  child: AutoSizeText(
                                    minFontSize: 8,
                                    maxFontSize: 14,
                                    maxLines: 1,
                                    '${DateFormat('dd-MM').format(DateTime.parse('${_TransReBillModels_CancelStatus[index].daterec}'))}-${int.parse('${DateFormat('yyyy').format(DateTime.parse('${_TransReBillModels_CancelStatus[index].daterec}'))}') + 543}',
                                    //  '${_TransReBillModels[index].daterec}',
                                    //'${DateFormat('dd-MM').format(DateTime.parse('${_TransReBillModels[index].daterec} '))}-${DateTime.parse('${_TransReBillModels[index].daterec} ').year + 543}',
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: Font_.Fonts_T,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Tooltip(
                                richMessage: const TextSpan(
                                  text: '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,

                                    //fontSize: 10.0
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.grey[200],
                                ),
                                child: AutoSizeText(
                                  minFontSize: 8,
                                  maxFontSize: 14,
                                  maxLines: 1,
                                  '${DateFormat('dd-MM').format(DateTime.parse('${_TransReBillModels_CancelStatus[index].pdate}'))}-${int.parse('${DateFormat('yyyy').format(DateTime.parse('${_TransReBillModels_CancelStatus[index].pdate}'))}') + 543}',
                                  // '${_TransReBillModels[index].pdate}',

                                  /// '${DateFormat('dd-MM').format(DateTime.parse('${_TransReBillModels[index].pdate} 00:00:00'))}-${DateTime.parse('${_TransReBillModels[index].pdate} 00:00:00').year + 543}',
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: Font_.Fonts_T,
                                  ),
                                ),
                              ),
                            ),
                            // Expanded(
                            //   flex: 1,
                            //   child: Padding(
                            //     padding: const EdgeInsets.all(8.0),
                            //     child: Tooltip(
                            //       richMessage: TextSpan(
                            //         text: '${_TransReBillModels[index].inv}',
                            //         style: const TextStyle(
                            //           fontWeight: FontWeight.bold,

                            //           //fontSize: 10.0
                            //         ),
                            //       ),
                            //       decoration: BoxDecoration(
                            //         borderRadius: BorderRadius.circular(5),
                            //         color: Colors.grey[200],
                            //       ),
                            //       child: AutoSizeText(
                            //         minFontSize: 10,
                            //         maxFontSize: 25,
                            //         maxLines: 1,
                            //         _TransReBillModels[index].inv == ''
                            //             ? '-'
                            //             : '${_TransReBillModels[index].inv}',
                            //         textAlign: TextAlign.start,
                            //         overflow: TextOverflow.ellipsis,
                            //         style: const TextStyle(),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            // Expanded(
                            //   flex: 1,
                            //   child: Tooltip(
                            //     richMessage: const TextSpan(
                            //       text: '',
                            //       style: TextStyle(
                            //         fontWeight: FontWeight.bold,

                            //         //fontSize: 10.0
                            //       ),
                            //     ),
                            //     decoration: BoxDecoration(
                            //       borderRadius: BorderRadius.circular(5),
                            //       color: Colors.grey[200],
                            //     ),
                            //     child: AutoSizeText(
                            //       minFontSize: 10,
                            //       maxFontSize: 25,
                            //       maxLines: 1,
                            //       '${_TransReBillModels[index].date}',
                            //       //'${DateFormat('dd-MM').format(DateTime.parse('${_TransReBillModels[index].date} 00:00:00'))}-${DateTime.parse('${_TransReBillModels[index].date} 00:00:00').year + 543}',
                            //       textAlign: TextAlign.start,
                            //       style: const TextStyle(),
                            //     ),
                            //   ),
                            // ),
                            Expanded(
                              flex: 1,
                              child: Tooltip(
                                richMessage: const TextSpan(
                                  text: '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,

                                    //fontSize: 10.0
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.grey[200],
                                ),
                                child: AutoSizeText(
                                  minFontSize: 8,
                                  maxFontSize: 14,
                                  maxLines: 1,
                                  _TransReBillModels_CancelStatus[index]
                                              .shopno
                                              .toString()
                                              .toUpperCase() ==
                                          '1'
                                      ? 'ด้วยตนเองผ่านเว็ป'
                                      : 'ผ่านเจ้าหน้า',
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: Font_.Fonts_T,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Tooltip(
                                richMessage: const TextSpan(
                                  text: '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,

                                    //fontSize: 10.0
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.grey[200],
                                ),
                                child: AutoSizeText(
                                  minFontSize: 8,
                                  maxFontSize: 14,
                                  maxLines: 1,
                                  _TransReBillModels_CancelStatus[index]
                                              .total_dis ==
                                          null
                                      ? '${nFormat.format(double.parse(_TransReBillModels_CancelStatus[index].total_bill!))}'
                                      : '${nFormat.format(double.parse(_TransReBillModels_CancelStatus[index].total_dis!))}',
                                  textAlign: TextAlign.end,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: Font_.Fonts_T,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Tooltip(
                                richMessage: const TextSpan(
                                  text: '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,

                                    //fontSize: 10.0
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.grey[200],
                                ),
                                child: AutoSizeText(
                                  minFontSize: 8,
                                  maxFontSize: 14,
                                  maxLines: 1,
                                  (_TransReBillModels_CancelStatus[index]
                                                  .pos
                                                  .toString()
                                                  .trim() ==
                                              '1' &&
                                          _TransReBillModels_CancelStatus[index]
                                                  .shopno
                                                  .toString()
                                                  .trim() ==
                                              '1' &&
                                          _TransReBillModels_CancelStatus[index]
                                                  .dtype !=
                                              '!Z')
                                      ? 'รอตรวจสอบ'
                                      : (_TransReBillModels_CancelStatus[index]
                                                      .pos
                                                      .toString()
                                                      .trim() ==
                                                  '0' &&
                                              _TransReBillModels_CancelStatus[
                                                          index]
                                                      .shopno
                                                      .toString()
                                                      .trim() ==
                                                  '1' &&
                                              _TransReBillModels_CancelStatus[
                                                          index]
                                                      .dtype ==
                                                  '!Z')
                                          ? 'ถูกปฏิเสธ'
                                          : 'ชำระสำเร็จ',
                                  textAlign: TextAlign.end,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontFamily: Font_.Fonts_T,
                                      color: (_TransReBillModels_CancelStatus[
                                                          index]
                                                      .pos
                                                      .toString()
                                                      .trim() ==
                                                  '1' &&
                                              _TransReBillModels_CancelStatus[
                                                          index]
                                                      .shopno
                                                      .toString()
                                                      .trim() ==
                                                  '1')
                                          ? Colors.orange
                                          : (_TransReBillModels_CancelStatus[
                                                              index]
                                                          .pos
                                                          .toString()
                                                          .trim() ==
                                                      '0' &&
                                                  _TransReBillModels_CancelStatus[
                                                              index]
                                                          .shopno
                                                          .toString()
                                                          .trim() ==
                                                      '1' &&
                                                  _TransReBillModels_CancelStatus[
                                                              index]
                                                          .dtype ==
                                                      '!Z')
                                              ? Colors.red
                                              : Colors.green),
                                ),
                              ),
                            ),
                            Expanded(
                                flex: 1,
                                child: StreamBuilder(
                                    stream: Stream.periodic(
                                        const Duration(seconds: 0)),
                                    builder: (context, snapshot) {
                                      return Align(
                                        alignment: Alignment.centerRight,
                                        child: (_TransReBillModels_CancelStatus[
                                                        index]
                                                    .dtype !=
                                                '!Z')
                                            ? Text('')
                                            : PopupMenuButton(
                                                child: Icon(
                                                  Icons.info,
                                                  color: Colors.red,
                                                  size: 20,
                                                ),
                                                itemBuilder:
                                                    (BuildContext context) => [
                                                          PopupMenuItem(
                                                            child: Container(
                                                                child: Text(
                                                              '${_TransReBillModels_CancelStatus[index].remark}',
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              // overflow:
                                                              //     TextOverflow
                                                              //         .ellipsis,
                                                              style: TextStyle(
                                                                  fontFamily: Font_
                                                                      .Fonts_T,
                                                                  color: Colors
                                                                      .black),
                                                            )),
                                                          ),
                                                        ]),
                                      );
                                    })),

                            // Expanded(
                            //   flex: 1,
                            //   child: Tooltip(
                            //     richMessage: const TextSpan(
                            //       text: '',
                            //       style: TextStyle(
                            //         fontWeight: FontWeight.bold,

                            //         //fontSize: 10.0
                            //       ),
                            //     ),
                            //     decoration: BoxDecoration(
                            //       borderRadius: BorderRadius.circular(5),
                            //       color: Colors.grey[200],
                            //     ),
                            //     child: FutureBuilder<String>(
                            //       future: red_Invoice_text(index),
                            //       builder: (context, snapshot) {
                            //         if (snapshot.connectionState ==
                            //             ConnectionState.waiting) {
                            //           // Return a loading indicator or some placeholder text while waiting.
                            //           return Row(
                            //             mainAxisAlignment:
                            //                 MainAxisAlignment.end,
                            //             children: [
                            //               SizedBox(
                            //                   height: 15,
                            //                   width: 15,
                            //                   child:
                            //                       CircularProgressIndicator()),
                            //             ],
                            //           ); // Example loading indicator.
                            //         } else if (snapshot.hasError) {
                            //           // Handle errors if necessary.
                            //           return Text("");
                            //         } else {
                            //           // Display the result when it's available.
                            //           return Text(
                            //             '${snapshot.data}' ??
                            //                 '', // Use ?? '' to handle null values
                            //             textAlign: TextAlign.end,
                            //             style: const TextStyle(),
                            //           );
                            //         }
                            //       },
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      )),
                ),
              );
            });
  }

  ///---------------------------------------------------------------------->
  Future<Null> checkshowDialog(
      index, daterec, dtype, pos, shopno, docnos) async {
    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                // title: Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     Container(
                //       alignment: Alignment.center,
                //       width: MediaQuery.of(context).size.width * 0.6,
                //       child: Text(
                //         'เลขที่บิล ${_TransReBillModels[index].docno}',
                //         style: const TextStyle(
                //           fontSize: 20.0,
                //           fontWeight: FontWeight.bold,
                //           color: Colors.black,
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
                content: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ScrollConfiguration(
                    behavior:
                        ScrollConfiguration.of(context).copyWith(dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                    }),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      dragStartBehavior: DragStartBehavior.start,
                      child: Row(
                        children: [
                          Container(
                              width: (Responsive.isDesktop(context))
                                  ? MediaQuery.of(context).size.width * 0.85
                                  : 1200,
                              child: Column(children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                              255, 184, 198, 133),
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(0),
                                            bottomLeft: Radius.circular(0),
                                            bottomRight: Radius.circular(0),
                                          ),
                                          // border: Border.all(
                                          //     color: Colors.grey, width: 1),
                                        ),
                                        // padding: const EdgeInsets.all(8.0),
                                        child: const Center(
                                          child: Text(
                                            'รายละเอียดบิล', //numinvoice
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontFamily: FontWeight_.Fonts_T,

                                              //fontSize: 10.0
                                              //fontSize: 10.0
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                              255, 184, 198, 133),
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(0),
                                            topRight: Radius.circular(10),
                                            bottomLeft: Radius.circular(0),
                                            bottomRight: Radius.circular(0),
                                          ),
                                          // border: Border.all(
                                          //     color: Colors.grey, width: 1),
                                        ),
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(15),
                                              topRight: Radius.circular(15),
                                              bottomLeft: Radius.circular(15),
                                              bottomRight: Radius.circular(15),
                                            ),
                                            // border: Border.all(
                                            //     color: Colors.grey, width: 1),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'บิลเลขที่ ${_TransReBillModels[index].docno}', //
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,

                                                //fontSize: 10.0
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  height: 50,
                                  padding: const EdgeInsets.all(8.0),
                                  color: Color.fromARGB(255, 201, 196, 186),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: AutoSizeText(
                                          minFontSize: 10,
                                          maxFontSize: 15,
                                          maxLines: 1,
                                          'ลำดับ',
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,

                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: AutoSizeText(
                                          minFontSize: 10,
                                          maxFontSize: 15,
                                          maxLines: 1,
                                          'วันที่ชำระ',
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,

                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: AutoSizeText(
                                          minFontSize: 10,
                                          maxFontSize: 15,
                                          maxLines: 1,
                                          'กำหนดชำระ',
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,

                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: AutoSizeText(
                                          minFontSize: 10,
                                          maxFontSize: 15,
                                          maxLines: 1,
                                          'เลขตั้งหนี้',
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,

                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: AutoSizeText(
                                          minFontSize: 10,
                                          maxFontSize: 15,
                                          maxLines: 1,
                                          'รายการ',
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,

                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: AutoSizeText(
                                          minFontSize: 10,
                                          maxFontSize: 15,
                                          maxLines: 1,
                                          'VAT(฿)',
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,

                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: AutoSizeText(
                                          minFontSize: 10,
                                          maxFontSize: 15,
                                          maxLines: 1,
                                          'WHT(฿)',
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,

                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: AutoSizeText(
                                          minFontSize: 10,
                                          maxFontSize: 15,
                                          maxLines: 1,
                                          'ยอดสุทธิ',
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,

                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: StreamBuilder(
                                    stream: Stream.periodic(
                                        const Duration(seconds: 0)),
                                    builder: (context, snapshot) {
                                      return _TransReBillHistoryModels.isEmpty
                                          ? SizedBox(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    height: 50,
                                                    width: 50,
                                                    child: LoadingIndicator(
                                                      indicatorType:
                                                          Indicator.values[30],
                                                      colors:
                                                          _kDefaultRainbowColors,
                                                      strokeWidth: 4.0,
                                                      // pathBackgroundColor:
                                                      //     showPathBackground ? Colors.black45 : null,
                                                    ),
                                                  ),
                                                  StreamBuilder(
                                                    stream: Stream.periodic(
                                                        const Duration(
                                                            milliseconds: 25),
                                                        (i) => i),
                                                    builder:
                                                        (context, snapshot) {
                                                      if (!snapshot.hasData)
                                                        return const Text('');
                                                      double elapsed =
                                                          double.parse(snapshot
                                                                  .data
                                                                  .toString()) *
                                                              0.05;
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: (elapsed > 8.00)
                                                            ? const Text(
                                                                '',
                                                                style: TextStyle(

                                                                    //fontSize: 10.0
                                                                    ),
                                                              )
                                                            : Text(
                                                                'ดาวน์โหลด : ${elapsed.toStringAsFixed(2)} s.',
                                                                // 'Time : ${elapsed.toStringAsFixed(2)} seconds',
                                                                style:
                                                                    const TextStyle(
                                                                  fontFamily: Font_
                                                                      .Fonts_T,
                                                                  //fontSize: 10.0
                                                                ),
                                                              ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            )
                                          : ListView.builder(
                                              physics:
                                                  const AlwaysScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount:
                                                  _TransReBillHistoryModels
                                                      .length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return ListTile(
                                                  title: Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                      border: Border(
                                                        bottom: BorderSide(
                                                          color: Colors.black12,
                                                          width: 1,
                                                        ),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          flex: 1,
                                                          child: AutoSizeText(
                                                            minFontSize: 10,
                                                            maxFontSize: 15,
                                                            maxLines: 1,
                                                            '${index + 1}',
                                                            textAlign:
                                                                TextAlign.start,
                                                            style:
                                                                const TextStyle(
                                                              fontFamily:
                                                                  Font_.Fonts_T,
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 2,
                                                          child: AutoSizeText(
                                                            minFontSize: 10,
                                                            maxFontSize: 15,
                                                            maxLines: 1,
                                                            '${DateFormat('dd-MM').format(DateTime.parse('${_TransReBillHistoryModels[index].dateacc}'))}-${int.parse('${DateFormat('yyyy').format(DateTime.parse('${_TransReBillHistoryModels[index].dateacc}'))}') + 543}',
                                                            // '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${_TransReBillHistoryModels[index].dateacc} 00:00:00'))}',
                                                            textAlign:
                                                                TextAlign.start,
                                                            style:
                                                                const TextStyle(
                                                              fontFamily:
                                                                  Font_.Fonts_T,
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 2,
                                                          child: AutoSizeText(
                                                            minFontSize: 10,
                                                            maxFontSize: 15,
                                                            maxLines: 1,
                                                            '${DateFormat('dd-MM').format(DateTime.parse('${_TransReBillHistoryModels[index].date}'))}-${int.parse('${DateFormat('yyyy').format(DateTime.parse('${_TransReBillHistoryModels[index].date}'))}') + 543}',
                                                            // '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${_TransReBillHistoryModels[index].date} 00:00:00'))}',
                                                            textAlign:
                                                                TextAlign.start,
                                                            style:
                                                                const TextStyle(
                                                              fontFamily:
                                                                  Font_.Fonts_T,
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 2,
                                                          child: AutoSizeText(
                                                            minFontSize: 10,
                                                            maxFontSize: 15,
                                                            maxLines: 1,
                                                            '${_TransReBillHistoryModels[index].refno}',
                                                            textAlign:
                                                                TextAlign.start,
                                                            style:
                                                                const TextStyle(
                                                              fontFamily:
                                                                  Font_.Fonts_T,
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 2,
                                                          child: AutoSizeText(
                                                            minFontSize: 10,
                                                            maxFontSize: 15,
                                                            maxLines: 1,
                                                            '${_TransReBillHistoryModels[index].expname}',
                                                            textAlign:
                                                                TextAlign.start,
                                                            style:
                                                                const TextStyle(
                                                              fontFamily:
                                                                  Font_.Fonts_T,
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: AutoSizeText(
                                                            minFontSize: 10,
                                                            maxFontSize: 15,
                                                            maxLines: 1,
                                                            '${_TransReBillHistoryModels[index].vat}',
                                                            textAlign:
                                                                TextAlign.end,
                                                            style:
                                                                const TextStyle(
                                                              fontFamily:
                                                                  Font_.Fonts_T,
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: AutoSizeText(
                                                            minFontSize: 10,
                                                            maxFontSize: 15,
                                                            maxLines: 1,
                                                            '${_TransReBillHistoryModels[index].wht}',
                                                            textAlign:
                                                                TextAlign.end,
                                                            style:
                                                                const TextStyle(
                                                              fontFamily:
                                                                  Font_.Fonts_T,
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: AutoSizeText(
                                                            minFontSize: 10,
                                                            maxFontSize: 15,
                                                            maxLines: 1,
                                                            '${nFormat.format(double.parse(_TransReBillHistoryModels[index].total!))}',
                                                            textAlign:
                                                                TextAlign.end,
                                                            style:
                                                                const TextStyle(
                                                              fontFamily:
                                                                  Font_.Fonts_T,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    width: (Responsive.isDesktop(context))
                                        ? MediaQuery.of(context).size.width *
                                            0.85
                                        : 1200,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: 250,
                                          // height: 50,
                                          // color: Colors.red,
                                          child: StreamBuilder(
                                              stream: Stream.periodic(
                                                  const Duration(seconds: 0)),
                                              builder: (context, snapshot) {
                                                return Column(
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4.0),
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: Color.fromARGB(
                                                              255,
                                                              201,
                                                              196,
                                                              186),
                                                          borderRadius: const BorderRadius
                                                              .only(
                                                              topLeft: Radius
                                                                  .circular(8),
                                                              topRight: Radius
                                                                  .circular(8),
                                                              bottomLeft: Radius
                                                                  .circular(8),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          8)),
                                                        ),
                                                        child: Text(
                                                          'วันที่ชำระ : ${DateFormat('dd-MM').format(DateTime.parse('${pdate}'))}-${int.parse('${DateFormat('yyyy').format(DateTime.parse('${pdate}'))}') + 543}',
                                                          // 'วันที่ชำระ : ${DateFormat('dd-MM').format(DateTime.parse('$pdate 00:00:00'))}-${DateTime.parse('$pdate 00:00:00').year + 543}',
                                                          textAlign:
                                                              TextAlign.end,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                            fontFamily:
                                                                Font_.Fonts_T,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const Align(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Text(
                                                        'รูปแบบการชำระ',
                                                        textAlign:
                                                            TextAlign.end,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontFamily:
                                                              Font_.Fonts_T,
                                                        ),
                                                      ),
                                                    ),
                                                    for (var i = 0;
                                                        i <
                                                            finnancetransModels
                                                                .length;
                                                        i++)
                                                      Align(
                                                        alignment:
                                                            Alignment.topLeft,
                                                        child: Text(
                                                          // minFontSize: 10,
                                                          // maxFontSize: 15,
                                                          '${i + 1}.(${finnancetransModels[i].type}) จำนวน ${nFormat.format(double.parse(finnancetransModels[i].amt!))} บาท',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                            fontFamily:
                                                                Font_.Fonts_T,
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                );
                                              }),
                                        ),
                                        Container(
                                          width: 350,
                                          // height: 50,
                                          decoration: BoxDecoration(
                                            color: Color.fromARGB(
                                                255, 201, 196, 186),
                                            borderRadius:
                                                const BorderRadius.only(
                                                    topLeft: Radius.circular(0),
                                                    topRight:
                                                        Radius.circular(0),
                                                    bottomLeft:
                                                        Radius.circular(0),
                                                    bottomRight:
                                                        Radius.circular(0)),
                                          ),
                                          child: StreamBuilder(
                                            stream: Stream.periodic(
                                                const Duration(seconds: 0)),
                                            builder: (context, snapshot) {
                                              return Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 120,
                                                        child: Text(
                                                          'รวม(บาท)',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                            fontFamily:
                                                                Font_.Fonts_T,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        // flex: 1,
                                                        child: Text(
                                                          textAlign:
                                                              TextAlign.end,
                                                          '${nFormat.format(sum_pvat)}',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                            fontFamily:
                                                                Font_.Fonts_T,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 120,
                                                        child: Text(
                                                          'ภาษีมูลค่าเพิ่ม(vat)',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontFamily:
                                                                Font_.Fonts_T,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        // flex: 1,
                                                        child: Text(
                                                          textAlign:
                                                              TextAlign.end,
                                                          '${nFormat.format(sum_vat)}',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                            fontFamily:
                                                                Font_.Fonts_T,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 120,
                                                        child: Text(
                                                          'หัก ณ ที่จ่าย',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                            fontFamily:
                                                                Font_.Fonts_T,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        // flex: 1,
                                                        child: Text(
                                                          textAlign:
                                                              TextAlign.end,
                                                          '${nFormat.format(sum_wht)}',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                            fontFamily:
                                                                Font_.Fonts_T,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 120,
                                                        child: Text(
                                                          'ยอดรวม',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                            fontFamily:
                                                                Font_.Fonts_T,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 1,
                                                        child: Text(
                                                          textAlign:
                                                              TextAlign.end,
                                                          '${nFormat.format(sum_amt)}',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                            fontFamily:
                                                                Font_.Fonts_T,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 120,
                                                        child: Text(
                                                          'ส่วนลด $sum_disp  %',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                            fontFamily:
                                                                Font_.Fonts_T,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        // flex: 1,
                                                        child: Text(
                                                          '${nFormat.format(sum_disamt)}',
                                                          textAlign:
                                                              TextAlign.end,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                            fontFamily:
                                                                Font_.Fonts_T,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 120,
                                                        child: Text(
                                                          'ยอดชำระ',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                            fontFamily:
                                                                Font_.Fonts_T,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        // flex: 1,
                                                        child: Text(
                                                          textAlign:
                                                              TextAlign.end,
                                                          '${nFormat.format(sum_amt - sum_disamt)}',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                            fontFamily:
                                                                Font_.Fonts_T,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                StreamBuilder(
                                    stream: Stream.periodic(
                                        const Duration(seconds: 0)),
                                    builder: (context, snapshot) {
                                      return Container(
                                        padding: const EdgeInsets.all(8.0),
                                        width: (Responsive.isDesktop(context))
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.85
                                            : 1200,
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            top: BorderSide(
                                              color: Colors.black12,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            if (daterec.toString() ==
                                                    day_now.toString() &&
                                                dtype == 'KP' &&
                                                pos == '1' &&
                                                shopno == '1')
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                // width: 180,
                                                child: InkWell(
                                                  onTap: () {
                                                    uploadFile_Slip(
                                                        context, docnos);
                                                  },
                                                  child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.orange,
                                                        borderRadius: const BorderRadius
                                                            .only(
                                                            topLeft: Radius
                                                                .circular(6),
                                                            topRight:
                                                                Radius.circular(
                                                                    6),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    6),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    6)),
                                                        border: Border.all(
                                                            color: Colors.grey,
                                                            width: 1),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    4.0),
                                                            child: Icon(
                                                              Icons.edit,
                                                              color:
                                                                  Colors.white,
                                                              size: 16,
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    4.0),
                                                            child: Text(
                                                              'แก้ไขหลักฐาน',
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                color: Colors
                                                                    .white,
                                                                fontFamily: Font_
                                                                    .Fonts_T,
                                                                // fontWeight:
                                                                //     FontWeight.bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      )),
                                                ),
                                              ),

                                            (Slip_history.toString() == null ||
                                                    Slip_history == null ||
                                                    Slip_history.toString() ==
                                                        'null')
                                                ? const SizedBox()
                                                : Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    width: 150,
                                                    child: InkWell(
                                                      onTap: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) =>
                                                              AlertDialog(
                                                                  title: Center(
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        Text(
                                                                          '${_TransReBillModels[index].docno}',
                                                                          maxLines:
                                                                              1,
                                                                          textAlign:
                                                                              TextAlign.start,
                                                                          style: const TextStyle(
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.bold,
                                                                              fontFamily: FontWeight_.Fonts_T,
                                                                              fontSize: 12.0),
                                                                        ),
                                                                        Text(
                                                                          '${Slip_history}',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style: const TextStyle(
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.bold,
                                                                              fontFamily: FontWeight_.Fonts_T,
                                                                              fontSize: 12.0),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  content:
                                                                      Stack(
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    children: <Widget>[
                                                                      Image.network(
                                                                          '${MyConstant().domain_chao}/files/$foder/slip/${Slip_history}')
                                                                    ],
                                                                  ),
                                                                  actions: <Widget>[
                                                                Column(
                                                                  children: [
                                                                    const SizedBox(
                                                                      height:
                                                                          5.0,
                                                                    ),
                                                                    const Divider(
                                                                      color: Colors
                                                                          .grey,
                                                                      height:
                                                                          4.0,
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          5.0,
                                                                    ),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              8.0),
                                                                          child:
                                                                              Container(
                                                                            padding:
                                                                                const EdgeInsets.all(8.0),
                                                                            width:
                                                                                150,
                                                                            child:
                                                                                InkWell(
                                                                              onTap: () {
                                                                                Navigator.pop(context);
                                                                              },
                                                                              child: Container(
                                                                                  decoration: BoxDecoration(
                                                                                    color: Colors.black,
                                                                                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6), bottomLeft: Radius.circular(6), bottomRight: Radius.circular(6)),
                                                                                    border: Border.all(color: Colors.grey, width: 1),
                                                                                  ),
                                                                                  child: const Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    children: [
                                                                                      Padding(
                                                                                        padding: EdgeInsets.all(4.0),
                                                                                        child: Icon(
                                                                                          Icons.highlight_off,
                                                                                          color: Colors.white,
                                                                                          size: 16,
                                                                                        ),
                                                                                      ),
                                                                                      Padding(
                                                                                        padding: EdgeInsets.all(4.0),
                                                                                        child: Text(
                                                                                          'ปิด',
                                                                                          style: TextStyle(
                                                                                            fontSize: 14,
                                                                                            color: Colors.white, fontFamily: Font_.Fonts_T,
                                                                                            // fontWeight:
                                                                                            //     FontWeight.bold,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  )),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ]),
                                                        );
                                                      },
                                                      child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .blue[200],
                                                            borderRadius: const BorderRadius
                                                                .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        6),
                                                                topRight: Radius
                                                                    .circular(
                                                                        6),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        6),
                                                                bottomRight:
                                                                    Radius
                                                                        .circular(
                                                                            6)),
                                                            border: Border.all(
                                                                color:
                                                                    Colors.grey,
                                                                width: 1),
                                                          ),
                                                          child: const Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            4.0),
                                                                child: Icon(
                                                                  Icons
                                                                      .receipt_long_rounded,
                                                                  color: Colors
                                                                      .black,
                                                                  size: 16,
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            4.0),
                                                                child: Text(
                                                                  'หลักฐานการโอน',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          )),
                                                    ),
                                                  ),
                                            // Container(
                                            //   padding:
                                            //       const EdgeInsets.all(8.0),
                                            //   width: 150,
                                            //   child: InkWell(
                                            //     onTap: () {
                                            //       List newValuePDFimg = [];
                                            //       for (int index = 0;
                                            //           index < 1;
                                            //           index++) {
                                            //         if (renTalModels[0]
                                            //                 .imglogo!
                                            //                 .trim() ==
                                            //             '') {
                                            //           // newValuePDFimg.add(
                                            //           //     'https://png.pngtree.com/png-vector/20190820/ourmid/pngtree-no-image-vector-illustration-isolated-png-image_1694547.jpg');
                                            //         } else {
                                            //           newValuePDFimg.add(
                                            //               '${MyConstant().domain}/files/$foder/logo/${renTalModels[0].imglogo!.trim()}');
                                            //         }
                                            //       }
                                            //       final tableData00 = [
                                            //         for (int index = 0;
                                            //             index <
                                            //                 _TransReBillHistoryModels
                                            //                     .length;
                                            //             index++)
                                            //           [
                                            //             // '${index + 1}',
                                            //             // '${_TransReBillHistoryModels[index].date}',
                                            //             // '${_TransReBillHistoryModels[index].expname}',
                                            //             // '${_TransReBillHistoryModels[index].nvat}',
                                            //             // '${_TransReBillHistoryModels[index].vtype}',
                                            //             // '${nFormat.format(double.parse(_TransReBillHistoryModels[index].vat!))}',
                                            //             // '${nFormat.format(double.parse(_TransReBillHistoryModels[index].amt!))}',
                                            //             // '${nFormat.format(double.parse(_TransReBillHistoryModels[index].total!))}',
                                            //             '${index + 1}',

                                            //             '${_TransReBillHistoryModels[index].date}',

                                            //             '${_TransReBillHistoryModels[index].expname}',

                                            //             '${nFormat.format(double.parse(_TransReBillHistoryModels[index].nvat!))}',
                                            //             '${nFormat.format(double.parse(_TransReBillHistoryModels[index].wht!))}',
                                            //             '${nFormat.format(double.parse(_TransReBillHistoryModels[index].amt!))}',
                                            //             '${nFormat.format(double.parse(_TransReBillHistoryModels[index].total!))}',
                                            //           ],
                                            //       ];
                                            //       String sname = _TransReBillModels[
                                            //                       index]
                                            //                   .sname ==
                                            //               null
                                            //           ? '${_TransReBillModels[index].remark}'
                                            //           : '${_TransReBillModels[index].sname}';
                                            //       String cname =
                                            //           '${_TransReBillModels[index].cname}';
                                            //       String addr =
                                            //           '${_TransReBillModels[index].addr}';
                                            //       String tax =
                                            //           '${_TransReBillModels[index].tax}';
                                            //       // Pdfgen_his_statusbill
                                            //       //     .exportPDF_statusbill(
                                            //       //         tableData00,
                                            //       //         context,
                                            //       //         _TransReBillHistoryModels,
                                            //       //         'Num_cid',
                                            //       //         'Namenew',
                                            //       //         sum_pvat,
                                            //       //         sum_vat,
                                            //       //         sum_wht,
                                            //       //         sum_amt,
                                            //       //         sum_disp,
                                            //       //         sum_disamt,
                                            //       //         '${sum_amt - sum_disamt}',
                                            //       //         renTal_name,
                                            //       //         sname,
                                            //       //         cname,
                                            //       //         addr,
                                            //       //         tax,
                                            //       //         bill_addr,
                                            //       //         bill_email,
                                            //       //         bill_tel,
                                            //       //         bill_tax,
                                            //       //         bill_name,
                                            //       //         newValuePDFimg,
                                            //       //         numinvoice,
                                            //       //         'cFinn',
                                            //       //         finnancetransModels,
                                            //       //         '${DateFormat('dd-MM').format(DateTime.parse('$pdate 00:00:00'))}-${DateTime.parse('$pdate 00:00:00').year + 543}');
                                            //     },
                                            //     child: Container(
                                            //         decoration: BoxDecoration(
                                            //           color: Colors.green,
                                            //           borderRadius:
                                            //               const BorderRadius
                                            //                       .only(
                                            //                   topLeft: Radius
                                            //                       .circular(6),
                                            //                   topRight: Radius
                                            //                       .circular(6),
                                            //                   bottomLeft: Radius
                                            //                       .circular(6),
                                            //                   bottomRight:
                                            //                       Radius
                                            //                           .circular(
                                            //                               6)),
                                            //           border: Border.all(
                                            //               color: Colors.grey,
                                            //               width: 1),
                                            //         ),
                                            //         child: const Row(
                                            //           mainAxisAlignment:
                                            //               MainAxisAlignment
                                            //                   .center,
                                            //           children: [
                                            //             Padding(
                                            //               padding:
                                            //                   EdgeInsets.all(
                                            //                       4.0),
                                            //               child: Icon(
                                            //                 Icons.print,
                                            //                 color: Colors.white,
                                            //                 size: 16,
                                            //               ),
                                            //             ),
                                            //             Padding(
                                            //               padding:
                                            //                   EdgeInsets.all(
                                            //                       4.0),
                                            //               child: Text(
                                            //                 'พิมพ์',
                                            //                 style: TextStyle(
                                            //                   fontSize: 14,
                                            //                   color:
                                            //                       Colors.white,
                                            //                   // fontWeight:
                                            //                   //     FontWeight.bold,
                                            //                 ),
                                            //               ),
                                            //             ),
                                            //           ],
                                            //         )),
                                            //   ),
                                            // ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              width: 150,
                                              child: InkWell(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                              topLeft: Radius
                                                                  .circular(6),
                                                              topRight: Radius
                                                                  .circular(6),
                                                              bottomLeft: Radius
                                                                  .circular(6),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          6)),
                                                      border: Border.all(
                                                          color: Colors.grey,
                                                          width: 1),
                                                    ),
                                                    child: const Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  4.0),
                                                          child: Icon(
                                                            Icons.highlight_off,
                                                            color: Colors.white,
                                                            size: 16,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  4.0),
                                                          child: Text(
                                                            'ปิด',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              color:
                                                                  Colors.white,
                                                              fontFamily:
                                                                  Font_.Fonts_T,
                                                              // fontWeight:
                                                              //     FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    )),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                              ])),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ));
  }
}
