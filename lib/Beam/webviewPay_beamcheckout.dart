// ignore_for_file: unused_import, unused_local_variable, unnecessary_null_comparison, unused_field, override_on_non_overriding_member, duplicate_import, must_be_immutable, body_might_complete_normally_nullable

import 'package:chaoperty_user/Responsive/responsive.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// import '../Responsive/responsive.dart';

class WebViewX2Pagebeamcheck extends StatefulWidget {
  final id_ser;
  // final amt_ser;
  // final name_ser;
  const WebViewX2Pagebeamcheck({
    Key? key,
    this.id_ser,
    // this.amt_ser,
    // this.name_ser,
  }) : super(key: key);

  @override
  _WebViewX2PagebeamcheckState createState() => _WebViewX2PagebeamcheckState();
}

class _WebViewX2PagebeamcheckState extends State<WebViewX2Pagebeamcheck> {
  late final WebViewController _controller;
  // final initialContent =
  //     '<div style="display: flex; justify-content: center;"><div style="text-align: center; width: 50%;">    <h2></h2><p></p>  </div></div>';

  Size get screenSize => MediaQuery.of(context).size;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => _showDialog());

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {
            debugPrint('A new page has started loading: $url\n');
          },
          onPageFinished: (String url) {
            debugPrint('The page has finished loading: $url\n');
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            debugPrint(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'TestDartCallback',
        onMessageReceived: (JavaScriptMessage message) {
          print(message.message);
        },
      )
      ..loadRequest(Uri.parse('${widget.id_ser}')); // Load the URL directly

    // readDataaa2(); // Logic moved to initialization
  }

  void dispose() {
    // _controller.dispose(); // WebViewController in 4.x doesn't need explicit dispose usually, unless cleaning up channels
    super.dispose();
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
              ],
            ),
          ),
        );
      },
    );
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop();
    });
  }

  // Future<Null> readDataaa2() async {
  //   Future.delayed(const Duration(seconds: 1), () {
  //     _controller.loadRequest(Uri.parse('${widget.id_ser}'));
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        child: _buildWebViewX());
  }

  Widget _buildWebViewX() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: (!Responsive.isDesktop(context))
          ? MediaQuery.of(context).size.height * 0.75
          : MediaQuery.of(context).size.height * 0.78,
      child: WebViewWidget(controller: _controller),
    );
  }

  Future<void> _goForward() async {
    if (await _controller.canGoForward()) {
      await _controller.goForward();
    }
  }

  Future<void> _goBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
    }
  }

  void _reload() {
    _controller.reload();
  }

  // void _toggleIgnore() {
  //   // toggle ignore logic if needed, 4.x doesn't expose this directly easily
  // }

  Future<void> _evalRawJsInGlobalContext() async {
    try {
      final result = await _controller.runJavaScriptReturningResult('2+2');
      // showSnackBar('The result is $result', context);
    } catch (e) {}
  }

  Future<void> _callPlatformIndependentJsMethod() async {
    try {
      // await _controller.runJavaScript('testPlatformIndependentMethod()');
    } catch (e) {}
  }

  Future<void> _callPlatformSpecificJsMethod() async {
    try {
      // await _controller.runJavaScript("testPlatformSpecificMethod('Hi')");
    } catch (e) {}
  }

  // Future<void> _getWebviewContent() async {
  //   try {
  //     // final content = await _controller.currentUrl(); // or logic to get HTML
  //   } catch (e) {
  //   }
  // }

  void _setUrl() {
    _controller.loadRequest(Uri.parse('https://flutter.dev'));
  }

  Widget buildSpace({
    Axis direction = Axis.horizontal,
    double amount = 0.2,
    bool flex = true,
  }) {
    return flex
        ? Flexible(
            child: FractionallySizedBox(
              widthFactor: direction == Axis.horizontal ? amount : null,
              heightFactor: direction == Axis.vertical ? amount : null,
            ),
          )
        : SizedBox(
            width: direction == Axis.horizontal ? amount : null,
            height: direction == Axis.vertical ? amount : null,
          );
  }

  List<Widget> _buildButtons() {
    return [
      buildSpace(direction: Axis.vertical, flex: false, amount: 20.0),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
              child: Column(
            children: [
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: _reload,
              ),
              Text('Reload')
            ],
          )),
        ],
      ),
    ];
  }
}
