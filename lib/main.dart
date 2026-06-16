// /----------------------------------------------------->
// / flutter run --enable-software-rendering
// / flutter run -d chrome --web-renderer html --enable-software-rendering
// / flutter run -d chrome  --no-sound-null-safety
// / flutter run -d chrome --web-browser-flag "--disable-web-security" (แก้ปัญหา security  CORS (Cross-Origin Resource Sharing))
// /----------------------------------------------------->
// / flutter build web --web-renderer html --release
// /  flutter build web --release --no-sound-null-safety
// /  flutter build web --web-renderer html --release --dart-define=web-browser-flag=--disable-web-security (แก้ปัญหา security  CORS (Cross-Origin Resource Sharing))
// /  flutter build web --web-renderer html --release --no-sound-null-safety --dart-define=web-browser-flag=--disable-web-security (แก้ปัญหา security  CORS (Cross-Origin Resource Sharing))
// /  flutter build web --release --web-renderer=html --dart-define=web-browser-flag=--disable-web-security
// /
// /
// /flutter build web --dart-define=BROWSER_IMAGE_DECODING_ENABLED=false   (แก้ปัญหา Security Capture Screen )
// /flutter build web --dart-define=BROWSER_IMAGE_DECODING_ENABLED=false-browser-flag=--disable-web-security
// /flutter build web --dart-define=BROWSER_IMAGE_DECODING_ENABLED=false-define=web-browser-flag=--disable-web-security --no-tree-shake-icons
// ** */ flutter build web --dart-define=BROWSER_IMAGE_DECODING_ENABLED=false-browser-flag=--disable-web-security --no-tree-shake-icons --base-href /user_intents/
// flutter build web --dart-define=BROWSER_IMAGE_DECODING_ENABLED=false-browser-flag=--disable-web-security --no-tree-shake-icons --base-href /user/
//----------------------------------------------------->

//----------------------------------------------------->
//
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';

import 'Constant/api_session.dart';
import 'screen/Screen_new/fitness_app_home_screen.dart';
import 'screen/loginscreen.dart';
import 'screen/provider/homeprovider.dart';
import 'screen/provider/payhisprovider.dart';
import 'screen/provider/payprovider.dart';
import 'security/watermark_widget.dart';

// ==== ตัวแปรเก็บ URL เริ่มต้น (แก้ปัญหา Router ลบ Hash) ====
String initialAppUrl = '';

void main() async {
  // เก็บเวลาเริ่มต้นเพื่อวัดประสิทธิภาพ
  final stopwatch = Stopwatch()..start();

  WidgetsFlutterBinding.ensureInitialized();

  // สำคัญมาก: เก็บ URL ไว้ตั้งแต่เปิดแอป ก่อนที่ Flutter Router จะลบมันทิ้ง!
  initialAppUrl = Uri.base.toString();
  try {
    initialAppUrl = Uri.decodeFull(html.window.location.href);
  } catch (e) {}

  // Initialize ApiSession to load saved tokens from SharedPreferences
  await ApiSession.initialize();

  debugPrint('Initialization took: ${stopwatch.elapsedMilliseconds}ms');

  // ปิด debugPrint ถ้า kEnableDebugPrint = false
  if (!kEnableDebugPrint) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  runApp(const SplashApp());
}

// ==== bool เปิด/ปิด ลายน้ำ ====
const bool kShowWatermark = false; // ← true = เปิด, false = ปิด

