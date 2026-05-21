import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../fitness_app_theme.dart';
import '../../../Model/GetCustomer_Model.dart';

class RunningViewPay extends StatelessWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;

  final List<CustomerModel>? customerModel;
  final String? cuslang;
  const RunningViewPay({
    Key? key,
    this.animationController,
    this.animation,
    this.customerModel,
    this.cuslang,
  }) : super(key: key);

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
                // Padding(
                //   padding: const EdgeInsets.only(
                //       left: 24, right: 24, top: 0, bottom: 0),
                //   child: Stack(
                //     clipBehavior: Clip.none,
                //     children: <Widget>[
                //       Padding(
                //         padding: const EdgeInsets.only(top: 16, bottom: 16),
                //         child: Container(
                //           decoration: BoxDecoration(
                //             color: FitnessAppTheme.white,
                //             borderRadius: BorderRadius.only(
                //                 topLeft: Radius.circular(8.0),
                //                 bottomLeft: Radius.circular(8.0),
                //                 bottomRight: Radius.circular(8.0),
                //                 topRight: Radius.circular(8.0)),
                //             boxShadow: <BoxShadow>[
                //               BoxShadow(
                //                   color: FitnessAppTheme.grey.withOpacity(0.4),
                //                   offset: Offset(1.1, 1.1),
                //                   blurRadius: 10.0),
                //             ],
                //           ),
                //           child: Stack(
                //             alignment: Alignment.topLeft,
                //             children: <Widget>[
                //               ClipRRect(
                //                 borderRadius:
                //                     BorderRadius.all(Radius.circular(8.0)),
                //                 child: SizedBox(
                //                   height: 74,
                //                   child: AspectRatio(
                //                     aspectRatio: 1.714,
                //                     child: Image.asset(
                //                         "assets/fitness_app/backx.png"),
                //                   ),
                //                 ),
                //               ),
                //               Column(
                //                 crossAxisAlignment: CrossAxisAlignment.start,
                //                 children: <Widget>[
                //                   Row(
                //                     children: <Widget>[
                //                       Padding(
                //                         padding: const EdgeInsets.only(
                //                           left: 100,
                //                           right: 16,
                //                           top: 16,
                //                         ),
                //                         child: Text(
                //                           cuslang == 'EN'
                //                               ? "Thank you for payment"
                //                               : 'ขอบคุณสำหรับการชำระเงิน',
                //                           textAlign: TextAlign.left,
                //                           style: TextStyle(
                //                             fontFamily:
                //                                 FitnessAppTheme.fontName,
                //                             fontWeight: FontWeight.w500,
                //                             fontSize: 14,
                //                             letterSpacing: 0.0,
                //                             color:
                //                                 FitnessAppTheme.nearlyDarkBlue,
                //                           ),
                //                         ),
                //                       ),
                //                     ],
                //                   ),
                //                   Padding(
                //                     padding: const EdgeInsets.only(
                //                       left: 100,
                //                       bottom: 12,
                //                       top: 4,
                //                       right: 16,
                //                     ),
                //                     child: Column(
                //                       mainAxisAlignment:
                //                           MainAxisAlignment.start,
                //                       children: [
                //                         Row(
                //                           children: [
                //                             Text(
                //                               cuslang == 'EN'
                //                                   ? 'Name : ${customerModel![0].cname}'
                //                                   : 'ชื่อ : ${customerModel![0].cname}',
                //                               textAlign: TextAlign.start,
                //                               style: TextStyle(
                //                                 fontFamily:
                //                                     FitnessAppTheme.fontName,
                //                                 fontWeight: FontWeight.w500,
                //                                 fontSize: 10,
                //                                 letterSpacing: 0.0,
                //                                 color: FitnessAppTheme.grey
                //                                     .withOpacity(0.5),
                //                               ),
                //                             ),
                //                           ],
                //                         ),
                //                         Row(
                //                           children: [
                //                             Text(
                //                               cuslang == 'EN'
                //                                   ? 'Member ID : ${customerModel![0].custno}'
                //                                   : 'รหัสสมาชิก : ${customerModel![0].custno}',
                //                               textAlign: TextAlign.start,
                //                               style: TextStyle(
                //                                 fontFamily:
                //                                     FitnessAppTheme.fontName,
                //                                 fontWeight: FontWeight.w500,
                //                                 fontSize: 10,
                //                                 letterSpacing: 0.0,
                //                                 color: FitnessAppTheme.grey
                //                                     .withOpacity(0.5),
                //                               ),
                //                             ),
                //                           ],
                //                         ),
                //                       ],
                //                     ),
                //                   ),
                //                 ],
                //               ),
                //             ],
                //           ),
                //         ),
                //       ),
                //       Positioned(
                //         top: -16,
                //         left: 0,
                //         child: SizedBox(
                //           width: 110,
                //           height: 110,
                //           child: Image.asset("assets/fitness_app/runnerx2.png"),
                //         ),
                //       )
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class RunningViewPayCid extends StatelessWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;

  final List<CustomerModel>? customerModel;
  final String? cuslang;
  final String? cid;
  const RunningViewPayCid({
    Key? key,
    this.animationController,
    this.animation,
    this.customerModel,
    this.cuslang,
    this.cid,
  }) : super(key: key);

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
                      left: 24, right: 24, top: 0, bottom: 0),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: FitnessAppTheme.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8.0),
                                bottomLeft: Radius.circular(8.0),
                                bottomRight: Radius.circular(8.0),
                                topRight: Radius.circular(8.0)),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: FitnessAppTheme.grey.withOpacity(0.4),
                                  offset: Offset(1.1, 1.1),
                                  blurRadius: 10.0),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.topLeft,
                            children: <Widget>[
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                child: SizedBox(
                                  height: 74,
                                  child: AspectRatio(
                                    aspectRatio: 1.714,
                                    child: Image.asset(
                                        "assets/fitness_app/backx.png"),
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 100,
                                            right: 16,
                                            top: 16,
                                          ),
                                          child: AutoSizeText(
                                            minFontSize: 8,
                                            maxFontSize: 16,
                                            maxLines: 1,
                                            cuslang == 'EN'
                                                ? "Payment Rental Contact $cid"
                                                : 'การชำระเงินเลขที่สัญญา $cid',
                                            // overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              fontFamily:
                                                  FitnessAppTheme.fontName,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                              letterSpacing: 0.0,
                                              color: FitnessAppTheme
                                                  .nearlyDarkBlue,
                                            ),
                                          ),
                                          // Text(
                                          //   cuslang == 'EN'
                                          //       ? "Payment Rental Contact $cid"
                                          //       : 'การชำระเงินเลขที่สัญญา $cid',
                                          //   textAlign: TextAlign.left,
                                          //   style: TextStyle(
                                          //     fontFamily:
                                          //         FitnessAppTheme.fontName,
                                          //     fontWeight: FontWeight.w500,
                                          //     fontSize: 14,
                                          //     letterSpacing: 0.0,
                                          //     color:
                                          //         FitnessAppTheme.nearlyDarkBlue,
                                          //   ),
                                          // ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 100,
                                      bottom: 12,
                                      top: 4,
                                      right: 16,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              cuslang == 'EN'
                                                  ? 'Name : ${customerModel![0].cname}'
                                                  : 'ชื่อ : ${customerModel![0].cname}',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontFamily:
                                                    FitnessAppTheme.fontName,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 10,
                                                letterSpacing: 0.0,
                                                color: FitnessAppTheme.grey
                                                    .withOpacity(0.5),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              cuslang == 'EN'
                                                  ? 'Member ID : ${customerModel![0].custno}'
                                                  : 'รหัสสมาชิก : ${customerModel![0].custno}',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontFamily:
                                                    FitnessAppTheme.fontName,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 10,
                                                letterSpacing: 0.0,
                                                color: FitnessAppTheme.grey
                                                    .withOpacity(0.5),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: -16,
                        left: 0,
                        child: SizedBox(
                          width: 110,
                          height: 110,
                          child: Image.asset("assets/fitness_app/runnerx2.png"),
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
