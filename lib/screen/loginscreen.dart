import 'dart:convert';
import 'dart:html' as html;
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Constant/Myconstant.dart';
import '../Constant/api_session.dart';
import '../Model/GetC_regis_Model.dart';
import '../Model/GetCustomer_Model.dart';
import '../Model/GetRenTal_Model.dart';
import '../color.dart';
import '../screen_Intents/APIS-V2/payment-intents.dart';
import 'Screen_new/fitness_app_home_screen.dart';
import 'Screen_new/fitness_app_theme.dart';
import 'Screen_new/ui_view/workout_view.dart';
import '../Constant/app_markets.dart';
import 'market_select_screen.dart';
import 'market_service.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final userController = TextEditingController();
  final passwordController = TextEditingController();
  final formkey = GlobalKey<FormState>();
  List<RenTalModel> renTalModels = [];
  String? renTal_name, renTal_user, Username_user, user_id, line_rser;
  int ser_Web = 0;
  bool _obscureText = true;
  String? _codeVerifier;
  html.EventListener? _messageHandler;

  // เพิ่มฟังก์ชันสำหรับสร้าง Code Verifier
  String _generateCodeVerifier() {
    var random = Random.secure();
    var values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64UrlEncode(values).replaceAll('=', '');
  }

  // เพิ่มฟังก์ชันสำหรับสร้าง Code Challenge
  String _generateCodeChallenge(String verifier) {
    var bytes = utf8.encode(verifier);
    var digest = sha256.convert(bytes);
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }

  @override
  void initState() {
    super.initState();

    // ตรวจสอบ URL fragment จาก LINE callback (กรณี redirect กลับมา)
    _checkLineCallback();

    // รับ callback จาก LINE OAuth (ผ่าน auth.html)
    _setupLineOAuthListener();

    Line_IoginAuto().then((value) {
      // print('object>>. $value');
      if (ser_Web == 0) {
        checkPreferance();
      }
    });
  }

  // ตรวจสอบ URL fragment จาก LINE callback
  void _checkLineCallback() {
    final hash = html.window.location.hash;
    print('=== _checkLineCallback ===');
    print('URL hash: $hash');

    if (hash.contains('line_code=')) {
      // ดึง code จาก URL fragment
      final params = Uri.parse('http://localhost/?${hash.substring(1)}');
      final code = params.queryParameters['line_code'];
      print(
          'Extracted code: ${code?.substring(0, 10)}...'); // แสดงแค่ 10 ตัวแรก

      if (code != null) {
        // ล้าง URL fragment
        html.window.history.replaceState(null, '', '/');
        // แลก code เป็น token
        _exchangeCodeForToken(code);
      }
    } else if (hash.contains('line_error=')) {
      final params = Uri.parse('http://localhost/?${hash.substring(1)}');
      final error = params.queryParameters['line_error'];
      html.window.history.replaceState(null, '', '/');
      print('LINE Login Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('LINE Login Failed: $error')),
      );
    } else {
      print('No LINE callback data in URL');
    }
  }

  // ตั้งค่า listener รับ message จาก auth.html (LINE OAuth callback)
  void _setupLineOAuthListener() {
    _messageHandler = (html.Event event) {
      final data = (event as html.MessageEvent).data;
      if (data is String) {
        try {
          final map = json.decode(data);
          if (map['type'] == 'LINE_LOGIN_SUCCESS') {
            final code = map['code'] as String?;
            if (code != null && mounted) {
              _exchangeCodeForToken(code);
            }
          } else if (map['type'] == 'LINE_LOGIN_ERROR') {
            final error = map['error'] as String?;
            print('LINE Login Error: $error');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('LINE Login Failed: $error')),
              );
            }
          }
        } catch (_) {}
      }
    };
    html.window.addEventListener('message', _messageHandler);
  }

  @override
  void dispose() {
    if (_messageHandler != null) {
      html.window.removeEventListener('message', _messageHandler);
      _messageHandler = null;
    }
    super.dispose();
  }

  // แลก authorization code เป็น access token
  Future<void> _exchangeCodeForToken(String code) async {
    if (!mounted) return;

    // Guard ผ่าน localStorage เพื่อป้องกันการทำงานซ้ำข้าม widget instance
    // (กรณี hot reload สะสม listener หลายตัว)
    const String processingKey = 'line_processing_code';
    if (html.window.localStorage[processingKey] == code) {
      print('=== _exchangeCodeForToken: Already processing, skipping ===');
      return;
    }
    html.window.localStorage[processingKey] = code;

    const String lineChannelId = '2007879464';
    const String lineCallbackUrl =
        'https://chaoperties.com/user_test/auth.html';

    print('=== _exchangeCodeForToken ===');
    print('Code: ${code.substring(0, 10)}...');
    print('Channel ID: $lineChannelId');
    print('Callback URL: $lineCallbackUrl');

    try {
      print('Sending request to LINE API...');

      // อ่าน verifier จาก localStorage เสมอ เพื่อให้ถูกต้องแม้ widget ถูก rebuild
      // ใช้ in-memory เป็น fallback
      final verifier =
          html.window.localStorage['line_code_verifier']?.toString() ??
              _codeVerifier;

      final Map<String, String> requestBody = <String, String>{
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': lineCallbackUrl,
        'client_id': lineChannelId,
      };

      if (verifier != null && verifier.isNotEmpty) {
        requestBody['code_verifier'] = verifier;
      }

      final response = await http.post(
        Uri.parse('https://api.line.me/oauth2/v2.1/token'),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: requestBody,
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final accessToken = data['access_token'] as String;
        final idToken = data['id_token'];

        print('Access Token: ${accessToken.substring(0, 20)}...');
        print('ID Token: ${idToken?.toString().substring(0, 20)}...');

        await _getLineUserInfo(accessToken);
      } else {
        print('Token exchange failed!');
        print('Error: ${response.body}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('LINE Login Failed: ${response.statusCode}')),
          );
        }
      }
    } catch (e, stackTrace) {
      print('Error exchanging code: $e');
      print('Stack trace: $stackTrace');
    } finally {
      html.window.localStorage.remove(processingKey);
      html.window.localStorage.remove('line_code_verifier');
      _codeVerifier = null;
    }
  }

  // ดึงข้อมูล user จาก LINE และ login ต่อ
  Future<void> _getLineUserInfo(String accessToken) async {
    print('=== _getLineUserInfo ===');
    print('Access Token: ${accessToken.substring(0, 20)}...');

    try {
      print('Fetching profile from LINE API...');
      final response = await http.get(
        Uri.parse('https://api.line.me/v2/profile'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('Profile response status: ${response.statusCode}');
      print('Profile response body: ${response.body}');

      if (response.statusCode == 200) {
        final profile = json.decode(response.body);
        final lineUserId = profile['userId'];
        final displayName = profile['displayName'];

        print('LINE User ID: $lineUserId');
        print('Display Name: $displayName');

        // เชื่อมต่อกับระบบ login โดยตั้งค่า ser_Web = 2 (LINE OAuth mode)
        setState(() {
          userController.text = lineUserId;
          user_id = lineUserId;
          ser_Web = 2;
        });

        print('Calling signInThread with ser_Web=2...');
        // เรียก login
        signInThread();
      } else {
        print('Failed to get profile: ${response.statusCode}');
        print('Error body: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('Error getting user info: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<Null> checkPreferance() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? custno = preferences.getString('custno');
    // print(' checkPreferance >>> $custno');
    if (custno != null && custno.isNotEmpty) {
      MaterialPageRoute route = MaterialPageRoute(
        builder: (context) => FitnessAppHomeScreen(
            custno_s: custno), //SelectCid(custno_s: custno),
      );
      // ignore: use_build_context_synchronously
      Navigator.pushAndRemoveUntil(context, route, (route) => false);
    } else {}
  }

  List<Color> _kDefaultRainbowColors = const [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
  ];

  Future<int> Line_IoginAuto() async {
    // ใช้ initialAppUrl ที่เก็บไว้ตอนเปิดแอปก่อนโดน router ลบทิ้ง
    String url = initialAppUrl;
    if (url.isEmpty) {
      url = Uri.decodeFull(Uri.base.toString());
    }

    try {
      int index = url.indexOf('userWeb=');
      int index2 = url.indexOf('username=');
      int index3 = url.indexOf('passwd=');
      int index4 = url.indexOf('serrental=');
      int index5 = url.indexOf('userid=');

      if (index != -1 || index2 != -1 || index3 != -1 || index4 != -1) {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        setState(() {
          preferences.clear();
        });

        index += 'userWeb='.length;
        index2 += 'username='.length;
        index3 += 'passwd='.length;
        index4 += 'serrental='.length;
        index5 += 'userid='.length;

        int endIndex = url.indexOf(',', index);
        int endIndex2 = url.indexOf(',', index2);
        int endIndex3 = url.indexOf(',', index3);
        int endIndex4 = url.indexOf(',', index4);
        int endIndex5 = url.indexOf(',', index5);

        if (endIndex == -1) endIndex = url.length;
        if (endIndex2 == -1) endIndex2 = url.length;
        if (endIndex3 == -1) endIndex3 = url.length;
        if (endIndex4 == -1) endIndex4 = url.length;
        if (endIndex5 == -1) endIndex5 = url.length;

        String userWeb = url.substring(index, endIndex);
        String usernameWeb = url.substring(index2, endIndex2);
        String passwdWeb = url.substring(index3, endIndex3);
        String rser = url.substring(index4, endIndex4);
        String userid = url.substring(index5, endIndex5);

        setState(() {
          userController.text = usernameWeb;
          passwordController.text = passwdWeb;
          user_id = userid;
          line_rser = rser;
          ser_Web = 1;
        });

        signInThread();
      } else {
        // ถอด URL ออกมาแล้วแต่หา userWeb ไม่เจอ ให้โชว์เพื่อแก้บัค
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Debug: URL Parsing Failed"),
            content: Text("URL: $url"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Debug: Line_IoginAuto Error"),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
    }

    return ser_Web;
  }

  // LINE Official OAuth Login
  void _lineLoginOAuth() {
    // === ตั้งค่า LINE OAuth ที่นี่ ===
    const String lineChannelId = '2007879464'; // Channel ID จาก LINE Console

    // ใช้ redirect_uri เดียวสำหรับทุก environment
    // ต้องลงทะเบียน URL นี้ใน LINE Developers Console
    // เปลี่ยนตาม path ที่ deploy: /user/ หรือ /user_test/
    const String lineCallbackUrl =
        'https://chaoperties.com/user_test/auth.html';
    print('=== _lineLoginOAuth ===');
    print('Callback URL: $lineCallbackUrl');
    const String lineState = 'chaoperty_login_state';

    _codeVerifier = _generateCodeVerifier();
    html.window.localStorage['line_code_verifier'] = _codeVerifier!;
    final String codeChallenge = _generateCodeChallenge(_codeVerifier!);

    // สร้าง LINE Login URL
    final String encodedCallback = Uri.encodeComponent(lineCallbackUrl);
    final String lineLoginUrl = 'https://access.line.me/oauth2/v2.1/authorize?'
        'response_type=code'
        '&client_id=$lineChannelId'
        '&redirect_uri=$encodedCallback'
        '&state=$lineState'
        '&scope=profile%20openid%20email'
        '&code_challenge_method=S256'
        '&code_challenge=$codeChallenge'
        '&prompt=consent';

    // เปิด LINE Login เป็น Popup (เพื่อไม่ให้เสีย State ของ Flutter)
    final int width = 500;
    final int height = 600;
    final int left = ((html.window.screen?.width ?? 1024) - width) ~/ 2;
    final int top = ((html.window.screen?.height ?? 768) - height) ~/ 2;

    html.window.open(lineLoginUrl, 'line_login',
        'width=$width,height=$height,top=$top,left=$left');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FitnessAppTheme.background,
      body: Stack(
        children: [
          // Background design elements (optional, can be simple color)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.4,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    const Color.fromARGB(255, 228, 229, 243), // Lighter tint
                    const Color.fromARGB(255, 193, 195, 224), // Original Color
                    const Color.fromARGB(255, 215, 217, 238), // Soft transition
                    Colors.white,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
            ),
          ),

          // Privacy Policy Button (Top Right)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: InkWell(
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Privacy_Policy(
                          Url:
                              'https://chaoperties.com/chao_api/Awaitdownload/Privacy_Policy.pdf',
                          title: ' เช่าเพอร์ตี้ Privacy Policy')),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.privacy_tip_outlined,
                      color: Colors.black,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Privacy Policy',
                      style: TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        fontSize: 12,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Main Login Card
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 32, horizontal: 24),
                    child: Form(
                      key: formkey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo
                          SizedBox(
                            height: 100,
                            child: Image.asset("images/chaoperty_dark.png",
                                fit: BoxFit.contain),
                          ),
                          const SizedBox(height: 16),

                          // Title
                          Text(
                            'Tenant ',
                            style: TextStyle(
                              fontFamily: Font_.Fonts_T,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: FitnessAppTheme.darkText,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'สําหรับผู้เช่า ',
                            style: TextStyle(
                              fontFamily: Font_.Fonts_T,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: FitnessAppTheme.darkText,
                            ),
                          ),
                          // Text(
                          //   'Member User',
                          //   style: TextStyle(
                          //     fontFamily: Font_.Fonts_T,
                          //     fontSize: 14,
                          //     color: FitnessAppTheme.lightText,
                          //   ),
                          // ),
                          const SizedBox(height: 32),

                          // Username Field
                          TextFormField(
                            style: const TextStyle(
                              fontFamily: Font_.Fonts_T,
                            ),
                            controller: userController,
                            validator: (str) {
                              if (str!.isEmpty) {
                                return "กรุณากรอก Username";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.person,
                                  color: FitnessAppTheme.grey),
                              hintText: "username",
                              hintStyle: TextStyle(
                                color: FitnessAppTheme.grey.withOpacity(0.5),
                                fontFamily: Font_.Fonts_T,
                              ),
                              filled: true,
                              fillColor:
                                  FitnessAppTheme.notWhite.withOpacity(0.4),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                    color: FitnessAppTheme.nearlyDarkBlue,
                                    width: 1),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          TextFormField(
                            style: const TextStyle(
                              fontFamily: Font_.Fonts_T,
                            ),
                            controller: passwordController,
                            obscureText: _obscureText,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'กรุณากรอก Password!!';
                              }
                              return null;
                            },
                            onFieldSubmitted: (value) {
                              if (formkey.currentState!.validate()) {
                                signInThread();
                              }
                            },
                            decoration: InputDecoration(
                              prefixIcon:
                                  Icon(Icons.lock, color: FitnessAppTheme.grey),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: FitnessAppTheme.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                              ),
                              hintText: "password",
                              hintStyle: TextStyle(
                                color: FitnessAppTheme.grey.withOpacity(0.5),
                                fontFamily: Font_.Fonts_T,
                              ),
                              filled: true,
                              fillColor:
                                  FitnessAppTheme.notWhite.withOpacity(0.4),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                    color: FitnessAppTheme.nearlyDarkBlue,
                                    width: 1),
                              ),
                            ),
                          ),

                          // Forgot Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        titlePadding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        clipBehavior: Clip.hardEdge,
                                        title: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10.0,
                                                vertical: 12.0),
                                            color:
                                                FitnessAppTheme.nearlyDarkBlue,
                                            child: Center(
                                              child: Text(
                                                "โปรดติดต่อเจ้าหน้าที่",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: Font_.Fonts_T,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            )),
                                        content: Container(
                                          constraints: const BoxConstraints(
                                              maxWidth: 400),
                                          padding: const EdgeInsets.all(20),
                                          child: Text(
                                            "กรุณาติดต่อเจ้าหน้าที่ดูแลโครงการ\nเพื่อขอทำการรีเซ็ตรหัสผ่าน",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: Font_.Fonts_T,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        actions: <Widget>[
                                          Center(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 16),
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      FitnessAppTheme
                                                          .nearlyDarkRed,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 32,
                                                      vertical: 10),
                                                ),
                                                onPressed: () => Navigator.pop(
                                                    context, 'OK'),
                                                child: const Text(
                                                  'ปิด',
                                                  style: TextStyle(
                                                    fontFamily: Font_.Fonts_T,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    });
                              },
                              child: Text(
                                "ลืมรหัสผ่าน ?",
                                style: TextStyle(
                                  color: FitnessAppTheme.grey,
                                  fontFamily: Font_.Fonts_T,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Login Button
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  FitnessAppTheme.nearlyDarkBlue,
                                  const Color(0xFF4F46E5),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: FitnessAppTheme.nearlyDarkBlue
                                      .withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: ElevatedButton(
                                  onPressed: () async {
                                    print('button pressed');
                                    final valid =
                                        formkey.currentState!.validate();
                                    print('validate: $valid');
                                    if (valid) {
                                      signInThread();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: const Text(
                                    "เข้าสู่ระบบ",
                                    style: TextStyle(
                                        fontFamily: Font_.Fonts_T,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.white),
                                  )),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // LINE Login Button (Official OAuth)
                          // Container(
                          //   width: double.infinity,
                          //   decoration: BoxDecoration(
                          //     // color: const Color(0xFF06C755), // LINE Green
                          //     borderRadius: BorderRadius.circular(30),
                          //     // boxShadow: [
                          //     //   BoxShadow(
                          //     //     color:
                          //     //         const Color(0xFF06C755).withOpacity(0.3),
                          //     //     blurRadius: 12,
                          //     //     offset: const Offset(0, 6),
                          //     //   ),
                          //     // ],
                          //   ),
                          //   child: ElevatedButton.icon(
                          //     onPressed: () {
                          //       // LINE Official OAuth Login
                          //       _lineLoginOAuth();
                          //     },
                          //     icon: ClipRRect(
                          //       borderRadius: BorderRadius.circular(4),
                          //       child: Image.asset(
                          //         'images/line_company_thailand_logo.webp',
                          //         width: 20,
                          //         height: 20,
                          //       ),
                          //     ),
                          //     label: const Text(
                          //       "เข้าสู่ระบบด้วย LINE",
                          //       style: TextStyle(
                          //         fontFamily: Font_.Fonts_T,
                          //         fontWeight: FontWeight.bold,
                          //         fontSize: 14,
                          //         color: Colors.grey,
                          //       ),
                          //     ),
                          //     style: ElevatedButton.styleFrom(
                          //       backgroundColor: Colors.transparent,
                          //       shadowColor: Colors.transparent,
                          //       shape: RoundedRectangleBorder(
                          //         borderRadius: BorderRadius.circular(30),
                          //       ),
                          //       padding:
                          //           const EdgeInsets.symmetric(vertical: 16),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Footer
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(12),
              color: Colors.white.withOpacity(0.9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.copyright,
                    color: FitnessAppTheme.grey,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Center(
                      child: Text(
                        '2023-2026 Dzentric Co.,Ltd. All Rights Reserved',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: FitnessAppTheme.grey,
                            fontWeight: FontWeight.w500,
                            fontFamily: Font_.Fonts_T,
                            fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  signInThread() async {
    if (!mounted) return;
    print('=== signInThread ===');
    var user = userController.text.toString();
    var id_token = (ser_Web == 1 || ser_Web == 2) ? user_id : '';

    // ตรวจสอบว่าเป็น LINE OAuth Login (ser_Web == 2) หรือไม่
    bool isLineOAuth = ser_Web == 2;

    String password = isLineOAuth
        ? '' // LINE OAuth ไม่ต้องใช้ password
        : (ser_Web == 1
            ? passwordController.text.toString()
            : md5.convert(utf8.encode(passwordController.text)).toString());

    String url = '${MyConstant().domain}/GC_user_loginV2.php';

    print('URL: $url');
    print('Username: $user');
    print('isLineOAuth: $isLineOAuth');
    print('ser_Web: $ser_Web');
    print('id_token: $id_token');
    print('line_rser: $line_rser');

    try {
      print('Sending request to backend...');
      var response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: json.encode({
          'isAdd': 'true',
          'username': user,
          'password': password,
          'idtoken': id_token,
          'line_rser': line_rser,
          'is_line_oauth':  isLineOAuth ? '1' : '0',
        }),
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      var decoded = json.decode(response.body);
      print('Decoded JSON: $decoded');

      var result;
      if (decoded is List) {
        result = decoded;
      } else if (decoded is Map && decoded['status'] == true) {
        result = decoded['data'];
      }
      print('Result data: $result');

      if (result != null && result is List) {
        print('Found user data, processing...');

        // Parse all results
        final List<c_regis_Model> allModels = (result as List)
            .map<c_regis_Model>((map) => c_regis_Model.fromJson(map))
            .toList();

        // For LINE / auto-login all rows are valid; for normal login check password once
        List<c_regis_Model> validModels;
        if (isLineOAuth || ser_Web == 1) { // <--- เพิ่ม ser_Web == 1
          validModels = allModels;
        } else {
          // All rows belong to the same user — check password against first row
          final firstPasswd =
              allModels.isNotEmpty ? allModels.first.passwd ?? '' : '';
          if (password.trim() == firstPasswd.trim()) {
            validModels = allModels;
          } else {
            validModels = [];
          }
        }

        if (validModels.isEmpty) {
          setState(() => passwordController.clear());
          if (!mounted) return;
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                surfaceTintColor: Colors.white,
                backgroundColor: Colors.white,
                title: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: const Text(
                    'Username & password ผิดพลาด กรุณาลองใหม่!',
                    style: TextStyle(fontFamily: Font_.Fonts_T),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('ปิด'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              );
            },
          );
        } else if (validModels.length == 1) {
          // Single market — proceed directly
          final m = validModels.first;
          print('Single market login: ${m.custno}');
          routeToService(FitnessAppHomeScreen(custno_s: m.custno), m);
        } else {
          // Multiple markets — save list then let user pick
          AppMarkets.markets = validModels;
          print('Multiple markets (${validModels.length}) — showing selection');
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MarketSelectScreen(
                markets: validModels,
                onSelect: (selected) =>
                    MarketService.applyMarket(context, selected),
              ),
            ),
          );
        }
      } else {
        // แจ้งเตือนเมื่อไม่พบผู้ใช้หรือเข้าสู่ระบบไม่สำเร็จ
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("ไม่สามารถเข้าสู่ระบบได้"),
            content: Text("ตรวจสอบ Username และ Password อีกครั้ง"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e, stackTrace) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Debug: API Error"),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  Future<Null> routeToService(
    Widget myWidget,
    c_regis_Model cregisModel,
  ) async {
    var rser = cregisModel.rser;
    var cusno = cregisModel.custno;
    var u_ser = cregisModel.ser;

    await ApiSession.setBearerToken(cregisModel.payEncoded64 ?? '');
    await ApiSession.setNonceId(cregisModel.fid ?? '');
    // print('ser user >>>>>>>>>> $u_ser');
    // if (rser != '106') {
    String url =
        '${MyConstant().domain}/Gc_customer_user.php?isAdd=true&ren=$rser&cusno=$cusno';

    var response = await http.get(Uri.parse(url));

    var result = json.decode(response.body);
    for (var map in result) {
      CustomerModel customerModel = CustomerModel.fromJson(map);

      SharedPreferences preferences = await SharedPreferences.getInstance();
      if (ser_Web == 1) {
        preferences.setString('custno', cregisModel.custno!);
        preferences.setString('pass_word', cregisModel.passwd.toString());
        preferences.setString('UsernameUSer', cregisModel.username.toString());
        preferences.setString('renTalSer', cregisModel.rser!);
        preferences.setString('renTalName', cregisModel.pn!);
        preferences.setString('lintid', user_id.toString());
        preferences.setString('ser', u_ser.toString());
        preferences.setString('cname', customerModel.cname.toString());
        preferences.setString('sname', customerModel.scname.toString());
        preferences.setString('email', customerModel.email.toString());
        preferences.setString('photo', customerModel.addr2.toString());
        preferences.setString('address', customerModel.addr1.toString());
        preferences.setString('contact', customerModel.attn.toString());
        preferences.setString('stype', customerModel.stype.toString());
        preferences.setString('tel', customerModel.tel.toString());
        preferences.setString('tax', customerModel.tax.toString());
        preferences.setString('foder', customerModel.foder.toString());
        preferences.setString('lang', cregisModel.language.toString());
        preferences.setString('pay_token', cregisModel.payToken ?? '');
        preferences.setString('pay_encoded64', cregisModel.payEncoded64 ?? '');
        preferences.setString('fid', cregisModel.fid ?? '');

        // Get customer JWT token for payment API
        await _getAndStoreCustomerToken(cusno, rser);

        setState(() {
          ser_Web = 0;
        });
      } else {
        preferences.setString('custno', cregisModel.custno!);
        preferences.setString('lang', cregisModel.language.toString());
        preferences.setString('pass_word', passwordController.text.toString());
        preferences.setString('UsernameUSer', userController.text.toString());
        preferences.setString('renTalSer', cregisModel.rser!);
        preferences.setString('renTalName', cregisModel.pn!);
        preferences.setString('lintid', customerModel.lineid.toString());
        preferences.setString('ser', u_ser.toString());
        preferences.setString('cname', customerModel.cname.toString());
        preferences.setString('sname', customerModel.scname.toString());
        preferences.setString('email', customerModel.email.toString());
        preferences.setString('photo', customerModel.addr2.toString());
        preferences.setString('address', customerModel.addr1.toString());
        preferences.setString('contact', customerModel.attn.toString());
        preferences.setString('stype', customerModel.stype.toString());
        preferences.setString('tel', customerModel.tel.toString());
        preferences.setString('tax', customerModel.tax.toString());
        preferences.setString('foder', customerModel.foder.toString());
        preferences.setString('pay_token', cregisModel.payToken ?? '');
        preferences.setString('pay_encoded64', cregisModel.payEncoded64 ?? '');
        preferences.setString('fid', cregisModel.fid ?? '');

        // Get customer JWT token for payment API
        await _getAndStoreCustomerToken(cusno, rser);
      }
    }
    if (!mounted) return;
    MaterialPageRoute route = MaterialPageRoute(
      builder: (context) => myWidget,
    );
    Navigator.pushAndRemoveUntil(context, route, (route) => false);
    // } else {
    //   html.window.open('https://chaoperties.com/Choice/user', '_self');
    // }
  }

  /// Get customer JWT token from payment API after login
  /// Uses pay_encoded64 for Basic Auth, then stores the returned JWT token
  Future<void> _getAndStoreCustomerToken(String? cusno, String? rser) async {
    if (cusno == null || rser == null) {
      print('❌ Cannot get customer token: cusno or rser is null');
      return;
    }

    // Keep raw custno/rser as-is (preserve leading zeros e.g. "00008")
    final customerNo16 = cusno.trim();
    final propertyNo16 = rser.trim();

    print(
        '🔑 Getting customer token for customer_no: $customerNo16, property_no: $propertyNo16');

    // Call the payment API to get JWT token
    final token = await getCustomerToken(
      customerNo: customerNo16,
      propertyNo: propertyNo16,
    );

    if (token != null) {
      print('✅ Customer JWT token obtained successfully');
      // Token is already stored in ApiSession by getCustomerToken()
    } else {
      print('❌ Failed to get customer JWT token - API calls may fail');
    }
  }
}
