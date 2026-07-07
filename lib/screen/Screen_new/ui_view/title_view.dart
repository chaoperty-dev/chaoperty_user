import 'package:flutter/material.dart';

import '../fitness_app_home_screen.dart';

class TitleView extends StatelessWidget {
  final String titleTxt;
  final String subTxt;
  final String imagePath;
  final AnimationController? animationController;
  final Animation<double>? animation;

  const TitleView({
    Key? key,
    this.titleTxt = "",
    this.subTxt = "",
    this.imagePath = "",
    this.animationController,
    this.animation,
  }) : super(key: key);

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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
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
                    height: 22,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      titleTxt,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontFamily: 'LINESeed2',
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        letterSpacing: 0.2,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  if (subTxt != 'X')
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          if (subTxt == 'Details' || subTxt == 'รายละเอียด') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const FitnessAppHomeScreen(
                                    pageroot: 'INFO'),
                              ),
                            );
                          } else if (subTxt == 'Rental contract All' ||
                              subTxt == 'สัญญาทั้งหมด') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const FitnessAppHomeScreen(
                                    pageroot: 'CONTACT'),
                              ),
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: Row(
                            children: [
                              Text(
                                subTxt,
                                style: const TextStyle(
                                  fontFamily: 'LINESeed2',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Color(0xFF4F46E5),
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Color(0xFF4F46E5),
                                size: 14,
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
        );
      },
    );
  }
}
