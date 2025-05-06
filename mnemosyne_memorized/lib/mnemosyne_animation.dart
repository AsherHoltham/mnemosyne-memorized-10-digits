import 'package:flutter/material.dart';
import 'dart:math' as math;

const List<Color> networkGraphColors = [
  //way of depicting geyscale // input on gradient from white to this
  Color(0xFF9B111E), // Ruby Red L1 on gradient from transparrent to this
  Color(0xFFFF7E00), // Amber Orange L2 on gradient from transparrent to this
  Color(0xFFD4AF37), // Royal Gold L3 on gradient from transparrent to this
  Color(0xFF008B8B), // Deep Teal L4 on gradient from transparrent to this
  Color(0xFF8A2BE2), // Blue Violet L5 on gradient from transparrent to this
];

enum MnemosyneState {
  initial, // .5 seconds
  movingIntoPlace, // 1.0 seconds
  drawToL1, // 1.0 Seconds
  drawToL2, // 1.0 Seconds
  drawToL3, // 1.0 Seconds
  drawToL4, // 1.0 Seconds
  finalModel,
}

class MnemosynePainter extends CustomPainter {
  final double time;
  final List<List<double>> data;
  MnemosyneState state = MnemosyneState.initial;

  MnemosynePainter({required this.time, required this.data});

  double _phaseProgress(double t, double start, double duration) {
    if (t < start) return 0.0;
    if (t >= start + duration) return 1.0;
    return (t - start) / duration;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cycleTime = time % 5.5;

    final initPct = _phaseProgress(cycleTime, 0.0, 0.5);
    final mvPct = _phaseProgress(cycleTime, 0.5, 1.0);
    final l1Pct = _phaseProgress(cycleTime, 1.5, 1.0);
    // final l2Pct = _phaseProgress(cycleTime, 2.5, 1.0);
    // final l3Pct = _phaseProgress(cycleTime, 3.5, 1.0);
    // final l4Pct = _phaseProgress(cycleTime, 4.5, 1.0);

    if (cycleTime < 0.5) {
      _drawInitial(canvas, size, initPct);
    } else if (cycleTime < 1.5) {
      _drawMove(canvas, size, mvPct);
    }
    // else if (cycleTime < 2.5) {
    //   print("Here");
    //   _drawL1(canvas, size, l1Pct);
    // }
    //else if (cycleTime < 3.5) {
    //   _drawL2(canvas, size, l2Pct);
    // } else if (cycleTime < 4.5) {
    //   _drawL3(canvas, size, l3Pct);
    // } else {
    //   _drawL4AndFinal(canvas, size, l4Pct);
    // }
  }

  void _drawInitial(canvas, size, initPct) {
    double blockDim = (size.height * .6) / 28;
    double yOffset = size.height * .2;
    double xOffset = (size.width - (size.height * .6)) / 2;

    for (int i = 0; i < data[0].length; i++) {
      int row = i ~/ 28;
      int col = i % 28;
      double xPos = col * blockDim + xOffset;
      double yPos = row * blockDim + yOffset;

      int alpha = ((data[0][i] * 255).round()).clamp(0, 255);
      Color base = networkGraphColors[0];
      final mPaint = Paint()..color = base.withAlpha(alpha);
      Rect rect = Offset(xPos, yPos) & Size(blockDim, blockDim);
      canvas.drawRect(rect, mPaint);
    }
  }

  void _drawMove(canvas, size, mvPct) {
    double yOffset = size.height * .2;
    double xOffset = (size.width - (size.height * .6)) / 2;
    int index = 0;
    for (int i = 0; i < data[index].length; i++) {
      double blockDim = (size.height * .6) / math.max(28, 28 * mvPct * 2);
      int row = i ~/ 28;
      int col = i % 28;
      double xPos = col * blockDim + xOffset;
      double yPos = row * blockDim + yOffset;
      double xEndPos = (size.width / 10) + (size.width / 5) * index;
      double yEndPos = ((size.height * .95) / data[index].length) * i;
      Offset start = Offset(xPos, yPos);
      Offset end = Offset(xEndPos, yEndPos);
      Offset curr = Offset.lerp(start, end, mvPct) ?? start;
      int alpha = ((data[index][i] * 255).round()).clamp(0, 255);
      Color base = networkGraphColors[index];
      final mPaint = Paint()..color = base.withAlpha(alpha);
      final rect = Rect.fromLTWH(curr.dx, curr.dy, blockDim, blockDim);
      final double radius = mvPct * 4;
      final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
      canvas.drawRRect(rrect, mPaint);
    }
  }

  // void _drawL1(canvas, size, l1Pct) {
  //   int index = 0;
  //   double initNodeDim = (size.height * .6) / 112;
  //   for (int i = 0; i < data[index].length; i++) {
  //     double xPos = (size.width / 10) + (size.width / 5) * index;
  //     double yPos = ((size.height * .95) / data[index].length) * i;
  //     Offset nodePos = Offset(xPos, yPos);
  //     int alpha = ((data[index][i] * 255).round()).clamp(0, 255);
  //     Color base = networkGraphColors[index];
  //     final mPaint = Paint()..color = base.withAlpha(alpha);
  //     final linePaint =
  //         Paint()
  //           ..style = PaintingStyle.stroke
  //           ..strokeWidth = 1.5
  //           ..color = networkGraphColors[index].withAlpha(alpha);
  //     canvas.drawCircle(nodePos, initNodeDim, mPaint);
  //     for (int j = 0; j < data[1].length; j++) {
  //       double xEndPos = (size.width / 10) + (size.width / 5);
  //       double yEndPos = (((size.height * .95) / data[1].length) * j);
  //       Offset end = Offset(xEndPos, yEndPos);
  //       Offset curr = Offset.lerp(nodePos, end, l1Pct) ?? nodePos;
  //       canvas.drawLine(nodePos, curr, linePaint);
  //     }
  //   }
  // }

  @override
  bool shouldRepaint(MnemosynePainter old) {
    return old.time != time || old.data != data;
  }
}
