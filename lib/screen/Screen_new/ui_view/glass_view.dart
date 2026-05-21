import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

import '../../../color.dart';
import '../../../main.dart';
import '../fitness_app_theme.dart';

class GlassView extends StatelessWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;
  final List<String>? textLists;
  const GlassView(
      {Key? key, this.animationController, this.animation, this.textLists})
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
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      left: 24, right: 24, top: 0, bottom: 24),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: HexColor("#D7E0F9"),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8.0),
                                bottomLeft: Radius.circular(8.0),
                                bottomRight: Radius.circular(8.0),
                                topRight: Radius.circular(8.0)),
                            // boxShadow: <BoxShadow>[
                            //   BoxShadow(
                            //       color: FitnessAppTheme.grey.withOpacity(0.2),
                            //       offset: Offset(1.1, 1.1),
                            //       blurRadius: 10.0),
                            // ],
                          ),
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 68, bottom: 12, right: 16, top: 12),
                                child: SizedBox(
                                  height: 25,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Marquee(
                                          text: '${textLists!.map((e) => e)}',
                                          style: const TextStyle(
                                            fontFamily: Font_.Fonts_T,
                                          ),
                                          scrollAxis: Axis.horizontal,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          blankSpace: 20.0,
                                          velocity: 30.0,
                                          // pauseAfterRound: Duration(seconds: 1),
                                          startPadding: 10.0,
                                          // accelerationDuration: Duration(seconds: 1),
                                          // accelerationCurve: Curves.linear,
                                          // decelerationDuration: Duration(milliseconds: 500),
                                          // decelerationCurve: Curves.easeOut,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                //  Row(
                                //   children: [
                                //     Expanded(
                                //       child: Marquee(
                                //         text: '${textLists!.map((e) => e)}',
                                //         style: const TextStyle(
                                //           fontFamily: Font_.Fonts_T,
                                //         ),
                                //         scrollAxis: Axis.horizontal,
                                //         crossAxisAlignment:
                                //             CrossAxisAlignment.start,
                                //         blankSpace: 20.0,
                                //         velocity: 30.0,
                                //         // pauseAfterRound: Duration(seconds: 1),
                                //         startPadding: 10.0,
                                //         // accelerationDuration: Duration(seconds: 1),
                                //         // accelerationCurve: Curves.linear,
                                //         // decelerationDuration: Duration(milliseconds: 500),
                                //         // decelerationCurve: Curves.easeOut,
                                //       ),
                                //     ),
                                //   ],
                                // ),
                                //     Text(
                                //   'Prepare your stomach for lunch with one or two glass of water',
                                //   textAlign: TextAlign.left,
                                //   style: TextStyle(
                                //     fontFamily: FitnessAppTheme.fontName,
                                //     fontWeight: FontWeight.w500,
                                //     fontSize: 14,
                                //     letterSpacing: 0.0,
                                //     color: FitnessAppTheme.nearlyDarkBlue
                                //         .withOpacity(0.6),
                                //   ),
                                // ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: -12,
                        left: 0,
                        child: SizedBox(
                          width: 80,
                          height: 80,
                          child: Image.asset("assets/fitness_app/glass.png"),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
