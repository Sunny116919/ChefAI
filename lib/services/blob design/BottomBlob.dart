import 'dart:math';

import 'package:flutter/material.dart';

class BottomBlob extends StatefulWidget {
  const BottomBlob({super.key});

  @override
  State<BottomBlob> createState() => _BottomBlobState();
}

class _BottomBlobState extends State<BottomBlob> {
  late final List<double> controlPoints;

  @override
  void initState() {
    super.initState();
    final Random random = Random();

    // Generate 3 control point heights (0.05 to 0.15 of screen height)
    controlPoints = List.generate(3, (_) => 0.05 + random.nextDouble() * 0.10);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BottomCurvePainter(controlPoints: controlPoints),
      child: const SizedBox.expand(),
    );
  }
}

class BottomCurvePainter extends CustomPainter {
  final List<double> controlPoints;

  BottomCurvePainter({required this.controlPoints});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ).createShader(Rect.fromLTWH(0, size.height - 200, size.width, 200));

    final double baseHeight = size.height;
    final Path path = Path();

    path.moveTo(0, baseHeight);
    path.lineTo(0, baseHeight - baseHeight * 0.08); // start of curve

    path.quadraticBezierTo(
      size.width * 0.15,
      baseHeight - baseHeight * controlPoints[0],
      size.width * 0.33,
      baseHeight - baseHeight * 0.08,
    );

    path.quadraticBezierTo(
      size.width * 0.50,
      baseHeight - baseHeight * controlPoints[1],
      size.width * 0.66,
      baseHeight - baseHeight * 0.08,
    );

    path.quadraticBezierTo(
      size.width * 0.85,
      baseHeight - baseHeight * controlPoints[2],
      size.width,
      baseHeight - baseHeight * 0.08,
    );

    path.lineTo(size.width, baseHeight);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant BottomCurvePainter oldDelegate) {
    return oldDelegate.controlPoints != controlPoints;
  }
}
