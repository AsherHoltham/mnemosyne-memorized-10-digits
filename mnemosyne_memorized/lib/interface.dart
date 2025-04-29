import 'package:flutter/material.dart';

const List<Color> networkGraphColors = [
  //way of depicting geyscale // input on gradient from white to this
  Color(0xFF9B111E), // Ruby Red L1 on gradient from transparrent to this
  Color(0xFFFF7E00), // Amber Orange L2 on gradient from transparrent to this
  Color(0xFFD4AF37), // Royal Gold L3 on gradient from transparrent to this
  Color(0xFF008B8B), // Deep Teal L4 on gradient from transparrent to this
  Color(0xFF8A2BE2), // Blue Violet L5 on gradient from transparrent to this
];

class DrawingSpaceTransition extends CustomPainter {
  final Animation<double> progress;
  final List<Offset> start, end;
  final double cellSize;
  final Paint paintFill;

  DrawingSpaceTransition(this.progress, this.start, this.end, this.cellSize)
    : paintFill = Paint()..color = Colors.blue,
      super(repaint: progress);

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value;
    for (int i = 0; i < start.length; i++) {
      // interpolate position
      final pos = Offset.lerp(start[i], end[i], t)!;
      // interpolate corner radius: 0 → cellSize/2
      final r = (cellSize / 2) * t;
      final rect = Rect.fromCenter(
        center: pos,
        width: cellSize,
        height: cellSize,
      );
      // draw rounded rect (morphing square→circle)
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(r)),
        paintFill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DrawingSpaceTransition old) => false;
}
