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

abstract class MnemosyneEvent {}

class OutputEvent extends MnemosyneEvent {}

class Mnemosyne {
  final delta = DeltaTime.instance;
  void outPut() {
    print('Δt: ${delta.deltaTime.inMicroseconds} μs');
  }
}

class MnemosyneRootStream extends Bloc<MnemosyneEvent, Mnemosyne> {
  MnemosyneRootStream() : super(Mnemosyne()) {
    on<OutputEvent>((_, __) => state.outPut());
    WidgetsFlutterBinding.ensureInitialized();
    SchedulerBinding.instance.addPersistentFrameCallback(_tick);
    SchedulerBinding.instance.scheduleFrame();
  }

  void _tick(Duration timestamp) {
    add(OutputEvent());
    SchedulerBinding.instance.scheduleFrame();
  }
}
