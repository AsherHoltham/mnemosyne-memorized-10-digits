// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'database_layer.dart';
// import 'business_logic_layer.dart';

// const List<Color> networkGraphColors = [
//   //way of depicting geyscale // input on gradient from white to this
//   Color(0xFF9B111E), // Ruby Red L1 on gradient from transparrent to this
//   Color(0xFFFF7E00), // Amber Orange L2 on gradient from transparrent to this
//   Color(0xFFD4AF37), // Royal Gold L3 on gradient from transparrent to this
//   Color(0xFF008B8B), // Deep Teal L4 on gradient from transparrent to this
//   Color(0xFF8A2BE2), // Blue Violet L5 on gradient from transparrent to this
// ];


// class _MnemosynePainter extends CustomPainter {
//   final double progressMove, progressMorph, progressDraw;
//   final List<List<Offset>> layers;
//   _GraphPainter({
//     required this.progressMove,
//     required this.progressMorph,
//     required this.progressDraw,
//     required this.layers,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     // 1) Compute interpolated node positions
//     // 2) Draw tiles/circles based on progressMove/morph
//     // 3) For each layer pair, draw edges with PathMetrics * progressDraw
//     // (Implementation detail omitted for brevity)
//   }

//   @override
//   bool shouldRepaint(covariant _GraphPainter old) =>
//       old.progressDraw != progressDraw ||
//       old.progressMove != progressMove ||
//       old.progressMorph != progressMorph;
// }


// class GreyscaleStack extends StatelessWidget {
//   final List<List<double>> values;
//   final double deltaTime;
//   final List<List<Offset>> endOffsets;

//   const GreyscaleStack({
//     super.key,
//     required this.values,
//     required this.deltaTime,
//     required this.endOffsets,
//   }) : assert(values.length == 28 * 28),
//        assert(endOffsets.length == 28 * 28);

//   @override
//   Widget build(BuildContext context) {
//     return
//   }
// }

// class GreyScaleInputTile extends StatelessWidget {
//   final double percentToEndPos;
//   final double scale;
//   final double xPos;
//   final double yPos;
//   final int greyIndex;

//   const GreyScaleInputTile({
//     super.key,
//     required this.percentToEndPos,
//     required this.scale,
//     required this.xPos,
//     required this.yPos,
//     required this.greyIndex,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       borderRadius: BorderRadius.circular(percentToEndPos * scale),
//       color: Color.fromARGB(255, greyIndex, greyIndex, greyIndex),
//       child: SizedBox(height: scale, width: scale),
//     );
//   }
// }
