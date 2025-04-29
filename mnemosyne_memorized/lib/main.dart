import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'interface.dart';
import 'business_logic.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  // DeltaTime.instance;
  runApp(
    BlocProvider(create: (_) => MnemosyneRootStream(), child: const Root()),
  );
}

class Root extends StatelessWidget {
  const Root({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const RootPage());
  }
}

class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidth = constraints.maxWidth;
        final double screenHeight = constraints.maxHeight;
        final double padDim = screenHeight / 2;

        return BlocBuilder<MnemosyneRootStream, Mnemosyne>(
          builder: (context, mnemo) {
            //final dtMs = mnemo.delta.deltaTime.inMicroseconds;
            return Scaffold(
              backgroundColor: Color.fromARGB(255, 42, 42, 42),
              body: Center(
                child: Container(
                  width: padDim,
                  height: padDim,
                  color: Colors.white,
                  child: DrawingPad(width: padDim, height: padDim),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
