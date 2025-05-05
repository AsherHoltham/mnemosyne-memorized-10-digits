import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'interface_layer.dart';
import 'business_logic_layer.dart';
import 'database_layer.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final rootBloc = MnemosyneRootStream();
  final dataBloc = MnemosyneDataStream();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: rootBloc),
        BlocProvider.value(value: dataBloc),
      ],
      child: const Root(),
    ),
  );
}

class Root extends StatelessWidget {
  const Root({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // localizationsDelegates: AppLocalizations.localizationsDelegates,
      // supportedLocales: AppLocalizations.supportedLocales,
      home: RootPage(),
    );
  }
}

class RootPage extends StatelessWidget {
  RootPage({super.key});
  final GlobalKey<DrawingPadState> padKey = GlobalKey<DrawingPadState>();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidth = constraints.maxWidth;
        final double screenHeight = constraints.maxHeight;
        final double padDim = screenHeight / 1.5;
        final double spacing = screenHeight / 40;
        final double fontSize = screenWidth * 0.013;
        final double buttonScale = screenWidth * 1 / 20;

        TextStyle planeTextStyle = TextStyle(
          color: Colors.white,
          fontFamily: 'alte haas grotesk',
          fontWeight: FontWeight.w700,
          fontSize: fontSize,
        );
        TextStyle buttonTextStyle = TextStyle(
          color: Color.fromARGB(255, 42, 42, 42),
          fontFamily: 'alte haas grotesk',
          fontWeight: FontWeight.w900,
          fontSize: fontSize,
        );

        return BlocBuilder<MnemosyneRootStream, Mnemosyne>(
          builder: (context, mnemo) {
            return BlocBuilder<MnemosyneDataStream, MnemosyneData>(
              builder: (context, mnemoData) {
                return InterfaceLayer(
                  width: screenWidth,
                  height: screenHeight,
                  padKey: padKey,
                  mnemo: mnemo,
                  mnemoData: mnemoData,
                  padDim: padDim,
                  spacing: spacing,
                  buttonScale: buttonScale,
                  planeTextStyle: planeTextStyle,
                  buttonTextStyle: buttonTextStyle,
                );
              },
            );
          },
        );
      },
    );
  }
}

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
