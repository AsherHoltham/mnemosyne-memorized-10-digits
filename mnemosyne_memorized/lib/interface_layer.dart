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
  DrawingPadState createState() => DrawingPadState();
}

class DrawingPadState extends State<DrawingPad> {
  final _points = <Offset?>[];

  void clear() {
    setState(() {
      _points.clear();
    });
  }

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
        child: ClipRect(
          child: CustomPaint(
            size: Size(widget.width, widget.height),
            painter: _DrawingPainter(_points, stroke),
          ),
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
