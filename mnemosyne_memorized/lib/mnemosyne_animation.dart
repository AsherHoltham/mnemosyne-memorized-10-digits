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

  @override
  void paint(Canvas canvas, Size size) {
    double initPercent = 0.0;
    double movePercent = 0.0;
    double l1Percent = 0.0;
    double l2Percent = 0.0;
    double l3Percent = 0.0;
    double l4Percent = 0.0;

    if (time < 0.5) {
      initPercent = time * 2.0;
      movePercent = 0.0;
      l1Percent = 0.0;
      l2Percent = 0.0;
      l3Percent = 0.0;
      l4Percent = 0.0;
      state = MnemosyneState.initial;
    } else if (time < 1.5) {
      initPercent = 1.0;
      movePercent = time - 0.5;
      l1Percent = 0.0;
      l2Percent = 0.0;
      l3Percent = 0.0;
      l4Percent = 0.0;
      state = MnemosyneState.movingIntoPlace;
    } else if (time < 2.5) {
      initPercent = 1.0;
      movePercent = 1.0;
      l1Percent = time - 1.5;
      l2Percent = 0.0;
      l3Percent = 0.0;
      l4Percent = 0.0;
      state = MnemosyneState.drawToL1;
    } else if (time < 3.5) {
      initPercent = 1.0;
      movePercent = 1.0;
      l1Percent = 1.0;
      l2Percent = time - 2.5;
      l3Percent = 0.0;
      l4Percent = 0.0;
      state = MnemosyneState.drawToL2;
    } else if (time < 4.5) {
      initPercent = 1.0;
      movePercent = 1.0;
      l1Percent = 1.0;
      l2Percent = 1.0;
      l3Percent = time - 3.5;
      l4Percent = 0.0;
      state = MnemosyneState.drawToL3;
    } else if (time < 5.5) {
      initPercent = 1.0;
      movePercent = 1.0;
      l1Percent = 1.0;
      l2Percent = 1.0;
      l3Percent = 1.0;
      l4Percent = time - 4.5;
      state = MnemosyneState.drawToL4;
    } else {
      initPercent = 1.0;
      movePercent = 1.0;
      l1Percent = 1.0;
      l2Percent = 1.0;
      l3Percent = 1.0;
      l4Percent = 1.0;
      state = MnemosyneState.finalModel;
    }

    if (state == MnemosyneState.initial) {
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
    } else {
      double yOffset = size.height * .2;
      double xOffset = (size.width - (size.height * .6)) / 2;
      for (int i = 0; i < data[0].length; i++) {
        double blockDim = (size.height * .6) / math.max(28, 28 * movePercent);
        int row = i ~/ 28;
        int col = i % 28;
        double xPos = col * blockDim + xOffset;
        double yPos = row * blockDim + yOffset;

        int alpha = ((data[0][i] * 255).round()).clamp(0, 255);
        Color base = networkGraphColors[0];
        final mPaint = Paint()..color = base.withAlpha(alpha);
        final rect = Rect.fromLTWH(xPos, yPos, blockDim, blockDim);
        final double radius = movePercent * 2;
        final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
        canvas.drawRRect(rrect, mPaint);
      }
    }
  }

  @override
  bool shouldRepaint(MnemosynePainter old) => old.time != time;
}
