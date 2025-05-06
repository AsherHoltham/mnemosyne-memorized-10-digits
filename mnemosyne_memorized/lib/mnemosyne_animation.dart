import 'package:flutter/material.dart';
//import 'dart:math' as math;

const List<Color> networkGraphColors = [
  //way of depicting geyscale // input on gradient from white to this
  Color(0xFF9B111E), // Ruby Red L1 on gradient from transparrent to this
  Color(0xFFFF7E00), // Amber Orange L2 on gradient from transparrent to this
  Color(0xFFD4AF37), // Royal Gold L3 on gradient from transparrent to this
  Color(0xFF008B8B), // Deep Teal L4 on gradient from transparrent to this
  Color(0xFF8A2BE2), // Blue Violet L5 on gradient from transparrent to this
];

class BrainEdge {
  final Offset startPos;
  final Offset endPos;
  final double scaledValue;
  BrainEdge({
    required this.startPos,
    required this.endPos,
    required this.scaledValue,
  });
}

class BrainNode {
  final Offset pos;
  final int index;
  final double scaledValue;
  final double radius;
  final List<BrainEdge> outEdgeList;

  BrainNode({
    required this.pos,
    required this.index,
    required this.scaledValue,
    required this.radius,
    required this.outEdgeList,
  });
}

class MnemosynePainter extends CustomPainter {
  final double time;
  final List<List<double>> data;
  List<BrainNode> nodeMap = [];

  MnemosynePainter({required this.time, required this.data});

  List<double> scaleToRange(
    List<double> values,
    double maxScale, {
    double minScale = 0,
  }) {
    if (values.isEmpty) return [];

    double minValue = values.reduce((a, b) => a < b ? a : b);
    double maxValue = values.reduce((a, b) => a > b ? a : b);

    if (minValue == maxValue) {
      return List.filled(values.length, ((minScale + maxScale) / 2));
    }

    return values.map((value) {
      return (((value - minValue) / (maxValue - minValue)) *
              (maxScale - minScale) +
          minScale);
    }).toList();
  }

