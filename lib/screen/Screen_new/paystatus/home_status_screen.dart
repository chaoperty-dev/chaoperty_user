import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../../Constant/Myconstant.dart';
import '../../../Man_PDF/Man_Pay_Receipt_PDF.dart';

import '../../../Model/GetCustomer_Model.dart';
import '../../../Model/GetRenTal_Model.dart';
import '../../../Model/GetInvoice_Model.dart';
import '../../../color.dart';
import '../../../main.dart';
import '../fitness_app_theme.dart';

class ReceiptPayScreen extends StatefulWidget {
  const ReceiptPayScreen({Key? key, this.animationController, this.cuslang})
      : super(key: key);
  final AnimationController? animationController;
  final String? cuslang;

  @override
  State<ReceiptPayScreen> createState() => _ReceiptPayScreenState();
}

enum InvoiceTab { unpaid, paid }

class _ReceiptPayScreenState extends State<ReceiptPayScreen>
    with TickerProviderStateMixin {
  // --- State ---
  final scrollController = ScrollController();
  final nFormat = NumberFormat("#,##0.00", "en_US");

  Animation<double>? topBarAnimation;
  double topBarOpacity = 0.0;

  bool isLoading = true;
  InvoiceTab currentTab = InvoiceTab.paid;

  // Profile / rental
  String? serRe, renTalName, custNo, cusLang, folder, temPageSer;
  String? billName,
      billAddr,
      billTax,
      billTel,
      billEmail,
      billDefault,
      billsName;
  String reportTitle = "ไม่ระบุ";
  String? cusPhoto, cusFoder, cusImgLogo;

  List<CustomerModel> customers = [];
  List<RenTalModel> rentals = [];
  List<InvoiceModel> invoices = [];
  final Map<String, Map<String, String>> bankCodeMap = {
    'ธนาคารกรุงเทพ': {
      'code': 'BBL',
      'en': 'Bangkok Bank',
      'logo': 'BBL.png',
    },
    'ธนาคารกสิกรไทย': {
      'code': 'KBANK',
      'en': 'Kasikornbank',
      'logo': 'KBANK.png',
    },
    'ธนาคารกรุงไทย': {
      'code': 'KTB',
      'en': 'Krung Thai Bank',
      'logo': 'KTB.png',
    },
    'ธนาคารทหารไทยธนชาต': {
      'code': 'TTB',
      'en': 'TMBThanachart Bank',
      'logo': 'TTB.png',
    },
    'ธนาคารไทยพาณิชย์': {
      'code': 'SCB',
      'en': 'Siam Commercial Bank',
      'logo': 'SCB.png',
    },
    'ธนาคารกรุงศรีอยุธยา': {
      'code': 'BAY',
      'en': 'Bank of Ayudhya',
      'logo': 'BAY.png',
    },
    'ธนาคารเกียรตินาคินภัทร': {
      'code': 'KKP',
      'en': 'Kiatnakin Phatra Bank',
      'logo': 'KKP.png',
    },
    'ธนาคารซีไอเอ็มบีไทย': {
      'code': 'CIMBT',
      'en': 'CIMB Thai Bank',
      'logo': 'CIMBT.png',
    },
    'ธนาคารทิสโก้': {
      'code': 'TISCO',
      'en': 'TISCO Bank',
      'logo': 'TISCO.png',
    },
    'ธนาคารยูโอบี': {
      'code': 'UOBT',
      'en': 'United Overseas Bank (Thai)',
      'logo': 'UOBT.png',
    },
    'ธนาคารไทยเครดิตเพื่อรายย่อย': {
      'code': 'TCD',
      'en': 'Thai Credit Retail Bank',
      'logo': 'TCD.png',
    },
    'ธนาคารแลนด์ แอนด์ เฮ้าส์': {
      'code': 'LHFG',
      'en': 'Land and Houses Bank',
      'logo': 'LHFG.png',
    },
    'ธนาคารไอซีบีซี (ไทย)': {
      'code': 'ICBCT',
      'en': 'ICBC (Thai)',
      'logo': 'ICBCT.png',
    },
    'ธนาคารพัฒนาวิสาหกิจขนาดกลางและขนาดย่อมแห่งประเทศไทย': {
      'code': 'SME',
      'en': 'SME Development Bank',
      'logo': 'SME.png',
    },
    'ธนาคารเพื่อการเกษตรและสหกรณ์การเกษตร': {
      'code': 'BAAC',
      'en': 'Bank for Agriculture and Agricultural Cooperatives',
      'logo': 'BAAC.png',
    },
    'ธนาคารออมสิน': {
      'code': 'GSB',
      'en': 'Government Savings Bank',
      'logo': 'GSB.png',
    },
    'ธนาคารอาคารสงเคราะห์': {
      'code': 'GHB',
      'en': 'Government Housing Bank',
      'logo': 'GHB.png',
    },
    'ธนาคารอิสลามแห่งประเทศไทย': {
      'code': 'ISBT',
      'en': 'Islamic Bank of Thailand',
      'logo': 'ISBT.png',
    },
    'ธนาคารอิสลามแห่งประเทศไทย2': {
      'code': 'ISBT2',
      'en': 'Islamic Bank of Thailand 2',
      'logo': 'ISBT2.png',
    },
    'BeamCheckOut': {
      'code': 'BEAM',
      'en': 'Beam Checkout',
      'logo': 'BEAM.png',
    },
    'ທະນາຄານການຄ້າຕ່າງປະເທດລາວ': {
      'code': 'BCEL',
      'en': 'Banque Pour Le Commerce Exterieur Lao',
      'logo': 'BCEL.png',
    },
    'Lao Development Bank': {
      'code': 'LDB',
      'en': 'Lao Development Bank',
      'logo': 'LDB.png',
    },
  };
  @override
  void initState() {
    super.initState();
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: widget.animationController!,
        curve: const Interval(0, 0.5, curve: Curves.fastOutSlowIn),
      ),
    );
    scrollController.addListener(_onScroll);
    _bootstrap();
  }

  void _onScroll() {
    final offset = scrollController.offset.clamp(0.0, 24.0);
    final newOpacity = (offset / 24.0);
    if (newOpacity != topBarOpacity) {
      setState(() => topBarOpacity = newOpacity);
    }
  }

  Future<void> _bootstrap() async {
    try {
      await _loadPrefs();
      await Future.wait([_loadRental(), _loadCustomer()]);
      await _loadInvoices(paid: false, type: '');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    serRe = p.getString('renTalSer');
    renTalName = p.getString('renTalName');
    custNo = p.getString('custno');
    cusLang = p.getString('lang');
    cusPhoto = p.getString('photo');
    cusFoder = p.getString('foder');

    if (cusPhoto != null &&
        cusPhoto!.isNotEmpty &&
        cusPhoto!.toLowerCase() != 'null' &&
        cusFoder != null &&
        cusFoder!.isNotEmpty) {
      final newUrl = MyConstant().domain_chao;
      cusImgLogo = '$newUrl/files/$cusFoder/contract/$cusPhoto';
    }
  }

  Future<void> _loadCustomer() async {
    if (serRe == null || custNo == null) return;
    final url =
        '${MyConstant().domain}/Gc_customer_user.php?isAdd=true&ren=$serRe&cusno=$custNo';
    final res = await http.get(Uri.parse(url));
    final List<dynamic> result = json.decode(res.body);
    if (mounted) {
      setState(() {
        customers = result.map((e) => CustomerModel.fromJson(e)).toList();
      });
    }
  }

  Future<void> _loadRental() async {
    final p = await SharedPreferences.getInstance();
    final ren = p.getString('renTalSer');
    renTalName = p.getString('renTalName');

    final url =
        '${MyConstant().domain_chao}/GC_rental_setring.php?isAdd=true&ren=$ren';
    final res = await http.get(Uri.parse(url));
    final List<dynamic>? result = json.decode(res.body);

    if (result == null) return;

    final list = result.map((e) => RenTalModel.fromJson(e)).toList();
    final r = list.first;

    if (mounted) {
      setState(() {
        rentals = list;
        folder = r.dbn;
        temPageSer = r.tem_page?.trim();
        billName = r.bill_name?.trim();
        billAddr = r.bill_addr?.trim();
        billTax = r.bill_tax?.trim();
        billTel = r.bill_tel?.trim();
        billEmail = r.bill_email?.trim();
        billDefault = r.bill_default;
        billsName = billDefault == 'P' ? 'บิลธรรมดา' : 'ใบกำกับภาษี';
        reportTitle = (r.receipt_title == '0')
            ? 'ไม่ระบุ'
            : (r.receipt_title == '1')
                ? 'ต้นฉบับ'
                : 'สำเนา';
      });
    }
  }
//     ORDER BY
//     c_financetrans.ser DESC;

  Future<void> _handleOpenPdf(InvoiceModel inv) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> newValuePDFimg = [];

    if (rentals.isNotEmpty && rentals[0].imglogo!.trim().isNotEmpty) {
      final urlimg =
          '${MyConstant().domain_chao}/files/$folder/logo/${rentals[0].imglogo!.trim()}';
      newValuePDFimg.add(urlimg);
      preferences.setString('renTal_logo', urlimg);
    }

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.green)),
    );

    try {
      ManPay_Receipt_PDF.overrideTabPaid =
          (currentTab == InvoiceTab.paid) ? 'true' : 'false';

      if (currentTab == InvoiceTab.paid) {
        await preferences.setString('Tabpaid', 'true');
      } else {
        await preferences.setString('Tabpaid', 'false');
      }

      if (!mounted) return;
      ManPay_Receipt_PDF.ManPayReceipt_PDF(
        inv.docno,
        context,
        folder,
        renTalName,
        billAddr,
        billEmail,
        billTel,
        billTax,
        billName,
        newValuePDFimg,
        null,
        temPageSer,
        billsName,
        '1',
      );
    } catch (e) {
      debugPrint('PDF Error: $e');
    } finally {
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _uploadSlipAgain(InvoiceModel inv) async {
    final docno = inv.docno;
    if (docno == null || docno.isEmpty) return;

    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 60,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (pickedFile == null) return;

    final imageBytes = await pickedFile.readAsBytes();
    final base64Slip = base64Encode(imageBytes);
    const extension = 'png';

    // สร้างชื่อไฟล์แบบ UUID ไม่ให้ซ้ำเลย
    final uuidPart = _generateShortUuid();
    final fileName = 'slip_${docno}_$uuidPart.$extension';

    final preferences = await SharedPreferences.getInstance();
    final ren = preferences.getString('renTalSer');
    final targetFolder = folder ?? preferences.getString('foder') ?? '';
    final month = DateFormat('MM').format(DateTime.now());
    final year = DateFormat('yyyy').format(DateTime.now());

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Colors.green),
      ),
    );

    try {
      // ใช้ Uri.replace(queryParameters:) เพื่อ encode พารามิเตอร์ถูกต้อง
      final uploadUri =
          Uri.parse('${MyConstant().domain_chao}/File_uploadSlip_NewEdit.php')
              .replace(queryParameters: {
        'name': fileName,
        'Foder': targetFolder,
        'extension': extension,
      });
      final uploadResponse = await http.post(
        uploadUri,
        body: {
          'image': base64Slip,
          'Foder': targetFolder,
          'name': fileName,
          'ex': extension,
        },
      );

      debugPrint(
          '📎 uploadSlipAgain step1: status=${uploadResponse.statusCode}, body=${uploadResponse.body}');

      if (uploadResponse.statusCode == 200) {
        final againUri =
            Uri.parse('${MyConstant().domain_chao}/File_uploadSlip_Again.php')
                .replace(queryParameters: {
          'name': fileName,
          'Foder': targetFolder,
          'extension': extension,
        });
        final againResponse = await http.post(
          againUri,
          body: {
            'ren': '$ren',
            'image': base64Slip,
            'Foder': targetFolder,
            'name': fileName,
            'ex': extension,
            'month': month,
            'year': year,
            'docno': docno,
            'slip_del': '',
          },
        );
        debugPrint(
            '📎 uploadSlipAgain step2: status=${againResponse.statusCode}, body=${againResponse.body}');
      }

      if (!mounted) return;
      Navigator.pop(context);
      setState(() => isLoading = true);
      await _loadInvoices(
        paid: false,
        type: currentTab == InvoiceTab.unpaid ? 'PAY' : '',
      );
      if (mounted) setState(() => isLoading = false);
    } catch (e, stack) {
      debugPrint('❌ uploadSlipAgain error: $e\n$stack');
      if (!mounted) return;
      Navigator.pop(context);
      setState(() => isLoading = false);
    }
  }

  /// สร้าง UUID สั้นๆ 16 ตัวอักษร ไม่ซ้ำแน่นอน
  String _generateShortUuid() {
    final r = Random();
    final uuid = List.generate(36, (i) {
      if (i == 8 || i == 13 || i == 18 || i == 23) return '-';
      if (i == 14) return '4';
      if (i == 19) return ((r.nextInt(4) + 8).toRadixString(16));
      return r.nextInt(16).toRadixString(16);
    }).join();
    return uuid.replaceAll('-', '').substring(0, 16);
  }

  /// ดูรูปหลักฐานการชำระเงิน
  void _viewSlipImage(InvoiceModel inv) async {
    final isEN = cusLang == 'EN';
    final folderName = folder ?? '';
    final docno = inv.docno ?? '';

    // แสดง loading ก่อน
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Colors.purple),
      ),
    );

    try {
      // เรียก API ที่คืน FinnancetransModel (มี field 'slip')
      final prefs = await SharedPreferences.getInstance();
      final ren = prefs.getString('renTalSer');
      final ciddoc = prefs.getString('usercid');

      final uri = Uri.parse('${MyConstant().domain_chao}/GC_bill_pay_amt.php')
          .replace(queryParameters: {
        'isAdd': 'true',
        'ren': ren ?? '',
        'ciddoc': ciddoc ?? '',
        'docnoin': docno,
      });

      debugPrint('📎 View slip API: $uri');
      final res = await http.get(uri);
      final result = json.decode(res.body);

      // ปิด loading
      if (mounted) Navigator.pop(context);

      // หา slip filename จาก FinnancetransModel (field 'slip')
      String? slipFileName;
      if (result is List && result.isNotEmpty) {
        for (var map in result) {
          final slip = map['slip']?.toString() ?? '';
          if (slip.isNotEmpty && slip != 'null') {
            slipFileName = slip;
            break;
          }
        }
      }

      if (slipFileName == null || slipFileName.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEN ? 'No slip image available' : 'ไม่พบรูปหลักฐานการชำระเงิน',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // สร้าง URL รูป: domain_chao/files/{foder}/slip/{slipFileName}
      final imageUrl = slipFileName.startsWith('http')
          ? slipFileName
          : '${MyConstant().domain_chao}/files/$folderName/slip/$slipFileName';

      debugPrint('📎 View slip URL: $imageUrl');

      // ✅ ตรวจสอบว่าไฟล์มีอยู่จริงบน server หรือไม่ (HEAD request)
      try {
        final headRes = await http.head(Uri.parse(imageUrl));
        if (headRes.statusCode == 404) {
          // มีชื่อไฟล์ใน DB แต่ไฟล์ไม่อยู่บน server
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isEN
                      ? 'Slip file not found on server (file missing)'
                      : 'ไฟล์สลิปไม่อยู่บน server (ไฟล์หาย)',
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
          return;
        }
      } catch (_) {
        // ถ้า HEAD ไม่ได้ ให้ลองแสดงต่อไป (บาง server ไม่รองรับ HEAD)
        debugPrint('📎 HEAD request failed, proceed to show image anyway');
      }

      if (!mounted) return;
      _showSlipDialog(imageUrl, docno, isEN);
    } catch (e, stack) {
      debugPrint('❌ viewSlip error: $e\n$stack');
      if (mounted) {
        Navigator.pop(context); // ปิด loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                isEN ? 'Error loading slip' : 'เกิดข้อผิดพลาดในการโหลดรูป'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// แสดง dialog รูปสลิป
  void _showSlipDialog(String imageUrl, String docno, bool isEN) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Container(
                      width: 4,
                      height: 18,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Text(
                      isEN ? 'Payment Evidence' : 'หลักฐานการชำระเงิน',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        fontFamily: Font_.Fonts_T,
                        color: Colors.purple,
                      ),
                    ),
                  ]),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 12),
            // Invoice info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.receipt_long,
                      size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(
                    docno,
                    style: TextStyle(
                      fontFamily: Font_.Fonts_T,
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Image
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.55,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.1,
                  maxScale: 4.0,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    cacheWidth: 500,
                    loadingBuilder: (_, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            color: Colors.purple,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.broken_image_outlined,
                                size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 8),
                            Text(
                              isEN ? 'Image not found' : 'ไม่พบรูปภาพ',
                              style: TextStyle(
                                fontFamily: Font_.Fonts_T,
                                color: Colors.grey.shade500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _loadInvoices({required bool paid, required String type}) async {
    final p = await SharedPreferences.getInstance();
    final ren = p.getString('renTalSer');
    final qutser = p.getString('qutser');
    final custno = p.getString('custno');

    final url =
        '${MyConstant().domain_chao}/GC_ReceiptUserV2.php?isAdd=true&ren=$ren&custno=$custno&qutser=$qutser&type=$type';

    final res = await http.get(Uri.parse(url));
    final result = json.decode(res.body);
    // print(url);
    if (mounted) {
      setState(() {
        if (result == null || result['data'] == null) {
          invoices = [];
        } else {
          final data = result['data'] as List;
          invoices = data.map((e) => InvoiceModel.fromJson(e)).toList();
        }
      });
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  int _crossAxisCountWidth(double width) {
    return 1;
  }

  Widget getAppBarUI() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _HeaderBar(
        opacity: topBarOpacity,
        title: (cusLang == 'EN') ? 'Payment receipt' : 'ใบเสร็จรับชำระ',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cross = _crossAxisCountWidth(width);
    final scale = MediaQuery.of(context).textScaleFactor;

    // Filter list based on current tab
    final filtered = invoices.where((inv) {
      if (currentTab == InvoiceTab.paid) {
        // "Waiting list" (รายการรอตรวจสอบ) -> Only Pending items
        return inv.status == '1';
      } else {
        // "Payment items" (รายการรับชำระ) -> Unpaid/Everything else
        // In the original app, unpaid items are usually those not yet confirmed
        return inv.status != '1';
      }
    }).toList();

    return Container(
      color: FitnessAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: isLoading
            ? Center(
                child: LoadingAnimationWidget.inkDrop(
                    color: Colors.green, size: 70),
              )
            : ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  },
                ),
                child: CustomScrollView(
                  key: ValueKey(
                      currentTab), // Force rebuild sliver state on tab switch
                  physics:
                      const AlwaysScrollableScrollPhysics(), // Ensure reactive scrolling
                  controller: scrollController,
                  slivers: [
                    getAppBarUI(),
                    SliverToBoxAdapter(child: _tabSwitcher()),
                    SliverToBoxAdapter(child: _titleBar(filtered.length)),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(8, 2, 8, 100),
                      sliver: cross == 1
                          ? SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, i) => InvoiceCard(
                                  key: ValueKey(filtered[i].docno ?? i),
                                  model: filtered[i],
                                  paid: currentTab == InvoiceTab.paid,
                                  nFormat: nFormat,
                                  cuslang: cusLang,
                                  bankCodeMap: bankCodeMap,
                                  onOpenPdf: _handleOpenPdf,
                                  onUploadSlipAgain: _uploadSlipAgain,
                                  onViewSlip: _viewSlipImage,
                                ),
                                childCount: filtered.length,
                              ),
                            )
                          : SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: cross,
                                mainAxisSpacing: 1,
                                crossAxisSpacing: 1,
                                mainAxisExtent:
                                    145.0 * (1 + (scale - 1).clamp(0.0, 0.25)),
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, i) => InvoiceCard(
                                  key: ValueKey(filtered[i].docno ?? i),
                                  model: filtered[i],
                                  paid: currentTab == InvoiceTab.paid,
                                  nFormat: nFormat,
                                  cuslang: cusLang,
                                  bankCodeMap: bankCodeMap,
                                  onOpenPdf: _handleOpenPdf,
                                  onUploadSlipAgain: _uploadSlipAgain,
                                  onViewSlip: _viewSlipImage,
                                ),
                                childCount: filtered.length,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _tabButton({
    required String text,
    required bool active,
    required BorderRadius radius,
    required VoidCallback onTap,
    required List<Color> activeColors,
    required List<Color> inactiveColors,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: HexColor('#FBF3D5').withOpacity(0.6),
                offset: const Offset(1.1, 4.0),
                blurRadius: 8.0,
              ),
            ],
            gradient: LinearGradient(
              colors: active ? activeColors : inactiveColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: radius,
          ),
          child: Center(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: active ? Colors.white : Colors.black,
                fontFamily: Font_.Fonts_T,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabSwitcher() {
    final _greenActive = [HexColor('#2E7D32'), HexColor('#66BB6A')];
    final _greenInactive = [HexColor('#E8F5E9'), HexColor('#C8E6C9')];
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          _tabButton(
            text:
                (cusLang == 'EN') ? 'Payments-Pending' : 'การรับชำระ-รอตรวจสอบ',
            active: currentTab == InvoiceTab.paid,
            radius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8),
              topRight: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
            onTap: () async {
              if (currentTab == InvoiceTab.paid) return;
              setState(() {
                currentTab = InvoiceTab.paid;
                isLoading = true; // Show loader while switching
                invoices.clear();
              });
              try {
                await _loadInvoices(paid: false, type: '');
              } finally {
                if (mounted) setState(() => isLoading = false);
              }
            },
            activeColors: _greenActive,
            inactiveColors: _greenInactive,
          ),
          const SizedBox(width: 5),
          _tabButton(
            text: (cusLang == 'EN')
                ? 'Payment-Verified'
                : 'การรับชำระ-ตรวจสอบแล้ว',
            active: currentTab == InvoiceTab.unpaid,
            radius: const BorderRadius.only(
              topRight: Radius.circular(8),
              bottomRight: Radius.circular(8),
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
            onTap: () async {
              if (currentTab == InvoiceTab.unpaid) return;
              setState(() {
                currentTab = InvoiceTab.unpaid;
                isLoading = true; // Show loader while switching
                invoices.clear();
              });
              try {
                await _loadInvoices(paid: false, type: 'PAY');
              } finally {
                if (mounted) setState(() => isLoading = false);
              }
            },
            activeColors: _greenActive,
            inactiveColors: _greenInactive,
          ),
        ],
      ),
    );
  }

  Widget _titleBar(int count) {
    final countTxt =
        (cusLang == 'EN') ? 'List $count bill' : 'รายการ $count บิล';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: _SectionTitle(
        title: countTxt,
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: widget.animationController!,
            curve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
          ),
        ),
        controller: widget.animationController!,
      ),
    );
  }
}

