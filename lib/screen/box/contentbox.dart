import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../color.dart';

class ContentBox extends StatelessWidget {
  final padding;
  final alignment;
  final title;
  final color;
  final fontsize;
  final fontWeight;
  final width;
  ContentBox(this.padding, this.width, this.alignment, this.title, this.color,
      this.fontsize, this.fontWeight);

  Widget build(BuildContext context) {
    return Container(
        padding: padding,
        alignment: alignment,
        width: width,
        child: Text(
          title,
          style: TextStyle(
              fontSize: fontsize, color: color, fontWeight: fontWeight),
        ));
  }
}

class ContentBoxBill extends StatelessWidget {
  final title1;
  final title2;

  ContentBoxBill(this.title1, this.title2);
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(title1), Container(child: title2)],
    );
  }
}

class BoxListBill extends StatelessWidget {
  final title;

  BoxListBill(this.title);
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Text(
          title,
        ));
  }
}

class ContentBox1 extends StatelessWidget {
  final title;
  final width;
  ContentBox1(this.title, this.width);
  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        width: width,
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ));
  }
}

class DialogLogin extends StatelessWidget {
  final title;
  DialogLogin(this.title);
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Error"),
      content: Text(title),
      actions: [
        SizedBox(
          width: 110,
          height: 40,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: false).pop();
            },
            style: ButtonStyle(
                shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                backgroundColor: MaterialStateProperty.all<Color>(
                  browncolor,
                )),
            child: const Text(
              "OK",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        )
      ],
    );
  }
}

class Box_payScreen extends StatelessWidget {
  final title;
  final enabled;
  final readonly;
  final title1;
  final controller;
  Box_payScreen(
      this.title, this.enabled, this.readonly, this.title1, this.controller);

  @override
  Widget build(BuildContext context) {
    {
      return Padding(
        padding: const EdgeInsets.all(2.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
                width: 100,
                padding: EdgeInsets.only(right: 8),
                alignment: Alignment.centerRight,
                child: Text(title)),
            Expanded(
              child: SizedBox(
                  height: 30,
                  child: TextFormField(
                      controller: controller,
                      enabled: enabled,
                      readOnly: readonly,
                      decoration: InputDecoration(
                        hintText: title1,
                        contentPadding:
                            const EdgeInsets.only(left: 8, right: 8),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5)),
                      ))),
            )
          ],
        ),
      );
    }
  }
}

class PersonalBox extends StatelessWidget {
  final title;
  final title1;
  final width;
  final color;

  PersonalBox(this.title, this.width, this.title1, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        children: [
          SizedBox(
            width: width,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: FontWeight_.Fonts_T,
              ),
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 30,
              child: TextFormField(
                  enabled: false,
                  readOnly: true,
                  decoration: InputDecoration(
                      hintText: title1,
                      hintStyle: TextStyle(
                        color: Colors.black,
                        fontFamily: Font_.Fonts_T,
                      ),
                      filled: true,
                      fillColor: color,
                      contentPadding: EdgeInsets.only(left: 8, right: 8),
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.transparent, width: 1),
                          borderRadius: BorderRadius.zero))),
            ),
          ),
        ],
      ),
    );
  }
}

class ElevatedButtonBox extends StatelessWidget {
  final width;
  final heigth;
  final onpress;
  final borderRadius;
  final color1;
  final color2;
  final title;
  final style;
  ElevatedButtonBox(this.width, this.heigth, this.onpress, this.borderRadius,
      this.color1, this.color2, this.title, this.style);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: heigth,
      child: ElevatedButton(
          onPressed: onpress,
          style: ButtonStyle(
            shape: MaterialStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder(borderRadius: borderRadius)),
            foregroundColor: MaterialStateProperty.all<Color>(color1),
            backgroundColor: MaterialStateProperty.all<Color>(color2),
          ),
          child: Text(
            title,
            style: style,
          )),
    );
  }
}
