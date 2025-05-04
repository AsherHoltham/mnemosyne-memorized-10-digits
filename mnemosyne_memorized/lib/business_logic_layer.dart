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

class AnimationEvent extends MnemosyneEvent {
  const AnimationEvent();
}

class Mnemosyne {
  final DeltaTime delta = DeltaTime.instance;
  final bool hasDrawn;
  final bool startAnimation;
  //List<Offset?> painterData;

  Mnemosyne({this.hasDrawn = false, this.startAnimation = false});

  Mnemosyne drawing({bool? hasDrawn}) {
    return Mnemosyne(hasDrawn: hasDrawn ?? this.hasDrawn);
  }

  Mnemosyne animating({bool? startAnimation}) {
    return Mnemosyne(startAnimation: startAnimation ?? this.startAnimation);
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
      emit(state.drawing(hasDrawn: true));
    });

    on<UndoDrawEvent>((event, emit) {
      emit(state.drawing(hasDrawn: false));
    });

    on<AnimationEvent>((event, emit) {
      emit(state.animating(startAnimation: true));
    });
  }

  void _tick(Duration timestamp) {
    add(OutputEvent());
    SchedulerBinding.instance.scheduleFrame();
  }
}