// ------- Widgets ย่อย -------
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.animation,
    required this.controller,
  });

  final String title;
  final Animation<double> animation;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    controller.forward();
    return FadeTransition(
      opacity: animation,
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: Font_.Fonts_T,
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class InvoiceCard extends StatelessWidget {
  const InvoiceCard({
    super.key,
    required this.model,
    required this.paid,
    required this.nFormat,
    required this.cuslang,
    required this.bankCodeMap,
    this.onOpenPdf, // ✅ ให้ parent จัดการกดปุ่ม
    this.onUploadSlipAgain,
    this.onViewSlip, // ✅ ดูรูปหลักฐาน
    this.badgeLeft = true, // ตัวเลือกโชว์ badge ซ้าย
  });

  final InvoiceModel model;
  final bool paid;
  final NumberFormat nFormat;
  final String? cuslang;
  final bankCodeMap;

  /// ให้ parent ส่งฟังก์ชันมาจัดการเปิด PDF หรือทำอย่างอื่น
  final void Function(InvoiceModel model)? onOpenPdf;
  final void Function(InvoiceModel model)? onUploadSlipAgain;
  final void Function(InvoiceModel model)? onViewSlip;

  /// เผื่ออยากซ่อน badge ซ้ายในบาง layout
  final bool badgeLeft;

  @override
  Widget build(BuildContext context) {
    // รวมยอด
    final total = nFormat.format(double.tryParse(model.total_bill ?? '0') ?? 0);
    final bank = model.bank ?? '';
    final bankInfo = bankCodeMap[bank];
    final logoFile = bankInfo?['logo'];
    // ภาษา (โปรเจ็กต์คุณใช้ 'EN'/'TH')
    final isEN = (cuslang?.toUpperCase() == 'EN');

    // วันที่กำหนดชำระ (กัน null/parse error)
    String dueStr;
    final rawDate = (model.date ?? '').trim();
    if (rawDate.isEmpty) {
      dueStr = isEN
          ? 'Payment date: Please contact staff.'
          : 'วันที่ชำระ: กรุณาติดต่อเจ้าหน้าที่';
    } else {
      DateTime? d;
      try {
        d = DateTime.parse('$rawDate 00:00:00');
      } catch (_) {}
      if (d == null) {
        dueStr = isEN
            ? 'Payment date: Please contact staff.'
            : 'วันที่ชำระ: กรุณาติดต่อเจ้าหน้าที่';
      } else {
        final f = DateFormat('dd-MM-yyyy');
        dueStr =
            isEN ? 'Payment date ${f.format(d)}' : 'วันที่ชำระ ${f.format(d)}';
      }
    }

    Widget chip(String text, Color bg, Color fg) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: fg.withOpacity(.25), width: .7),
          ),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: Font_.Fonts_T,
              fontWeight: FontWeight.w700,
              fontSize: 11.5,
              color: fg,
            ),
          ),
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12, width: .4),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // เนื้อหา
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(children: [
                      // โลโก้
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white,
                        child: logoFile != null
                            ? Image.asset(
                                'assets/images/LogoBank/$logoFile',
                                cacheWidth: 100, // ลด Memory Leak
                                height: 26,
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.account_balance,
                                    size: 20,
                                    color: Colors.grey),
                              )
                            : const Icon(Icons.account_balance,
                                size: 20, color: Colors.grey),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          model.docno ?? '-',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14.5,
                            color: Colors.black,
                            fontFamily: Font_.Fonts_T,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          total,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            fontSize: 14.5,
                            color: Colors.black,
                            fontFamily: Font_.Fonts_T,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 10,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Row(mainAxisSize: MainAxisSize.min, children: [
                        //   const Icon(Icons.badge_outlined,
                        //       size: 14, color: Colors.black54),
                        //   const SizedBox(width: 6),
                        //   Text(
                        //     model.cid ?? '-',
                        //     maxLines: 1,
                        //     overflow: TextOverflow.ellipsis,
                        //     style: const TextStyle(
                        //       fontFamily: Font_.Fonts_T,
                        //       fontSize: 12.5,
                        //     ),
                        //   ),
                        // ]),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 14, color: Colors.black54),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                dueStr,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: Font_.Fonts_T,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (model.bno != '' && model.bno != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.account_balance,
                                  size: 14, color: Colors.black54),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  (model.ptname.toString() == 'เงินสด' ||
                                          model.bno.toString() == 'เงินสด')
                                      ? isEN
                                          ? 'cash'
                                          : model.bno ?? '-'
                                      : model.bno ?? '-',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: Font_.Fonts_T,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        // ตัวอย่าง chip ขวา (จะโชว์อะไรก็เปลี่ยนได้)ฃ
                        (model.status.toString() == '1')
                            ? chip(isEN ? 'Pending' : 'รอตรวจสอบ',
                                Colors.orange.withOpacity(.08), Colors.orange)
                            : chip(isEN ? 'Success' : 'ชำระสำเร็จ',
                                Colors.green.withOpacity(.08), Colors.green),
                      ],
                    ),
                    // ✅ แถวด้านล่าง: แสดงสถานะไฟล์สลิป + ปุ่มดู/อัปโหลด
                    const SizedBox(height: 6),
                    _SlipStatusBar(
                      model: model,
                      isEN: isEN,
                      onViewSlip: onViewSlip,
                      onUploadSlipAgain: onUploadSlipAgain,
                    ),
                    if (model.inv_list != null && model.inv_list != '') ...[
                      const SizedBox(height: 6),
                      _InvListItem(
                        text: model.inv_list ?? '-',
                        isEN: isEN,
                      ),
                    ]
                  ],
                ),
              ),
            ),

            // ปุ่ม action (ให้ parent จัดการ)
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: onOpenPdf == null ? null : () => onOpenPdf!(model),
              tooltip: isEN ? 'Open details' : 'ดูรายละเอียด',
            ),
          ],
        ),
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
    return Material(
      child: Container(
        decoration: BoxDecoration(
          color: FitnessAppTheme.white.withOpacity(opacity),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(0.0),
          ),
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

/// ✅ Widget แสดง inv_list แบบย่อ/ขยายได้
class _InvListItem extends StatefulWidget {
  const _InvListItem({required this.text, required this.isEN});
  final String text;
  final bool isEN;

  @override
  State<_InvListItem> createState() => _InvListItemState();
}

class _InvListItemState extends State<_InvListItem> {
  bool _isExpanded = false;

  // คำนวณว่าข้อความยาวพอที่จะต้องย่อหรือไม่ (มากกว่า ~ 35 ตัวอักษร)
  bool get _isLongText => widget.text.length > 35;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isEN ? 'ref to : ' : 'อ้างอิงถึง : ',
              style: const TextStyle(
                fontFamily: Font_.Fonts_T,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment: Alignment.topLeft,
                child: Text(
                  widget.text,
                  maxLines: _isExpanded ? null : 1,
                  overflow: _isExpanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: Font_.Fonts_T,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ),
          ],
        ),
        // แสดงปุ่มย่อ/ขยาย เมื่อข้อความยาวพอ
        if (_isLongText)
          Padding(
            padding: const EdgeInsets.only(top: 2, left: 70),
            child: InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              borderRadius: BorderRadius.circular(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isExpanded
                        ? (widget.isEN ? 'Collapse' : 'ย่อ')
                        : (widget.isEN ? 'Expand' : 'ขยาย'),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                      fontFamily: Font_.Fonts_T,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 14,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// ✅ แถบสถานะไฟล์สลิปด้านล่างของแต่ละการ์ด
/// ตรวจสอบว่ามีชื่อไฟล์สลิปใน DB และไฟล์มีอยู่จริงบน server
class _SlipStatusBar extends StatefulWidget {
  const _SlipStatusBar({
    required this.model,
    required this.isEN,
    this.onViewSlip,
    this.onUploadSlipAgain,
  });

  final InvoiceModel model;
  final bool isEN;
  final void Function(InvoiceModel model)? onViewSlip;
  final void Function(InvoiceModel model)? onUploadSlipAgain;

  @override
  State<_SlipStatusBar> createState() => _SlipStatusBarState();
}

class _SlipStatusBarState extends State<_SlipStatusBar> {
  /// 0 = ยังไม่ได้ตรวจ, 1 = มีไฟล์, 2 = ไม่มีชื่อไฟล์ใน DB, 3 = มีชื่อแต่ไฟล์หาย
  int _status = 0;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _checkSlipFile();
  }

  Future<void> _checkSlipFile() async {
    if (_checking) return;
    _checking = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final ren = prefs.getString('renTalSer');
      final ciddoc = prefs.getString('usercid');
      final folderName = prefs.getString('foder') ?? '';

      // 1) ดึงชื่อไฟล์สลิปจาก DB
      final uri = Uri.parse('${MyConstant().domain_chao}/GC_bill_pay_amt.php')
          .replace(queryParameters: {
        'isAdd': 'true',
        'ren': ren ?? '',
        'ciddoc': ciddoc ?? '',
        'docnoin': widget.model.docno ?? '',
      });

      final res = await http.get(uri);
      final result = json.decode(res.body);

      String? slipFileName;
      if (result is List && result.isNotEmpty) {
        for (var map in result) {
          final slip = map['slip']?.toString() ?? '';
          if (slip.isNotEmpty && slip != 'null') {
            slipFileName = slip;
            break;
          }
        }
      }

      if (slipFileName == null || slipFileName.isEmpty) {
        if (mounted) setState(() => _status = 2); // ไม่มีชื่อไฟล์ใน DB
        return;
      }

      // 2) ตรวจสอบว่าไฟล์มีอยู่จริงบน server (HEAD request)
      final imageUrl = slipFileName.startsWith('http')
          ? slipFileName
          : '${MyConstant().domain_chao}/files/$folderName/slip/$slipFileName';

      try {
        final headRes = await http.head(Uri.parse(imageUrl));
        if (headRes.statusCode == 404) {
          if (mounted) setState(() => _status = 3); // มีชื่อแต่ไฟล์หาย
        } else {
          if (mounted) setState(() => _status = 1); // มีไฟล์
        }
      } catch (_) {
        // ถ้า HEAD ไม่ได้ ให้ถือว่ามีไฟล์ (เผื่อ server ไม่รองรับ HEAD)
        if (mounted) setState(() => _status = 1);
      }
    } catch (_) {
      if (mounted) setState(() => _status = 0); // ตรวจไม่ได้
    } finally {
      _checking = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEN = widget.isEN;
    final status = widget.model.status.toString();

    // กำลังตรวจสอบ
    if (_status == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              isEN ? 'Checking slip...' : 'กำลังตรวจสอบสลิป...',
              style: TextStyle(
                fontFamily: Font_.Fonts_T,
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    // ไม่มีชื่อไฟล์ใน DB (แสดงสถานะอย่างเดียว ไม่ให้อัปโหลดใหม่)
    if (_status == 2) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.withOpacity(.2), width: .5),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                size: 16, color: Colors.orange),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                isEN ? 'No slip uploaded yet' : 'ยังไม่มีหลักฐานการชำระเงิน',
                style: TextStyle(
                  fontFamily: Font_.Fonts_T,
                  fontSize: 12,
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // มีชื่อไฟล์แต่ไฟล์หายจาก server (อนุญาตให้อัปโหลดใหม่ได้)
    if (_status == 3) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.withOpacity(.2), width: .5),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, size: 16, color: Colors.red),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                isEN
                    ? 'Slip file is missing, please upload again'
                    : 'ไฟล์สลิปหลักฐานมีปัญหา กรุณาอัปโหลดใหม่',
                style: TextStyle(
                  fontFamily: Font_.Fonts_T,
                  fontSize: 12,
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (widget.onUploadSlipAgain != null)
              InkWell(
                onTap: () => widget.onUploadSlipAgain!(widget.model),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(.1),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.blue.withOpacity(.3)),
                  ),
                  child: Text(
                    isEN ? 'Re-upload' : 'อัปโหลดใหม่',
                    style: TextStyle(
                      fontFamily: Font_.Fonts_T,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    // มีไฟล์สลิปปกติ (เหลือเฉพาะปุ่ม "ดู" ไม่ให้อัปใหม่)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(.2), width: .5),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              isEN ? 'Slip uploaded' : 'แนบหลักฐานแล้ว',
              style: TextStyle(
                fontFamily: Font_.Fonts_T,
                fontSize: 12,
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (widget.onViewSlip != null)
            InkWell(
              onTap: () => widget.onViewSlip!(widget.model),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(.1),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.purple.withOpacity(.3)),
                ),
                child: Text(
                  isEN ? 'View' : 'ดู',
                  style: TextStyle(
                    fontFamily: Font_.Fonts_T,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.purple,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
