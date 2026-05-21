import 'package:flutter/material.dart';


class MobileScannerPage extends StatelessWidget {
  const MobileScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Scan QR Code')), body: Container()
        // MobileScanner(
        //   onDetect: (capture) {
        //     final List<Barcode> barcodes = capture.barcodes;
        //     if (barcodes.isNotEmpty) {
        //       final code = barcodes.first.rawValue;
        //       if (code != null) {
        //         Navigator.pop(context, code);
        //       }
        //     }
        //   },
        // ),
        );
  }
}
