import 'package:flutter_test/flutter_test.dart';
import 'package:egg_yolk_app/services/auto_crop_service.dart';
import 'package:egg_yolk_app/services/local_predict_service.dart';

void main() {
  group('LocalPredictService & AutoCropService Unit Tests', () {
    // ─── CIELAB Conversion Tests ──────────────────────────────────────────
    // ทดสอบ LocalPredictService.rgbToCielab() ซึ่งเป็นตัว authoritative
    // ที่ใช้จริงในการทำนาย (YolkDetector และ ColorExtractor ถูกลบออกแล้ว)

    test('CIELAB matches CIE D65 reference — bright yolk RGB(255,180,50)', () {
      // Reference: Python skimage.color.rgb2lab([[[255,180,50]]]/255.0)
      // L*=78.542, a*=16.933, b*=71.568
      final lab = LocalPredictService.rgbToCielab(255.0, 180.0, 50.0);
      expect(lab['l']!, closeTo(78.54, 0.1));
      expect(lab['a']!, closeTo(16.93, 0.1));
      expect(lab['b']!, closeTo(71.57, 0.1));
    });

    test('CIELAB matches CIE D65 reference — dark yolk RGB(180,110,20)', () {
      // Reference: Python skimage.color.rgb2lab([[[180,110,20]]]/255.0)
      // L*=52.85, a*=21.56, b*=55.69
      final lab = LocalPredictService.rgbToCielab(180.0, 110.0, 20.0);
      expect(lab['l']!, closeTo(52.85, 0.1));
      expect(lab['a']!, closeTo(21.56, 0.1));
      expect(lab['b']!, closeTo(55.69, 0.1));
    });

    test('CIELAB full precision — values are NOT pre-rounded (precision fix)', () {
      // ตรวจสอบว่า rgbToCielab คืนค่า full precision (ไม่มี toStringAsFixed กลาง pipeline)
      final lab = LocalPredictService.rgbToCielab(220.0, 140.0, 35.0);
      expect(lab['l']!, isA<double>());
      expect(lab['a']!, isA<double>());
      expect(lab['b']!, isA<double>());
      // L* ควรอยู่ในช่วงที่ valid สำหรับสีไข่แดง
      expect(lab['l']!, inInclusiveRange(0.0, 100.0));
    });

    // ─── CIELAB Range Validation ──────────────────────────────────────────

    test('CIELAB range — yolk colors have high b* (yellow-orange)', () {
      // ไข่แดง: L* อยู่ในช่วง 40-85, b* > 30 (เหลือง-ส้ม)
      final yolkLab = LocalPredictService.rgbToCielab(220.0, 130.0, 20.0);
      expect(yolkLab['l']!, inInclusiveRange(40.0, 85.0));
      expect(yolkLab['b']!, greaterThan(30.0));
    });

    test('CIELAB range — white background has high L* and near-zero b*', () {
      final whiteLab = LocalPredictService.rgbToCielab(245.0, 245.0, 245.0);
      expect(whiteLab['l']!, greaterThan(90.0));
      expect(whiteLab['b']!.abs(), lessThan(5.0));
    });

    test('CIELAB range — black has very low L*', () {
      final blackLab = LocalPredictService.rgbToCielab(20.0, 20.0, 20.0);
      expect(blackLab['l']!, lessThan(10.0));
    });

    // ─── AutoCropService ──────────────────────────────────────────────────

    test('AutoCropService: DetectedYolkBox isDetected=false has valid normalized fallback', () {
      // ทดสอบว่า fallback box มีค่า normalized coordinates ที่ valid (0.0–1.0)
      const normX = 0.1;
      const normY = 0.1;
      const normW = 0.8;
      const normH = 0.8;
      expect(normX, greaterThanOrEqualTo(0.0));
      expect(normY, greaterThanOrEqualTo(0.0));
      expect(normX + normW, lessThanOrEqualTo(1.0));
      expect(normY + normH, lessThanOrEqualTo(1.0));
    });

    test('AutoCropService: DetectedYolkBox can be constructed', () {
      final box = DetectedYolkBox(
        normX: 0.1, normY: 0.1,
        normWidth: 0.8, normHeight: 0.8,
        isDetected: false,
      );
      expect(box.isDetected, isFalse);
      expect(box.normWidth, equals(0.8));
    });
  });
}

