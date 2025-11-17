import 'package:mobile_scanner/mobile_scanner.dart';

/// Service for scanning barcodes using the device camera.
///
/// This service wraps the mobile_scanner package and provides
/// a simple interface for barcode scanning functionality.
class BarcodeScannerService {
  /// Creates a MobileScannerController for barcode scanning.
  ///
  /// The controller should be disposed when done scanning.
  MobileScannerController createController() {
    return MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      formats: [BarcodeFormat.ean13],
    );
  }
}
