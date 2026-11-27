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
// flutter build web --dart-define=BROWSER_IMAGE_DECODING_ENABLED=false-browser-flag=--disable-web-security --no-tree-shake-icons --base-href /user_test/
//----------------------------------------------------->

//----------------------------------------------------->
//
import 'dart:async';
import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';

import 'Constant/api_session.dart';
import 'debug/remote_debug_reporter.dart';
import 'screen/loginscreen.dart';
import 'screen/provider/homeprovider.dart';
import 'screen/provider/payhisprovider.dart';
import 'screen/provider/payprovider.dart';
import 'screen/signin_service.dart';
import 'security/watermark_widget.dart';

// ==== ตัวแปรเก็บ URL เริ่มต้น (แก้ปัญหา Router ลบ Hash) ====
String initialAppUrl = '';

const _debugLogEndpoint = String.fromEnvironment('DEBUG_LOG_ENDPOINT');
final _remoteDebugLoggingEnabled = _debugLogEndpoint.isNotEmpty;

Future<void> _reportDebugError(
  String source,
  Object error, [
  StackTrace? stackTrace,
]) async {
  if (!_remoteDebugLoggingEnabled) return;

  await reportRemoteDebugError(
    endpoint: _debugLogEndpoint,
    source: source,
    error: error.toString(),
    stackTrace: stackTrace?.toString() ?? '',
  );
}

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      if (kDebugMode || _remoteDebugLoggingEnabled) {
        FlutterError.onError = (details) {
          if (kDebugMode) {
            FlutterError.presentError(details);
            debugPrint('FLUTTER ERROR: ${details.exceptionAsString()}');
            debugPrintStack(stackTrace: details.stack);
          }
          unawaited(_reportDebugError(
            'FlutterError',
            details.exception,
            details.stack,
          ));
        };
        PlatformDispatcher.instance.onError = (error, stackTrace) {
          if (kDebugMode) {
            debugPrint('UNCAUGHT ERROR: $error');
            debugPrintStack(stackTrace: stackTrace);
          }
          unawaited(_reportDebugError('PlatformDispatcher', error, stackTrace));
          return true;
        };
        if (kDebugMode) {
          ErrorWidget.builder = (details) {
            debugPrint('WIDGET ERROR: ${details.exceptionAsString()}');
            debugPrintStack(stackTrace: details.stack);
            unawaited(_reportDebugError(
              'ErrorWidget',
              details.exception,
              details.stack,
            ));
            return Material(
              color: Colors.white,
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'DEBUG ERROR\n\n${details.exceptionAsString()}\n\n${details.stack ?? ''}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          };
        }
      }
      if (!kDebugMode) {
        debugPrint = (String? message, {int? wrapWidth}) {};
      }

      // สำคัญมาก: เก็บ URL ไว้ตั้งแต่เปิดแอป ก่อนที่ Flutter Router จะลบมันทิ้ง!
      initialAppUrl = currentDebugPageUrl();

      unawaited(_reportDebugError(
        'AppStart',
        'Flutter debug session started',
      ));

      // Initialize ApiSession to load saved tokens from SharedPreferences
      // Deferred: ไม่ block startup — โหลดแบบ fire-and-forget
      // (AuthGate จะเรียก getInstance() เองอยู่แล้ว จึงไม่ต้องรอที่นี่)
      unawaited(ApiSession.initialize());

      // เข้าแอปทันที — ตัด SplashApp ออกเพราะสร้าง MaterialApp ซ้ำอีกชั้น
      // และมี CircularProgressIndicator วนตลอด ทำให้เข้า login ช้าโดยไม่จำเป็น
      runApp(const MyApp());
    },
    (error, stack) {
      if (kDebugMode || _remoteDebugLoggingEnabled) {
        if (kDebugMode) {
          debugPrint('ZONE ERROR: $error');
          debugPrintStack(stackTrace: stack);
        }
        unawaited(_reportDebugError('Zone', error, stack));
      }
    },
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) {
        if (kDebugMode) {
          parent.print(zone, line);
        }
      },
    ),
  );
}

