import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
//import 'dart:math' as math;
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
    on<UpdateInputData>((event, emit) {});
    on<UpdateActivations>((event, emit) {});
  }
}
