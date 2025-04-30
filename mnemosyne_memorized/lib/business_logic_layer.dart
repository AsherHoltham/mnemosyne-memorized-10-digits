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

abstract class MnemosyneEvent {
  const MnemosyneEvent();
}

class OutputEvent extends MnemosyneEvent {}

class DrawEvent extends MnemosyneEvent {
  const DrawEvent();
}

class UndoDrawEvent extends MnemosyneEvent {
  const UndoDrawEvent();
}

class Mnemosyne {
  final DeltaTime delta = DeltaTime.instance;
  final bool hasDrawn;

  Mnemosyne({this.hasDrawn = false});

  Mnemosyne copyWith({bool? hasDrawn}) {
    return Mnemosyne(hasDrawn: hasDrawn ?? this.hasDrawn);
  }

  void outPut() {
    print('Δt: ${delta.deltaTime.inMicroseconds} μs');
  }
}

class MnemosyneRootStream extends Bloc<MnemosyneEvent, Mnemosyne> {
  MnemosyneRootStream() : super(Mnemosyne()) {
    WidgetsFlutterBinding.ensureInitialized();
    SchedulerBinding.instance.addPersistentFrameCallback(_tick);
    SchedulerBinding.instance.scheduleFrame();

    on<OutputEvent>((_, __) => state.outPut());

    on<DrawEvent>((event, emit) {
      emit(state.copyWith(hasDrawn: true));
    });

    on<UndoDrawEvent>((event, emit) {
      emit(state.copyWith(hasDrawn: false));
    });
  }

  void _tick(Duration timestamp) {
    add(OutputEvent());
    SchedulerBinding.instance.scheduleFrame();
  }
}
