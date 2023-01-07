
import '../model/entity.dart';
import '../model/field.dart';

class EntityWriter {
  final Entity entity;

  EntityWriter(this.entity);

  void writeExternalImports(StringBuffer buffer) {
    Set<String> imports = {};
    collectExternalImports(imports);
    for(final import in imports) {
      buffer.writeln(import);
    }
  }

  void collectExternalImports(Set<String> imports) {
    if (entity.copyWith) {
      imports.add("import 'package:copy_with_extension/copy_with_extension.dart';");
    }
  }

  void writeModelImports(StringBuffer buffer, String Function(String name) createEntityFilePath) {
    for (var dep in entity.dependencies) {
      final path = createEntityFilePath(dep);
      buffer.writeln("import '$path';");
    }
    buffer.writeln();
  }

  void writeAutoGenImports(StringBuffer buffer, String Function(String name) createEntityFilePath) {
    if (entity.copyWith) {
      final path = createEntityFilePath(entity.name).replaceFirst(".dart", ".g.dart");
      buffer.writeln("part '$path';");
      buffer.writeln();
    }
  }

  void writeBody(StringBuffer buffer) {
    if (entity.copyWith) {
      buffer.writeln("@CopyWith()");
    }
    buffer.writeln('class ${entity.name} {');
    for(var f in entity.fields) {
      _writeField(f, buffer);
    }
    buffer.writeln();
    _writeConstructor(entity, buffer);
    buffer.writeln('}\n');
  }

  void _writeField(Field f, StringBuffer buffer) {
    if (f.comment != null) {
      buffer.writeln("  ///${f.comment}");
    }
    final fStr = f.isFinal ? "final " : "";
    final optStr = f.isOptional ? "?" : "";
    if (f.isList) {
      buffer.writeln("  ${fStr}List<${f.valueType}>$optStr ${f.name};");
    } else if (f.isMap) {
      buffer.writeln("  ${fStr}Map<${f.keyType}, ${f.valueType}>$optStr ${f.name};");
    } else {
      //plain field
      buffer.writeln("  $fStr${f.type}$optStr ${f.name};");
    }
  }

  void _writeConstructor(Entity entity, StringBuffer buffer) {
    buffer.writeln("  ${entity.name}({");
    for(final f in entity.fields) {
      if (f.isOptional) {
        buffer.writeln("    this.${f.name},");
      } else {
        buffer.writeln("    required this.${f.name},");
      }
    }
    buffer.writeln("  });");
  }
}