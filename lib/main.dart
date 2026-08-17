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
// / flutter build web --release --web-renderer=html --dart-define=web-browser-flag=--disable-web-security
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
import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';

import 'Constant/api_session.dart';
import 'screen/loginscreen.dart';
import 'screen/provider/homeprovider.dart';
import 'screen/provider/payhisprovider.dart';
import 'screen/provider/payprovider.dart';
import 'screen/signin_service.dart';
import 'security/watermark_widget.dart';

// ==== ตัวแปรเก็บ URL เริ่มต้น (แก้ปัญหา Router ลบ Hash) ====
String initialAppUrl = '';

void main() {
  // ===== ปิด debugPrint และ print ทั้งหมดเมื่อ kEnableDebugPrint = true =====
  // ต้องครอบตั้งแต่ WidgetsFlutterBinding.ensureInitialized() ด้านใน Zone
  // มิฉะนั้น callback ของ Flutter (เช่น onPressed -> signInThread) จะรันใน
  // Zone.root และพ้นจากการดักจับ print
  runZonedGuarded(
    () async {
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

      // 1) ปิด debugPrint โดยตั้งเป็นฟังก์ชันว่าง
      // 2) ดักจับ print ผ่าน ZoneSpecification (print ไม่สามารถ assign ใหม่ได้)
      if (!kEnableDebugPrint) {
        debugPrint = (String? message, {int? wrapWidth}) {};
      }

      if (kEnableDebugPrint) {
        debugPrint('Initialization took: ${stopwatch.elapsedMilliseconds}ms');
      }

      runApp(const SplashApp());
    },
    (error, stack) {
      final message = 'Uncaught error: $error';
      if (kEnableDebugPrint) {
        debugPrint('$message\n$stack');
      }
      _appendAppDebugLog(message);
    },
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) {
        final message = line?.toString() ?? '';
        if (kEnableDebugPrint) {
          parent.print(zone, line);
        }
        _appendAppDebugLog(message);
      },
    ),
  );
}

// ==== bool เปิด/ปิด ลายน้ำ ====
const bool kShowWatermark = false; // ← true = เปิด, false = ปิด

// ==== bool เปิด/ปิด debugPrint ====
const bool kEnableDebugPrint = false; // ← true = เปิด, false = ปิด
final ValueNotifier<List<String>> appDebugLogs =
    ValueNotifier<List<String>>(<String>[]);
final ValueNotifier<bool> appShowDebugPanel = ValueNotifier<bool>(false);

void _appendAppDebugLog(String line) {
  // ??????? ValueNotifier rebuild ??????? build phase
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final logs = List<String>.from(appDebugLogs.value);
    logs.add(line);
    if (logs.length > 120) {
      logs.removeRange(0, logs.length - 120);
    }
    appDebugLogs.value = logs;
  });
}

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
          ...GlobalMaterialLocalizations.delegates,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
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

          return ValueListenableBuilder<List<String>>(
            valueListenable: appDebugLogs,
            builder: (context, logs, child) {
              return ValueListenableBuilder<bool>(
                valueListenable: appShowDebugPanel,
                builder: (context, showDebug, child) {
                  // ปิด debug overlay ทั้งหมดเมื่อ kEnableDebugPrint = true
                  // (ไม่งั้น Stack ครอบ child ทำให้ UI ซีดจาง + กิน hit-test)
                  if (!kEnableDebugPrint) {
                    return child!;
                  }
                  return Stack(
                    children: [
                      child!,
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: FloatingActionButton.small(
                          heroTag: 'debug-log-toggle',
                          backgroundColor: Colors.black87,
                          foregroundColor: Colors.white,
                          onPressed: () {
                            appShowDebugPanel.value = !showDebug;
                          },
                          child: const Icon(Icons.bug_report),
                        ),
                      ),
                      if (showDebug)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          height: MediaQuery.of(context).size.height * 0.45,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.85),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      const Text(
                                        'Debug Log',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          appShowDebugPanel.value = false;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(color: Colors.white54, height: 1),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: ListView.builder(
                                      itemCount: logs.length,
                                      reverse: true,
                                      itemBuilder: (context, index) {
                                        final log =
                                            logs[logs.length - 1 - index];
                                        return Text(
                                          log,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
                child: child,
              );
            },
            child: result,
          );
        },
        // home: const ButtonNavBar(),
        home: const AuthGate(),
        // home: FitnessAppHomeScreen(),
      ),
    );
  }
}

