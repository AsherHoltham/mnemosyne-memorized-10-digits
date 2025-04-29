import 'package:flutter/material.dart';

const List<Color> networkGraphColors = [
  //way of depicting geyscale // input on gradient from white to this
  Color(0xFF9B111E), // Ruby Red L1 on gradient from transparrent to this
  Color(0xFFFF7E00), // Amber Orange L2 on gradient from transparrent to this
  Color(0xFFD4AF37), // Royal Gold L3 on gradient from transparrent to this
  Color(0xFF008B8B), // Deep Teal L4 on gradient from transparrent to this
  Color(0xFF8A2BE2), // Blue Violet L5 on gradient from transparrent to this
];

class DrawingPad extends StatefulWidget {
  final double width;
  final double height;

  const DrawingPad({super.key, required this.width, required this.height});

  @override
  // ignore: library_private_types_in_public_api
  _DrawingPadState createState() => _DrawingPadState();
}

class _DrawingPadState extends State<DrawingPad> {
  final _points = <Offset?>[];

  @override
  Widget build(BuildContext context) {
    final stroke = widget.width / 28.0;
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: GestureDetector(
        onPanUpdate: (d) {
          final box = context.findRenderObject() as RenderBox;
          setState(() => _points.add(box.globalToLocal(d.globalPosition)));
        },
        onPanEnd: (_) => _points.add(null),
        child: CustomPaint(
          size: Size(widget.width, widget.height),
          painter: _DrawingPainter(_points, stroke),
        ),
      ),
    );
  }
}

class _DrawingPainter extends CustomPainter {
  final List<Offset?> points;
  final double strokeWidth;
  _DrawingPainter(this.points, this.strokeWidth);

  @override
  void paint(Canvas c, Size s) {
    final paint =
        Paint()
          ..color = Colors.black
          ..strokeCap = StrokeCap.round
          ..strokeWidth = strokeWidth;
    for (var i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        c.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_) => true;
}
