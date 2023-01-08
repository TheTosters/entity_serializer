import 'package:recase/recase.dart';

import '../model/entity.dart';
import '../model/field.dart';
import '../model/serializer.dart';
import '../values_processor.dart';

class MapExtensionWriter {
  final Serializer serializer;
  final List<ValuesProcessor> processors;
  final List<Entity> entities;
  final ValuesProcessor? Function(Field field) findProcessorFor;

  MapExtensionWriter({
    required this.entities,
    required this.serializer,
    required this.processors,
    required this.findProcessorFor,
  });

  void write(StringBuffer buffer) {
    buffer.writeln(
        "extension ${serializer.name}SerializerMapExt on Map<String, dynamic> {");
    for (final processor in processors) {
      _writeProcessor(buffer: buffer, processor: processor);
      buffer.writeln();
      _writeBuilder(buffer: buffer, processor: processor);
    }

    for (final entity in entities) {
      _writeEntityBuilder(buffer: buffer, entity: entity);
      buffer.writeln();
    }

    buffer.writeln("}\n");
  }

  void _writeEntityBuilder(
      {required StringBuffer buffer, required Entity entity}) {
    buffer.writeln(
        "  ${entity.name} to${entity.name}Using${serializer.name}() {");
    buffer.writeln("    return ${entity.name}(");
    for (var f in entity.fields) {
      if (f.isList) {
        if (f.isPlain) {
          buffer.writeln(
              "      ${f.name}: List<${f.valueType}>.from(this['${f.name}'] as List) , /*DART TYPES LIST*/");
        } else if (f.isValueCustomType) {
          buffer.writeln(
              "      ${f.name}: (this['${f.name}'] as List<dynamic>) /*CUSTOM TYPE LIST*/");
          buffer.writeln(
              "        .map((e) => (e as Map<String, dynamic>).to${f.valueType}Using${serializer.name}())");
          buffer.writeln("        .toList(),");
        } else {
          final processor = findProcessorFor(f)!;
          buffer.writeln(
              "      ${f.name}: (this['${f.name}'] as List<dynamic>).from${processor.name}(), /*DYNAMIC LIST*/");
        }
      } else if (f.isMap) {
        if (f.isPlain) {
          buffer.writeln(
              "      ${f.name}: Map<${f.keyType}, ${f.valueType}>.from(this['${f.name}'] as Map) , /*DART TYPES MAP*/");
        } else if (f.isValueCustomType) {
          buffer.writeln(
              "      ${f.name}: (this['${f.name}'] as Map) /*CUSTOM TYPE MAP*/");
          buffer.writeln(
              "        .map((k,v) => MapEntry(k, (v as Map<String, dynamic>).to${f.valueType}Using${serializer.name}())),");
        } else {
          final processor = findProcessorFor(f)!;
          buffer.writeln(
              "      ${f.name}: (this['${f.name}'] as Map<String, dynamic>).from${processor.name}(), /*DYNAMIC LIST*/");
        }
      } else {
        if (serializer.hasSpecialization(f)) {
          final processed =
              serializer.handleDeserialization(f, "this['${f.name}']");
          buffer.writeln("      ${f.name}: $processed, /*SPECIALIZATION*/");
        } else if (f.isCustomType) {
          final method = "to_${f.type}_using_${serializer.name}".camelCase;
          buffer.writeln(
              "      ${f.name}: (this['${f.name}'] as Map<String, dynamic>).$method(), /*ENTITY*/");
        } else {
          buffer.writeln(
              "      ${f.name}: this['${f.name}'] as ${f.type}, /*DART TYPE*/");
        }
      }
    }
    buffer.writeln("    );");
    buffer.writeln("  }");
  }

  void _writeProcessor(
      {required StringBuffer buffer, required ValuesProcessor processor}) {
    if (!processor.usedOnMap) {
      return;
    }
    buffer
        .writeln("  Map<String, dynamic> to${processor.name}() => map((k,v) {");
    buffer.write("    ");
    int count = processor.types.length;
    for (final type in processor.types) {
      buffer.write(
          "if (v is $type) {v = v.to${serializer.name}(decorate: true);}");
      count--;
      if (count > 0) {
        buffer.write("\n    else ");
      }
    }
    buffer.writeln("\n    return MapEntry(k, v);");
    buffer.writeln("  });\n");
  }

  void _writeBuilder(
      {required StringBuffer buffer, required ValuesProcessor processor}) {
    if (!processor.usedOnMap) {
      return;
    }
    buffer.writeln(
        "  Map<String, dynamic> from${processor.name}() => map((k,v) {");
    buffer.writeln("    if (v is Map) {");
    buffer.writeln("      final className = v['_c'];");
    buffer.writeln("      if (className == null) {return MapEntry(k,v);}");
    int count = processor.types.length;
    buffer.write("      ");
    for (final type in processor.types) {
      buffer.writeln("if (className == '$type') {");
      buffer.write(
          "        v = (v as Map<String, dynamic>).to${type}Using${serializer.name}();");
      count--;
      if (count > 0) {
        buffer.write("\n      } else ");
      }
    }
    buffer.writeln("\n      }\n    }\n    return MapEntry(k,v);");
    buffer.writeln("  });\n");
  }
}