// ==== bool เปิด/ปิด ลายน้ำ ====
const bool kShowWatermark = false; // ← true = เปิด, false = ปิด

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

          // Debug overlay ถอดออกแล้ว — เคยมี ValueListenableBuilder 2 ชั้น
          // ครอบทั้งแอป ทำให้ทุก log rebuild ทั้ง tree
          return result;
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
  bool _hasNavigated = false;

  /// true = ยังไม่มี credentials ในเครื่อง → render Login ตรง ไม่ยิง API
  bool _skipToLogin = false;

  /// true เฉพาะช่วงอ่าน SharedPreferences รอบแรก
  ///
  /// แยกจาก _resultFuture เพราะ build รอบแรก _resultFuture ยัง null เสมอ
  /// ของเดิมตีความ null ว่า "ไป Login" แล้ว schedule MaterialPageRoute ทันที
  /// แม้ _runGate กำลังเช็ค credentials อยู่ ทำให้ route แข่งกับ auth validation
  bool _isCheckingSavedCredentials = false;

  @override
  void initState() {
    super.initState();
    // URL special ต้องให้ LoginScreen จัดการทันที (LINE callback / userWeb)
    if (_shouldLetLoginHandleUrl()) {
      _skipToLogin = true;
    } else {
      _isCheckingSavedCredentials = true;
      _runGate();
    }
  }

  /// Fast path: เช็ค credentials ในเครื่องก่อน (ไม่ยิง network)
  ///
  /// เปิดเว็บครั้งแรกที่ยังไม่ล็อกอิน → ไม่มี credentials → ไป Login ทันที
  /// ไม่ต้องรอ `validateSavedSession()` ที่ยิง POST ไป backend
  Future<void> _runGate() async {
    final hasCredentials = await SignInService.hasSavedCredentials();
    if (!mounted) return;

    setState(() {
      _isCheckingSavedCredentials = false;
      if (hasCredentials) {
        // มี credentials ค่อย validate กับ backend ใน FutureBuilder ด้านล่าง
        _resultFuture = SignInService.validateSavedSession();
      } else {
        // ไม่มี credentials: Login render ตรงใน AuthGate, ไม่ยิง POST
        _skipToLogin = true;
      }
    });
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
    if (_hasNavigated) return;
    _hasNavigated = true;

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
    // URL special หรือไม่มี credentials → render Login เป็น child ตรง ๆ
    //
    // ห้ามใช้ _navigateTo ที่นี่: route post-frame เพิ่ม frame/transition และ
    // build แรก _resultFuture ยัง null ทำให้ route แข่งกับ _runGate จน startup ช้า
    // LoginScreen เองไม่ยิง POST เมื่อไม่มี URL special / credentials
    if (_skipToLogin) {
      return const LoginScreen();
    }

    // ระหว่าง SharedPreferences read ครั้งเดียว: มี placeholder สั้น ๆ เท่านั้น
    if (_isCheckingSavedCredentials || _resultFuture == null) {
      return const _GatePlaceholder();
    }

    return FutureBuilder<SignInResult>(
      future: _resultFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _GatePlaceholder();
        }

        // validate credentials ล้มเหลว → render Login ตรง ไม่ route ซ้อน
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        final result = snapshot.data!;

        // ✅ กรณีสำเร็จและ backend ตอบ 1 ตลาด -> เปิด FitnessAppHomeScreen
        if (result.destination != null) {
          _navigateTo(result.destination!);
          return const _GatePlaceholder();
        }

        // ✅ กรณี backend ตอบหลายตลาด -> เปิด MarketSelectScreen ให้ผู้ใช้เลือก
        if (result.requiresMarketSelection && result.validMarkets.isNotEmpty) {
          _navigateTo(
              SignInService.buildMarketSelectScreen(result.validMarkets));
          return const _GatePlaceholder();
        }

        // backend validation failure → Login render ตรง ไม่เพิ่ม route/frame
        if (result.errorMessage != null) {
          debugPrint('AuthGate failure: ${result.errorMessage}');
        }
        return const LoginScreen();
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
