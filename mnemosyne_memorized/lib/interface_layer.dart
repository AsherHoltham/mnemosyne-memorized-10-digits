import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'database_layer.dart';
import 'business_logic_layer.dart';
import 'mnemosyne_animation.dart';

class InterfaceLayer extends StatelessWidget {
  final double width;
  final double height;
  final GlobalKey<DrawingPadState> padKey;
  final Mnemosyne mnemo;
  final MnemosyneData mnemoData;
  final double padDim;
  final double spacing;
  final double buttonScale;
  final TextStyle planeTextStyle;
  final TextStyle buttonTextStyle;

  const InterfaceLayer({
    required this.width,
    required this.height,
    super.key,
    required this.padKey,
    required this.mnemo,
    required this.mnemoData,
    required this.padDim,
    required this.spacing,
    required this.buttonScale,
    required this.planeTextStyle,
    required this.buttonTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 42, 42, 42),
      body: Center(
        child: Stack(
          children: [
            if (mnemo.animationReady)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                            "Mnemosyne sees a ${mnemoData.prediction}",
                            style: planeTextStyle,
                          )
                          .animate(mnemo.showUIEnd)
                          .fade()
                          .slide(from: const Offset(0, .2)),
                    ],
                  ),
                  SizedBox(height: spacing),
                  PredictionAnimator(
                    screenWidth: width,
                    screenHeight: height,
                    padWidth: padDim,
                    padHeight: padDim,
                    inputPoints: mnemo.painterData,
                  ),
                  SizedBox(height: spacing),
                  MyButton(
                        scale: buttonScale,
                        childStyle: buttonTextStyle,
                        child: const Text("Draw again"),
                        onPressed: () {
                          context.read<MnemosyneRootStream>().add(
                            const ResetEvent(),
                          );
                          padKey.currentState?.clear();
                        },
                      )
                      .animate(mnemo.showUIEnd)
                      .fade()
                      .slide(from: const Offset(0, .2)),
                ],
              ),
            if (!mnemo.animationReady)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Text("Draw a Digit Below", style: planeTextStyle)
                          .animate(
                            !mnemo.hasDrawn && !mnemo.startAnimation,
                            duration: const Duration(milliseconds: 200),
                          )
                          .fade()
                          .slide(from: const Offset(0, .2)),
                      MyButton(
                            scale: buttonScale,
                            childStyle: buttonTextStyle,
                            child: const Text("Reset Drawing"),
                            onPressed: () {
                              context.read<MnemosyneRootStream>().add(
                                const UndoDrawEvent(),
                              );
                              padKey.currentState?.clear();
                            },
                          )
                          .animate(mnemo.hasDrawn && !mnemo.startAnimation)
                          .fade()
                          .slide(from: const Offset(0, .2)),
                    ],
                  ),
                  SizedBox(height: spacing),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanDown: (_) {
                      if (!mnemo.startAnimation) {
                        context.read<MnemosyneRootStream>().add(
                          const DrawEvent(),
                        );
                      }
                    },
                    child: Container(
                      width: padDim,
                      height: padDim,
                      color: Colors.white,
                      child: DrawingPad(
                        key: padKey,
                        width: padDim,
                        height: padDim,
                        enableDrawing: !mnemo.startAnimation,
                      ),
                    ),
                  ),
                  SizedBox(height: spacing),
                  MyButton(
                        scale: buttonScale,
                        childStyle: buttonTextStyle,
                        child: const Text("Show Mnemosyne"),
                        onPressed: () {
                          context.read<MnemosyneRootStream>().add(
                            StartAnimationEvent(
                              padKey.currentState?.normalizedPoints ?? [],
                            ),
                          );
                        },
                      )
                      .animate(mnemo.hasDrawn && !mnemo.startAnimation)
                      .fade()
                      .slide(from: const Offset(0, .2)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class PredictionAnimator extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final double padWidth;
  final double padHeight;
  final List<Offset?> inputPoints;

  const PredictionAnimator({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.padWidth,
    required this.padHeight,
    required this.inputPoints,
  });
  @override
  // ignore: library_private_types_in_public_api
  _PredictionAnimatorState createState() => _PredictionAnimatorState();
}

