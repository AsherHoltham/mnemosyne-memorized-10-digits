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
  bool runAnimation = true;
  bool animationFinished = false;

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
              (size.width * .025) + ((size.width * .95) / 4.05) * layer;
          double yPos =
              (size.height * .05) +
              ((size.height * .90) / scaledCurrLayerValues.length) * node;
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
                  (size.width * .025) + ((size.width * .95) / 4.05) * nextLayer;
              double yNextPos =
                  (size.height * .05) +
                  ((size.height * .9) / scaledNextLayerValues.length) * outNode;
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
      double xPos = (size.width * .025) + ((size.width * .95) / 4.05) * 4;
      double yPos = (size.height * .05) + ((size.height * .9) / 10) * outputs;
      double nodeRadius = ((size.height * .95) / 10) / 2.5;
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
    return brainMap;
  }

  @override
  void paint(Canvas canvas, Size size) {
    nodeMap = initNodeMap(data, size);

    if (time < .5) {
      _drawInitial(canvas, size);
    } else if (runAnimation) {
      double mvPct = time - .5;
      if (mvPct > 1 && runAnimation) {
        mvPct = 1;
        runAnimation = false;
      }
      _drawMove(canvas, size, mvPct);
    }
    if (!runAnimation) {
      _drawFullGraph(canvas, size, nodeMap);
      animationFinished = true;
    }
  }

  void _drawInitial(canvas, size) {
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
      double xEndPos = (size.width * .025) + ((size.width * .95) / 4.5) * index;
      double yEndPos =
          (size.height * .05) + ((size.height * .90) / data[index].length) * i;
      Offset start = Offset(xPos, yPos);
      Offset end = Offset(xEndPos, yEndPos);
      Offset curr = Offset.lerp(start, end, mvPct) ?? start;
      int alpha = ((data[index][i] * 255).round()).clamp(0, 255);
      Color base = networkGraphColors[index];
      final mPaint = Paint()..color = base.withAlpha(alpha);
      if (alpha > .5) {
        if (mvPct < .95) {
          final rect = Rect.fromLTWH(curr.dx, curr.dy, blockDim, blockDim);
          final double radius = mvPct * 4;
          final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
          canvas.drawRRect(rrect, mPaint);
        } else {
          canvas.drawCircle(end, (size.height * .005), mPaint);
        }
      }
    }
  }

  // void _drawAccrossGraph(canvas, size, nodeMap, percent) {
  //   //double currXValue =
  //   for (int i = 0; i < nodeMap.length; i++) {
  //     int alpha = (nodeMap[i].scaledValue * 255).round().clamp(0, 255);
  //     Color base = networkGraphColors[nodeMap[i].index];
  //     final mPaint = Paint()..color = base.withAlpha(alpha);
  //     canvas.drawCircle(nodeMap[i].pos, nodeMap[i].radius, mPaint);
  //     for (int j = 0; j < nodeMap[i].outEdgeList.length; j++) {
  //       int lineAlpha = (nodeMap[i].outEdgeList[j].scaledValue * 255)
  //           .round()
  //           .clamp(0, 255);
  //       final linePaint =
  //           Paint()
  //             ..style = PaintingStyle.stroke
  //             ..strokeWidth = .5
  //             ..color = networkGraphColors[nodeMap[i].index].withAlpha(
  //               lineAlpha,
  //             );
  //       canvas.drawLine(
  //         nodeMap[i].outEdgeList[j].startPos,
  //         nodeMap[i].outEdgeList[j].endPos,
  //         linePaint,
  //       );
  //     }
  //   }
  // }

  void _drawFullGraph(canvas, size, nodeMap) {
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
  bool shouldRepaint(MnemosynePainter old) {
    return old.time != time || old.data != data;
  }
}
