import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'interface_layer.dart';
import 'business_logic_layer.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  runApp(
    BlocProvider(create: (_) => MnemosyneRootStream(), child: const Root()),
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
            //final dtMs = mnemo.delta.deltaTime.inMicroseconds;
            return Scaffold(
              backgroundColor: Color.fromARGB(255, 42, 42, 42),
              body: Center(
                child: Stack(
                  children: [
                    if (mnemo.animationReady)
                      PredictionAnimator(
                        width: padDim,
                        height: padDim,
                        inputPoints: mnemo.painterData,
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
                                    duration: Duration(milliseconds: 200),
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
                                  .animate(
                                    mnemo.hasDrawn && !mnemo.startAnimation,
                                  )
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
                                child: Text("Show Mnemosyne"),
                                onPressed:
                                    () => {
                                      context.read<MnemosyneRootStream>().add(
                                        StartAnimationEvent(
                                          padKey
                                                  .currentState
                                                  ?.normalizedPoints ??
                                              [],
                                        ),
                                      ),
                                    },
                              )
                              .animate(mnemo.hasDrawn && !mnemo.startAnimation)
                              .fade()
                              .slide(from: Offset(0, .2)),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
