import 'dart:convert';

import 'dart:io';

import 'package:chaoperty_user/Model/GetTrans_Model.dart';

import 'package:ficonsax/ficonsax.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import 'package:widgets_to_image/widgets_to_image.dart';
import '../Constant/Myconstant.dart';
import '../INSERT_Log/Insert_log.dart';
import '../Model/GetC_Quot_Select_Model.dart';
import '../Model/GetContract_Photo_Model.dart';
import '../Model/GetContractf_Model.dart';
import '../Model/GetRenTal_Model.dart';
import '../Model/GetTeNant_Model.dart';
import '../Model/GetZone_Model.dart';
import '../PDF/PDF_Agreement/pdf_RentalInforma.dart';
import '../Responsive/responsive.dart';
import '../color.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../color.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:flutter/gestures.dart';

import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart' as crypto;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Constant/Myconstant.dart';
import '../Model/GetCustomer_Model.dart';
import '../Model/GetRenTal_Model.dart';
import '../downloadImage.dart';
import 'box/contentbox.dart';
import 'home_select_cid.dart';
import 'loginscreen.dart';
import 'pdf_screen.dart';
import 'select_screen.dart';

////////////////////////////////////////////////
class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => PersonalInfoScreenState();
}

class PersonalInfoScreenState extends State<PersonalInfoScreen> {
  // WidgetsToImageController to access widget
  WidgetsToImageController controller = WidgetsToImageController();
  // to save image bytes of widget
  Uint8List? bytes;
  List items = [];
  String? value;
  bool? isChecked = false;
  int count = 0;
  List<TransModel> _TransModels = [];

  // Added 2026-07-08: dispose all controllers to prevent memory leak.
  // Previously this State had no dispose() at all, so every visit
  // leaked 23 TextEditingControllers + 1 ScrollController.
  @override
  void dispose() {
    Form_bussshop.dispose();
    Form_bussscontact.dispose();
    Form_address.dispose();
    Form_tel.dispose();
    Form_email.dispose();
    Form_tax.dispose();
    Form_wnote.dispose();
    rental_count_text.dispose();
    Form_area.dispose();
    Form_ln.dispose();
    Form_sdate.dispose();
    Form_ldate.dispose();
    Form_period.dispose();
    Form_rtname.dispose();
    Form_docno.dispose();
    Form_zn.dispose();
    Form_aser.dispose();
    Form_qty.dispose();
    Form_cdate.dispose();
    Form_nameshop.dispose();
    Form_typeshop.dispose();
    Form_User.dispose();
    Form_UserPass.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  List<QuotxSelectModel> quotxSelectModels = [];
  List<CustomerModel> customerModels = [];
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
      imgl,
      imglogo_,
      _verticalGroupValue;
  String? Ser_re,
      renTal_user,
      ren_name,
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
      cus_lncode,
      cus_zn;

  List<ContractfModel> contractfModels = [];
  String? cxname_card,
      cxname_lease,
      cxname_other,
      cxname_card_ser,
      cxname_lease_ser,
      cxname_other_ser,
      cid_doc,
      Cust_no_;
  List<ContractfModel> Other_file = [];
  List<RenTalModel> renTalModels = [];
  String? USer_;
  String? pic_tenant, pic_shop, pic_plan, fiew;
  List<ContractPhotoModel> contractPhotoModels = [];
  final Form_bussshop = TextEditingController();
  final Form_bussscontact = TextEditingController();
  final Form_address = TextEditingController();
  final Form_tel = TextEditingController();
  final Form_email = TextEditingController();
  final Form_tax = TextEditingController();
  final Form_wnote = TextEditingController();
  final rental_count_text = TextEditingController();
  final Form_area = TextEditingController();
  final Form_ln = TextEditingController();
  final Form_sdate = TextEditingController();
  final Form_ldate = TextEditingController();
  final Form_period = TextEditingController();
  final Form_rtname = TextEditingController();
  final Form_docno = TextEditingController();
  final Form_zn = TextEditingController();
  final Form_aser = TextEditingController();
  final Form_qty = TextEditingController();
  final Form_cdate = TextEditingController();

  final Form_nameshop = TextEditingController();
  final Form_typeshop = TextEditingController();
  final Form_User = TextEditingController();
  final Form_UserPass = TextEditingController();
  var nFormat = NumberFormat("#,##0.00", "en_US");
  List<TeNantModel> teNantModels = [];
  List<ZoneModel> zoneModels = [];

  final _formKey = GlobalKey<FormState>();
  int select_page = 0;

  @override
  void initState() {
    super.initState();
    checkPreferance();
    read_data();
    read_zoneAll();
    GC_contractf();
    read_GC_rental();
    red_report();
    read_GC_photo();
    red_reporttrans();
    // sum_disamtx.text = '0.00';
  }

  ///////////////////////////------------------------------------------>
  // _importFromExcel() async {
  //   ByteData data = await rootBundle.load('assets/newphoto2.xlsx');
  //   var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  //   var excel = Excel.decodeBytes(bytes);
  //   int index = 0;

  //   for (var table in excel.tables.keys) {
  //     for (var row in excel.tables[table]!.rows) {
  //       var ser = '${row[0]!.value}';
  //       var cusno = '${row[1]!.value}';
  //       var sname = '${row[2]!.value}';
  //       var cname = '${row[3]!.value}';

  //       var tel = '${row[4]!.value}';
  //       var email = '${row[5]!.value}';
  //       var tax = '${row[6]!.value}';
  //       var type = '${row[7]!.value}';
  //       var addr_1 = '${row[8]!.value}';
  //       var addr_2 = '${row[9]!.value}';

  //       index++;

  //       String url =
  //           '${MyConstant().domain_chao}/UP_CUSNEWDATA.php?isAdd=true&ren=81&cus_no=$cusno&scname=$sname&cname=$cname&tel=$tel&email=$email&tax=$tax&type=$type&addr_1=$addr_1&addr_2=$addr_2';

  //       try {
  //         var response = await http.get(Uri.parse(url));

  //         var result = json.decode(response.body);

  //         if (result.toString() == 'true') {
  //           print(
  //               "-true----$index------- > $ser  ---> $cusno  --->$sname -->$cname -->$tel -->$email -->$tax-->$type-->$addr_1-->$addr_2");
  //           print("true");
  //         } else {}
  //       } catch (e) {
  //         print('catch----$index------- >-->$cusno');
  //       }
  //     }
  //   }
  // }

//////////////------------------------------------------------->
  List<Color> _kDefaultRainbowColors = const [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
  ];

  // Future<void> _showSingleAnimationDialog(BuildContext context,
  //     Indicator indicator, bool showPathBackground) async {
  //   await showDialog(
  //     barrierDismissible: false,
  //     context: context,
  //     builder: (ctx) {
  //       Future.delayed(Duration(seconds: 2), () {
  //         Navigator.of(ctx).pop(true);
  //       });
  //       return Center(
  //         child: SizedBox(
  //           width: 50,
  //           height: 50,
  //           child: LoadingIndicator(
  //             indicatorType: indicator,
  //             colors: _kDefaultRainbowColors,
  //             strokeWidth: 4.0,
  //             pathBackgroundColor: showPathBackground ? Colors.black45 : null,
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
  ////////////---------------------------------------------->
  Future<Null> red_reporttrans() async {
    if (_TransModels.length != 0) {
      setState(() {
        _TransModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    // var ren = '50';
    // var ciddoc = 'LE000411';
    // var qutser = '1';
    var ciddoc = preferences.getString('usercid');
    var qutser = preferences.getString('qutser');
    var ren = preferences.getString('renTalSer');
    // var ren = preferences.getString('renTalSer');
    // var ciddoc = widget.Get_Value_cid;
    // var qutser = widget.Get_Value_NameShop_index;

    String url =
        '${MyConstant().domain_chao}/GC_trans_x.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);

      // print(result);
      // if (result.toString() != 'null') {
      if (result != null) {
        for (var map in result) {
          TransModel _TransModel = TransModel.fromJson(map);
          setState(() {
            _TransModels.add(_TransModel);
          });
        }
      } else {
        setState(() {
          _TransModels.clear();
        });
      }
    } catch (e) {}
  }

  ////////////---------------------------------------------->

////////////---------------------------------------------->
  Future<void> uploadImage(ImageSource source) async {
    ////////////////------------------------------------------------------>
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ciddoc_ = preferences.getString('usercid');
    var qutser_ = preferences.getString('qutser');
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    ////////////////------------------------------------------------------>

    int timestamp = DateTime.now().millisecondsSinceEpoch;
    var fileName_Slip = 'pic_tenant_${ciddoc_}_$timestamp.jpg';

    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: source);

    if (pickedFile == null) {
      // print('User canceled image selection');
      return;
    }

    try {
      // 2. Read the image as bytes
      final imageBytes = await pickedFile.readAsBytes();

      // 3. Encode the image as a base64 string
      final base64Image = base64Encode(imageBytes);

      // 4. Make an HTTP POST request to your server
      final url =
          '${MyConstant().domain_chao}/File_photo.php?name=$fileName_Slip&Foder=$foder';

      final response = await http.post(
        Uri.parse(url),
        body: {
          'image': base64Image,
          'Foder': foder,
          'name': fileName_Slip
        }, // Send the image as a form field named 'image'
      );

      if (response.statusCode == 200) {
        // print('Image uploaded successfully');
        up_photo_string(fileName_Slip, base64Image);
      } else {
        // print('Image upload failed');
      }
    } catch (e) {
      // print('Error during image processing: $e');
    }
  }

  Future<Null> up_photo_string(fileName_Slip, base64Image) async {
    ////////////////------------------------------------------------------>
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ciddoc_ = preferences.getString('usercid');
    var qutser_ = preferences.getString('qutser');
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    ////////////////------------------------------------------------------>
    var fiewx = 'pic_tenant';
    String? fileName_Slip_ = fileName_Slip.toString().trim();

    String url =
        '${MyConstant().domain_chao}/GC_tran_Kon_photo.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc_&qutser=$qutser_&fiewx=$fiewx&fileName_Slip=$fileName_Slip_';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() == 'true') {
        setState(() {
          fiew = null;
          read_GC_photo();
        });
      }
    } catch (e) {}
  }

