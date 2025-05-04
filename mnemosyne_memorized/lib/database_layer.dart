import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import 'dart:convert';

class Model {
  final List<List<List<double>>> modelWeights;
  final List<List<double>> modelBiases;
  Model({required this.modelWeights, required this.modelBiases});

  factory Model.fromJsonArray(List<dynamic> jsonArray) {
    final layerCount = jsonArray.length ~/ 2;
    final weightJson = jsonArray.sublist(0, layerCount);
    final biasJson = jsonArray.sublist(layerCount);

    final weights =
        weightJson.map<List<List<double>>>((layer) {
          final rows = layer as List;
          return rows.map<List<double>>((r) {
            return (r as List)
                .map<double>((e) => (e as num).toDouble())
                .toList();
          }).toList();
        }).toList();

    final biases =
        biasJson.map<List<double>>((b) {
          return (b as List).map<double>((e) => (e as num).toDouble()).toList();
        }).toList();

    return Model(modelWeights: weights, modelBiases: biases);
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
}

class MnemosyneData {
  final List<double> inputs;
  final List<List<double>> latestActivations;
  late final Model mnemosyneBrain;

  Future<void> getTrainedModelData() async {
    final modelStr = await rootBundle.loadString('assets/mnist_weights.json');
    final modelArray = jsonDecode(modelStr) as List<dynamic>;
    mnemosyneBrain = Model.fromJsonArray(modelArray);
  }

  MnemosyneData({List<double>? inputs, List<List<double>>? latestActivations})
    : inputs = inputs ?? [],
      latestActivations = latestActivations ?? [];
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

class MnemosyneDataStream extends Bloc<MnemosyneDataEvent, MnemosyneData> {
  MnemosyneDataStream() : super(MnemosyneData()) {
    _initialize();
    on<UpdateInputData>(_onUpdateInputData);
    on<UpdateActivations>(_onUpdateActivations);
  }

  Future<void> _initialize() async {
    await state.getTrainedModelData();
    add(const UpdateActivations());
  }

  Future<void> _onUpdateInputData(
    UpdateInputData event,
    Emitter<MnemosyneData> emit,
  ) async {
    final newState = MnemosyneData(
      inputs: event.newInputs,
      latestActivations: state.latestActivations,
    )..mnemosyneBrain = state.mnemosyneBrain;

    emit(newState);
  }

  void _onUpdateActivations(
    UpdateActivations event,
    Emitter<MnemosyneData> emit,
  ) {
    final activations = state.mnemosyneBrain.predict(state.inputs);

    final newState = MnemosyneData(
      inputs: state.inputs,
      latestActivations: activations,
    )..mnemosyneBrain = state.mnemosyneBrain;

    emit(newState);
  }
}
