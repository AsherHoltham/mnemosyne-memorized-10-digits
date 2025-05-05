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

class StartAnimationEvent extends MnemosyneEvent {
  final List<Offset?> newPoints;
  StartAnimationEvent(this.newPoints);
}

class Mnemosyne {
  final DeltaTime delta = DeltaTime.instance;
  final bool hasDrawn;
  final bool startAnimation;
  final List<Offset?> painterData;
  final bool animationReady;

  Mnemosyne({
    this.hasDrawn = false,
    this.startAnimation = false,
    List<Offset?>? painterData,
    this.animationReady = false,
  }) : painterData = painterData ?? [];

  Mnemosyne drawing({bool? hasDrawn}) {
    return Mnemosyne(
      hasDrawn: hasDrawn ?? this.hasDrawn,
      startAnimation: startAnimation,
      painterData: painterData,
    );
  }

  Mnemosyne setAnimationData({
    bool? startAnimation,
    List<Offset?>? painterData,
  }) {
    return Mnemosyne(
      hasDrawn: hasDrawn,
      startAnimation: startAnimation ?? this.startAnimation,
      painterData: painterData ?? this.painterData,
    );
  }

  Mnemosyne animate() {
    return Mnemosyne(
      hasDrawn: hasDrawn,
      startAnimation: startAnimation,
      painterData: painterData,
      animationReady: true,
    );
  }

  void outPut() {
    //print('Δt: ${delta.deltaTime.inMicroseconds} μs');
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

    on<StartAnimationEvent>((event, emit) async {
      emit(
        state.setAnimationData(
          startAnimation: true,
          painterData: event.newPoints,
        ),
      );
      await Future.delayed(const Duration(seconds: 1, milliseconds: 200));
      emit(state.animate());
    });
  }

  void _tick(Duration timestamp) {
    add(OutputEvent());
    SchedulerBinding.instance.scheduleFrame();
  }
}
