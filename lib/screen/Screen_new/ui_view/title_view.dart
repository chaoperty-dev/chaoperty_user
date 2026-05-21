import 'package:flutter/material.dart';

import '../../../color.dart';
import '../fitness_app_home_screen.dart';
import '../fitness_app_theme.dart';

class TitleView extends StatelessWidget {
  final String titleTxt;
  final String subTxt;
  final String imagePath;
  final AnimationController? animationController;
  final Animation<double>? animation;

  const TitleView(
      {Key? key,
      this.titleTxt = "",
      this.subTxt = "",
      this.imagePath = "",
      this.animationController,
      this.animation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: new Transform(
            transform: new Matrix4.translationValues(
                0.0, 30 * (1.0 - animation!.value), 0.0),
            child: Container(
              child: Padding(
                padding: const EdgeInsets.only(left: 24, right: 24),
                child: Row(
                  children: <Widget>[
                    if (imagePath != "") ...[
                      Image.asset(
                        imagePath,
                        height: 30,
                        width: 30,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        titleTxt,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontFamily: Font_.Fonts_T,
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          letterSpacing: 0.5,
                          color: FitnessAppTheme.lightText,
                        ),
                      ),
                    ),
                    subTxt == 'X'
                        ? SizedBox()
                        : InkWell(
                            highlightColor: Colors.transparent,
                            borderRadius:
                                BorderRadius.all(Radius.circular(4.0)),
                            onTap: () {
                              if (subTxt == 'Details' ||
                                  subTxt == 'รายละเอียด') {
                                MaterialPageRoute route = MaterialPageRoute(
                                  builder: (context) =>
                                      FitnessAppHomeScreen(pageroot: 'INFO'),
                                );
                                Navigator.push(context, route);
                              } else if (subTxt == 'Rental contract All' ||
                                  subTxt == 'สัญญาทั้งหมด') {
                                MaterialPageRoute route = MaterialPageRoute(
                                  builder: (context) =>
                                      FitnessAppHomeScreen(pageroot: 'CONTACT'),
                                );
                                Navigator.push(context, route);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    subTxt,
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontFamily: Font_.Fonts_T,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 16,
                                      letterSpacing: 0.5,
                                      color: FitnessAppTheme.nearlyDarkBlue,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 38,
                                    width: 26,
                                    child: Icon(
                                      Icons.arrow_forward,
                                      color: FitnessAppTheme.darkText,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
