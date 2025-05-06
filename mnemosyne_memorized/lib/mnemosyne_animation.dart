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
  // final List<List<double>> layers;
  // final List<Offset> startTilesOffsets;
  // final List<List<Offset>> endNodesOffsets;

  //   required this.layers,
  //   required this.startTilesOffsets,
  //   required this.endNodesOffsets,

  MnemosynePainter({required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final mPaint = Paint()..color = networkGraphColors[0];
    canvas.drawCircle(Offset.zero, 8, mPaint);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 8, mPaint);
    final Offset curr =
        Offset.lerp(
          Offset.zero,
          Offset(size.width / 2, size.height / 2),
          time / 2.0,
        ) ??
        Offset.zero;
    canvas.drawLine(Offset.zero, curr, mPaint);
  }

  @override
  bool shouldRepaint(covariant MnemosynePainter old) => old.time != time;
}
