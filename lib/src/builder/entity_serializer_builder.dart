import 'dart:async';

import 'package:build/build.dart';
import 'package:xml/xml.dart';

import '../../entity_serializer.dart';

Builder entitySerializerBuilder(BuilderOptions options) =>
    EntitySerializerBuilder(options);

class EntitySerializerBuilder implements Builder {
  final BuilderOptions options;

  EntitySerializerBuilder(this.options);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    final outPath = buildStep.allowedOutputs.first.path;
    final wrapper = GeneratorWrapper(
        await buildStep.readAsString(buildStep.inputId), outPath);

    final output = AssetId(buildStep.inputId.package, outPath);
    return buildStep.writeAsString(output, wrapper.process());
  }

  String get _getInputFolder => options.config["input_folder"] ?? "data_model";

  String get _getInputExt => options.config["input_files_extension"] ?? "xml";

  String get _getOutputFolder =>
      options.config["output_folder"] ?? "lib/src/model";

  @override
  Map<String, List<String>> get buildExtensions => {
        '$_getInputFolder/{{}}.$_getInputExt': ['$_getOutputFolder/{{}}.dart']
      };
}

class GeneratorWrapper {
  final String xmlString;
  final String outPath;
  String? _resultString;

  GeneratorWrapper(this.xmlString, this.outPath);

  String process() {
    final document = XmlDocument.parse(xmlString);
    final modelsGenerator = ModelGenerator(from: document);
    final outputGenerator = OutputGenerator.forBuilder(
      models: modelsGenerator,
      outputConsumer: _consume,
      outputPath: outPath,
    );
    outputGenerator.generateOutput();
    return _resultString!;
  }

  void _consume(String data) {
    _resultString = data;
  }
}
