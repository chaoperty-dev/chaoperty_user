// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../color.dart';
// import 'package:crypto/crypto.dart' as crypto;
// import 'dart:convert';

// import 'package:chaopert_user/color.dart';
// import 'package:crypto/crypto.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/src/widgets/framework.dart';
// import 'package:flutter/src/widgets/placeholder.dart';
// import 'dart:convert';

// import 'package:auto_size_text/auto_size_text.dart';

// import 'package:flutter/gestures.dart';

// import 'package:flutter/services.dart';
// import 'package:flutter/src/widgets/container.dart';
// import 'package:http/http.dart' as http;
// import 'package:crypto/crypto.dart' as crypto;
// import 'package:loading_indicator/loading_indicator.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../Constant/Myconstant.dart';
// import '../Model/GetCustomer_Model.dart';
// import '../Model/GetRenTal_Model.dart';
// import 'select_screen.dart';

// class EditAccountScreen extends StatefulWidget {
//   final Cust_no_;

//   const EditAccountScreen({
//     super.key,
//     this.Cust_no_,
//   });

//   @override
//   State<EditAccountScreen> createState() => EditAccountScreenState();
// }

// class EditAccountScreenState extends State<EditAccountScreen> {
//   @override
//   void initState() {
//     super.initState();
//     checkPreferance();

//     // sum_disamtx.text = '0.00';
//   }

//   final _formKey = GlobalKey<FormState>();
//   final Form_User = TextEditingController();
//   final Form_UserPass = TextEditingController();

//   Future<Null> checkPreferance() async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     setState(() {
//       Form_User.text = preferences.getString('UsernameUSer')!;
//     });
//   }

