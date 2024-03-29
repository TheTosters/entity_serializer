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
    buffer.writeln("extension ${serializer.name}SerializerMapExt on Map<String, dynamic> {");
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

  void _writeEntityBuilder({required StringBuffer buffer, required Entity entity}) {
    buffer.writeln("  ${entity.name} to${entity.name}Using${serializer.name}() {");
    buffer.writeln("    return ${entity.name}(");
    for (var f in entity.fields) {
      final fieldName = serializer.nameFor(f);
      final optPart = f.isOptional ? "this['$fieldName'] == null ? null : " : "";
      if (f.isList) {
        if (f.isPlain) {
          buffer.writeln(
              "      ${f.name}: ${optPart}List<${f.valueType}>.from(this['$fieldName'] as List) , /*DART TYPES LIST*/");
        } else if (f.isValueCustomType) {
          buffer.writeln(
              "      ${f.name}: $optPart(this['$fieldName'] as List<dynamic>) /*CUSTOM TYPE LIST*/");
          buffer.writeln(
              "        .map((e) => (e as Map<String, dynamic>).to${f.valueType}Using${serializer.name}())");
          buffer.writeln("        .toList(),");
        } else {
          final processor = findProcessorFor(f)!;
          buffer.writeln(
              "      ${f.name}: $optPart(this['$fieldName'] as List<dynamic>).from${processor.name}(), /*DYNAMIC LIST*/");
        }
      } else if (f.isMap) {
        if (f.isPlain) {
          final postProcess = f.keyType == "int" ? ".map((k,v) => MapEntry(int.parse(k), v))" : "";
          buffer.writeln(
              "      ${f.name}: ${optPart}Map<${f.keyType}, ${f.valueType}>.from((this['$fieldName'] as Map)$postProcess) , /*DART TYPES MAP*/");
        } else if (f.isValueCustomType) {
          final key = f.keyType == "int" ? "int.parse(k)" : "k";
          buffer
              .writeln("      ${f.name}: $optPart(this['$fieldName'] as Map) /*CUSTOM TYPE MAP*/");
          final processedValue = serializer.hasValueSpecialization(f)
              ? serializer.handleValueDeserialization(f, "v")
              : "(v as Map<String, dynamic>).to${f.valueType}Using${serializer.name}()";
          buffer.writeln("        .map((k,v) => MapEntry($key, $processedValue)),");
        } else {
          final processor = findProcessorFor(f)!;
          buffer.writeln(
              "      ${f.name}: $optPart(this['$fieldName'] as Map<String, dynamic>).from${processor.name}(), /*DYNAMIC LIST*/");
        }
      } else {
        if (serializer.hasSpecialization(f)) {
          final processed = serializer.handleDeserialization(f, "this['$fieldName']");
          buffer.writeln("      ${f.name}: $optPart$processed, /*SPECIALIZATION*/");
        } else if (f.isCustomType) {
          if (f.type == "dynamic") {
            final processor = findProcessorFor(f)!;
            buffer.writeln(
                "      ${f.name}: ${optPart}dynamicProxyFrom${processor.name}(this['$fieldName']), /*DYNAMIC*/");
          } else {
            final method = "to_${f.type}_using_${serializer.name}".camelCase;
            buffer.writeln(
                "      ${f.name}: $optPart(this['$fieldName'] as Map<String, dynamic>).$method(), /*ENTITY*/");
          }
        } else {
          if (f.type.toLowerCase() == "int") {
            buffer.writeln(
                "      ${f.name}: $optPart(this['$fieldName'] as num).toInt(), /*DART INT TYPE*/");
          } else if (f.type.toLowerCase() == "double") {
            buffer.writeln(
                "      ${f.name}: $optPart(this['$fieldName'] as num).toDouble(), /*DART DOUBLE TYPE*/");
          } else {
            buffer.writeln(
                "      ${f.name}: $optPart(this['$fieldName'] as ${f.type}), /*DART TYPE*/");
          }
        }
      }
    }
    buffer.writeln("    );");
    buffer.writeln("  }");
  }

  void _writeProcessor({required StringBuffer buffer, required ValuesProcessor processor}) {
    if (!processor.usedOnMap) {
      return;
    }
    buffer.writeln("  Map<String, dynamic> to${processor.name}() => map((k,v) {");
    buffer.write("    ");
    int count = processor.types.length;
    for (final type in processor.types) {
      buffer.write("if (v is $type) {v = v.to${serializer.name}(decorate: true);}");
      count--;
      if (count > 0) {
        buffer.write("\n    else ");
      }
    }
    buffer.writeln("\n    return MapEntry(k, v);");
    buffer.writeln("  });\n");
  }

  void _writeBuilder({required StringBuffer buffer, required ValuesProcessor processor}) {
    if (!processor.usedOnMap) {
      return;
    }
    buffer.writeln("  Map<String, dynamic> from${processor.name}() => map((k,v) {");
    buffer.writeln("    if (v is Map) {");
    buffer.writeln("      final className = v['_c'];");
    buffer.writeln("      if (className == null) {return MapEntry(k,v);}");
    int count = processor.types.length;
    buffer.write("      ");
    for (final type in processor.types) {
      buffer.writeln("if (className == '$type') {");
      buffer.write("        v = (v as Map<String, dynamic>).to${type}Using${serializer.name}();");
      count--;
      if (count > 0) {
        buffer.write("\n      } else ");
      }
    }
    buffer.writeln("\n      }\n    }\n    return MapEntry(k,v);");
    buffer.writeln("  });\n");
  }
}
