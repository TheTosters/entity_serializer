import 'dart:async';
import 'dart:io';

import 'package:build/build.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:xml/xml.dart';

import '../../entity_serializer.dart';

Builder entitySerializerBuilder(BuilderOptions options) =>
    EntitySerializerBuilder(options);

class EntitySerializerBuilder implements Builder {
  final BuilderOptions options;

  EntitySerializerBuilder(this.options);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    _dumpConfig();
    final outPath = buildStep.allowedOutputs.first.path;
    final inPath = dirname(buildStep.inputId.path);
    final wrapper = GeneratorWrapper(
        await buildStep.readAsString(buildStep.inputId), inPath, outPath);

    final output = AssetId(buildStep.inputId.package, outPath);
    final resultAsStr = wrapper.process();
    if (resultAsStr.isNotEmpty) {
      return buildStep.writeAsString(output, resultAsStr);
    }
  }

  String get _getInputFolder => options.config["input_folder"] ?? "data_model";

  String get _getInputExt => options.config["input_files_extension"] ?? "xml";

  String get _getOutputFolder =>
      options.config["output_folder"] ?? "lib/src/model";

  @override
  Map<String, List<String>> get buildExtensions => {
        '$_getInputFolder/{{}}.$_getInputExt': ['$_getOutputFolder/{{}}.dart']
      };

  void _dumpConfig() {
    log.log(Level.FINE, "EntitySerializerBuilder CONFIG:");
    log.log(Level.FINE, "  input_folder: $_getInputFolder");
    log.log(Level.FINE, "  input_files_extension: $_getInputExt");
    log.log(Level.FINE, "  output_folder: $_getOutputFolder");
    log.log(Level.FINE, "  buildExtensions: $buildExtensions");
  }
}

class GeneratorWrapper {
  final String xmlString;
  final String inPath;
  final String outPath;
  String? _resultString;

  GeneratorWrapper(this.xmlString, this.inPath, this.outPath);

  String _readFile(String filename) {
    final filePath = join(inPath, filename);
    return File(filePath).readAsStringSync();
  }

  String process() {
    final document = XmlDocument.parse(xmlString);
    Model model = Model();
    ModelGenerator(from: document, model: model, readFileFunc: _readFile);
    if (model.isNotEmpty) {
      final outputGenerator = OutputGenerator.forBuilder(
        models: model,
        outputConsumer: _consume,
        outputPath: outPath,
      );
      outputGenerator.generateOutput();
    }
    return _resultString ?? "";
  }

  void _consume(String data) {
    _resultString = data;
  }
}