//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 30),
//       child: Container(
//           width: 400,
//           height: 250,
//           alignment: Alignment.center,
//           decoration: BoxDecoration(
//             boxShadow: [
//               BoxShadow(
//                   color: Colors.grey.withOpacity(0.5),
//                   spreadRadius: 2,
//                   blurRadius: 5,
//                   offset: const Offset(0, 0))
//             ],
//             borderRadius: BorderRadius.circular(30),
//             color: const Color.fromARGB(255, 219, 221, 218),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(30),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     ListTile(
//                       leading: const SizedBox(
//                           width: 80,
//                           child: Text(
//                             "username :",
//                             style: TextStyle(
//                                 fontSize: 15, fontWeight: FontWeight.bold),
//                           )),
//                       title: SizedBox(
//                         height: 50,
//                         width: 60,
//                         child: TextFormField(
//                             controller: Form_User,
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'ใส่ข้อมูลให้ครบถ้วน ';
//                               }
//                               // if (int.parse(value.toString()) < 13) {
//                               //   return '< 13';
//                               // }
//                               return null;
//                             },
//                             decoration: const InputDecoration(
//                                 filled: true,
//                                 fillColor: Colors.white,
//                                 contentPadding:
//                                     EdgeInsets.only(left: 8, right: 8),
//                                 border: OutlineInputBorder(
//                                     borderSide: BorderSide.none,
//                                     borderRadius: BorderRadius.zero))),
//                       ),
//                     ),
//                     ListTile(
//                       leading: const SizedBox(
//                           width: 80,
//                           child: Text(
//                             "password :",
//                             style: TextStyle(
//                                 fontSize: 15, fontWeight: FontWeight.bold),
//                           )),
//                       title: SizedBox(
//                         height: 50,
//                         width: 60,
//                         child: TextFormField(
//                             controller: Form_UserPass,
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'ใส่ข้อมูลให้ครบถ้วน ';
//                               }
//                               // if (int.parse(value.toString()) < 13) {
//                               //   return '< 13';
//                               // }
//                               return null;
//                             },
//                             decoration: const InputDecoration(
//                                 filled: true,
//                                 fillColor: Colors.white,
//                                 contentPadding:
//                                     EdgeInsets.only(left: 8, right: 8),
//                                 border: OutlineInputBorder(
//                                     borderSide: BorderSide.none,
//                                     borderRadius: BorderRadius.zero))),
//                       ),
//                     ),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     Align(
//                       alignment: Alignment.bottomCenter,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Container(
//                                   width: 80,
//                                   decoration: const BoxDecoration(
//                                     color: Colors.green,
//                                     borderRadius: BorderRadius.only(
//                                         topLeft: Radius.circular(10),
//                                         topRight: Radius.circular(10),
//                                         bottomLeft: Radius.circular(10),
//                                         bottomRight: Radius.circular(10)),
//                                   ),
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: TextButton(
//                                     onPressed: () async {
//                                       SharedPreferences preferences =
//                                           await SharedPreferences.getInstance();
//                                       String? ren =
//                                           preferences.getString('renTalSer');
//                                       String? ser_user =
//                                           preferences.getString('ser');
//                                       var ciddoc_ =
//                                           preferences.getString('usercid');
//                                       var qutser_ =
//                                           preferences.getString('qutser');

//                                       String Cid_ = '${ciddoc_}';
//                                       print(
//                                           'User : ${Form_User.text}  /// ${Form_UserPass.text}');
//                                       print('Cust_no_ : ${widget.Cust_no_}');

//                                       String password = md5
//                                           .convert(
//                                               utf8.encode(Form_UserPass.text))
//                                           .toString();
//                                       print('password Md5 $password');
//                                       if (_formKey.currentState!.validate()) {}
//                                       //   String url =
//                                       //       '${MyConstant().domain}/UpC_custno_cid_Informa.php?isAdd=true&cust_no=$Cust_no_&user_U=${Form_User.text}&pass_U=$password&ren=$ren';
//                                       //   try {
//                                       //     var response = await http.get(Uri.parse(url));

//                                       //     var result = json.decode(response.body);

//                                       //     setState(() {
//                                       //       Form_UserPass.clear();
//                                       //       Form_User.clear();
//                                       //     });
//                                       //     Navigator.pop(context, 'OK');
//                                       //     ScaffoldMessenger.of(context).showSnackBar(
//                                       //         const SnackBar(
//                                       //             content:
//                                       //                 Text('แก้ไขข้อมูลเสร็จสิ้น !!',
//                                       //                     style: TextStyle(
//                                       //                       color: Colors.black,
//                                       //                     ))));
//                                       //   } catch (e) {
//                                       //     Navigator.pop(context, 'OK');
//                                       //     ScaffoldMessenger.of(context).showSnackBar(
//                                       //       const SnackBar(
//                                       //           content: Text('เกิดข้อผิดพลาด',
//                                       //               style: TextStyle(
//                                       //                 color: Colors.black,
//                                       //               ))),
//                                       //     );
//                                       //   }
//                                       // }
//                                       // Navigator.of(context).pop();
//                                     },
//                                     child: const Text(
//                                       'ยืนยัน',
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Container(
//                                   width: 80,
//                                   decoration: const BoxDecoration(
//                                     color: Colors.redAccent,
//                                     borderRadius: BorderRadius.only(
//                                         topLeft: Radius.circular(10),
//                                         topRight: Radius.circular(10),
//                                         bottomLeft: Radius.circular(10),
//                                         bottomRight: Radius.circular(10)),
//                                   ),
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: TextButton(
//                                     onPressed: () {
//                                       setState(() {
//                                         Form_UserPass.clear();
//                                         Form_User.clear();
//                                       });
//                                       Navigator.pop(context, 'OK');
//                                     },
//                                     child: const Text(
//                                       'ยกเลิก',
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ]),
//             ),
//           )),
//     );

//     //  Scaffold(
//     //     backgroundColor: bgcolor,
//     //     appBar: AppBar(
//     //       automaticallyImplyLeading: false,
//     //       elevation: 0,
//     //       title: const Text(
//     //         'แก้ไขข้อมูลบัญชี',
//     //         style: TextStyle(
//     //             color: Color.fromRGBO(100, 108, 110, 1),
//     //             fontWeight: FontWeight.bold),
//     //       ),
//     //       backgroundColor: bgcolor,
//     //     ),
//     //     body: Column(
//     //       children: [
//     //         const Padding(
//     //           padding: EdgeInsets.only(bottom: 8.0),
//     //           child: ListTile(
//     //             title: Text(
//     //               "คุณ มาลี มีนา",
//     //               style: TextStyle(
//     //                 fontSize: 30,
//     //                 color: Colors.black,
//     //               ),
//     //             ),
//     //             leading: Icon(
//     //               Icons.account_circle,
//     //               size: 60,
//     //             ),
//     //           ),
//     //         ),

//     //       ],
//     //     ));
//   }
// }
