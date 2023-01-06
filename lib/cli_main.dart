import 'dart:io';

import 'package:args/args.dart';
import 'package:xml/xml.dart';

import 'src/generator/model_generator.dart';
import 'src/generator/output_generator.dart';

const help = "help";
const splitByFiles = "split-by-files";
const output = "output";
const input = "input";

ArgParser describeArguments() {
  return ArgParser()
    ..addFlag(help, abbr: 'h', negatable: false, hide: true)
    ..addOption(input, abbr: "i", help: "Path to the input xml file")
    ..addOption(output,
        abbr: "o", help: "Path to the output dart file. Prints to console if not specified")
    ..addFlag(
      splitByFiles,
      abbr: 's',
      negatable: false,
      help: "Create a file for each generated models.\n"
          "Files are stored in the provided by $output option folder.",
    );
}

Future<void> main(List<String> arguments) async {
  final argsParser = describeArguments();
  final parsedArgs = argsParser.parse(arguments);

  if (parsedArgs[help] || arguments.isEmpty) {
    print(
      """
A command-line app which is used to generate serializers for entities.
Usage: entgen [arguments]
Options:
${argsParser.usage}""",
    );
    return;
  }

  final String? pathToXml = parsedArgs[input];
  if (pathToXml == null) {
    throw Exception("Path to the XML file must be specified");
  }
  final shouldSplitByFiles = parsedArgs[splitByFiles];
  final String? pathToOutput = parsedArgs[output];
  final xmlFile = File(pathToXml);

  if (!await xmlFile.exists()) {
    print(xmlFile.absolute.path);
    print("Given file $pathToXml doesn't exist");
    exit(1);
  } else {
    final document = XmlDocument.parse(xmlFile.readAsStringSync());

    final modelsGenerator = ModelGenerator(from: document);
    final outputGenerator = OutputGenerator(
      models: modelsGenerator,
      outputPath: pathToOutput,
      splitByFiles: shouldSplitByFiles,
    );
    outputGenerator.generateOutput();
    print("Done!");
  }
}

