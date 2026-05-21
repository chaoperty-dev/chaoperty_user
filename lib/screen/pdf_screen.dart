import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PreviewScreenRental_ extends StatelessWidget {
  final title;
  final Url;

  PreviewScreenRental_({Key? key, this.title, this.Url}) : super(key: key);

  static const customSwatch = MaterialColor(
    0xFF8DB95A,
    <int, Color>{
      50: Color.fromRGBO(196, 188, 133, 1),
      100: Color.fromRGBO(196, 188, 133, 1),
      200: Color.fromRGBO(196, 188, 133, 1),
      300: Color.fromRGBO(196, 188, 133, 1),
      400: Color.fromRGBO(196, 188, 133, 1),
      500: Color.fromRGBO(196, 188, 133, 1),
      600: Color.fromRGBO(196, 188, 133, 1),
      700: Color.fromRGBO(196, 188, 133, 1),
      800: Color.fromRGBO(196, 188, 133, 1),
      900: Color.fromRGBO(196, 188, 133, 1),
    },
  );
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  // Future<void> downloadPdf(String pdfUrl) async {
  //   var response = await http.get(Uri.parse(pdfUrl));
  //   var blob = html.Blob([response.bodyBytes]);
  //   var url = html.Url.createObjectUrlFromBlob(blob);
  //   var anchor = html.document.createElement('a') as html.AnchorElement
  //     ..href = url
  //     ..download = '$title.pdf';
  //   html.document.body?.append(anchor);
  //   anchor.click();
  //   html.Url.revokeObjectUrl(url);
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: 'Flutter Demo',
      // theme: ThemeData(
      //   primarySwatch: customSwatch,
      // ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 184, 198, 133),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_outlined,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          title: Text(
            title.toString(),
            style: TextStyle(
              color: Colors.white,
              //fontFamily: Font_.Fonts_T,
            ),
          ),
          // actions: <Widget>[
          //   IconButton(
          //     icon: Icon(
          //       Icons.zoom_in,
          //       color: Colors.white,
          //     ),
          //     onPressed: () async {
          //       // String pdfUrl = Url.toString();
          //       downloadPdf(Url);
          //     },
          //   ),
          // ],
        ),
        body: SfPdfViewer.network(
          Url,
          enableDocumentLinkAnnotation: false,
          key: _pdfViewerKey,
          canShowScrollHead: false,
          canShowScrollStatus: false,
          pageLayoutMode: PdfPageLayoutMode.continuous,
          controller: PdfViewerController(),
        ),

        // floatingActionButton: Container(
        //   color: Color.fromARGB(255, 141, 185, 90),
        //   width: MediaQuery.of(context).size.width,
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //     children: [
        //       SizedBox(),
        //       IconButton(
        //         icon: Icon(Icons.print),
        //         onPressed: () {
        //           html.window.print();
        //         },
        //       ),
        //       SizedBox(),
        //       IconButton(
        //         icon: Icon(Icons.download),
        //         onPressed: () {
        //           downloadPdf(Url.toString());
        //         },
        //       ),
        //       SizedBox(),
        //     ],
        //   ),
        // ),
      ),
    );
  }

  // Future<void> _launchUrl() async {
  //   // const url = Url;
  //   // const url = "https://flutter.io";
  //   js.context.callMethod('open', ['$Url']);
  // }
}
