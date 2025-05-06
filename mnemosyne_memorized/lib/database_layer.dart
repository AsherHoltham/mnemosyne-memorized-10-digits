import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import 'dart:convert';

class Model {
  final List<List<List<double>>> modelWeights;
  final List<List<double>> modelBiases;

  Model({required this.modelWeights, required this.modelBiases});

  factory Model.empty() {
    return Model(modelWeights: [], modelBiases: []);
  }

  List<List<double>> predict(List<double> input) {
    var activations = <List<double>>[];
    var a = input;
    activations.add(a);
    for (var layer = 0; layer < modelWeights.length; layer++) {
      final weights = modelWeights[layer];
      final biases = modelBiases[layer];
      final outLen = biases.length;
      final z = List<double>.filled(outLen, 0.0);
      for (var j = 0; j < outLen; j++) {
        var sum = biases[j];
        for (var i = 0; i < a.length; i++) {
          sum += a[i] * weights[i][j];
        }
        z[j] = sum;
      }

      if (layer < modelWeights.length - 1) {
        a = z.map((v) => v > 0 ? v.toDouble() : 0.0).toList();
      } else {
        final maxZ = z.reduce(math.max);
        final expZ = z.map((v) => math.exp(v - maxZ)).toList();
        final sumExp = expZ.reduce((p, c) => p + c);
        a = expZ.map((v) => v / sumExp).toList();
      }
      activations.add(a);
    }
    return activations;
  }

  factory Model.fromJsonMap(Map<String, dynamic> json) {
    final weightKeys =
        json.keys.where((k) => k.endsWith('_weights')).toList()..sort((a, b) {
          final ai = int.parse(a.split('_')[1]);
          final bi = int.parse(b.split('_')[1]);
          return ai.compareTo(bi);
        });
    final biasKeys =
        json.keys.where((k) => k.endsWith('_biases')).toList()..sort((a, b) {
          final ai = int.parse(a.split('_')[1]);
          final bi = int.parse(b.split('_')[1]);
          return ai.compareTo(bi);
        });

    final weights =
        weightKeys.map<List<List<double>>>((key) {
          final rawLayer = json[key] as List;
          return rawLayer.map<List<double>>((row) {
            return (row as List)
                .map<double>((e) => (e as num).toDouble())
                .toList();
          }).toList();
        }).toList();

    final biases =
        biasKeys.map<List<double>>((key) {
          final rawBias = json[key] as List;
          return rawBias.map<double>((e) => (e as num).toDouble()).toList();
        }).toList();

    return Model(modelWeights: weights, modelBiases: biases);
  }
}

class MnemosyneData {
  final List<double> inputs;
  final List<List<double>> latestActivations;
  final Model mnemosyneBrain;
  final int prediction;
  final bool predictionReady;

  const MnemosyneData({
    this.inputs = const [],
    this.latestActivations = const [],
    required this.mnemosyneBrain,
    this.prediction = 0,
    this.predictionReady = false,
  });

  MnemosyneData copyWith({
    List<double>? inputs,
    List<List<double>>? latestActivations,
    Model? mnemosyneBrain,
    int? prediction,
    bool? predictionReady,
  }) {
    return MnemosyneData(
      inputs: inputs ?? this.inputs,
      latestActivations: latestActivations ?? this.latestActivations,
      mnemosyneBrain: mnemosyneBrain ?? this.mnemosyneBrain,
      prediction: prediction ?? this.prediction,
      predictionReady: predictionReady ?? this.predictionReady,
    );
  }
}

abstract class MnemosyneDataEvent {
  const MnemosyneDataEvent();
}

class UpdateInputData extends MnemosyneDataEvent {
  final List<double> newInputs;
  const UpdateInputData(this.newInputs);
}

class UpdateActivations extends MnemosyneDataEvent {
  const UpdateActivations();
}

class InitializeData extends MnemosyneDataEvent {
  const InitializeData();
}

class MnemosyneDataStream extends Bloc<MnemosyneDataEvent, MnemosyneData> {
  MnemosyneDataStream() : super(MnemosyneData(mnemosyneBrain: Model.empty())) {
    on<InitializeData>(onInitialize);
    on<UpdateInputData>(onUpdateInputData);
    on<UpdateActivations>(onUpdateActivations);
    add(const InitializeData());
  }

  Future<void> onInitialize(
    InitializeData event,
    Emitter<MnemosyneData> emit,
  ) async {
    final jsonStr = await rootBundle.loadString('lib/data/mnist_weights.json');
    final brain = Model.fromJsonMap(jsonDecode(jsonStr));
    emit(state.copyWith(mnemosyneBrain: brain));
    add(const UpdateActivations());
  }

  void onUpdateInputData(UpdateInputData event, Emitter<MnemosyneData> emit) {
    emit(state.copyWith(inputs: event.newInputs, predictionReady: false));
  }

  void onUpdateActivations(
    UpdateActivations event,
    Emitter<MnemosyneData> emit,
  ) {
    final normalized = state.inputs.map((px) => 1.0 - (px / 255.0)).toList();
    final acts = state.mnemosyneBrain.predict(normalized);

    int prediction = 0;
    double currMax = 0.0;
    for (int i = 0; i < acts[4].length; i++) {
      if (acts[4][i] > currMax) {
        currMax = acts[4][i];
        prediction = i;
      }
    }
    emit(
      state.copyWith(
        latestActivations: acts,
        prediction: prediction,
        predictionReady: true,
      ),
    );
  }
}
