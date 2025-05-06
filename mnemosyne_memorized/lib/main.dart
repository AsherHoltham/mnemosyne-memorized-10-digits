import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'interface_layer.dart';
import 'business_logic_layer.dart';
import 'database_layer.dart';
//import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
      debugShowCheckedModeBanner: false,
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
        final double txtFontSize = screenWidth * 0.018;
        final double btnFontSize = screenWidth * 0.013;
        final double buttonScale = screenWidth * 1 / 20;

        TextStyle planeTextStyle = TextStyle(
          color: Colors.white,
          fontFamily: 'alte haas grotesk',
          fontWeight: FontWeight.w700,
          fontSize: txtFontSize,
        );
        TextStyle buttonTextStyle = TextStyle(
          color: Color.fromARGB(255, 42, 42, 42),
          fontFamily: 'alte haas grotesk',
          fontWeight: FontWeight.w900,
          fontSize: btnFontSize,
        );

        return BlocBuilder<MnemosyneRootStream, Mnemosyne>(
          builder: (context, mnemo) {
            return BlocBuilder<MnemosyneDataStream, MnemosyneData>(
              builder: (context, mnemoData) {
                return InterfaceLayer(
                  time: mnemo.sequenceTime,
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
