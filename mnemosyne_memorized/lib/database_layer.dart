import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;

class Model {
  final List<List<double>> modelWeights;
  final List<double> modelBiases;

  Model({List<List<double>>? weights, List<double>? biases})
    : modelWeights = weights ?? [<double>[]],
      modelBiases = biases ?? [];
}

abstract class MnemosyneDataEvent {
  const MnemosyneDataEvent();
}

class UpdateData extends MnemosyneDataEvent {
  const UpdateData();
}

class MnemosyneData {
  final List<List<double>> latestActivations = [];
  final Model mnemosyneBrain = Model();

  Future<String> getTrainedModelData() async {
    final String model = await rootBundle.loadString(
      "lib/data/mnist_weights.json",
    );
    return model;
  }

  Future<List<List<List<double>>>> parseModel() async {}
}

class MnemosyneDataStream extends Bloc<MnemosyneDataEvent, MnemosyneData> {
  MnemosyneDataStream() : super(MnemosyneData()) {
    on<UpdateData>((_, __) => {});
  }
}
