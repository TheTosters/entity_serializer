import 'package:entity_serializer/src/writer/api_proxy_writer.dart';

import '../model/entity.dart';
import '../model/field.dart';
import 'import_writer.dart';

class EntityWriter {
  final Entity entity;

  EntityWriter(this.entity);

  void collectExternalImports(ImportWriter collector) {
    if (entity.copyWith) {
      collector
          .addImport("package:copy_with_extension/copy_with_extension.dart");
    }
  }

  void collectModelImports(
    ImportWriter collector,
    String Function(String name) createEntityFilePath,
  ) {
    for (var dep in entity.dependencies) {
      collector.addImport(createEntityFilePath(dep));
    }
  }

  void collectAutoGenImports(
    ImportWriter collector,
    String Function(String name) createEntityFilePath,
  ) {
    if (entity.copyWith) {
      final path =
          createEntityFilePath(entity.name).replaceFirst(".dart", ".g.dart");
      collector.addPart(path);
    }
  }

  void writeBody(
      {required StringBuffer buffer, required ApiProxyWriter proxiesWriter}) {
    if (entity.copyWith) {
      buffer.writeln("@CopyWith()");
    }
    final mixinSection = entity.mixins.isNotEmpty ? "with ${entity.mixins.join(', ')}" : "";
    buffer.writeln('class ${entity.name} $mixinSection {');
    for (var f in entity.fields) {
      _writeField(f, buffer);
    }
    buffer.writeln();
    _writeConstructor(entity, buffer);
    buffer.writeln();
    for (final proxyAlias in entity.apiProxies) {
      proxiesWriter.writeProxyMethods(
          entity: entity, buffer: buffer, proxyAlias: proxyAlias);
    }
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
      buffer.writeln(
          "  ${fStr}Map<${f.keyType}, ${f.valueType}>$optStr ${f.name};");
    } else {
      //plain field
      buffer.writeln("  $fStr${f.type}$optStr ${f.name};");
    }
  }

  void _writeConstructor(Entity entity, StringBuffer buffer) {
    buffer.writeln("  ${entity.name}({");
    for (final f in entity.fields) {
      if (f.isOptional) {
        buffer.writeln("    this.${f.name},");
      } else {
        buffer.writeln("    required this.${f.name},");
      }
    }
    buffer.writeln("  });");
  }
}