  List<BrainNode> initNodeMap(List<List<double>> data, Size size) {
    List<BrainNode> brainMap = [];
    double scaleCutOff = .5;
    for (int layer = 0; layer < data.length - 1; layer++) {
      int nextLayer = layer + 1;
      List<double> scaledCurrLayerValues = scaleToRange(data[layer], 1.0);
      List<double> scaledNextLayerValues = scaleToRange(data[nextLayer], 1.0);
      for (int node = 0; node < scaledCurrLayerValues.length; node++) {
        double nodeValue = scaledCurrLayerValues[node];
        if (nodeValue > scaleCutOff) {
          double xPos =
              (size.width * .025) + ((size.width * .95) / 4.5) * layer;
          double yPos =
              (size.height * .025) +
              ((size.height * .95) / scaledCurrLayerValues.length) * node;
          double nodeRadius = (size.height * .005);
          Offset nodePos = Offset(xPos, yPos);
          List<BrainEdge> nodeEdges = [];
          for (
            int outNode = 0;
            outNode < scaledNextLayerValues.length;
            outNode++
          ) {
            if (scaledNextLayerValues[outNode] > scaleCutOff) {
              double xNextPos =
                  (size.width * .025) + ((size.width * .95) / 4.5) * nextLayer;
              double yNextPos =
                  (size.height * .025) +
                  ((size.height * .95) / scaledNextLayerValues.length) *
                      outNode;
              Offset nextPos = Offset(xNextPos, yNextPos);
              double edgeValue =
                  (scaledNextLayerValues[outNode] + nodeValue) / 2;
              BrainEdge edge = BrainEdge(
                startPos: nodePos,
                endPos: nextPos,
                scaledValue: edgeValue,
              );
              nodeEdges.add(edge);
            }
          }
          BrainNode newNode = BrainNode(
            pos: nodePos,
            index: layer,
            scaledValue: nodeValue,
            radius: nodeRadius,
            outEdgeList: nodeEdges,
          );
          brainMap.add(newNode);
        }
      }
    }
    for (int outputs = 0; outputs < 10; outputs++) {
      double xPos = (size.width * .025) + ((size.width * .95) / 4.5) * 4;
      double yPos = (size.height * .025) + ((size.height * .95) / 10) * outputs;
      double nodeRadius = ((size.height * .95) / 10) / 3;
      Offset nodePos = Offset(xPos, yPos);
      BrainNode outNode = BrainNode(
        pos: nodePos,
        index: 4,
        scaledValue: data[4][outputs],
        radius: nodeRadius,
        outEdgeList: [],
      );
      brainMap.add(outNode);
    }
    //print(brainMap.length);
    return brainMap;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(Offset(0, 0), 10, Paint()..color = Colors.black);
    canvas.drawCircle(
      Offset(0, size.height),
      10,
      Paint()..color = Colors.black,
    );
    canvas.drawCircle(Offset(size.width, 0), 10, Paint()..color = Colors.black);
    canvas.drawCircle(
      Offset(size.width, size.height),
      10,
      Paint()..color = Colors.black,
    );
    nodeMap = initNodeMap(data, size);
    for (int i = 0; i < nodeMap.length; i++) {
      int alpha = (nodeMap[i].scaledValue * 255).round().clamp(0, 255);
      Color base = networkGraphColors[nodeMap[i].index];
      final mPaint = Paint()..color = base.withAlpha(alpha);
      canvas.drawCircle(nodeMap[i].pos, nodeMap[i].radius, mPaint);
      for (int j = 0; j < nodeMap[i].outEdgeList.length; j++) {
        int lineAlpha = (nodeMap[i].outEdgeList[j].scaledValue * 255)
            .round()
            .clamp(0, 255);
        final linePaint =
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = .5
              ..color = networkGraphColors[nodeMap[i].index].withAlpha(
                lineAlpha,
              );
        canvas.drawLine(
          nodeMap[i].outEdgeList[j].startPos,
          nodeMap[i].outEdgeList[j].endPos,
          linePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(MnemosynePainter old) => false;
}

// void _drawInitial(canvas, size, initPct) {
  //   double blockDim = (size.height * .6) / 28;
  //   double yOffset = size.height * .2;
  //   double xOffset = (size.width - (size.height * .6)) / 2;

  //   for (int i = 0; i < data[0].length; i++) {
  //     int row = i ~/ 28;
  //     int col = i % 28;
  //     double xPos = col * blockDim + xOffset;
  //     double yPos = row * blockDim + yOffset;

  //     int alpha = ((data[0][i] * 255).round()).clamp(0, 255);
  //     Color base = networkGraphColors[0];
  //     final mPaint = Paint()..color = base.withAlpha(alpha);
  //     Rect rect = Offset(xPos, yPos) & Size(blockDim, blockDim);
  //     canvas.drawRect(rect, mPaint);
  //   }
  // }

  // void _drawMove(canvas, size, mvPct) {
  //   double yOffset = size.height * .2;
  //   double xOffset = (size.width - (size.height * .6)) / 2;
  //   int index = 0;
  //   for (int i = 0; i < data[index].length; i++) {
  //     double blockDim = (size.height * .6) / math.max(28, 28 * mvPct * 2);
  //     int row = i ~/ 28;
  //     int col = i % 28;
  //     double xPos = col * blockDim + xOffset;
  //     double yPos = row * blockDim + yOffset;
  //     double xEndPos = (size.width / 10) + (size.width / 5) * index;
  //     double yEndPos = ((size.height * .95) / data[index].length) * i;
  //     Offset start = Offset(xPos, yPos);
  //     Offset end = Offset(xEndPos, yEndPos);
  //     Offset curr = Offset.lerp(start, end, mvPct) ?? start;
  //     int alpha = ((data[index][i] * 255).round()).clamp(0, 255);
  //     Color base = networkGraphColors[index];
  //     final mPaint = Paint()..color = base.withAlpha(alpha);
  //     final rect = Rect.fromLTWH(curr.dx, curr.dy, blockDim, blockDim);
  //     final double radius = mvPct * 4;
  //     final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
  //     canvas.drawRRect(rrect, mPaint);
  //   }
  // }

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