// ==== bool เปิด/ปิด debugPrint ====
const bool kEnableDebugPrint = true; // ← true = เปิด, false = ปิด

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) {
          return WaitPayListProvider();
        }),
        ChangeNotifierProvider(create: (context) {
          return PayFormProvider();
        }),
        ChangeNotifierProvider(create: (context) {
          return PayHisProvider();
        }),
      ],
      child: MaterialApp(
        // ignore: prefer_const_literals_to_create_immutables
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          SfGlobalLocalizations.delegate
        ],
        // ignore: prefer_const_literals_to_create_immutables
        supportedLocales: [
          const Locale('en', 'US'), // English
          const Locale('th', 'TH'), // Thai
          const Locale('lo', 'LA'), // Lao
        ],
        locale: const Locale('th'),
        title: 'Chaoperty',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primarySwatch: Colors.green,
            scrollbarTheme: const ScrollbarThemeData().copyWith(
              thumbColor: MaterialStateProperty.all(Colors.lightGreen[200]),
            )),
        // เพิ่ม Watermark ครอบทุกหน้า (เปิด/ปิดด้วย kShowWatermark)
        // และจำกัดขนาดสูงสุดแค่แท็บเล็ตด้วย ResponsiveWrapper
        builder: (context, child) {
          Widget result = child!;

          // ป้องกัน UI แตกเมื่อ user ขยายฟอนต์ระบบ (Accessibility)
          final mediaQuery = MediaQuery.of(context);
          result = MediaQuery(
            data: mediaQuery.copyWith(
              textScaler: TextScaler.linear(1.0), // ล็อกขนาดฟอนต์ให้คงที่
            ),
            child: result,
          );

          // จำกัดขนาดสูงสุดคือโทรศัพท์ (480px)
          result = ResponsiveWrapper(child: result);

          // เพิ่มลายน้ำถ้าเปิด
          if (kShowWatermark) {
            result = WatermarkOverlay(
              text: 'USER-${DateTime.now().millisecondsSinceEpoch}',
              child: result,
            );
          }

          return result;
        },
        // home: const ButtonNavBar(),
        home: const AuthGate(),
        // home: FitnessAppHomeScreen(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  bool _shouldLetLoginHandleUrl() {
    final url = initialAppUrl.isNotEmpty ? initialAppUrl : Uri.base.toString();
    return url.contains('userWeb=') ||
        url.contains('username=') ||
        url.contains('passwd=') ||
        url.contains('serrental=') ||
        url.contains('line_code=') ||
        url.contains('line_error=');
  }

  Future<String?> _readSavedCustomerNo() async {
    if (_shouldLetLoginHandleUrl()) return null;

    final preferences = await SharedPreferences.getInstance();
    final custno = preferences.getString('custno')?.trim();
    if (custno == null || custno.isEmpty) return null;

    return custno;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _readSavedCustomerNo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.indigo,
              ),
            ),
          );
        }

        final custno = snapshot.data;
        if (custno != null) {
          return FitnessAppHomeScreen(custno_s: custno);
        }

        return const LoginScreen();
      },
    );
  }
}

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }
}

// Splash Screen ที่โหลดเร็วก่อนแอปหลัก
class SplashApp extends StatefulWidget {
  const SplashApp({super.key});

  @override
  State<SplashApp> createState() => _SplashAppState();
}

class _SplashAppState extends State<SplashApp> {
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // โหลดข้อมูลที่จำเป็นใน background
    // จำลองการโหลด (เอาออกได้ถ้าไม่ต้องการ)
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _isReady = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isReady) {
      return const MyApp();
    }

    // Splash Screen ง่ายๆ โหลดเร็ว
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ใช้ Icon แทนรูป (โหลดเร็วกว่า)
              // const Icon(
              //   Icons.home_work,
              //   size: 80,
              //   color: Colors.white,
              // ),
              const SizedBox(height: 20),
              // const Text(
              //   'Chaoperty',
              //   style: TextStyle(
              //     fontSize: 32,
              //     fontWeight: FontWeight.bold,
              //     color: Colors.black,
              //   ),
              // ),
              // รูปอยู่ใน CircularProgressIndicator
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // CircularProgressIndicator รอบนอก
                    const SizedBox(
                      width: 90,
                      height: 90,
                      child: CircularProgressIndicator(
                        color: Colors.indigo,
                        strokeWidth: 4,
                      ),
                    ),
                    // รูปตรงกลาง
                    ClipOval(
                      child: Image.asset(
                        'images/Icon-chao.png',
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ResponsiveWrapper - จำกัดขนาดสูงสุดคือโทรศัพท์ (480px)
// และสไลด์ด้านข้างได้เมื่อหน้าจอน้อยกว่า 300px
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final double minWidth; // ขนาดขั้นต่ำที่ต้องการ

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.maxWidth = 480, // ขนาดสูงสุดโทรศัพท์
    this.minWidth = 330, // ขนาดขั้นต่ำที่รองรับ
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // พื้นหลังสีเทาด้านนอก
      body: LayoutBuilder(
        builder: (context, constraints) {
          // ถ้าหน้าจอเล็กกว่า minWidth ให้สไลด์ด้านข้างได้
          final bool needScroll = constraints.maxWidth < minWidth;

          return Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                maxHeight: double.infinity,
              ),
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: needScroll
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: minWidth,
                        height: constraints.maxHeight,
                        child: ClipRect(
                          child: child,
                        ),
                      ),
                    )
                  : ClipRect(
                      child: child,
                    ),
            ),
          );
        },
      ),
    );
  }
}