  Future<Null> read_GC_photo() async {
    if (contractPhotoModels.isNotEmpty) {
      setState(() {
        contractPhotoModels.clear();
      });
    }
    ////////////////------------------------------------------------------>
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ciddoc_ = preferences.getString('usercid');
    var qutser_ = preferences.getString('qutser');
    ////////////////------------------------------------------------------>
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');

    String url =
        '${MyConstant().domain_chao}/GC_photo_cont.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc_&qutser=$qutser_';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() != 'null') {
        for (var map in result) {
          ContractPhotoModel contractPhotoModel =
              ContractPhotoModel.fromJson(map);

          var pic_tenantx = contractPhotoModel.pic_tenant!.trim();
          var pic_shopx = contractPhotoModel.pic_shop!.trim();
          var pic_planx = contractPhotoModel.pic_plan!.trim();
          setState(() {
            pic_tenant = pic_tenantx;
            pic_shop = pic_shopx;
            pic_plan = pic_planx;
            contractPhotoModels.add(contractPhotoModel);
          });
        }
      }
    } catch (e) {}
  }

  Future<Null> checkPreferance() async {
    DateTime currentDate = DateTime.now();

    // Format the date as 'YYYY-MM-DD'
    String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
    String new_Url = MyConstant().domain_chao;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? DateLogin;
    setState(() {
      Form_User.text = preferences.getString('UsernameUSer')!;
      Ser_re = preferences.getString('renTalSer');
      renTal_user = preferences.getString('renTalSer');
      ren_name = preferences.getString('renTalName');
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
      cus_lncode = preferences.getString('lncode');
      cus_zn = preferences.getString('zn');
    });
    if (cus_photo != null ||
        cus_photo.toString() != '' ||
        cus_photo.toString() != 'null') {
      cus_imglogo_ = '$new_Url/files/$cus_foder/contract/$cus_photo';
    }
  }

  Future<Null> red_report() async {
    if (quotxSelectModels.length != 0) {
      setState(() {
        quotxSelectModels.clear();
      });
    }
    ////////////////------------------------------------------------------>
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ciddoc_ = preferences.getString('usercid');
    var qutser_ = preferences.getString('qutser');
    var ren = preferences.getString('renTalSer');

    ////////////////------------------------------------------------------>

    String url =
        '${MyConstant().domain_chao}/GC_quot_conx.php?isAdd=true&ren=$ren&ciddoc=$ciddoc_&qutser=$qutser_';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() != 'null') {
        if (quotxSelectModels.isNotEmpty) {
          setState(() {
            quotxSelectModels.clear();
          });
        }
        for (var map in result) {
          QuotxSelectModel quotxSelectModel = QuotxSelectModel.fromJson(map);
          setState(() {
            quotxSelectModels.add(quotxSelectModel);
          });
        }
      } else {
        setState(() {
          quotxSelectModels.clear();
        });
      }
    } catch (e) {}
  }

  Future<Null> read_zoneAll() async {
    if (zoneModels.length != 0) {
      setState(() {
        zoneModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    // var ren = preferences.getString('renTalSer');
    //  var ciddoc = widget.Get_Value_cid;
    // var qutser = widget.Get_Value_NameShop_index;
    // var qutser = widget.Get_Value_NameShop_index;
    // var ren = '65';
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('user');
    var ciddoc = preferences.getString('usercid');
    var qutser = preferences.getString('qutser');
    setState(() {
      cid_doc = ciddoc;
    });
    String url = '${MyConstant().domain}/GC_zoneAll.php?isAdd=true&ren=$ren';
    // 'https://dzentric.com/chaoperty_user/chao_api_user/GC_zoneAll.php?isAdd=true&ren=65';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
//      print(result);
      if (result != null) {
        for (var map in result) {
          ZoneModel zoneModel = ZoneModel.fromJson(map);
          setState(() {
            zoneModels.add(zoneModel);
          });
        }
      }
    } catch (e) {}
  }

  Future<Null> read_GC_rental() async {
    if (renTalModels.isNotEmpty) {
      renTalModels.clear();
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    String new_Url = MyConstant().domain_chao;
    //https://dzentric.com/chao_perty/chao_api/GC_rental_setring.php?isAdd=true&ren=50
    String url =
        '${MyConstant().domain_chao}/GC_rental_setring.php?isAdd=true&ren=$ren';
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
            imgl = renTalModel.imglogo;
            imglogo_ =
                '$new_Url/files/$foder/logo/${renTalModel.imglogo!.trim()}';
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

    // print('imglogo_>>>>>  $imglogo_');
  }

  Future<Null> read_data() async {
    if (teNantModels.length != 0) {
      setState(() {
        teNantModels.clear();
      });
    }
    ////////////////------------------------------------------------------>
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var ciddoc_ = preferences.getString('usercid');
    var qutser_ = preferences.getString('qutser');
    ////////////////------------------------------------------------------>

    String url =
        '${MyConstant().domain_chao}/GC_tenantlookAS.php?isAdd=true&ren=$ren&ciddoc=$ciddoc_&qutser=$qutser_';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result != null) {
        for (var map in result) {
          TeNantModel teNantModel = TeNantModel.fromJson(map);
          setState(() {
            teNantModels.add(teNantModel);
            Cust_no_ = teNantModel.custno_1.toString();
            rtname = teNantModel.rtname.toString();
            // teNantModels.add(teNantModel);
            _verticalGroupValue = teNantModel.ctype;
            Form_nameshop.text = teNantModel.sname.toString();
            Form_typeshop.text = teNantModel.stype.toString();
            Form_bussshop.text = teNantModel.cname.toString();
            Form_bussscontact.text = teNantModel.attn.toString();
            Form_address.text = teNantModel.addr.toString();
            Form_tel.text = teNantModel.tel.toString();
            Form_email.text = teNantModel.email.toString();
            Form_tax.text =
                teNantModel.tax == null ? "-" : teNantModel.tax.toString();
            Form_area.text = teNantModel.area.toString();
            Form_ln.text = teNantModel.area_c.toString();
            Form_wnote.text = teNantModel.wnote.toString();
            Form_sdate.text = DateFormat('dd-MM-yyyy')
                .format(DateTime.parse('${teNantModel.sdate} 00:00:00'))
                .toString();
            Form_ldate.text = DateFormat('dd-MM-yyyy')
                .format(DateTime.parse('${teNantModel.ldate} 00:00:00'))
                .toString();
            Form_period.text = teNantModel.period.toString();
            Form_rtname.text = teNantModel.rtname.toString();
            Form_docno.text = teNantModel.docno.toString();
            Form_zn.text = teNantModel.zn.toString();
            Form_aser.text = teNantModel.aser.toString();
            Form_qty.text = teNantModel.qty.toString();
            Form_cdate.text = teNantModel.cdate.toString();
          });
        }
        red_coutumer();
      }
    } catch (e) {}
  }

  Future<Null> red_coutumer() async {
    if (customerModels.isNotEmpty) {
      setState(() {
        customerModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    String url =
        '${MyConstant().domain_chao}/GC_custo_informa.php?isAdd=true&ren=$ren&cusno=$Cust_no_';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      //print(result);
      List<int> encodedBytes = [];
      Uint8List decodedBytes;
      if (result.toString() != 'null') {
        for (var map in result) {
          CustomerModel customerModel = CustomerModel.fromJson(map);
          setState(() {
            customerModels.add(customerModel);

            Form_User.text = customerModel.user_name.toString();
            // encodedBytes = hex.decode(customerModel.passw!);
            // decodedBytes = Uint8List.fromList(encodedBytes);
            // const utf8Decoder = Utf8Decoder(allowMalformed: true);
            // Form_UserPass.text = utf8Decoder.convert(encodedBytes);
          });
        }
      }
    } catch (e) {}
  }

  Future<Null> GC_contractf() async {
    if (contractfModels.length != 0) {
      contractfModels.clear();
    }
    setState(() {
      Other_file = [];
      cxname_card = null;
      cxname_lease = null;
      cxname_other = null;
      cxname_card_ser = null;
      cxname_lease_ser = null;
      cxname_other_ser = null;
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    var ser_user = preferences.getString('ser');
    var ciddoc = preferences.getString('usercid');
    String url =
        '${MyConstant().domain}/GC_contractf.php?isAdd=true&ren=$ren&ser_user=$ser_user&namecid=$ciddoc';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result != null) {
        for (var map in result) {
          ContractfModel contractfModelss = ContractfModel.fromJson(map);
          setState(() {
            contractfModels.add(contractfModelss);
          });

          if (contractfModelss.cxname.toString() == 'contract/card') {
            setState(() {
              cxname_card = contractfModelss.filename.toString();
              cxname_card_ser = contractfModelss.ser.toString();
            });
          } else if (contractfModelss.cxname.toString() == 'contract/lease') {
            setState(() {
              cxname_lease = contractfModelss.filename.toString();
              cxname_lease_ser = contractfModelss.ser.toString();
            });
          } else if (contractfModelss.cxname.toString() == 'contract/other') {
            setState(() {
              cxname_other = contractfModelss.filename.toString();
              cxname_other_ser = contractfModelss.ser.toString();
            });

            //////////----------------------------------

            setState(() {
              Other_file.add(contractfModelss);
            });
          } else {}
        }

        // print('contractfModels>>>>>>>>>>>>>>>>> ${contractfModels.length}');
      } else {}
    } catch (e) {}
  }

  showdialog_Coming() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Container(
              height: MediaQuery.of(context).size.width * 0.2,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Center(
                  child: Container(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Coming soon...',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: Font_.Fonts_T,
                        ),
                      )),
                ),
              ),
            ),
          );
        });
  }

  showdialog_pdf() async {
    // dynamic Url_ = 'https://chaoperties.com/#/';
    // String new_Url =
    //     '${Url_.toString().substring(0, Url_.toString().length - 3)}/chao_api';
    String new_Url = await MyConstant().domain_chao;
    String Url =
        '$new_Url/files/$foder/contract/other/${Other_file[0].filename}';

    // print("${Url}");
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            titlePadding: EdgeInsets.zero,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            clipBehavior: Clip.hardEdge,
            title: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                color: Color.fromARGB(255, 184, 198, 133),
                child: Center(
                  child: Text(
                    "สัญญาเช่า (PDF)",
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: Font_.Fonts_T,
                    ),
                  ),
                )),
            content: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: Column(children: [
                for (int index = 0; index < contractfModels.length; index++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                          color: Color.fromARGB(255, 201, 196, 186),
                          borderRadius: BorderRadius.circular(5)),
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).push(
                              MaterialPageRoute(
                                fullscreenDialog: true,
                                builder: (context) => PreviewScreenRental_(
                                    title: '${Other_file[0].filename}',
                                    Url: "${Url}"),
                              ),
                            );
                          },
                          child: Text(
                            '${Other_file[index].filename}',
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: Font_.Fonts_T,
                            ),
                          )),
                    ),
                  )
              ]),
            ),
            actions: <Widget>[
              Column(
                children: [
                  const SizedBox(
                    height: 5.0,
                  ),
                  const Divider(
                    color: Colors.grey,
                    height: 4.0,
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          width: 150,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(6),
                                      topRight: Radius.circular(6),
                                      bottomLeft: Radius.circular(6),
                                      bottomRight: Radius.circular(6)),
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
                                          color: Colors.white,
                                          fontFamily: Font_.Fonts_T,
                                          // fontWeight:
                                          //     FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                        ),
                        // Container(
                        //   width: 100,
                        //   decoration: const BoxDecoration(
                        //     color: Colors.redAccent,
                        //     borderRadius: BorderRadius.only(
                        //         topLeft: Radius.circular(10),
                        //         topRight: Radius.circular(10),
                        //         bottomLeft: Radius.circular(10),
                        //         bottomRight: Radius.circular(10)),
                        //   ),
                        //   padding: const EdgeInsets.all(8.0),
                        //   child: TextButton(
                        //     onPressed: () => Navigator.pop(context, 'OK'),
                        //     child: const Text(
                        //       'ปิด',
                        //       style: TextStyle(
                        //         color: Colors.white,
                        //         fontWeight: FontWeight.bold,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        });
  }

  showdialog_EditUSer() async {
    String Url =
        await '${MyConstant().domain_chao}/files/$foder/contract/other/${Other_file[0].filename}';
    // print("${Url}");
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            titlePadding: EdgeInsets.zero,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            clipBehavior: Clip.hardEdge,
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 6.0),
                    color: Color.fromARGB(255, 184, 198, 133),
                    child: const Text(
                      "แก้ไขข้อมูลบัญชี",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: Font_.Fonts_T,
                      ),
                    )),
              ),
            ),
            content: Container(
              constraints: const BoxConstraints(maxHeight: 500),
              child: Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Container(
                    width: 400,
                    height: 250,
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
                      color: const Color.fromARGB(255, 219, 221, 218),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: Form(
                        key: _formKey,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ListTile(
                                leading: const SizedBox(
                                    width: 80,
                                    child: Text(
                                      "username :",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: FontWeight_.Fonts_T,
                                      ),
                                    )),
                                title: SizedBox(
                                  height: 50,
                                  width: 60,
                                  child: TextFormField(
                                      style: TextStyle(
                                        fontFamily: Font_.Fonts_T,
                                      ),
                                      controller: Form_User,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'ใส่ข้อมูลให้ครบถ้วน ';
                                        }
                                        // if (int.parse(value.toString()) < 13) {
                                        //   return '< 13';
                                        // }
                                        return null;
                                      },
                                      decoration: const InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding: EdgeInsets.only(
                                              left: 8, right: 8),
                                          border: OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                              borderRadius:
                                                  BorderRadius.zero))),
                                ),
                              ),
                              ListTile(
                                leading: const SizedBox(
                                    width: 80,
                                    child: Text(
                                      "password :",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: FontWeight_.Fonts_T,
                                      ),
                                    )),
                                title: SizedBox(
                                  height: 50,
                                  width: 60,
                                  child: TextFormField(
                                      style: TextStyle(
                                        fontFamily: Font_.Fonts_T,
                                      ),
                                      controller: Form_UserPass,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'ใส่ข้อมูลให้ครบถ้วน ';
                                        }
                                        // if (int.parse(value.toString()) < 13) {
                                        //   return '< 13';
                                        // }
                                        return null;
                                      },
                                      decoration: const InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding: EdgeInsets.only(
                                              left: 8, right: 8),
                                          border: OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                              borderRadius:
                                                  BorderRadius.zero))),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8.0),
                                            width: 150,
                                            child: InkWell(
                                              onTap: () async {
                                                SharedPreferences preferences =
                                                    await SharedPreferences
                                                        .getInstance();
                                                String? ren = preferences
                                                    .getString('renTalSer');
                                                String? ser_user = preferences
                                                    .getString('ser');
                                                var ciddoc_ = preferences
                                                    .getString('usercid');
                                                var qutser_ = preferences
                                                    .getString('qutser');

                                                String Cid_ = '${ciddoc_}';
                                                // print(
                                                //     'User : ${Form_User.text}  /// ${Form_UserPass.text}');
                                                // print('Cust_no_ : ${Cust_no_}');

                                                String password = md5
                                                    .convert(utf8.encode(
                                                        Form_UserPass.text))
                                                    .toString();
                                                // print('password Md5 $password');
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  String url =
                                                      '${MyConstant().domain_chao}/UpC_custno_cid_Informa.php?isAdd=true&cust_no=$Cust_no_&user_U=${Form_User.text}&pass_U=$password&ren=$ren';
                                                  try {
                                                    var response = await http
                                                        .get(Uri.parse(url));

                                                    var result = json
                                                        .decode(response.body);

                                                    Insert_log.Insert_logs(
                                                        'ข้อมูลส่วนตัว',
                                                        'แก้ไขข้อมูล $Cust_no_  (U:${Form_User.text} )(P:${Form_UserPass.text})');
                                                    setState(() {
                                                      Form_UserPass.clear();
                                                      Form_User.clear();
                                                    });
                                                    checkPreferance();
                                                    read_data();
                                                    read_zoneAll();
                                                    GC_contractf();
                                                    read_GC_rental();
                                                    Navigator.pop(
                                                        context, 'OK');
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                            const SnackBar(
                                                                backgroundColor:
                                                                    Colors
                                                                        .green,
                                                                content: Text(
                                                                    'แก้ไขข้อมูลเสร็จสิ้น !!',
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                    ))));
                                                  } catch (e) {
                                                    Navigator.pop(
                                                        context, 'OK');
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                          backgroundColor:
                                                              Colors.red,
                                                          content: Text(
                                                              'เกิดข้อผิดพลาด',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontFamily: Font_
                                                                    .Fonts_T,
                                                              ))),
                                                    );
                                                  }
                                                }
                                                // Navigator.of(context).pop();
                                              },
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.green,
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    6),
                                                            topRight:
                                                                Radius.circular(
                                                                    6),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    6),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    6)),
                                                  ),
                                                  child: const Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.all(4.0),
                                                        child: Icon(
                                                          Icons.check,
                                                          color: Colors.white,
                                                          size: 16,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.all(4.0),
                                                        child: Text(
                                                          'ยืนยัน',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.white,
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
                                          // Container(
                                          //   width: 80,
                                          //   decoration: const BoxDecoration(
                                          //     color: Colors.green,
                                          //     borderRadius: BorderRadius.only(
                                          //         topLeft: Radius.circular(10),
                                          //         topRight: Radius.circular(10),
                                          //         bottomLeft:
                                          //             Radius.circular(10),
                                          //         bottomRight:
                                          //             Radius.circular(10)),
                                          //   ),
                                          //   padding: const EdgeInsets.all(8.0),
                                          //   child: TextButton(
                                          //     onPressed: () async {
                                          //       SharedPreferences preferences =
                                          //           await SharedPreferences
                                          //               .getInstance();
                                          //       String? ren = preferences
                                          //           .getString('renTalSer');
                                          //       String? ser_user = preferences
                                          //           .getString('ser');
                                          //       var ciddoc_ = preferences
                                          //           .getString('usercid');
                                          //       var qutser_ = preferences
                                          //           .getString('qutser');

                                          //       String Cid_ = '${ciddoc_}';
                                          //       print(
                                          //           'User : ${Form_User.text}  /// ${Form_UserPass.text}');
                                          //       print('Cust_no_ : ${Cust_no_}');

                                          //       String password = md5
                                          //           .convert(utf8.encode(
                                          //               Form_UserPass.text))
                                          //           .toString();
                                          //       print('password Md5 $password');
                                          //       if (_formKey.currentState!
                                          //           .validate()) {
                                          //         String url =
                                          //             '${MyConstant().domain_chao}/UpC_custno_cid_Informa.php?isAdd=true&cust_no=$Cust_no_&user_U=${Form_User.text}&pass_U=$password&ren=$ren';
                                          //         try {
                                          //           var response = await http
                                          //               .get(Uri.parse(url));

                                          //           var result = json
                                          //               .decode(response.body);

                                          //           setState(() {
                                          //             Form_UserPass.clear();
                                          //             Form_User.clear();
                                          //           });
                                          //           checkPreferance();
                                          //           read_data();
                                          //           read_zoneAll();
                                          //           GC_contractf();
                                          //           read_GC_rental();
                                          //           Navigator.pop(
                                          //               context, 'OK');
                                          //           ScaffoldMessenger.of(
                                          //                   context)
                                          //               .showSnackBar(
                                          //                   const SnackBar(
                                          //                       content: Text(
                                          //                           'แก้ไขข้อมูลเสร็จสิ้น !!',
                                          //                           style:
                                          //                               TextStyle(
                                          //                             color: Colors
                                          //                                 .black,
                                          //                           ))));
                                          //         } catch (e) {
                                          //           Navigator.pop(
                                          //               context, 'OK');
                                          //           ScaffoldMessenger.of(
                                          //                   context)
                                          //               .showSnackBar(
                                          //             const SnackBar(
                                          //                 content: Text(
                                          //                     'เกิดข้อผิดพลาด',
                                          //                     style: TextStyle(
                                          //                       color: Colors
                                          //                           .black,
                                          //                     ))),
                                          //           );
                                          //         }
                                          //       }
                                          //       // Navigator.of(context).pop();
                                          //     },
                                          //     child: const Text(
                                          //       'ยืนยัน',
                                          //       style: TextStyle(
                                          //         color: Colors.white,
                                          //         fontWeight: FontWeight.bold,
                                          //       ),
                                          //     ),
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8.0),
                                            width: 150,
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  Form_UserPass.clear();
                                                  Form_User.clear();
                                                  checkPreferance();
                                                  read_data();
                                                  read_zoneAll();
                                                  GC_contractf();
                                                  read_GC_rental();
                                                });
                                                Navigator.pop(context, 'OK');
                                              },
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.red,
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    6),
                                                            topRight:
                                                                Radius.circular(
                                                                    6),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    6),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    6)),
                                                  ),
                                                  child: const Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.all(4.0),
                                                        child: Icon(
                                                          Icons.highlight_off,
                                                          color: Colors.white,
                                                          size: 16,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.all(4.0),
                                                        child: Text(
                                                          'ปิด',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.white,
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
                                          // Container(
                                          //   width: 80,
                                          //   decoration: const BoxDecoration(
                                          //     color: Colors.redAccent,
                                          //     borderRadius: BorderRadius.only(
                                          //         topLeft: Radius.circular(10),
                                          //         topRight: Radius.circular(10),
                                          //         bottomLeft:
                                          //             Radius.circular(10),
                                          //         bottomRight:
                                          //             Radius.circular(10)),
                                          //   ),
                                          //   padding: const EdgeInsets.all(8.0),
                                          //   child: TextButton(
                                          //     onPressed: () {
                                          //       setState(() {
                                          //         Form_UserPass.clear();
                                          //         Form_User.clear();
                                          //         checkPreferance();
                                          //         read_data();
                                          //         read_zoneAll();
                                          //         GC_contractf();
                                          //         read_GC_rental();
                                          //       });
                                          //       Navigator.pop(context, 'OK');
                                          //     },
                                          //     child: const Text(
                                          //       'ยกเลิก',
                                          //       style: TextStyle(
                                          //         color: Colors.white,
                                          //         fontWeight: FontWeight.bold,
                                          //       ),
                                          //     ),
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ]),
                      ),
                    )),
              ),
            ),
          );
        });
  }

  showdialog_Detail() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            titlePadding: EdgeInsets.zero,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            clipBehavior: Clip.hardEdge,
            // title: Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Center(
            //     child: const Text(
            //       "รายละเอียดค่าบริการ",
            //       style: TextStyle(color: Colors.black),
            //     ),
            //   ),
            // ),
            content: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
              }),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                dragStartBehavior: DragStartBehavior.start,
                child: Row(
                  children: [
                    SizedBox(
                      width: (Responsive.isDesktop(context))
                          ? MediaQuery.of(context).size.width * 0.84
                          : 900,
                      height: MediaQuery.of(context).size.height,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 184, 198, 133),
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
                                      'รายละเอียดค่าบริการ', //numinvoice
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
                                    color: Color.fromARGB(255, 184, 198, 133),
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
                                        'สัญญา ${cid_doc}', //
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
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 201, 196, 186),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(0),
                                    topRight: Radius.circular(0),
                                    bottomLeft: Radius.circular(0),
                                    bottomRight: Radius.circular(0)),
                              ),
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      'งวด',
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: FontWeight_.Fonts_T,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      'วันที่',
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: FontWeight_.Fonts_T,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      'รายการ',
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: FontWeight_.Fonts_T,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      'ยอด/งวด',
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: FontWeight_.Fonts_T,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      'ยอด',
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: FontWeight_.Fonts_T,
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                          Expanded(
                            // height: (Responsive.isDesktop(context))
                            //     ? MediaQuery.of(context).size.width * 0.1
                            //     : 300,
                            // width: (Responsive.isDesktop(context))
                            //     ? MediaQuery.of(context).size.width * 0.84
                            //     : 900,
                            // decoration: const BoxDecoration(
                            //   borderRadius: BorderRadius.only(
                            //       topLeft: Radius.circular(0),
                            //       topRight: Radius.circular(0),
                            //       bottomLeft: Radius.circular(0),
                            //       bottomRight: Radius.circular(0)),
                            //   // border: Border.all(color: Colors.grey, width: 1),
                            // ),
                            child: quotxSelectModels.isEmpty
                                ? SizedBox(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                              const Duration(milliseconds: 25),
                                              (i) => i),
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData)
                                              return const Text('');
                                            double elapsed = double.parse(
                                                    snapshot.data.toString()) *
                                                0.05;
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
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
                                                        fontFamily:
                                                            Font_.Fonts_T,
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
                                    physics:
                                        const AlwaysScrollableScrollPhysics(), //NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: quotxSelectModels.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Material(
                                        color: Colors.white,
                                        child: Column(
                                          children: [
                                            ListTile(
                                                onTap: () {},
                                                title: SizedBox(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Expanded(
                                                        flex: 1,
                                                        child: Text(
                                                          // maxFontSize: 15,
                                                          '${quotxSelectModels[index].unit} / ${quotxSelectModels[index].term} (งวด)',
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
                                                        child: Text(
                                                          '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${quotxSelectModels[index].sdate!} 00:00:00'))} - ${DateFormat('dd-MM-yyyy').format(DateTime.parse('${quotxSelectModels[index].ldate!} 00:00:00'))}',
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
                                                        child: Tooltip(
                                                          richMessage: TextSpan(
                                                            text:
                                                                '${quotxSelectModels[index].expname}',
                                                            style:
                                                                const TextStyle(
                                                              fontFamily:
                                                                  Font_.Fonts_T,
                                                            ),
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                            color: Colors
                                                                .grey[200],
                                                          ),
                                                          child: Text(
                                                            '${quotxSelectModels[index].expname}',
                                                            textAlign:
                                                                TextAlign.start,
                                                            style:
                                                                const TextStyle(
                                                              fontFamily:
                                                                  Font_.Fonts_T,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 1,
                                                        child: Text(
                                                          '${nFormat.format(double.parse(quotxSelectModels[index].total!))}',
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
                                                        child: Text(
                                                          '${nFormat.format(int.parse(quotxSelectModels[index].term!) * double.parse(quotxSelectModels[index].total!))}',
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
                                                )),
                                            const Divider(
                                              color: Colors.black12,
                                              height: 2.0,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              Column(
                children: [
                  const SizedBox(
                    height: 5.0,
                  ),
                  const Divider(
                    color: Colors.grey,
                    height: 4.0,
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          width: 150,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(6),
                                      topRight: Radius.circular(6),
                                      bottomLeft: Radius.circular(6),
                                      bottomRight: Radius.circular(6)),
                                  // border:
                                  //     Border.all(color: Colors.grey, width: 1),
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
                                          color: Colors.white,
                                          fontFamily: Font_.Fonts_T,
                                          // fontWeight:
                                          //     FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                        ),
                        // Container(
                        //   width: 100,
                        //   decoration: const BoxDecoration(
                        //     color: Colors.redAccent,
                        //     borderRadius: BorderRadius.only(
                        //         topLeft: Radius.circular(10),
                        //         topRight: Radius.circular(10),
                        //         bottomLeft: Radius.circular(10),
                        //         bottomRight: Radius.circular(10)),
                        //   ),
                        //   padding: const EdgeInsets.all(8.0),
                        //   child: TextButton(
                        //     onPressed: () {
                        //       Navigator.pop(context, 'OK');
                        //     },
                        //     child: const Text(
                        //       'ปิด',
                        //       style: TextStyle(
                        //         color: Colors.white,
                        //         fontWeight: FontWeight.bold,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        });
  }

  Map<int, dynamic> tNM_list = {};
  ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: bgcolor,
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    // border: Border.all(color: grey, style: BorderStyle.solid),
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'ข้อมูลสัญญาเช่า',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color.fromRGBO(100, 108, 110, 1),
                              fontFamily: FontWeight_.Fonts_T,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12, left: 15, right: 15),
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
                  child: teNantModels.isEmpty
                      ? SizedBox()
                      : Column(children: [
                          // teNantModels.length == 0
                          //     ? SizedBox()
                          //     : Row(
                          //         mainAxisAlignment: MainAxisAlignment.center,
                          //         children: [
                          //           Padding(
                          //             padding: const EdgeInsets.all(0.0),
                          //             child: Stack(
                          //               children: [
                          //                 WidgetsToImage(
                          //                   controller: controller,
                          //                   child: Row(
                          //                     children: [
                          //                       SizedBox(
                          //                         width: MediaQuery.of(context)
                          //                                 .size
                          //                                 .width *
                          //                             0.89,
                          //                         child: Container(
                          //                           // width: 350,
                          //                           // height: 135,
                          //                           decoration: BoxDecoration(
                          //                             color: Colors.white,
                          //                             borderRadius:
                          //                                 const BorderRadius
                          //                                         .only(
                          //                                     topLeft: Radius
                          //                                         .circular(10),
                          //                                     topRight: Radius
                          //                                         .circular(0),
                          //                                     bottomLeft: Radius
                          //                                         .circular(10),
                          //                                     bottomRight:
                          //                                         Radius
                          //                                             .circular(
                          //                                                 0)),
                          //                             boxShadow: [
                          //                               BoxShadow(
                          //                                 color: Colors.grey
                          //                                     .withOpacity(0.5),
                          //                                 spreadRadius: 3,
                          //                                 blurRadius: 5,
                          //                                 offset: const Offset(
                          //                                     0,
                          //                                     3), // changes position of shadow
                          //                               ),
                          //                             ],
                          //                             // image: const DecorationImage(
                          //                             //   image: AssetImage("pngegg2.png"),
                          //                             //   fit: BoxFit.cover,
                          //                             // ),
                          //                           ),
                          //                           padding:
                          //                               const EdgeInsets.all(
                          //                                   2.0),
                          //                           child: Row(
                          //                             mainAxisAlignment:
                          //                                 MainAxisAlignment
                          //                                     .spaceBetween,
                          //                             crossAxisAlignment:
                          //                                 CrossAxisAlignment
                          //                                     .center,
                          //                             children: [
                          //                               SizedBox(
                          //                                 width: 10,
                          //                               ),
                          //                               Padding(
                          //                                 padding:
                          //                                     const EdgeInsets
                          //                                             .fromLTRB(
                          //                                         4, 0, 0, 0),
                          //                                 child: Container(
                          //                                   color: Colors.white,
                          //                                   child: Column(
                          //                                     crossAxisAlignment:
                          //                                         CrossAxisAlignment
                          //                                             .center,
                          //                                     mainAxisAlignment:
                          //                                         MainAxisAlignment
                          //                                             .center,
                          //                                     children: [
                          //                                       Container(
                          //                                         height: 120,
                          //                                         width: 120,
                          //                                         child:
                          //                                             SfBarcodeGenerator(
                          //                                           value:
                          //                                               '$cid_doc',
                          //                                           symbology:
                          //                                               QRCode(),
                          //                                           showValue:
                          //                                               false,
                          //                                         ),
                          //                                       ),
                          //                                       const Text(
                          //                                         'ลงชื่อ..........................',
                          //                                         style:
                          //                                             TextStyle(
                          //                                           fontSize:
                          //                                               10.0,
                          //                                           fontFamily:
                          //                                               Font_
                          //                                                   .Fonts_T,
                          //                                           // color: PeopleChaoScreen_Color.Colors_Text1_,
                          //                                           //fontWeight: FontWeight.bold,
                          //                                           // fontFamily: Font_.Fonts_T,
                          //                                         ),
                          //                                       ),
                          //                                     ],
                          //                                   ),
                          //                                 ),
                          //                               ),
                          //                               Stack(
                          //                                 children: [
                          //                                   Padding(
                          //                                     padding:
                          //                                         const EdgeInsets
                          //                                                 .fromLTRB(
                          //                                             4,
                          //                                             4,
                          //                                             0,
                          //                                             4),
                          //                                     child: Container(
                          //                                       width: 170,
                          //                                       child: Column(
                          //                                         crossAxisAlignment:
                          //                                             CrossAxisAlignment
                          //                                                 .start,
                          //                                         children: [
                          //                                           const SizedBox(
                          //                                             height:
                          //                                                 5.0,
                          //                                           ),
                          //                                           Text(
                          //                                             '${renname}',
                          //                                             maxLines:
                          //                                                 1,
                          //                                             style:
                          //                                                 const TextStyle(
                          //                                               fontSize:
                          //                                                   10.0,

                          //                                               /// color: PeopleChaoScreen_Color.Colors_Text1_,
                          //                                               fontWeight:
                          //                                                   FontWeight.bold,
                          //                                               fontFamily:
                          //                                                   FontWeight_.Fonts_T,
                          //                                               //  fontFamily: Font_.Fonts_T,
                          //                                             ),
                          //                                           ),
                          //                                           Text(
                          //                                             '${teNantModels.first.sdate} ถึง ${teNantModels.first.ldate}',
                          //                                             maxLines:
                          //                                                 1,
                          //                                             style:
                          //                                                 const TextStyle(
                          //                                               fontSize:
                          //                                                   10.0,
                          //                                               fontFamily:
                          //                                                   Font_.Fonts_T,

                          //                                               /// color: PeopleChaoScreen_Color.Colors_Text1_,
                          //                                               // fontWeight: FontWeight.bold,
                          //                                               //  fontFamily: Font_.Fonts_T,
                          //                                             ),
                          //                                           ),
                          //                                           Text(
                          //                                             '$cid_doc',
                          //                                             style:
                          //                                                 const TextStyle(
                          //                                               fontSize:
                          //                                                   10.0,
                          //                                               // color: PeopleChaoScreen_Color.Colors_Text1_,
                          //                                               fontWeight:
                          //                                                   FontWeight.bold,
                          //                                               fontFamily:
                          //                                                   FontWeight_.Fonts_T,
                          //                                               // fontFamily: Font_.Fonts_T,
                          //                                             ),
                          //                                           ),
                          //                                           const Text(
                          //                                             'ชื่อผู้ติดต่อ',
                          //                                             style:
                          //                                                 TextStyle(
                          //                                               fontSize:
                          //                                                   10.0,
                          //                                               fontFamily:
                          //                                                   Font_.Fonts_T,
                          //                                               // color: PeopleChaoScreen_Color.Colors_Text1_,
                          //                                               //fontWeight: FontWeight.bold,
                          //                                               // fontFamily: Font_.Fonts_T,
                          //                                             ),
                          //                                           ),
                          //                                           Text(
                          //                                             '${teNantModels[count].cname}',
                          //                                             maxLines:
                          //                                                 2,
                          //                                             style:
                          //                                                 const TextStyle(
                          //                                               fontSize:
                          //                                                   10.0,
                          //                                               // color: PeopleChaoScreen_Color.Colors_Text1_,
                          //                                               fontWeight:
                          //                                                   FontWeight.bold,
                          //                                               fontFamily:
                          //                                                   FontWeight_.Fonts_T,
                          //                                               // fontFamily: Font_.Fonts_T,
                          //                                             ),
                          //                                           ),
                          //                                           const Text(
                          //                                             'ชื่อร้านค้า',
                          //                                             style:
                          //                                                 TextStyle(
                          //                                               fontSize:
                          //                                                   10.0,
                          //                                               fontFamily:
                          //                                                   Font_.Fonts_T,
                          //                                               // color: PeopleChaoScreen_Color.Colors_Text1_,
                          //                                               // fontWeight: FontWeight.bold,
                          //                                               // fontFamily: Font_.Fonts_T,
                          //                                             ),
                          //                                           ),
                          //                                           Text(
                          //                                             teNantModels[count].sname ==
                          //                                                     null
                          //                                                 ? teNantModels[count].sname_q == null
                          //                                                     ? ''
                          //                                                     : '${teNantModels[count].sname_q}'
                          //                                                 : '${teNantModels[count].sname}',
                          //                                             maxLines:
                          //                                                 2,
                          //                                             style:
                          //                                                 const TextStyle(
                          //                                               fontSize:
                          //                                                   10.0,
                          //                                               // color: PeopleChaoScreen_Color.Colors_Text1_,
                          //                                               fontWeight:
                          //                                                   FontWeight.bold,
                          //                                               fontFamily:
                          //                                                   FontWeight_.Fonts_T,
                          //                                               // fontFamily: Font_.Fonts_T,
                          //                                             ),
                          //                                           ),
                          //                                           Text(
                          //                                             //   'พื้นที่ : ${teNantModels.first.area_c} ( ${teNantModels.first.area})',
                          //                                             teNantModels[count].ln_c ==
                          //                                                     null
                          //                                                 ? 'พื้นที่ :${teNantModels.first.area_c}'
                          //                                                 : 'พื้นที่ : ${teNantModels.first.area_c}',
                          //                                             maxLines:
                          //                                                 2,
                          //                                             style:
                          //                                                 const TextStyle(
                          //                                               fontSize:
                          //                                                   9.0,
                          //                                               fontFamily:
                          //                                                   Font_.Fonts_T,
                          //                                               // color: PeopleChaoScreen_Color.Colors_Text1_,
                          //                                               // fontWeight: FontWeight.bold,
                          //                                               // fontFamily: Font_.Fonts_T,
                          //                                             ),
                          //                                           ),
                          //                                           Text(
                          //                                             'โซน :${teNantModels[count].zn}',
                          //                                             maxLines:
                          //                                                 2,
                          //                                             style:
                          //                                                 const TextStyle(
                          //                                               fontSize:
                          //                                                   9.0,
                          //                                               fontFamily:
                          //                                                   Font_.Fonts_T,
                          //                                             ),
                          //                                           ),
                          //                                         ],
                          //                                       ),
                          //                                     ),
                          //                                   ),
                          //                                 ],
                          //                               ),
                          //                             ],
                          //                           ),
                          //                         ),
                          //                       ),
                          //                       Container(
                          //                         height: 157,
                          //                         width: 15,
                          //                         decoration: BoxDecoration(
                          //                           color: Colors.green[300],
                          //                           borderRadius:
                          //                               const BorderRadius.only(
                          //                                   topLeft:
                          //                                       Radius.circular(
                          //                                           0),
                          //                                   topRight:
                          //                                       Radius.circular(
                          //                                           10),
                          //                                   bottomLeft:
                          //                                       Radius.circular(
                          //                                           0),
                          //                                   bottomRight:
                          //                                       Radius.circular(
                          //                                           10)),
                          //                         ),
                          //                         child: Column(
                          //                           mainAxisAlignment:
                          //                               MainAxisAlignment
                          //                                   .center,
                          //                           children: [
                          //                             RotatedBox(
                          //                               quarterTurns: 1,
                          //                               child: Text(
                          //                                 '',
                          //                                 maxLines: 1,
                          //                                 style:
                          //                                     const TextStyle(
                          //                                   fontSize: 9.0,
                          //                                   color: Colors.white,
                          //                                   // fontWeight: FontWeight.bold,
                          //                                   // fontFamily: Font_.Fonts_T,
                          //                                 ),
                          //                               ),
                          //                             ),
                          //                           ],
                          //                         ),
                          //                       ),
                          //                     ],
                          //                   ),
                          //                 ),
                          //                 // Positioned(
                          //                 //     bottom: 10,
                          //                 //     right: 10,
                          //                 //     child: InkWell(
                          //                 //         child: Container(
                          //                 //           width: 30.0,
                          //                 //           height: 30.0,
                          //                 //           decoration: BoxDecoration(
                          //                 //             color: Colors.black.withOpacity(0.5),
                          //                 //             shape: BoxShape.circle,
                          //                 //           ),
                          //                 //           child: const Center(
                          //                 //               child: Icon(
                          //                 //             IconsaxBold.save_add,
                          //                 //             // Icons.download,
                          //                 //             color: Colors.white,
                          //                 //           )),
                          //                 //         ),
                          //                 //         onTap: () async {
                          //                 //           final bytes = await controller.capture();
                          //                 //           setState(() {
                          //                 //             this.bytes = bytes;
                          //                 //           })
                          //                 //           final base64String = base64Encode(bytes!);
                          //                 //           // print(base64String);
                          //                 //           captureAndConvertToBase64(
                          //                 //               base64String, 'Load_QR_$cid_doc', foder);
                          //                 //         }))
                          //               ],
                          //             ),
                          //           ),
                          //         ],
                          //       ),
                          Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 3,
                                  blurRadius: 5,
                                  offset: const Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  // decoration: BoxDecoration(color: Colors.green[300]),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            // Image(image: NetworkImage(),width: 10,height: 10,),
                                            Icon(
                                              Icons.account_circle,
                                              color: Colors.green[300],
                                              size: 40,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              '${teNantModels[count].cname}',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        ),
                                        Text(
                                            'พื้นที่ : ${teNantModels[count].area_c}',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 0.5,
                                  margin: EdgeInsets.symmetric(horizontal: 20),
                                  decoration:
                                      BoxDecoration(color: Colors.black38),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('ตลาด : $renname'),
                                          Text(
                                              'โซน : ${teNantModels[count].zn}')
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              'พื้นที่ (ตร.ม.) : ${teNantModels[count].area}'),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        'ข้อมูผู้เช่า',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Container(
                                        height: 0.5,
                                        margin: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color: Colors.black38),
                                      ),
                                      Row(
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              text: 'ประเภท : ',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 16,
                                                // fontFamily: Font_.Fonts_T,
                                              ),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text:
                                                      '${teNantModels[count].ctype}',
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                    // fontWeight: FontWeight.bold,
                                                    // fontFamily: Font_.Fonts_T,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              text: 'ชื่อร้านค้า : ',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 16,
                                                // fontFamily: Font_.Fonts_T,
                                              ),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text:
                                                      '${teNantModels[count].sname}',
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                    // fontWeight: FontWeight.bold,
                                                    // fontFamily: Font_.Fonts_T,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              text: 'ประเภทร้านค้า : ',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 16,
                                                // fontFamily: Font_.Fonts_T,
                                              ),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text:
                                                      '${teNantModels[count].stype}',
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                    // fontWeight: FontWeight.bold,
                                                    // fontFamily: Font_.Fonts_T,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              text: 'ชื่อผู้เช่า/บริษัท : ',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 16,
                                                // fontFamily: Font_.Fonts_T,
                                              ),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text:
                                                      '${teNantModels[count].sname}',
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                    // fontWeight: FontWeight.bold,
                                                    // fontFamily: Font_.Fonts_T,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              text: 'ชื่อบุคคลติดต่อ : ',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 16,
                                                // fontFamily: Font_.Fonts_T,
                                              ),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text:
                                                      '${teNantModels[count].cname}',
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                    // fontWeight: FontWeight.bold,
                                                    // fontFamily: Font_.Fonts_T,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              text: 'ที่อยู่ : ',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 16,
                                                // fontFamily: Font_.Fonts_T,
                                              ),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text:
                                                      '${teNantModels[count].addr}',
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                    // fontWeight: FontWeight.bold,
                                                    // fontFamily: Font_.Fonts_T,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              text: 'โทร : ',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 16,
                                                // fontFamily: Font_.Fonts_T,
                                              ),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text:
                                                      '${teNantModels[count].tel}',
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                    // fontWeight: FontWeight.bold,
                                                    // fontFamily: Font_.Fonts_T,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              text: 'อีเมล : ',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 16,
                                                // fontFamily: Font_.Fonts_T,
                                              ),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text:
                                                      '${teNantModels[count].email}',
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                    // fontWeight: FontWeight.bold,
                                                    // fontFamily: Font_.Fonts_T,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              text: 'ID / TEX ID : ',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 16,
                                                // fontFamily: Font_.Fonts_T,
                                              ),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text:
                                                      '${teNantModels[count].tax}',
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                    // fontWeight: FontWeight.bold,
                                                    // fontFamily: Font_.Fonts_T,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              text: 'เลขที่อ้างอิง : ',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 16,
                                                // fontFamily: Font_.Fonts_T,
                                              ),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text:
                                                      '${teNantModels[count].wnote == '' ? '-' : teNantModels[count].wnote}',
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                    // fontWeight: FontWeight.bold,
                                                    // fontFamily: Font_.Fonts_T,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        'พื้นที่เช่า',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Container(
                                        height: 0.5,
                                        margin: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color: Colors.black38),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              text: 'รหัสพื้นที่เช่า : ',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 16,
                                                // fontFamily: Font_.Fonts_T,
                                              ),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text:
                                                      '${teNantModels[count].ln == null ? '-' : teNantModels[count].ln}',
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                    // fontWeight: FontWeight.bold,
                                                    // fontFamily: Font_.Fonts_T,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          RichText(
                                            text: TextSpan(
                                              text: 'โซนพื้นที่เช่า : ',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 16,
                                                // fontFamily: Font_.Fonts_T,
                                              ),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text:
                                                      '${teNantModels[count].zn}',
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                    // fontWeight: FontWeight.bold,
                                                    // fontFamily: Font_.Fonts_T,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              text:
                                                  'รวมพื้นที่เช่า (ตร. ม.) : ',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 16,
                                                // fontFamily: Font_.Fonts_T,
                                              ),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text:
                                                      '${teNantModels[count].area}',
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                    // fontWeight: FontWeight.bold,
                                                    // fontFamily: Font_.Fonts_T,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          RichText(
                                            text: TextSpan(
                                              text: 'จำนวนพื้นที่ : ',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 16,
                                                // fontFamily: Font_.Fonts_T,
                                              ),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text:
                                                      '${teNantModels[count].qty}',
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                    // fontWeight: FontWeight.bold,
                                                    // fontFamily: Font_.Fonts_T,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        'ข้อมูลสัญญา/เสนอราคา',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Container(
                                        height: 0.5,
                                        margin: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color: Colors.black38),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              text: 'เริ่ม : ',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 16,
                                                // fontFamily: Font_.Fonts_T,
                                              ),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text:
                                                      '${teNantModels[count].sdate}',
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                    // fontWeight: FontWeight.bold,
                                                    // fontFamily: Font_.Fonts_T,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          RichText(
                                            text: TextSpan(
                                              text: 'ถึง : ',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 16,
                                                // fontFamily: Font_.Fonts_T,
                                              ),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text:
                                                      '${teNantModels[count].ldate}',
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                    // fontWeight: FontWeight.bold,
                                                    // fontFamily: Font_.Fonts_T,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: RichText(
                                          text: TextSpan(
                                            text: 'อายุสัญญา : ',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 16,
                                              // fontFamily: Font_.Fonts_T,
                                            ),
                                            children: <TextSpan>[
                                              TextSpan(
                                                text:
                                                    '${teNantModels[count].period} ล็อก/ห้อง',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  // fontWeight: FontWeight.bold,
                                                  // fontFamily: Font_.Fonts_T,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text('สัญญาเช่า (pdf)'),
                                                  ]),
                                            ),
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  InkWell(
                                                    onTap: () async {
                                                      // setState(() {
                                                      //   showdialog_Coming();
                                                      //   // showdialog_pdf();
                                                      // });
                                                      List newValuePDFimg = [];
                                                      for (int index = 0;
                                                          index < 1;
                                                          index++) {
                                                        if (renTalModels[0]
                                                                .imglogo!
                                                                .trim() ==
                                                            '') {
                                                          // newValuePDFimg.add(
                                                          //     'https://png.pngtree.com/png-vector/20190820/ourmid/pngtree-no-image-vector-illustration-isolated-png-image_1694547.jpg');
                                                        } else {
                                                          newValuePDFimg.add(
                                                              '${MyConstant().domain_chao}/files/$foder/logo/${renTalModels[0].imglogo!.trim()}');
                                                        }
                                                      }
                                                      SharedPreferences
                                                          preferences =
                                                          await SharedPreferences
                                                              .getInstance();
                                                      var renTal_name =
                                                          preferences.getString(
                                                              'renTalName');
                                                      var ciddoc = preferences
                                                          .getString('usercid');
                                                      var qutser = preferences
                                                          .getString('qutser');
                                                      Pdfgen_RentalInforma
                                                          .exportPDF_RentalInforma(
                                                        context,
                                                        qutser,
                                                        ciddoc,
                                                        _verticalGroupValue,
                                                        Form_nameshop.text,
                                                        Form_typeshop.text,
                                                        Form_bussshop.text,
                                                        Form_bussscontact.text,
                                                        Form_address.text,
                                                        Form_tel.text,
                                                        Form_email.text,
                                                        Form_tax.text,
                                                        Form_ln.text,
                                                        Form_zn.text,
                                                        Form_area.text,
                                                        Form_qty.text,
                                                        Form_sdate.text,
                                                        Form_ldate.text,
                                                        Form_period.text,
                                                        Form_rtname.text,
                                                        Form_cdate.text,
                                                        quotxSelectModels,
                                                        _TransModels,
                                                        '$renTal_name',
                                                        ' ${renTalModels[0].bill_addr}',
                                                        ' ${renTalModels[0].bill_email}',
                                                        ' ${renTalModels[0].bill_tel}',
                                                        ' ${renTalModels[0].bill_tax}',
                                                        ' ${renTalModels[0].bill_name}',
                                                        newValuePDFimg,
                                                      );
                                                    },
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      padding:
                                                          EdgeInsets.all(4),
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        color: Color.fromRGBO(
                                                            196, 188, 133, 1),
                                                        // border: Border.all(width: 1)
                                                      ),
                                                      child: const Text(
                                                        "เรียกดู pdf",
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontFamily:
                                                              Font_.Fonts_T,
                                                          fontSize: 15,
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
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text('รายละเอียดค่าบริการ'),
                                                  ]),
                                            ),
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        if (select_page == 1) {
                                                          select_page = 0;
                                                        } else {
                                                          select_page = 1;
                                                          _scrollController.animateTo(
                                                              _scrollController
                                                                      .offset +
                                                                  450,
                                                              curve:
                                                                  Curves.linear,
                                                              duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          500));
                                                        }
                                                        // showdialog_Detail();
                                                      });
                                                    },
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      padding:
                                                          EdgeInsets.all(4),
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        color: Color.fromRGBO(
                                                            196, 188, 133, 1),
                                                        // border: Border.all(width: 1)
                                                      ),
                                                      child: Text(
                                                        select_page == 1
                                                            ? "แสดงน้อยลง"
                                                            : "เรียกดู",
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 15,
                                                          fontFamily:
                                                              Font_.Fonts_T,
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
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text('ตารางสรุปค่าบริการ'),
                                                  ]),
                                            ),
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        if (select_page == 2) {
                                                          select_page = 0;
                                                        } else {
                                                          select_page = 2;
                                                          _scrollController.animateTo(
                                                              _scrollController
                                                                      .offset +
                                                                  450,
                                                              curve:
                                                                  Curves.linear,
                                                              duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          500));
                                                        }
                                                        // showdialog_Detail();
                                                      });
                                                    },
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      padding:
                                                          EdgeInsets.all(4),
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        color: Color.fromRGBO(
                                                            196, 188, 133, 1),
                                                        // border: Border.all(width: 1)
                                                      ),
                                                      child: Text(
                                                        select_page == 2
                                                            ? "แสดงน้อยลง"
                                                            : "เรียกดู",
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 15,
                                                          fontFamily:
                                                              Font_.Fonts_T,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text('รูปภาพ'),
                                                  ]),
                                            ),
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        if (select_page == 3) {
                                                          select_page = 0;
                                                        } else {
                                                          select_page = 3;
                                                          _scrollController.animateTo(
                                                              _scrollController
                                                                      .offset +
                                                                  450,
                                                              curve:
                                                                  Curves.linear,
                                                              duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          500));
                                                        }
                                                        // showdialog_Detail();
                                                      });
                                                    },
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      padding:
                                                          EdgeInsets.all(4),
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        color: Color.fromRGBO(
                                                            196, 188, 133, 1),
                                                        // border: Border.all(width: 1)
                                                      ),
                                                      child: Text(
                                                        select_page == 3
                                                            ? "แสดงน้อยลง"
                                                            : "เรียกดู",
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 15,
                                                          fontFamily:
                                                              Font_.Fonts_T,
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
                                      SizedBox(
                                        height: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]),
                ),
              ),
              if (select_page == 0) SizedBox(),
              if (select_page == 1)
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.35,
                  color: Colors.white,
                  padding: EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 184, 198, 133),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(0),
                              bottomLeft: Radius.circular(0),
                              bottomRight: Radius.circular(0),
                            ),
                            // border: Border.all(
                            //     color: Colors.grey, width: 1),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'รายละเอียดค่าบริการ', //numinvoice
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: FontWeight_.Fonts_T,

                                  //fontSize: 10.0
                                  //fontSize: 10.0
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 201, 196, 186),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(0),
                                  topRight: Radius.circular(0),
                                  bottomLeft: Radius.circular(0),
                                  bottomRight: Radius.circular(0)),
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    'งวด',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: FontWeight_.Fonts_T,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    'รายการ/วันที่',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: FontWeight_.Fonts_T,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    'ยอด/งวด',
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: FontWeight_.Fonts_T,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    'ยอด',
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: FontWeight_.Fonts_T,
                                    ),
                                  ),
                                ),
                              ],
                            )),
                        quotxSelectModels.isEmpty
                            ? SizedBox()
                            : ListView.builder(
                                // itemExtent: 50,
                                physics:
                                    const AlwaysScrollableScrollPhysics(), //NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: quotxSelectModels.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Material(
                                    color: Colors.white,
                                    child: Column(
                                      children: [
                                        quotxSelectModels[index].etype == 'F'
                                            ? SizedBox()
                                            : ListTile(
                                                onTap: () {},
                                                title: SizedBox(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Expanded(
                                                        flex: 1,
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Text(
                                                                    // maxFontSize: 15,
                                                                    '${quotxSelectModels[index].unit}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .start,
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Text(
                                                                    // maxFontSize: 15,
                                                                    '${quotxSelectModels[index].term} (งวด)',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .start,
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 1,
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Text(
                                                                    // maxFontSize: 15,
                                                                    "${quotxSelectModels[index].expname}",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .start,
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 1,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: SizedBox(
                                                            child: Text(
                                                              '${nFormat.format(double.parse(quotxSelectModels[index].total!))}',
                                                              textAlign:
                                                                  TextAlign.end,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 12,
                                                                fontFamily: Font_
                                                                    .Fonts_T,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 1,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: SizedBox(
                                                            child: Text(
                                                              '${nFormat.format(int.parse(quotxSelectModels[index].term!) * double.parse(quotxSelectModels[index].total!))}',
                                                              textAlign:
                                                                  TextAlign.end,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 12,
                                                                fontFamily: Font_
                                                                    .Fonts_T,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )),
                                        const Divider(
                                          color: Colors.black12,
                                          height: 2.0,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ),
              if (select_page == 2)
                Container(
                  // width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.50,
                  color: Colors.white,
                  padding: EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 184, 198, 133),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(0),
                              topRight: Radius.circular(0),
                              bottomLeft: Radius.circular(0),
                              bottomRight: Radius.circular(0),
                            ),
                            // border: Border.all(
                            //     color: Colors.grey, width: 1),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'รายละเอียดค่าบริการ', //numinvoice
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  // fontFamily: FontWeight_.Fonts_T,

                                  //fontSize: 10.0
                                  //fontSize: 10.0
                                ),
                              ),
                            ],
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: 1000,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Container(
                                      // width: 1000,
                                      decoration: const BoxDecoration(
                                        color:
                                            Color.fromARGB(255, 201, 196, 186),
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(0),
                                            topRight: Radius.circular(0),
                                            bottomLeft: Radius.circular(0),
                                            bottomRight: Radius.circular(0)),
                                      ),
                                      padding: const EdgeInsets.all(8.0),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              'วันที่',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                // fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              'ประเภทค่าบริการ',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                // fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              'VAT',
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                // fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              'VAT(%)',
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                // fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              'ประเภทค่าบริการ\nVAT(฿)',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                // fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              '',
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                // fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              'WHT(%)',
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                // fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              'WHT(฿)',
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                // fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              'ยอดสุทธิ',
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                // fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: SizedBox(
                                      width: 1000,
                                      child: ListView.builder(
                                        // itemExtent: 50,
                                        physics:
                                            const AlwaysScrollableScrollPhysics(), //NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: _TransModels.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return Material(
                                            color: Colors.white,
                                            child: Column(
                                              children: [
                                                ListTile(
                                                    onTap: () {},
                                                    title: SizedBox(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Expanded(
                                                            flex: 1,
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          Text(
                                                                        // maxFontSize: 15,
                                                                        '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${_TransModels[index].duedate!} 00:00:00'))}',
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        style: const TextStyle(
                                                                            // fontSize: 14,
                                                                            // fontFamily: Font_.Fonts_T,
                                                                            ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                // Row(
                                                                //   children: [
                                                                //     Expanded(
                                                                //       child: Text(
                                                                //         // maxFontSize: 15,
                                                                //         '${_TransModels[index].name!}',
                                                                //         textAlign: TextAlign.start,
                                                                //         style: const TextStyle(
                                                                //             // fontSize: 14,
                                                                //             // fontFamily: Font_.Fonts_T,
                                                                //             ),
                                                                //       ),
                                                                //     ),
                                                                //   ],
                                                                // ),
                                                              ],
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          Text(
                                                                        // maxFontSize: 15,
                                                                        "${_TransModels[index].name!}",
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        style: const TextStyle(
                                                                            // fontSize: 14,
                                                                            // fontFamily: Font_.Fonts_T,
                                                                            ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: SizedBox(
                                                                child: Text(
                                                                  '${_TransModels[index].vtype!}',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .end,
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    // fontFamily:
                                                                    //     Font_.Fonts_T,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: SizedBox(
                                                                child: Text(
                                                                  '${_TransModels[index].nvat!} %',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .end,
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    // fontFamily:
                                                                    //     Font_.Fonts_T,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: SizedBox(
                                                                child: Text(
                                                                  '${_TransModels[index].vat!}',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .end,
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    // fontFamily:
                                                                    //     Font_.Fonts_T,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: SizedBox(
                                                                child: Text(
                                                                  '${_TransModels[index].pvat!}',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .end,
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    // fontFamily:
                                                                    //     Font_.Fonts_T,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: SizedBox(
                                                                child: Text(
                                                                  '${nFormat.format(double.parse(_TransModels[index].nwht!))}',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .end,
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    // fontFamily:
                                                                    //     Font_.Fonts_T,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: SizedBox(
                                                                child: Text(
                                                                  '${nFormat.format(double.parse(_TransModels[index].wht!))}',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .end,
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    // fontFamily:
                                                                    //     Font_.Fonts_T,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: SizedBox(
                                                                child: Text(
                                                                  '${nFormat.format(double.parse(_TransModels[index].total!))}',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .end,
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    // fontFamily:
                                                                    //     Font_.Fonts_T,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )),
                                                const Divider(
                                                  color: Colors.black12,
                                                  height: 2.0,
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (select_page == 3)
                Container(
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                  child: ScrollConfiguration(
                    behavior:
                        ScrollConfiguration.of(context).copyWith(dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                    }),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Column(children: [
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            "รูปผู้เช่า",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontFamily: Font_.Fonts_T,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: 300, height: 150,
                              // height: 135,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 3,
                                    blurRadius: 5,
                                    offset: const Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ],
                                // image: const DecorationImage(
                                //   image: AssetImage("pngegg2.png"),
                                //   fit: BoxFit.cover,
                                // ),
                              ),
                              padding: const EdgeInsets.all(4.0),
                              child: (pic_tenant == null ||
                                      pic_tenant.toString() == '')
                                  ? Icon(
                                      Icons.image_not_supported,
                                      size: 30,
                                    )
                                  : InkWell(
                                      child: Image.network(
                                        'https://chaoperties.com/chao_perty/files/$foder/contract/$pic_tenant',
                                        fit: BoxFit.cover,
                                      ),
                                      onTap: () {
                                        // setState(() {
                                        //   fiew =
                                        //       'pic_tenant';
                                        // });
                                        // uploadImage();},
                                      },
                                    ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "รูปร้านค้า",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontFamily: Font_.Fonts_T,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: 300, height: 150,
                              // height: 135,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 3,
                                    blurRadius: 5,
                                    offset: const Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ],
                                // image: const DecorationImage(
                                //   image: AssetImage("pngegg2.png"),
                                //   fit: BoxFit.cover,
                                // ),
                              ),
                              padding: const EdgeInsets.all(4.0),
                              child: (pic_tenant == null ||
                                      pic_tenant.toString() == '')
                                  ? Icon(
                                      Icons.image_not_supported,
                                      size: 30,
                                    )
                                  : InkWell(
                                      child: Image.network(
                                        'https://chaoperties.com/chao_perty/files/$foder/contract/$pic_shop',
                                        fit: BoxFit.cover,
                                      ),
                                      onTap: () {
                                        // setState(() {
                                        //   fiew =
                                        //       'pic_shop';
                                        // });
                                        // uploadImage();},
                                      }),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "รูปแผนฝัง",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontFamily: Font_.Fonts_T,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: 300, height: 150,
                              // height: 135,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 3,
                                    blurRadius: 5,
                                    offset: const Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ],
                                // image: const DecorationImage(
                                //   image: AssetImage("pngegg2.png"),
                                //   fit: BoxFit.cover,
                                // ),
                              ),
                              padding: const EdgeInsets.all(4.0),
                              child: (pic_tenant == null ||
                                      pic_tenant.toString() == '')
                                  ? Icon(
                                      Icons.image_not_supported,
                                      size: 30,
                                    )
                                  : InkWell(
                                      child: Image.network(
                                        'https://chaoperties.com/chao_perty/files/$foder/contract/$pic_plan',
                                        fit: BoxFit.cover,
                                      ),
                                      onTap: () {
                                        // setState(() {
                                        //   fiew =
                                        //       'pic_plan';
                                        // });
                                        // uploadImage();
                                      },
                                    ),
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ),
                ),
              SizedBox(
                height: 100,
              ),
            ],
          ),
        ));
  }
}

// class boxinfo extends StatelessWidget {
//   const boxinfo({super.key, required this.title, required this.subtitle});
//   final String title;
//   final String subtitle;
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: TextStyle(
//             color: Colors.grey,
//             fontSize: 16,
//             // fontFamily: Font_.Fonts_T,
//           ),
//         ),
//         Text(
//           subtitle,
//           style: const TextStyle(
//             color: Colors.black,
//             fontSize: 16,
//             // fontWeight: FontWeight.bold,
//             // fontFamily: Font_.Fonts_T,
//           ),
//         ),
//       ],
//     );
//   }
// }

class PreviewScreenRentalInforma extends StatelessWidget {
  final pw.Document doc;
  final netImage_;

  const PreviewScreenRentalInforma(
      {Key? key, required this.doc, this.netImage_})
      : super(key: key);

  static const customSwatch = MaterialColor(
    0xFF8DB95A,
    <int, Color>{
      50: Color(0xFFC2FD7F),
      100: Color(0xFFB6EE77),
      200: Color(0xFFB2E875),
      300: Color(0xFFACDF71),
      400: Color(0xFFA7DA6E),
      500: Color(0xFFA1D16A),
      600: Color(0xFF94BF62),
      700: Color(0xFF90B961),
      800: Color(0xFF85AB5A),
      900: Color(0xFF7A9B54),
    },
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: customSwatch,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          // backgroundColor: Color.fromARGB(255, 141, 185, 90),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_outlined,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          title: const Text(
            "ข้อมูลผู้เช่า",
            style: TextStyle(
              color: Colors.white,
              fontFamily: Font_.Fonts_T,
            ),
          ),
        ),
        body: PdfPreview(
          build: (format) => doc.save(),
          allowSharing: true,
          allowPrinting: true, canDebug: false,
          canChangeOrientation: false, canChangePageFormat: false,
          maxPageWidth: MediaQuery.of(context).size.width * 0.6,
          // scrollViewDecoration:,
          initialPageFormat: PdfPageFormat.a4,
          pdfFileName: "ข้อมูลผู้เช่า.pdf",
        ),
      ),
    );
  }
}