/// AuthGate - ตัวตัดสินใจว่าจะเปิดหน้าไหนเมื่อแอปเริ่มทำงาน (รวมถึงตอน refresh)
/// เลียนแบบ signInThread() ใน loginscreen.dart แต่อ่าน credentials จาก SharedPreferences
/// เพื่อให้ตอนรีเฟรชหน้าเว็บแล้ว ระบบเช็คก่อนว่าควรไปหน้าไหน
///   - ไม่มี credentials          -> LoginScreen
///   - backend ตอบ 1 ตลาด          -> FitnessAppHomeScreen(custno)
///   - backend ตอบหลายตลาด         -> MarketSelectScreen (ให้ผู้ใช้เลือก)
///   - backend ตอบผิดพลาด / error  -> LoginScreen
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Future<SignInResult>? _resultFuture;

  @override
  void initState() {
    super.initState();
    // ✅ Defer async validateSavedSession() ไปหลัง frame แรก
    // เพื่อหลีกเลี่ยง _LocalizationsScope assertion ใน window.dart
    if (_shouldLetLoginHandleUrl()) {
      _resultFuture = null;
    } else {
      // ใช้ Future.microtask แทน เพื่อให้แน่ใจว่า widget tree พร้อมแล้ว
      _resultFuture = Future<SignInResult>.microtask(
        () async => await SignInService.validateSavedSession(),
      );
    }
  }

  bool _shouldLetLoginHandleUrl() {
    final url = initialAppUrl.isNotEmpty ? initialAppUrl : Uri.base.toString();
    return url.contains('userWeb=') ||
        url.contains('username=') ||
        url.contains('passwd=') ||
        url.contains('serrental=') ||
        url.contains('line_code=') ||
        url.contains('line_error=');
  }

  // ✅ นำทางหลังจาก build เสร็จ เพื่อไม่ให้ LoginScreen.initState ทำงาน
  // ระหว่างที่ AuthGate กำลัง build (ป้องกัน setState during build loop)
  void _navigateTo(Widget page) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => page),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // URL พิเศษ -> ให้ LoginScreen จัดการเอง (นำทางหลัง build)
    if (_resultFuture == null) {
      _navigateTo(const LoginScreen());
      return const _GatePlaceholder();
    }

    return FutureBuilder<SignInResult>(
      future: _resultFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _GatePlaceholder();
        }

        if (!snapshot.hasData) {
          _navigateTo(const LoginScreen());
          return const _GatePlaceholder();
        }

        final result = snapshot.data!;

        // ✅ กรณีสำเร็จและ backend ตอบ 1 ตลาด -> เปิด FitnessAppHomeScreen
        if (result.destination != null) {
          _navigateTo(result.destination!);
          return const _GatePlaceholder();
        }

        // ✅ กรณี backend ตอบหลายตลาด -> เปิด MarketSelectScreen ให้ผู้ใช้เลือก
        if (result.requiresMarketSelection && result.validMarkets.isNotEmpty) {
          _navigateTo(SignInService.buildMarketSelectScreen(
              context, result.validMarkets));
          return const _GatePlaceholder();
        }

        // ✅ กรณี failure (ไม่มี creds / password ผิด / error) -> LoginScreen
        if (result.errorMessage != null) {
          debugPrint('AuthGate failure: ${result.errorMessage}');
        }
        _navigateTo(const LoginScreen());
        return const _GatePlaceholder();
      },
    );
  }
}

/// จอโหลดชั่วคราวระหว่างรอ AuthGate ตัดสินใจว่าจะไปหน้าไหน
class _GatePlaceholder extends StatelessWidget {
  const _GatePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(
          color: Colors.indigo,
        ),
      ),
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
    this.maxWidth = 500, // ขนาดสูงสุดโทรศัพท์
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
