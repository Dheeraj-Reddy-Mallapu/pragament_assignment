import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mass_qr/models/settings.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mass_qr/models/scans.dart';
import 'dart:ui';
import 'dart:io' show Platform;

class ScanPage extends StatefulWidget {
  ScanPage({Key? key}) : super(key: key);

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  MobileScannerController controller = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('MultiQR | Private QR Scanner'),
        ),
        body:
            Column(
        children :[ Expanded(
            flex: 5,
            child: _buildQrView(context)
        )
    ],
            ),
    );
  }


            // Expanded(
            //   flex: 1,
            //   child: FittedBox(
            //     fit: BoxFit.contain,
            //
            //     child: Column(
            //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //       children: <Widget>[
            //         Row(
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           crossAxisAlignment: CrossAxisAlignment.center,
            //           children: <Widget>[
            //             Container(
            //               margin: EdgeInsets.all(8),
            //               child: IconButton(
            //                 color: Colors.white,
            //                 icon: ValueListenableBuilder(
            //                   valueListenable: controller.torchState,
            //                   builder: (context, state, child) {
            //                     switch (state as TorchState) {
            //                       case TorchState.off:
            //                         return const Icon(Icons.flash_off);
            //                       case TorchState.on:
            //                         return const Icon(Icons.flash_on);
            //                     }
            //                     return null;
            //                   },
            //                 ),
            //                 onPressed: () => controller.toggleTorch(),
            //               ),
            //             ),
            //             Container(
            //               margin: EdgeInsets.all(8),
            //               alignment: Alignment.bottomRight,
            //               child: IconButton(
            //                 color: Colors.white,
            //                 icon: ValueListenableBuilder(
            //                   valueListenable: controller.cameraFacingState,
            //                   builder: (context, state, child) {
            //                     switch (state as CameraFacing) {
            //                       case CameraFacing.front:
            //                         return Icon(Icons.camera_front); // Icon for front camera
            //                       case CameraFacing.back:
            //                         return Icon(Icons.camera_rear); // Icon for rear camera
            //                       default:
            //                         return Icon(Icons.camera); // Default icon
            //                     }
            //                     return SizedBox();
            //                   },
            //                 ),
            //                 onPressed: () => controller.switchCamera(),
            //               ),
            //             ),
            //           ],
            //         ),
                  // ],
              //   ),
              // );
    //         ),
    //       ],
    //     ),
    //   ),
    // );

  Widget _buildQrView(BuildContext context) {
    return MobileScanner(
                key: qrKey,
                controller: controller,
                  onDetect: ( capture ) async {
                    final List<Barcode> barcodes = capture.barcodes;
                    final Uint8List? image = capture.image;
                    for (final barcode in barcodes) {
                      String barcodeValue = barcode.rawValue ?? '';
                      if (barcodeValue.isNotEmpty) {
                        ScansModel scans = Provider.of<ScansModel>(
                            context, listen: false);
                        if (!scans.scans.contains(barcodeValue)) {
                          scans.add(barcodeValue);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              duration: Duration(seconds: 1),
                              content: Text('Added "$barcodeValue"')));
                        }
                      }
                    }
                  }
                // ),
          );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
