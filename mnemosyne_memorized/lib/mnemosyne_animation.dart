import 'package:flutter/material.dart';

const List<Color> networkGraphColors = [
  //way of depicting geyscale // input on gradient from white to this
  Color(0xFF9B111E), // Ruby Red L1 on gradient from transparrent to this
  Color(0xFFFF7E00), // Amber Orange L2 on gradient from transparrent to this
  Color(0xFFD4AF37), // Royal Gold L3 on gradient from transparrent to this
  Color(0xFF008B8B), // Deep Teal L4 on gradient from transparrent to this
  Color(0xFF8A2BE2), // Blue Violet L5 on gradient from transparrent to this
];

class MnemosynePainter extends CustomPainter {
  final double time;
  final List<List<double>> data;

  MnemosynePainter({required this.time, required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    //double blockDim = (size.height * .6) / 28;

    double blockOffset = (size.height / 784);

    for (int i = 0; i < data[0].length; i++) {
      int alpha = ((data[0][i] * 255).round()).clamp(0, 255);
      Color base = networkGraphColors[0];
      final mPaint = Paint()..color = base.withAlpha(alpha);
      // Rect rect = Offset(0.0, blockOffset * i) & Size(blockDim, blockDim);
      // canvas.drawRect(rect, mPaint);
      canvas.drawCircle(Offset(0.0, blockOffset * i), 2, mPaint);
      final Offset curr =
          Offset.lerp(
            Offset(0.0, blockOffset * i),
            Offset(size.width / 2, size.height / 2),
            time / 2.0,
          ) ??
          Offset.zero;
      canvas.drawLine(Offset(0.0, blockOffset * i), curr, mPaint);
    }

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      8,
      Paint()..color = networkGraphColors[0],
    );
  }

  @override
  bool shouldRepaint(covariant MnemosynePainter old) => old.time != time;
}
