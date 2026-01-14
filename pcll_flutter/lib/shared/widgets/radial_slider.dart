// Radial Slider Widget

import 'dart:math' as math;
import 'package:flutter/material.dart';

class RadialSlider extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;
  final bool inverse; // If true, colors go red→blue (high values are good)
  final double size;

  const RadialSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions = 10,
    this.inverse = false,
    this.size = 220,
  });

  @override
  State<RadialSlider> createState() => _RadialSliderState();
}

class _RadialSliderState extends State<RadialSlider> {
  // Gradient colors: Blue → Green → Yellow → Orange → Red
  static const List<Color> _normalGradient = [
    Color(0xFF2196F3), // Blue (low intensity - good)
    Color(0xFF4CAF50), // Green
    Color(0xFFFFEB3B), // Yellow
    Color(0xFFFF9800), // Orange
    Color(0xFFF44336), // Red (high intensity - bad)
  ];

  // Inverse gradient: Red → Orange → Yellow → Green → Blue
  static const List<Color> _inverseGradient = [
    Color(0xFFF44336), // Red (low = bad)
    Color(0xFFFF9800), // Orange
    Color(0xFFFFEB3B), // Yellow
    Color(0xFF4CAF50), // Green
    Color(0xFF2196F3), // Blue (high = good)
  ];

  List<Color> get _gradient =>
      widget.inverse ? _inverseGradient : _normalGradient;

  double get _progress =>
      (widget.value - widget.min) / (widget.max - widget.min);

  Color get _currentColor {
    final progress = _progress.clamp(0.0, 1.0);
    final colorIndex = progress * (_gradient.length - 1);
    final lowerIndex = colorIndex.floor();
    final upperIndex = colorIndex.ceil();

    if (lowerIndex == upperIndex) {
      return _gradient[lowerIndex];
    }

    final t = colorIndex - lowerIndex;
    return Color.lerp(_gradient[lowerIndex], _gradient[upperIndex], t)!;
  }

  void _handlePanUpdate(Offset localPosition, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final vector = localPosition - center;

    // Calculate angle from top (270°) going clockwise
    double angle = math.atan2(vector.dx, -vector.dy);
    if (angle < 0) angle += 2 * math.pi;

    // Map angle to value (arc from -135° to +135°, i.e., 270° sweep)
    final startAngle = math.pi * 0.75; // 135° from top, going counter-clockwise
    final sweepAngle = math.pi * 1.5; // 270° sweep

    // Normalize angle relative to start
    double normalizedAngle = angle - (2 * math.pi - startAngle);
    if (normalizedAngle < 0) normalizedAngle += 2 * math.pi;

    // Calculate progress
    double progress = normalizedAngle / sweepAngle;
    progress = progress.clamp(0.0, 1.0);

    // Calculate value with snapping to divisions
    final range = widget.max - widget.min;
    double newValue = widget.min + (progress * range);

    if (widget.divisions > 0) {
      final step = range / widget.divisions;
      newValue = (newValue / step).round() * step;
    }

    newValue = newValue.clamp(widget.min, widget.max);
    widget.onChanged(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final valueString = widget.value
        .toStringAsFixed(widget.value == widget.value.roundToDouble() ? 0 : 1);
    final label = widget.inverse
        ? 'Recovery quality: $valueString out of ${widget.max.toInt()}'
        : 'Value: $valueString, range ${widget.min.toInt()} to ${widget.max.toInt()}';

    return Semantics(
      label: label,
      value: valueString,
      slider: true,
      enabled: true,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: GestureDetector(
          onPanStart: (details) => _handlePanUpdate(
              details.localPosition, Size(widget.size, widget.size)),
          onPanUpdate: (details) => _handlePanUpdate(
              details.localPosition, Size(widget.size, widget.size)),
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _RadialSliderPainter(
              progress: _progress,
              gradient: _gradient,
              currentColor: _currentColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _RadialSliderPainter extends CustomPainter {
  final double progress;
  final List<Color> gradient;
  final Color currentColor;

  _RadialSliderPainter({
    required this.progress,
    required this.gradient,
    required this.currentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 20;
    final strokeWidth = 16.0;

    // Start from bottom-left (225°) and sweep 270° clockwise
    const startAngle = math.pi * 0.75; // 135° (bottom-left)
    const sweepAngle = math.pi * 1.5; // 270° sweep

    // Draw track background
    final trackPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    // Draw gradient arc by drawing many small segments
    final segmentCount = 100;
    final activeSegments = (segmentCount * progress.clamp(0.0, 1.0)).round();

    if (activeSegments > 0) {
      for (int i = 0; i < activeSegments; i++) {
        final segmentProgress = i / segmentCount;
        final segmentAngle = startAngle + (sweepAngle * segmentProgress);
        final segmentSweep = sweepAngle / segmentCount * 1.1; // Slight overlap

        // Get color for this segment
        final colorProgress = segmentProgress;
        final colorIndex = colorProgress * (gradient.length - 1);
        final lowerIdx = colorIndex.floor().clamp(0, gradient.length - 1);
        final upperIdx = colorIndex.ceil().clamp(0, gradient.length - 1);
        final t = colorIndex - lowerIdx;
        final segmentColor =
            Color.lerp(gradient[lowerIdx], gradient[upperIdx], t)!;

        final segmentPaint = Paint()
          ..color = segmentColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = i == 0 || i == activeSegments - 1
              ? StrokeCap.round
              : StrokeCap.butt;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          segmentAngle,
          segmentSweep,
          false,
          segmentPaint,
        );
      }
    }

    // Draw thumb
    final thumbAngle = startAngle + (sweepAngle * progress);
    final thumbCenter = Offset(
      center.dx + radius * math.cos(thumbAngle),
      center.dy + radius * math.sin(thumbAngle),
    );

    // Thumb shadow
    canvas.drawCircle(
      thumbCenter.translate(0, 2),
      14,
      Paint()..color = Colors.black.withOpacity(0.2),
    );

    // Thumb outer ring
    canvas.drawCircle(
      thumbCenter,
      14,
      Paint()..color = Colors.white,
    );

    // Thumb inner fill with current color
    canvas.drawCircle(
      thumbCenter,
      10,
      Paint()..color = currentColor,
    );

    // Draw tick marks
    final tickPaint = Paint()
      ..color = Colors.grey.withOpacity(0.4)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i <= 10; i++) {
      final tickAngle = startAngle + (sweepAngle * i / 10);
      final tickOuterRadius = radius + strokeWidth / 2 + 8;
      final tickInnerRadius = radius + strokeWidth / 2 + 3;

      final outerPoint = Offset(
        center.dx + tickOuterRadius * math.cos(tickAngle),
        center.dy + tickOuterRadius * math.sin(tickAngle),
      );
      final innerPoint = Offset(
        center.dx + tickInnerRadius * math.cos(tickAngle),
        center.dy + tickInnerRadius * math.sin(tickAngle),
      );

      canvas.drawLine(innerPoint, outerPoint, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadialSliderPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.currentColor != currentColor;
  }
}
