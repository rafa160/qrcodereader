import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:readercam/camera_qr_code/barcode_detector.dart';
import 'package:readercam/camera_qr_code/camera_view.dart';

class BarcodeScannerView extends StatefulWidget {
  final bool? showCloseButton;
  final Function(String paintText) onChange;
  final List<CameraDescription> cameras;

  const BarcodeScannerView(
      {super.key,
      required this.onChange,
      this.showCloseButton = false,
      required this.cameras});

  @override
  State<BarcodeScannerView> createState() => _BarcodeScannerViewState();
}

class _BarcodeScannerViewState extends State<BarcodeScannerView> {
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;

  @override
  void dispose() {
    _canProcess = false;
    _barcodeScanner.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      cameras: widget.cameras,
      appBarTitle: 'Refill Scan',
      title: 'Barcode Scanner',
      customPaint: _customPaint,
      text: _text,
      showCloseButton: widget.showCloseButton,
      onImage: (inputImage) {
        processImage(inputImage);
      },
    );
  }

  Future<void> processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final barcodes = await _barcodeScanner.processImage(inputImage);
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = BarcodeDetectorPainter(
          barcodes,
          inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);
      _customPaint = CustomPaint(painter: painter);
      if (painter.barcodes.isNotEmpty &&
          painter.barcodes.first.displayValue != null) {
        widget.onChange(painter.barcodes.first.displayValue!) ??
            widget.onChange('');
        return;
      }
    } else {
      String text = 'Barcodes found: ${barcodes.length}\n\n';
      for (final barcode in barcodes) {
        text += 'Barcode: ${barcode.rawValue}\n\n';
      }
      _text = text;
      // TODO: set _customPaint to draw boundingRect on top of image
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
