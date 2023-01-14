import 'package:recase/recase.dart';

import '../model/entity.dart';
import '../model/field.dart';
import '../model/serializer.dart';
import '../values_processor.dart';

class EntityExtensionWriter {
  final Entity entity;
  final Serializer serializer;
  final ValuesProcessor? Function(Field field) findProcessorFor;

  EntityExtensionWriter({
    required this.entity,
    required this.serializer,
    required this.findProcessorFor,
  });

  void write(StringBuffer buffer) {
    final extName = "${serializer.name}Ext${entity.name.pascalCase}";
    buffer.writeln("extension $extName on ${entity.name} {");
    _writeSerializer(buffer);
    buffer.writeln("}\n");
  }

  String _fieldAccess(Field field) => field.isOptional ? "${field.name}?" : field.name;

  void _writeSerializer(StringBuffer buffer) {
    buffer.writeln("  Map<String, dynamic> to${serializer.name}({bool decorate=false}) {");
    buffer.writeln("    return {");
    buffer.writeln("      if (decorate) '_c': '${entity.name}', ");
    //process for collections serialization
    Map<String, String> collection = {};
    for (var f in entity.fields) {
      if (f.isCollection) {
        if (f.isPlain) {
          //this collection will handle only int, double, bool, String
          //nothing is needed to be done
          collection[f.name] = "${f.name} /*PLAIN*/";
        } else {
          if (f.isValueTypeDynamic) {
            //this collection contain dynamic values, we will process values using specialized
            //extension of map/list
            final processor = findProcessorFor(f)!;
            collection[f.name] = "${_fieldAccess(f)}.to${processor.name}() /*DYNAMIC*/";
            if (f.isList) {
              processor.usedOnList = true;
            } else {
              processor.usedOnMap = true;
            }
          } else {
            //This is collection, which all values are of one specific type, and it's not dynamic
            if (f.isValueCustomType) {
              //We will have one of Entity defined types, map those types using extension method
              if (f.isList) {
                collection[f.name] =
                    "${_fieldAccess(f)}.map((v) => v.to${serializer.name}()).toList() /*EXPECTED*/";
              } else if (f.isMap) {
                collection[f.name] =
                    "${_fieldAccess(f)}.map((k, v) => MapEntry(k, v.to${serializer.name}())) /*EXPECTED*/";
              } else {
                throw Exception("Internal error");
              }
            } else {
              //this collection uses one of Dart base types
              collection[f.name] = "${f.name} /*DART SINGLE TYPE*/";
            }
          }
        }
      }
    }

    for (var f in entity.fields) {
      final fieldName = serializer.nameFor(f);
      if (f.isCollection) {
        buffer.writeln("      '$fieldName': ${collection[f.name]},");
      } else {
        if (serializer.hasSpecialization(f)) {
          final processed = serializer.handleSerialization(f, f.name);
          buffer.writeln("      '$fieldName': $processed, /*SPECIALIZATION*/");
        } else if (f.isCustomType) {
          if (f.isOptional) {
            buffer.writeln("      if (${f.name} != null)");
            buffer.writeln("        '$fieldName': ${f.name}!.to${serializer.name}(), /*ENTITY*/");
          } else {
            buffer.writeln("      '$fieldName': ${f.name}.to${serializer.name}(), /*ENTITY*/");
          }
        } else {
          buffer.writeln("      '$fieldName': ${f.name}, /*DART TYPE*/");
        }
      }
    }
    buffer.writeln("    };");
    buffer.writeln("  }");
  }
}
