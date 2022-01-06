import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScanPage extends StatefulWidget {
  Function onScanned;
  QRScanPage(this.onScanned);

  @override
  _QRScanPageState createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  Barcode barcode;

  QRViewController controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("QR-Code Scannen"),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          buildQrView(context),
        ],
      ),
    );
  }

  Widget buildQrView(BuildContext context) => QRView(
    overlay: QrScannerOverlayShape(
      borderWidth: 10,
      borderRadius: 5,
      borderColor: Theme.of(context).primaryColor,
    ),
    key: qrKey,
        onQRViewCreated: onQRViewCreated,
      );

  void onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen((barcode) {
      if (barcode.code.isNotEmpty) {
          controller.stopCamera();
          widget.onScanned(barcode.code);
          Navigator.pop(context);
      }
    });
  }
}
