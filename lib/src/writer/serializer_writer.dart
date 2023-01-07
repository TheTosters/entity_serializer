import 'package:recase/recase.dart';

import '../model/entity.dart';
import '../model/field.dart';
import '../model/serializer.dart';
import '../values_processor.dart';
import 'entity_extension_writer.dart';
import 'list_extension_writer.dart';
import 'map_extension_writer.dart';

class SerializerWriter {
  final Serializer serializer;
  final List<Entity> entities;
  final List<ValuesProcessor> processors = [];

  SerializerWriter(this.serializer, List<Entity> entities)
      : entities = entities
            .where((e) => e.serializers.isEmpty || e.serializers.contains(serializer.name))
            .toList();

  void writeImports(StringBuffer buffer, String Function(String name) createEntityFilePath) {
    for (final ent in entities) {
      final path = createEntityFilePath(ent.name);
      buffer.writeln("import '$path';");
    }
    Set<String> imports = {};
    serializer.collectImports(imports);
    for (final import in imports) {
      buffer.writeln(import);
    }
    buffer.writeln();
  }

  void writeBody(StringBuffer buffer) {
    for (final ent in entities) {
      _addProcessorsIfNeeded(ent);
      final writer = EntityExtensionWriter(
        entity: ent,
        serializer: serializer,
        findProcessorFor: _findProcessorFor,
      );
      writer.write(buffer);
    }

    //dump processors for maps and lists
    final mapExtWriter = MapExtensionWriter(
      entities: entities,
      serializer: serializer,
      processors: processors,
      findProcessorFor: _findProcessorFor,
    );
    mapExtWriter.write(buffer);

    if (processors.any((element) => element.usedOnList)) {
      final writer = ListExtensionWriter(serializer: serializer, processors: processors);
      writer.write(buffer);
    }
  }

  void _addProcessorsIfNeeded(Entity ent) {
    for (final f in ent.fields) {
      if (f.isPlain || f.isValueCustomType) {
        //No processor needed for this case
        continue;
      }
      if (_findProcessorFor(f, exact: true) != null) {
        //we already have matching processor
        continue;
      }
      String name = "${serializer.name}_processor_${processors.length}";
      processors.add(ValuesProcessor(name: name.pascalCase, field: f, entities: entities));
    }
  }

  ValuesProcessor? _findProcessorFor(Field f, {bool exact = false}) {
    final matches = processors.where((e) => e.match(f, exact)).toList();
    ValuesProcessor? result;
    if (matches.length == 1) {
      result = matches[0];
    } else if (matches.length > 1) {
      //possible matches are:
      //1) specialized processor which match exactly types
      //2) consumeAll processor
      //if we have both matches, prefer specialized
      assert(matches.length <= 2);
      result = matches[0].consumesAll ? matches[1] : matches[0];
    }
    return result;
  }
}
