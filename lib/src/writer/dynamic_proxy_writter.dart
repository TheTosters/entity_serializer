import '../model/serializer.dart';
import '../values_processor.dart';

class DynamicProxyWriter {
  final Serializer serializer;
  final List<ValuesProcessor> processors;

  DynamicProxyWriter({
    required this.serializer,
    required this.processors,
  });

  void write(StringBuffer buffer) {
    for (final processor in processors) {
      _writeProcessor(buffer: buffer, processor: processor);
      buffer.writeln();
      _writeBuilder(buffer: buffer, processor: processor);
    }
  }

  void _writeProcessor(
      {required StringBuffer buffer, required ValuesProcessor processor}) {
    if (!processor.usedOnDynamic) {
      return;
    }
    buffer.writeln("dynamic dynamicProxyTo${processor.name}(dynamic input) {");
    buffer.write("  ");
    int count = processor.types.length;
    for (final type in processor.types) {
      buffer.write(
          "if (input is $type) {return input.to${serializer.name}(decorate: true);}");
      count--;
      if (count > 0) {
        buffer.write("\n  else ");
      }
    }
    buffer.writeln("\n  return input;");
    buffer.writeln("}\n");
  }

  void _writeBuilder(
      {required StringBuffer buffer, required ValuesProcessor processor}) {
    if (!processor.usedOnDynamic) {
      return;
    }
    buffer.writeln("dynamic dynamicProxyFrom${processor.name}(dynamic e) {");
    buffer.writeln("  if (e is Map) {");
    buffer.writeln("    final className = e['_c'];");
    buffer.writeln("    if (className == null) {return e;}");
    int count = processor.types.length;
    buffer.write("    ");
    for (final type in processor.types) {
      buffer.writeln("if (className == '$type') {");
      buffer.write(
          "      e = (e as Map<String, dynamic>).to${type}Using${serializer.name}();");
      count--;
      if (count > 0) {
        buffer.write("\n    } else ");
      }
    }
    buffer.writeln("\n    }\n  }\n  return e;");
    buffer.writeln("}\n");
  }
}
