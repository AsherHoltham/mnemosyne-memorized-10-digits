import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/scheduler.dart';

class DeltaTime {
  DeltaTime._() {
    WidgetsFlutterBinding.ensureInitialized();
    SchedulerBinding.instance.addPersistentFrameCallback(_onFrame);
    SchedulerBinding.instance.scheduleFrame();
  }
  static final instance = DeltaTime._();

  Duration _last = Duration.zero;

  Duration deltaTime = Duration.zero;

  void _onFrame(Duration timestamp) {
    if (_last != Duration.zero) {
      deltaTime = timestamp - _last;
    }
    _last = timestamp;
    SchedulerBinding.instance.scheduleFrame();
  }
}

class Mnemosyne {
  final deltaTime = DeltaTime.instance;
  Mnemosyne();
}

class MnemosyneRootStream extends Bloc<dynamic, Mnemosyne> {
  MnemosyneRootStream() : super(Mnemosyne());
}
