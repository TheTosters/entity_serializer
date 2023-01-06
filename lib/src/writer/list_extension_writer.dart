
import '../model/serializer.dart';
import '../values_processor.dart';

class ListExtensionWriter {
  final Serializer serializer;
  final List<ValuesProcessor> processors;

  ListExtensionWriter({
    required this.serializer,
    required this.processors,
  });

  void write(StringBuffer buffer) {
    buffer.writeln("extension ${serializer.name}SerializerListExt on List<dynamic> {");
    for (final processor in processors) {
      _writeProcessor(buffer: buffer, processor:processor);
      buffer.writeln();
      _writeBuilder(buffer: buffer, processor:processor);
    }
    buffer.writeln("}\n");
  }

  void _writeProcessor({required StringBuffer buffer, required ValuesProcessor processor}) {
    if (!processor.usedOnList) {
      return;
    }
    buffer.writeln("  List<dynamic> to${processor.name}() => map((e) {");
    buffer.write("    ");
    int count = processor.types.length;
    for (final type in processor.types) {
      buffer.write("if (e is $type) {e = e.to${serializer.name}(decorate: true);}");
      count--;
      if (count > 0) {
        buffer.write("\n    else ");
      }
    }
    buffer.writeln("\n    return e;");
    buffer.writeln("  }).toList();\n");
  }

  void _writeBuilder({required StringBuffer buffer, required ValuesProcessor processor}) {
    if (!processor.usedOnList) {
      return;
    }
    buffer.writeln("  List<dynamic> from${processor.name}() => map((e) {");
    buffer.writeln("    if (e is Map) {");
    buffer.writeln("      final className = e['_c'];");
    buffer.writeln("      if (className == null) {return e;}");
    int count = processor.types.length;
    buffer.write("      ");
    for (final type in processor.types) {
      buffer.writeln("if (className == '$type') {");
      buffer.write("        e = (e as Map<String, dynamic>).to${type}Using${serializer.name}();");
      count--;
      if (count > 0) {
        buffer.write("\n      } else ");
      }
    }
    buffer.writeln("\n      }\n    }\n    return e;");
    buffer.writeln("  }).toList();\n");
  }
}