class _PredictionAnimatorState extends State<PredictionAnimator> {
  final GlobalKey _boundaryKey = GlobalKey();
  late final MnemosyneDataStream _dataBloc;
  late final MnemosyneRootStream _controlBloc;
  bool start = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dataBloc = context.read<MnemosyneDataStream>();
    _controlBloc = context.read<MnemosyneRootStream>();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _exportGrid());
    setState(() => start = false);
  }

  Future<void> _exportGrid() async {
    final grid = await GridExporter.exportTo28x28(_boundaryKey);
    final inputs = grid.map((i) => i.toDouble()).toList();
    _dataBloc.add(UpdateInputData(inputs));
    _dataBloc.add(UpdateActivations());
    await _dataBloc.stream.firstWhere((s) => s.predictionReady);
    setState(() => start = true);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (!start)
          RepaintBoundary(
            key: _boundaryKey,
            child: CustomPaint(
              size: Size(widget.padWidth, widget.padHeight),
              painter: _AnimationInitPainter(
                widget.inputPoints,
                widget.padWidth / 28,
              ),
            ),
          ),
        if (start)
          Container(
            width: widget.screenWidth * .9,
            height: widget.screenHeight * .8,
            color: Colors.black,
            child: CustomPaint(
              size: Size.infinite,
              painter: MnemosynePainter(time: _controlBloc.state.sequenceTime),
            ),
          ),
      ],
    );
  }
}

class _AnimationInitPainter extends CustomPainter {
  final List<Offset?> normPts;
  final double strokeWidth;

  _AnimationInitPainter(this.normPts, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);

    final paint =
        Paint()
          ..color = Colors.black
          ..strokeCap = StrokeCap.round
          ..strokeWidth = strokeWidth;

    final pts =
        normPts
            .map(
              (p) =>
                  p == null
                      ? null
                      : Offset(p.dx * size.width, p.dy * size.height),
            )
            .toList();

    for (var i = 0; i < pts.length - 1; i++) {
      if (pts[i] != null && pts[i + 1] != null) {
        canvas.drawLine(pts[i]!, pts[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AnimationInitPainter old) => true;
}

class GridExporter {
  static Future<List<int>> exportTo28x28(GlobalKey boundaryKey) async {
    final boundary =
        boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );
    final Uint8List pixels = byteData!.buffer.asUint8List();

    final width = image.width;
    final height = image.height;

    const int N = 28;
    final tileW = (width / N).floor();
    final tileH = (height / N).floor();

    final List<int> result = List.filled(N * N, 0);

    for (var row = 0; row < N; row++) {
      for (var col = 0; col < N; col++) {
        int sum = 0;
        int count = 0;

        final xStart = col * tileW;
        final yStart = row * tileH;

        for (var y = yStart; y < yStart + tileH; y++) {
          for (var x = xStart; x < xStart + tileW; x++) {
            final idx = (y * width + x) * 4;
            final r = pixels[idx];
            final g = pixels[idx + 1];
            final b = pixels[idx + 2];
            sum += ((r + g + b) ~/ 3);
            count++;
          }
        }
        result[row * N + col] = (sum ~/ count).clamp(0, 255);
      }
    }

    return result;
  }
}

class GreyscaleGrid extends StatelessWidget {
  final List<int> values;
  final double tileSize;

  const GreyscaleGrid({super.key, required this.values, required this.tileSize})
    : assert(values.length == 28 * 28);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: tileSize * 28,
      height: tileSize * 28,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 28,
          childAspectRatio: 1.0,
          mainAxisSpacing: 0,
          crossAxisSpacing: 0,
        ),
        itemCount: values.length,
        itemBuilder: (context, index) {
          final gray = values[index].clamp(0, 255);
          return Container(
            width: tileSize,
            height: tileSize,
            color: Color.fromARGB(255, gray, gray, gray),
          );
        },
      ),
    );
  }
}
// PRE ANIMATION WIDGETS //
// PRE ANIMATION WIDGETS //
// PRE ANIMATION WIDGETS //
// PRE ANIMATION WIDGETS //

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

          if (local.dx >= 0 &&
              local.dx <= widget.width &&
              local.dy >= 0 &&
              local.dy <= widget.height) {
            setState(() {
              _normPoints.add(
                Offset(local.dx / widget.width, local.dy / widget.height),
              );
            });
          }
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
