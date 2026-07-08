import 'package:flutter/material.dart';

import '../../../color.dart';
import '../fitness_app_home_screen.dart';
import '../fitness_app_theme.dart';

class TitleView extends StatelessWidget {
  final String titleTxt;
  final String subTxt;
  final String imagePath;
  final int? badgeCount;
  final AnimationController? animationController;
  final Animation<double>? animation;

  const TitleView(
      {Key? key,
      this.titleTxt = "",
      this.subTxt = "",
      this.imagePath = "",
      this.badgeCount,
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
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - animation!.value), 0.0),
            child: Container(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 24, right: 24, top: 4, bottom: 4),
                child: Row(
                  children: <Widget>[
                    if (imagePath != "") ...[
                      Image.asset(
                        imagePath,
                        height: 26,
                        width: 26,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 10),
                    ],
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: FitnessAppTheme.nearlyDarkBlue,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            titleTxt,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontFamily: Font_.Fonts_T,
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                              letterSpacing: 0.3,
                              color: FitnessAppTheme.darkerText,
                            ),
                          ),
                          if (badgeCount != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: FitnessAppTheme.nearlyDarkBlue
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$badgeCount',
                                style: TextStyle(
                                  fontFamily: Font_.Fonts_T,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: FitnessAppTheme.nearlyDarkBlue,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    subTxt == 'X'
                        ? const SizedBox()
                        : Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              highlightColor: Colors.transparent,
                              onTap: () {
                                if (subTxt == 'Details' ||
                                    subTxt == 'รายละเอียด') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const FitnessAppHomeScreen(
                                              pageroot: 'INFO'),
                                    ),
                                  );
                                } else if (subTxt == 'Rental contract All' ||
                                    subTxt == 'สัญญาทั้งหมด') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const FitnessAppHomeScreen(
                                              pageroot: 'CONTACT'),
                                    ),
                                  );
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 4),
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      subTxt,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontFamily: Font_.Fonts_T,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        color: FitnessAppTheme.nearlyDarkBlue,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: FitnessAppTheme.nearlyDarkBlue,
                                      size: 14,
                                    ),
                                  ],
                                ),
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
