import 'dart:math';

import 'package:flutter/material.dart';

class TopBlob extends StatefulWidget {
  const TopBlob({super.key});

  @override
  State<TopBlob> createState() => _TopBlobState();
}

class _TopBlobState extends State<TopBlob> {
  late final List<double> controlPoints;

  @override
  void initState() {
    super.initState();
    final Random random = Random();

    // Generate 3 distinct curve heights between 0.08 and 0.2 (ensures enough curvature)
    controlPoints = List.generate(3, (_) => 0.08 + random.nextDouble() * 0.12);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: TopCurvePainter(controlPoints: controlPoints),
      child: const SizedBox.expand(),
    );
  }
}

class TopCurvePainter extends CustomPainter {
  final List<double> controlPoints;

  TopCurvePainter({required this.controlPoints});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFC107), Color(0xFFE91E63)],
        begin: Alignment.topLeft,
        end: Alignment.topRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.3));

    final Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, size.height * 0.12); // start of curves

    path.quadraticBezierTo(
      size.width * 0.15,
      size.height * controlPoints[0],
      size.width * 0.33,
      size.height * 0.12,
    );

    path.quadraticBezierTo(
      size.width * 0.50,
      size.height * controlPoints[1],
      size.width * 0.66,
      size.height * 0.12,
    );

    path.quadraticBezierTo(
      size.width * 0.85,
      size.height * controlPoints[2],
      size.width,
      size.height * 0.12,
    );

    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant TopCurvePainter oldDelegate) {
    return oldDelegate.controlPoints != controlPoints;
  }
}
