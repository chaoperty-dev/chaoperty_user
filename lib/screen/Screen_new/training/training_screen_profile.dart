import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../../Constant/Myconstant.dart';
import '../../../Model/GetCustomer_Model.dart';
import '../../../Model/GetInvoice_Model.dart';
import '../../../Model/GetTeNant_Model.dart';
import '../fitness_app_theme.dart';
import '../ui_view/running_view.dart';
import '../ui_view/workout_view.dart';

class TrainingProfileScreen extends StatefulWidget {
  const TrainingProfileScreen({Key? key, this.animationController})
      : super(key: key);

  final AnimationController? animationController;
  @override
  _TrainingProfileScreenState createState() => _TrainingProfileScreenState();
}

class _TrainingProfileScreenState extends State<TrainingProfileScreen>
    with TickerProviderStateMixin {
  Animation<double>? topBarAnimation;

  List<Widget> listViews = <Widget>[];
  List<CustomerModel> customerModels = [];
  List<TeNantModel> teNantModels = [];
  List<InvoiceModel> invoiceModels = [];
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;

  // User Data Variables
  String? renTalSer;
  String? custno;
  String? curLang;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initData();

    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: widget.animationController!,
            curve: const Interval(0, 0.5, curve: Curves.fastOutSlowIn)));

    scrollController.addListener(() {
      if (scrollController.offset >= 24) {
        if (topBarOpacity != 1.0) {
          setState(() => topBarOpacity = 1.0);
        }
      } else if (scrollController.offset <= 24 &&
          scrollController.offset >= 0) {
        if (topBarOpacity != scrollController.offset / 24) {
          setState(() => topBarOpacity = scrollController.offset / 24);
        }
      } else if (scrollController.offset <= 0) {
        if (topBarOpacity != 0.0) {
          setState(() => topBarOpacity = 0.0);
        }
      }
    });
  }

  Future<void> _initData() async {
    try {
      await _loadPreferences();
      await _fetchCustomerData();
      await _fetchTenantData();
      await _fetchInvoiceData();
      _buildListViews();
    } catch (e) {
      debugPrint("Error loading profile data: $e");
    } finally {
      if (mounted) {
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            isLoading = false;
          });
        });
      }
    }
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      renTalSer = prefs.getString('renTalSer');
      custno = prefs.getString('custno');
      curLang = prefs.getString('lang');
    });
  }

  Future<void> _fetchCustomerData() async {
    if (renTalSer == null || custno == null) return;

    final url =
        '${MyConstant().domain}/Gc_customer_user.php?isAdd=true&ren=$renTalSer&cusno=$custno';
    print(url);
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result != null) {
          customerModels.clear();
          for (var map in result) {
            customerModels.add(CustomerModel.fromJson(map));
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching customer: $e");
    }
  }

  Future<void> _fetchTenantData() async {
    if (renTalSer == null || custno == null) return;

    final url =
        '${MyConstant().domain}/GC_tenantAll.php?isAdd=true&ren=$renTalSer&custno=$custno';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result != null) {
          teNantModels.clear();
          for (var map in result) {
            final model = TeNantModel.fromJson(map);
            if (model.cid != null && model.cid.toString() != 'null') {
              teNantModels.add(model);
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching tenant: $e");
    }
  }

  Future<void> _fetchInvoiceData() async {
    if (teNantModels.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final qutser = prefs.getString('qutser');

    invoiceModels.clear();

    // Process sequentially or use Future.wait if concurrency is desired
    for (var tenant in teNantModels) {
      final ciddoc = tenant.cid;
      final url =
          '${MyConstant().domain_chao}/GC_bill_invoice.php?isAdd=true&ren=$renTalSer&ciddoc=$ciddoc&qutser=$qutser';

      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final result = json.decode(response.body);
          if (result != null && result.toString() != 'null') {
            for (var map in result) {
              invoiceModels.add(InvoiceModel.fromJson(map));
            }
          }
        }
      } catch (e) {
        debugPrint("Error fetching invoice for cid $ciddoc: $e");
      }
    }
  }

  void _buildListViews() {
    listViews.clear();
    const int count = 5;

    // 1. Running View (User Info Header)
    // listViews.add(
    //   RunningView(
    //     animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    //         parent: widget.animationController!,
    //         curve: const Interval((1 / count) * 3, 1.0,
    //             curve: Curves.fastOutSlowIn))),
    //     animationController: widget.animationController!,
    //     cuslang: curLang,
    //     customerModel: customerModels,
    //   ),
    // );

    // 2. Workout View (Profile Details - Full Width)
    listViews.add(
      WorkoutView(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve: const Interval((1 / count) * 3, 1.0,
                curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
        customerModel: customerModels,
        cuslang: curLang,
        teNantModel: teNantModels,
        invoiceModels: invoiceModels,
      ),
    );
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(microseconds: 300));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FitnessAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: isLoading
            ? Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 30,
                        backgroundImage:
                            AssetImage('assets/images/Icon-chao.png'),
                      ),
                    ),
                    LoadingAnimationWidget.inkDrop(
                      color: Colors.indigo,
                      size: 70,
                    ),
                  ],
                ),
              )
            : CustomScrollView(
                controller: scrollController,
                slivers: <Widget>[
                  getAppBarUI(),
                  getMainListViewUI(),
                  SliverToBoxAdapter(
                      child: SizedBox(
                    height: MediaQuery.of(context).padding.bottom,
                  ))
                ],
              ),
      ),
    );
  }

  Widget getMainListViewUI() {
    return FutureBuilder<bool>(
      future: getData(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (!snapshot.hasData) {
          return SliverToBoxAdapter(child: SizedBox()
              // Center(
              //   child: Stack(
              //     alignment: Alignment.center,
              //     children: [
              //       Padding(
              //         padding: const EdgeInsets.all(8.0),
              //         child: CircleAvatar(
              //           backgroundColor: Colors.transparent,
              //           radius: 30, // ปรับขนาดของ CircleAvatar
              //           backgroundImage:
              //               AssetImage('assets/images/Icon-chao.png'),
              //         ),
              //       ),
              //       LoadingAnimationWidget.inkDrop(
              //         color: Colors.green,
              //         size: 70,
              //       ),
              //     ],
              //   ),
              // ),
              );
        } else {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                widget.animationController?.forward();
                return Padding(
                  padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                  child: listViews[index],
                );
              },
              childCount: listViews.length,
            ),
          );
        }
      },
    );
  }

  Widget getAppBarUI() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _HeaderBar(
        opacity: topBarOpacity,
        title: curLang == 'EN' ? 'Personal Information' : 'ข้อมูลส่วนตัว',
      ),
    );
  }
}

