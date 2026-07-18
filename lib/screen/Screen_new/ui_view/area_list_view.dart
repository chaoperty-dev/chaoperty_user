import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../Model/GetCustomer_Model.dart';
import '../../../color.dart';
import '../fitness_app_home_screen.dart';
import '../fitness_app_theme.dart';

class AreaListView extends StatefulWidget {
  const AreaListView({
    Key? key,
    this.mainScreenAnimationController,
    this.mainScreenAnimation,
    this.customerModel,
    this.cuslang,
  }) : super(key: key);

  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;
  final List<CustomerModel>? customerModel;
  final String? cuslang;

  @override
  State<AreaListView> createState() => _AreaListViewState();
}

class _AreaListViewState extends State<AreaListView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _cardAnimCtrl;

  @override
  void initState() {
    super.initState();
    _cardAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  // หน้า/การ์ดที่แสดง
  static const List<AreaItem> _items = <AreaItem>[
    AreaItem(
      imagePath: 'assets/fitness_app/area1x.png',
      titleTh: 'มิเตอร์ไฟฟ้า และ มิเตอร์น้ำ',
      titleEn: 'Electricity & Water Usage',
      pageRoot: 'MITER',
      tooltip: 'มิเตอร์',
    ),
    AreaItem(
      imagePath: 'assets/fitness_app/area3x.png',
      titleTh: 'ใบแจ้งหนี้/ใบวางบิล',
      titleEn: 'Billing & Invoices',
      pageRoot: 'INVOICE',
      tooltip: 'ใบแจ้งหนี้',
    ),
    AreaItem(
      imagePath: 'assets/fitness_app/area2x.png',
      titleTh: 'สถานะการชำระ',
      titleEn: 'Payment Info',
      pageRoot: 'PAYMENT',
      tooltip: 'การชำระเงิน',
    ),
    AreaItem(
      imagePath: 'assets/fitness_app/area5x.jpg',
      titleTh: 'สัญญาเช่าทั้งหมด',
      titleEn: 'All Leases',
      pageRoot: 'CONTACT',
      tooltip: 'สัญญาเช่า',
    ),
    AreaItem(
      imagePath: 'assets/fitness_app/area4x.png',
      titleTh: 'แจ้งซ่อม',
      titleEn: 'Report Repair',
      pageRoot: 'REPAE',
      tooltip: 'แจ้งซ่อม',
    ),
    AreaItem(
      imagePath: 'assets/fitness_app/Smarthome.png',
      titleTh: 'สมาร์ทโฮม',
      titleEn: 'Smart Home',
      pageRoot: 'SMART_HOME',
      tooltip: 'สมาร์ทโฮม',
      comingSoon: true,
    ),
  ];

  @override
  void dispose() {
    _cardAnimCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final anim = widget.mainScreenAnimation ?? const AlwaysStoppedAnimation(1);
    final ctrl = widget.mainScreenAnimationController;

    return AnimatedBuilder(
      animation: ctrl ?? _cardAnimCtrl,
      builder: (context, _) {
        return FadeTransition(
          opacity: anim,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - anim.value)),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final double width = constraints.maxWidth;
                      final double maxExtent;
                      final double padding;

                      // Responsive logic
                      if (width >= 1400) {
                        maxExtent = 280.0;
                        padding = kIsWeb ? 32.0 : 16.0;
                      } else if (width >= 1000) {
                        maxExtent = 260.0;
                        padding = kIsWeb ? 24.0 : 16.0;
                      } else if (width >= 800) {
                        maxExtent = 240.0;
                        padding = 16.0;
                      } else {
                        maxExtent = 220.0;
                        padding = 16.0;
                      }

                      return GridView.builder(
                        padding:
                            EdgeInsets.fromLTRB(padding, padding, padding, 100),
                        itemCount: _items.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: maxExtent,
                          mainAxisSpacing: 24,
                          crossAxisSpacing: 24,
                          childAspectRatio: 0.92,
                        ),
                        itemBuilder: (context, i) {
                          final item = _items[i];
                          return FadeTransition(
                            opacity: CurvedAnimation(
                              parent: _cardAnimCtrl,
                              curve: Interval(
                                (i / _items.length) * 0.7,
                                1,
                                curve: Curves.easeOut,
                              ),
                            ),
                            child: AreaCard(
                              item: item,
                              lang: widget.cuslang,
                              onTap: () => _navigateTo(context, item),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateTo(BuildContext context, AreaItem item) {
    if (item.comingSoon) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: SizedBox(
            height: MediaQuery.of(context).size.width *
                0.2, // Fixed logic here as well
            child: Center(
              child: Text(
                'Coming soon...',
                style: TextStyle(
                  color: Colors.black87,
                  fontFamily: FitnessAppTheme.fontName,
                ),
              ),
            ),
          ),
        ),
      );
      return;
    }

    final route = MaterialPageRoute(
      builder: (_) => FitnessAppHomeScreen(pageroot: item.pageRoot),
    );

    Navigator.push(context, route);
  }
}

class AreaItem {
  final String imagePath;
  final String titleTh;
  final String titleEn;
  final String pageRoot;
  final String tooltip;
  final bool comingSoon;

  const AreaItem({
    required this.imagePath,
    required this.titleTh,
    required this.titleEn,
    required this.pageRoot,
    required this.tooltip,
    this.comingSoon = false,
  });

  String title(String? lang) => (lang == 'EN') ? titleEn : titleTh;
}

class AreaCard extends StatefulWidget {
  const AreaCard({
    super.key,
    required this.item,
    required this.lang,
    required this.onTap,
  });

  final AreaItem item;
  final String? lang;
  final VoidCallback onTap;

  @override
  State<AreaCard> createState() => _AreaCardState();
}

class _AreaCardState extends State<AreaCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final title = widget.item.title(widget.lang);

    return Semantics(
      button: true,
      label: title,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: AnimatedScale(
          scale: _hover ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: FitnessAppTheme.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.black12.withOpacity(_hover ? .18 : .1),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                splashColor: FitnessAppTheme.nearlyDarkBlue.withOpacity(0.10),
                highlightColor:
                    FitnessAppTheme.nearlyDarkBlue.withOpacity(0.04),
                onTap: widget.onTap,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            widget.item.imagePath,
                            fit: BoxFit.contain,
                            cacheWidth:
                                300, // บีบอัดขนาดใน Memory ป้องกัน Safari Crash
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: Font_.Fonts_T,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          height: 1.25,
                          color: FitnessAppTheme.nearlyDarkBlue,
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
