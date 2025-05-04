import 'package:flutter/material.dart';

const List<Color> networkGraphColors = [
  //way of depicting geyscale // input on gradient from white to this
  Color(0xFF9B111E), // Ruby Red L1 on gradient from transparrent to this
  Color(0xFFFF7E00), // Amber Orange L2 on gradient from transparrent to this
  Color(0xFFD4AF37), // Royal Gold L3 on gradient from transparrent to this
  Color(0xFF008B8B), // Deep Teal L4 on gradient from transparrent to this
  Color(0xFF8A2BE2), // Blue Violet L5 on gradient from transparrent to this
];

class PredictionAnimator extends StatelessWidget {
  final double padWidth;
  final double padHeight;
  final List<Offset?> inputPoints;
  final double time = 0.0;

  const PredictionAnimator({
    super.key,
    required this.padWidth,
    required this.padHeight,
    required this.inputPoints,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: padWidth,
      height: padHeight,
      color: Colors.white,
      child: CustomPaint(
        size: Size(padWidth, padHeight),
        painter: _AnimationInitPainter(inputPoints, padWidth / 28.0),
      ),
    );
  }
}

class _AnimationInitPainter extends CustomPainter {
  final List<Offset?> normPts;
  final double strokeWidth;
  _AnimationInitPainter(this.normPts, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.black
          ..strokeCap = StrokeCap.round
          ..strokeWidth = strokeWidth;

    List<Offset?> pts =
        normPts.map((p) {
          if (p == null) return null;
          return Offset(p.dx * size.width, p.dy * size.height);
        }).toList();

    for (var i = 0; i < pts.length - 1; i++) {
      if (pts[i] != null && pts[i + 1] != null) {
        canvas.drawLine(pts[i]!, pts[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ScaledPainter old) => true;
}

class DrawingPad extends StatefulWidget {
  final double width;
  final double height;
  final bool enableDrawing;

  const DrawingPad({
    super.key,
    required this.width,
    required this.height,
    required this.enableDrawing,
  });

  @override
  // ignore: library_private_types_in_public_api
  DrawingPadState createState() => DrawingPadState();
}

class DrawingPadState extends State<DrawingPad> {
  final _normPoints = <Offset?>[];

  bool get _canDraw => widget.enableDrawing;

  void clear() => setState(() => _normPoints.clear());

  List<Offset?> get normalizedPoints => List.unmodifiable(_normPoints);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: GestureDetector(
        onPanUpdate: (d) {
          if (!_canDraw) return;
          final local = d.localPosition;
          setState(() {
            _normPoints.add(
              Offset(local.dx / widget.width, local.dy / widget.height),
            );
          });
        },
        onPanEnd: (_) {
          if (!_canDraw) return;
          setState(() => _normPoints.add(null));
        },
        child: ClipRect(
          child: CustomPaint(
            size: Size(widget.width, widget.height),
            painter: _ScaledPainter(_normPoints, widget.width / 28.0),
          ),
        ),
      ),
    );
  }
}

class _ScaledPainter extends CustomPainter {
  final List<Offset?> normPts;
  final double strokeWidth;
  _ScaledPainter(this.normPts, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.black
          ..strokeCap = StrokeCap.round
          ..strokeWidth = strokeWidth;

    List<Offset?> pts =
        normPts.map((p) {
          if (p == null) return null;
          return Offset(p.dx * size.width, p.dy * size.height);
        }).toList();

    for (var i = 0; i < pts.length - 1; i++) {
      if (pts[i] != null && pts[i + 1] != null) {
        canvas.drawLine(pts[i]!, pts[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ScaledPainter old) => true;
}

abstract class _Effect {
  Widget build(Widget child, Animation<double> anim);
}

class _FadeEffect implements _Effect {
  @override
  Widget build(Widget child, Animation<double> anim) =>
      FadeTransition(opacity: anim, child: child);
}

class _SlideEffect implements _Effect {
  final Offset from;
  _SlideEffect(this.from);

  @override
  Widget build(Widget child, Animation<double> anim) => SlideTransition(
    position: anim.drive(
      Tween(
        begin: from,
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOut)),
    ),
    child: child,
  );
}

class AnimateWidget extends StatefulWidget {
  final Widget child;
  final bool show;
  final Duration duration;
  // ignore: library_private_types_in_public_api
  final List<_Effect> effects;

  const AnimateWidget({
    super.key,
    required this.child,
    required this.show,
    this.duration = const Duration(milliseconds: 300),
    this.effects = const [],
  });

  AnimateWidget fade() => AnimateWidget(
    show: show,
    duration: duration,
    effects: [...effects, _FadeEffect()],
    child: child,
  );

  AnimateWidget slide({Offset from = const Offset(0, 1)}) => AnimateWidget(
    show: show,
    duration: duration,
    effects: [...effects, _SlideEffect(from)],
    child: child,
  );

  @override
  // ignore: library_private_types_in_public_api
  _AnimateWidgetState createState() => _AnimateWidgetState();
}

class _AnimateWidgetState extends State<AnimateWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(vsync: this, duration: widget.duration);
    if (widget.show) _ctl.forward();
  }

  @override
  void didUpdateWidget(covariant AnimateWidget old) {
    super.didUpdateWidget(old);
    if (old.show != widget.show) {
      if (widget.show) {
        _ctl.forward();
      } else {
        _ctl.reverse();
      }
    }
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctl,
      builder: (_, child) {
        Widget w = child!;
        for (final e in widget.effects) {
          w = e.build(w, _ctl);
        }
        return w;
      },
      child: widget.child,
    );
  }
}

extension AnimateExtension on Widget {
  AnimateWidget animate(
    bool show, {
    Duration duration = const Duration(milliseconds: 800),
  }) {
    return AnimateWidget(show: show, duration: duration, child: this);
  }
}

class MyButton extends StatelessWidget {
  final double scale;
  final Widget child;
  final VoidCallback onPressed;
  final Color? color;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final TextStyle childStyle;

  const MyButton({
    super.key,
    required this.scale,
    required this.child,
    required this.onPressed,
    required this.childStyle,
    this.color = Colors.white,
    this.borderRadius = 4,
    this.padding = const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(scale / 8),
      child: SizedBox(
        width: scale * 2.7,
        height: scale,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onPressed,
          child: Padding(
            padding: padding,
            child: DefaultTextStyle(
              style: childStyle,
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}
