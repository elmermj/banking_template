import 'dart:math';

import 'package:flutter/material.dart';

class CustomPieChart extends StatefulWidget {
  final List<double> data;
  final int? touchedIndex;
  final Function(int?) onSegmentTapped;

  const CustomPieChart({super.key, 
    required this.data,
    required this.touchedIndex,
    required this.onSegmentTapped,
  });

  @override
  CustomPieChartState createState() => CustomPieChartState();
}

class CustomPieChartState extends State<CustomPieChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 75),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 10).animate(_controller);
  }

  @override
  void didUpdateWidget(CustomPieChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.touchedIndex != widget.touchedIndex) {
      if (widget.touchedIndex == null) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Color> _generateColors(int count) {
    List<Color> colors = [];
    for (int i = 0; i < count; i++) {
      final hue = (360 / count) * i;
      colors.add(HSVColor.fromAHSV(0.7, hue, 0.7, 0.9).toColor());
    }
    return colors;
  }

  @override
  Widget build(BuildContext context) {
    List<Color> colors = _generateColors(widget.data.length);

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapUp: (details) async {
            final index = await _getTouchedIndex(details.localPosition, constraints.biggest);
            widget.onSegmentTapped(index == widget.touchedIndex ? null : index);
          },
          onTapDown: (details) async {
            final index = await _getTouchedIndex(details.localPosition, constraints.biggest);
            widget.onSegmentTapped(index == widget.touchedIndex ? null : index);
          },
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                size: constraints.biggest,
                painter: PieChartPainter(
                  data: widget.data,
                  colors: colors,
                  touchedIndex: widget.touchedIndex,
                  separation: _animation.value,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<int?> _getTouchedIndex(Offset touchPosition, Size size) async {
    if (_animation.value == 10) {
      await _controller.reverse();
    }

    final center = Offset(size.width / 2, size.height / 2);
    final touchVector = touchPosition - center;
    final touchAngle = atan2(touchVector.dy, touchVector.dx);
    final touchDistance = touchVector.distance;

    if (touchDistance > min(size.width / 2, size.height / 2)) {
      return null;
    }

    double startAngle = -pi / 2;
    final total = widget.data.reduce((a, b) => a + b);

    for (int i = 0; i < widget.data.length; i++) {
      final sweepAngle = (widget.data[i] / total) * 2 * pi;
      double endAngle = startAngle + sweepAngle;

      double normalizedTouchAngle = touchAngle < 0 ? touchAngle + 2 * pi : touchAngle;
      double normalizedStartAngle = startAngle < 0 ? startAngle + 2 * pi : startAngle;
      double normalizedEndAngle = endAngle < 0 ? endAngle + 2 * pi : endAngle;

      if (normalizedStartAngle > normalizedEndAngle) {
        if (normalizedTouchAngle >= normalizedStartAngle || normalizedTouchAngle <= normalizedEndAngle) {
          return i;
        }
      } else if (normalizedTouchAngle >= normalizedStartAngle && normalizedTouchAngle <= normalizedEndAngle) {
        return i;
      }

      startAngle += sweepAngle;
    }

    return null;
  }

}

class PieChartPainter extends CustomPainter {
  final List<double> data;
  final List<Color> colors;
  final int? touchedIndex;
  final double separation;

  PieChartPainter({
    required this.data,
    required this.colors,
    this.touchedIndex,
    required this.separation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final total = data.reduce((a, b) => a + b);
    final radius = min(size.width / 2, size.height / 2);
    final center = Offset(size.width / 2, size.height / 2);

    double startAngle = -pi / 2;
    for (int i = 0; i < data.length; i++) {
      final sweepAngle = (data[i] / total) * 2 * pi;
      final segmentCenterAngle = startAngle + sweepAngle / 2;

      Offset segmentCenter = center;
      if (touchedIndex == i) {
        segmentCenter = center + Offset(
          cos(segmentCenterAngle) * separation,
          sin(segmentCenterAngle) * separation,
        );
      }

      paint.color = colors[i];
      canvas.drawArc(
        Rect.fromCircle(center: segmentCenter, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      if (touchedIndex == i) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: "${((data[i]/total)*100).toStringAsFixed(2)}%",
            style: const TextStyle(color: Colors.black, fontSize: 12),
          ),
          textDirection: TextDirection.ltr
        );
        textPainter.layout();
        final textOffset = segmentCenter +
            Offset(
              cos(segmentCenterAngle) * radius / 2,
              sin(segmentCenterAngle) * radius / 2,
            ) -
            Offset(textPainter.width / 2, textPainter.height / 2);
        textPainter.paint(canvas, textOffset);
      }

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}