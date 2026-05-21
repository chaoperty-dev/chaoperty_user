import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Constant/Myconstant.dart';
import '../Model/GetZone_Model.dart';
import '../color.dart';
import 'package:http/http.dart' as http;

import 'rentalareainfo_screen.dart';

class RentalAreaScreen extends StatefulWidget {
  const RentalAreaScreen({super.key});

  @override
  State<RentalAreaScreen> createState() => RentalAreaScreenState();
}

class RentalAreaScreenState extends State<RentalAreaScreen> {
  List<String> listzone = [];
  int tap = -1;
  String? dropdownValue = " ";

  @override
  void initState() {
    super.initState();
    read_zoneAll();
  }

  var nFormat = NumberFormat("#,##0.00", "en_US");
  List<ZoneModel> zoneModels = [];
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
    var ren = '65';

    String url = '${MyConstant().domain}/GC_zoneAll.php?isAdd=true&ren=$ren';
    // 'https://dzentric.com/chaoperty_user/chao_api_user/GC_zoneAll.php?isAdd=true&ren=65';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      print(result);
      if (result != null) {
        for (var map in result) {
          ZoneModel zoneModel = ZoneModel.fromJson(map);
          setState(() {
            zoneModels.add(zoneModel);
          });
        }

        listzone.add("All");
        zoneModels.forEach((element) {
          listzone.add("${element.zn}");
        });

        dropdownValue = listzone.first;
      }
    } catch (e) {}
  }

  int count = 0;
  @override
  Widget build(BuildContext context) {
    var year = zoneModels[count].data_update;
    int date = int.parse(year![0] + year[1] + year[2] + year[3]);
    int dt = date + 543;
    List<Widget> data = [];
    for (var index = 101; index < 120; index++) {
      data.add(InkWell(
        onTap: () {
          setState(() {
            tap = index;
          });
        },
        child: Container(
          height: 40,
          decoration: BoxDecoration(color: tap == index ? const Color.fromARGB(255, 230, 255, 233) : Colors.white),
          child: Row(
            children: [
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      "Shop ${index}",
                      style: const TextStyle(color: Colors.black),
                    )),
              )),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Container(
                    // color:
                    //     tap ? Color.fromARGB(255, 230, 255, 233) : Colors.white,
                    alignment: Alignment.center,
                    child: const Text(
                      "mini Big C",
                      style: TextStyle(color: Colors.black),
                    )),
              )),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Container(
                  // color:
                  //     tap ? Color.fromARGB(255, 230, 255, 233) : Colors.white,
                  alignment: Alignment.center,
                  child: Visibility(
                    visible: tap == index,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          Navigator.push(context, MaterialPageRoute(builder: (ctx) {
                            return const RentalAreaInfoScreen();
                          }));
                        });
                      },
                      child: const Text(
                        "เรียกดู",
                        style: TextStyle(fontSize: 15, color: Colors.black),
                      ),
                      style: ButtonStyle(
                          shape: MaterialStateProperty.all<OutlinedBorder>(
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                          backgroundColor: MaterialStateProperty.all<Color>(
                            const Color.fromARGB(255, 184, 198, 133),
                          )),
                    ),
                  ),
                ),
              ))
            ],
          ),
        ),
      ));
    }
    return Scaffold(
        backgroundColor: bgcolor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'พื้นที่เช่า',
                style: TextStyle(color: Color.fromRGBO(100, 108, 110, 1), fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 100,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 30,
                      child: Text(
                        "ปี:",
                        style: TextStyle(fontSize: 25, color: Colors.black),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: TextFormField(
                            enabled: false,
                            readOnly: true,
                            decoration: InputDecoration(
                                hintText: "${dt}",
                                hintStyle: TextStyle(color: Colors.black),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.only(left: 8, right: 8),
                                border: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.transparent, width: 1),
                                    borderRadius: BorderRadius.zero))),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          backgroundColor: bgcolor,
        ),
        body: Column(
          children: [
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Text(
                    "โซนพื้นที่ :",
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black26, width: 2),
                          borderRadius: BorderRadius.circular(30)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: DropdownButton<String>(
                          value: dropdownValue,
                          hint: const Text(
                            "ภาพรวม | โซนA | โซนB ",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          underline: Container(),
                          items: listzone.map((e) {
                            return DropdownMenuItem(value: e, child: Text("${e}"));
                          }).toList(),
                          icon: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: Colors.black26, width: 2),
                                  color: Colors.white),
                              width: 50,
                              child: const Icon(Icons.arrow_drop_down_sharp)),
                          iconSize: 40,
                          isExpanded: true,
                          onChanged: (value) {
                            setState(() {
                              dropdownValue = value;
                              count = listzone.indexOf('${dropdownValue}');

                              print("dropdownValue:${dropdownValue} local:${count}");
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 50),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color.fromARGB(255, 156, 152, 145), width: 1),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 0))
                    ],
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                      color: const Color.fromARGB(255, 201, 196, 186),
                                      border: Border.all(color: const Color.fromARGB(255, 156, 152, 145), width: 1)),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    "พื้นที่เช่า",
                                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                  ))),
                          Expanded(
                              child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                      color: const Color.fromARGB(255, 201, 196, 186),
                                      border: Border.all(color: const Color.fromARGB(255, 156, 152, 145), width: 1)),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    "สถานะ",
                                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                  ))),
                          Expanded(
                              child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                      color: const Color.fromARGB(255, 201, 196, 186),
                                      border: Border.all(color: const Color.fromARGB(255, 156, 152, 145), width: 1)),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    "รายละเอียด",
                                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                  )))
                        ],
                      ),
                      Expanded(
                          child: ListView(
                        children: data,
                      ))
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
