import 'package:flutter/material.dart';
import '../color.dart';

class RentalAreaInfoScreen extends StatefulWidget {
  const RentalAreaInfoScreen({super.key});

  @override
  State<RentalAreaInfoScreen> createState() => RentalAreaInfoScreenState();
}

class RentalAreaInfoScreenState extends State<RentalAreaInfoScreen> {
  final items = ["SHOP 101", "SHOP 102", "SHOP 103", "SHOP 104"];
  String? value;
  bool? isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: bgcolor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          title: Text(
            'ข้อมูลพื้นที่เช่า',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: bgcolor,
        ),
        body: Column(
          children: [
            SizedBox(
              height: 150,
              child: Image.asset("assets/image/HaxHouse.png"),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Container(
                alignment: Alignment.center,
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(
                              width: 170,
                              child: Text(
                                "รหัสพื้นที่ ",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black, width: 1)),
                                height: 30,
                                child: TextFormField(
                                    enabled: false,
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                        hintText: "SHOP 101",
                                        hintStyle: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                        filled: true,
                                        fillColor:
                                            Color.fromARGB(255, 201, 196, 186),
                                        contentPadding:
                                            EdgeInsets.only(left: 8, right: 8),
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.transparent,
                                                width: 1),
                                            borderRadius: BorderRadius.zero))),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(
                              width: 170,
                              child: Text(
                                " พื้นที่ (ตร.ม.) ",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black, width: 1)),
                                height: 30,
                                child: TextFormField(
                                    enabled: false,
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                        hintText: "140",
                                        hintStyle: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                        filled: true,
                                        fillColor:
                                            Color.fromARGB(255, 201, 196, 186),
                                        contentPadding:
                                            EdgeInsets.only(left: 8, right: 8),
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide(width: 1),
                                            borderRadius: BorderRadius.zero))),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 170,
                              child: Text(
                                "ค่าเช่าต่อเดือน (บาท) ",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black, width: 1)),
                                height: 30,
                                width: 100,
                                child: TextFormField(
                                    enabled: false,
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                        hintText: "4500",
                                        hintStyle: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                        filled: true,
                                        fillColor: Colors.white,
                                        contentPadding:
                                            EdgeInsets.only(left: 8, right: 8),
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.transparent,
                                                width: 1),
                                            borderRadius: BorderRadius.zero))),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 170,
                              child: Text(
                                "ค่าส่วนกลาง (บาท) ",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black, width: 1)),
                                height: 30,
                                width: 100,
                                child: TextFormField(
                                    enabled: false,
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                        hintText: "2500",
                                        hintStyle: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                        filled: true,
                                        fillColor: Colors.white,
                                        contentPadding:
                                            EdgeInsets.only(left: 8, right: 8),
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.transparent,
                                                width: 1),
                                            borderRadius: BorderRadius.zero))),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 190,
                              child: Text(
                                "ค่าน้ำไฟฟ้า:เหมาเดือนละ (บาท)",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black, width: 1)),
                                height: 30,
                                width: 100,
                                child: TextFormField(
                                    enabled: false,
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                        hintText: "2000",
                                        hintStyle: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                        filled: true,
                                        fillColor: Colors.white,
                                        contentPadding:
                                            EdgeInsets.only(left: 8, right: 8),
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.zero))),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 150,
                              child: Text(
                                "ระยะเวลาเช่า (เดือน)",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 30,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1,
                                      style: BorderStyle.solid,
                                      color: Colors.black),
                                  color: Colors.white,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 15),
                                  child: DropdownButton<String>(
                                    hint: const Text(
                                      "12",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                    underline: Container(),
                                    items: items.map(buildMenuIem).toList(),
                                    icon: Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black26,
                                              width: 1,
                                              style: BorderStyle.solid),
                                        ),
                                        child: const Icon(
                                            Icons.arrow_drop_down_sharp)),
                                    value: value,
                                    isExpanded: true,
                                    onChanged: (value) {
                                      setState(() {
                                        this.value = value;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                  )
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 23, right: 23, bottom: 30),
              child: Container(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 120,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        Navigator.of(context, rootNavigator: false).pop();
                      });
                    },
                    style: ButtonStyle(
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.black),
                        backgroundColor: MaterialStateProperty.all<Color>(
                          const Color.fromARGB(255, 168, 170, 169),
                        )),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          "ปิด",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ));
  }

  DropdownMenuItem<String> buildMenuIem(String item) => DropdownMenuItem(
        value: item,
        child: Text(
          item,
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      );
}
