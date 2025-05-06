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
  const StartAnimationEvent(this.newPoints);
}

class ResetEvent extends MnemosyneEvent {
  const ResetEvent();
}

// model with copyWith
class Mnemosyne {
  final List<Offset?> painterData;
  final DeltaTime delta = DeltaTime.instance;
  final bool hasDrawn;
  final bool startAnimation;
  final bool animationReady;
  final bool beginSequence;
  final double sequenceTime;
  final bool showUIEnd;

  Mnemosyne({
    List<Offset?>? painterData,
    this.hasDrawn = false,
    this.startAnimation = false,
    this.animationReady = false,
    this.beginSequence = false,
    this.sequenceTime = 0.0,
    this.showUIEnd = false,
  }) : painterData = painterData ?? const [];

  Mnemosyne copyWith({
    List<Offset?>? painterData,
    bool? hasDrawn,
    bool? startAnimation,
    bool? animationReady,
    bool? beginSequence,
    double? sequenceTime,
    bool? showUIEnd,
  }) {
    return Mnemosyne(
      painterData: painterData ?? this.painterData,
      hasDrawn: hasDrawn ?? this.hasDrawn,
      startAnimation: startAnimation ?? this.startAnimation,
      animationReady: animationReady ?? this.animationReady,
      beginSequence: beginSequence ?? this.beginSequence,
      sequenceTime: sequenceTime ?? this.sequenceTime,
      showUIEnd: showUIEnd ?? this.showUIEnd,
    );
  }

  void output() {
    // print('Δt: ${delta.deltaTime.inMicroseconds} μs');
  }
}

class MnemosyneRootStream extends Bloc<MnemosyneEvent, Mnemosyne> {
  MnemosyneRootStream() : super(Mnemosyne()) {
    WidgetsFlutterBinding.ensureInitialized();
    SchedulerBinding.instance.addPersistentFrameCallback(_tick);
    SchedulerBinding.instance.scheduleFrame();

    on<OutputEvent>((_, __) => state.output());

    on<DrawEvent>((_, emit) => emit(state.copyWith(hasDrawn: true)));

    on<UndoDrawEvent>((_, emit) => emit(state.copyWith(hasDrawn: false)));

    on<StartAnimationEvent>((event, emit) async {
      emit(
        state.copyWith(
          startAnimation: true,
          painterData: event.newPoints,
          animationReady: false,
          beginSequence: false,
          showUIEnd: false,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 1200));
      emit(state.copyWith(animationReady: true));
      await Future.delayed(const Duration(milliseconds: 3000));
      emit(state.copyWith(beginSequence: true, sequenceTime: 0.0));
      double time = 0.0;
      while (time < 2.0) {
        await Future.delayed(const Duration(milliseconds: 16));
        final dt = DeltaTime.instance.deltaTime.inMilliseconds / 1000.0;
        time += dt;
        emit(state.copyWith(sequenceTime: time.clamp(0.0, 2.0)));
      }
      emit(state.copyWith(showUIEnd: true));
    });

    on<ResetEvent>((_, emit) => emit(Mnemosyne()));
  }

  void _tick(Duration timestamp) {
    add(OutputEvent());
    SchedulerBinding.instance.scheduleFrame();
  }
}
