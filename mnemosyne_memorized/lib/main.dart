import 'package:flutter/material.dart';
import 'interface.dart';
import 'business_logic.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Root());
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

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text("")],
          ),
        );
      },
    );
  }
}
