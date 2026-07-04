import 'package:flutter/material.dart';

/// AbsenKu brand palette and the pin+geofence+checkmark mark, shared between
/// in-app usage (login/splash) and the app-icon generation script.
class Brand {
  static const teal = Color(0xFF12504E);
  static const tealDeep = Color(0xFF0A3230);
  static const amber = Color(0xFFF0A63D);
  static const amberSoft = Color(0xFFF7CF8E);
  static const paper = Color(0xFFF7F2E7);

  static const seed = teal;
}

/// The AbsenKu mark: a location pin with a geofence ring and a checkmark
/// carved into the pin's head as negative space.
class AbsenKuMark extends StatelessWidget {
  const AbsenKuMark({
    super.key,
    this.size = 48,
    this.tile = false,
    this.tileCornerRadius = 44,
    this.pinColor = Brand.amber,
    this.checkColor = Brand.teal,
    this.ringColor = Brand.amber,
    this.showRing = true,
  });

  final double size;

  /// When true, draws the full app-icon tile (background + mark).
  final bool tile;

  /// Corner radius on the 200x200 design canvas. Use 0 when exporting the
  /// master PNG for app icons — the OS applies its own mask.
  final double tileCornerRadius;

  final Color pinColor;
  final Color checkColor;
  final Color ringColor;
  final bool showRing;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _AbsenKuMarkPainter(
        tile: tile,
        tileCornerRadius: tileCornerRadius,
        pinColor: pinColor,
        checkColor: checkColor,
        ringColor: ringColor,
        showRing: showRing,
      ),
    );
  }
}

class _AbsenKuMarkPainter extends CustomPainter {
  _AbsenKuMarkPainter({
    required this.tile,
    required this.tileCornerRadius,
    required this.pinColor,
    required this.checkColor,
    required this.ringColor,
    required this.showRing,
  });

  final bool tile;
  final double tileCornerRadius;
  final Color pinColor;
  final Color checkColor;
  final Color ringColor;
  final bool showRing;

  /// All geometry below is authored on a 200x200 canvas, matching the SVG
  /// concept, then scaled to fit [size].
  static const _designSize = 200.0;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / _designSize;
    canvas.save();
    canvas.scale(scale, scale);

    if (tile) {
      final tileRect = Rect.fromLTWH(0, 0, _designSize, _designSize);
      final tileRRect = RRect.fromRectAndRadius(tileRect, Radius.circular(tileCornerRadius));
      final tilePaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Brand.teal, Brand.tealDeep],
        ).createShader(tileRect);
      canvas.drawRRect(tileRRect, tilePaint);
    }

    if (showRing) {
      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = ringColor.withValues(alpha: 0.55);
      _drawDashedCircle(canvas, const Offset(100, 90), 62, ringPaint, dashLength: 5, gapLength: 11);
    }

    final pinPath = _pinPath();

    final pinPaint = Paint()..color = pinColor;
    canvas.drawPath(pinPath, pinPaint);

    final checkPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = checkColor;
    final checkPath = Path()
      ..moveTo(83, 86)
      ..lineTo(95, 98)
      ..lineTo(119, 71);
    canvas.drawPath(checkPath, checkPaint);

    canvas.restore();
  }

  static Path _pinPath() {
    return Path()
      ..moveTo(100, 40)
      ..cubicTo(124, 40, 144, 60, 144, 84)
      ..cubicTo(144, 110, 118, 140, 100, 166)
      ..cubicTo(82, 140, 56, 110, 56, 84)
      ..cubicTo(56, 60, 76, 40, 100, 40)
      ..close();
  }

  static void _drawDashedCircle(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint, {
    required double dashLength,
    required double gapLength,
  }) {
    final circumference = 2 * 3.14159265358979 * radius;
    final step = dashLength + gapLength;
    final dashCount = (circumference / step).floor();
    final angleStep = (2 * 3.14159265358979) / dashCount;
    final dashAngle = angleStep * (dashLength / step);

    for (var i = 0; i < dashCount; i++) {
      final startAngle = i * angleStep;
      final path = Path()
        ..addArc(Rect.fromCircle(center: center, radius: radius), startAngle, dashAngle);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AbsenKuMarkPainter oldDelegate) {
    return oldDelegate.tile != tile ||
        oldDelegate.tileCornerRadius != tileCornerRadius ||
        oldDelegate.pinColor != pinColor ||
        oldDelegate.checkColor != checkColor ||
        oldDelegate.ringColor != ringColor ||
        oldDelegate.showRing != showRing;
  }
}