class _HeaderBar extends SliverPersistentHeaderDelegate {
  _HeaderBar({required this.opacity, required this.title});
  final double opacity;
  final String title;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: FitnessAppTheme.white.withOpacity(opacity),
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: FitnessAppTheme.grey.withOpacity(0.4 * opacity),
              offset: const Offset(1.1, 1.1),
              blurRadius: 10.0),
        ],
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: MediaQuery.of(context).padding.top,
      ),
      alignment: Alignment.centerLeft,
      child: SizedBox(
        height: kToolbarHeight,
        child: Row(
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage('assets/images/Icon-chao.png'),
              radius: 16,
              backgroundColor: Colors.transparent, // Image icon
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 22,
                color: FitnessAppTheme.darkerText,
                letterSpacing: 0.4,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent =>
      kToolbarHeight +
      16 +
      MediaQueryData.fromView(
              WidgetsBinding.instance.platformDispatcher.views.first)
          .padding
          .top;
  @override
  double get minExtent =>
      kToolbarHeight +
      16 +
      MediaQueryData.fromView(
              WidgetsBinding.instance.platformDispatcher.views.first)
          .padding
          .top;
  @override
  bool shouldRebuild(covariant _HeaderBar oldDelegate) =>
      oldDelegate.opacity != opacity || oldDelegate.title != title;
}
