import 'package:entity_serializer/src/generator/entity_generator.dart';
import 'package:xml/xml.dart';

import '../model/entity.dart';
import '../model/serializer.dart';
import 'serializer_generator.dart';

class ModelGenerator {
  final List<Serializer> serializers = [];
  final List<Entity> entities = [];

  ModelGenerator({required XmlDocument from}) {
    for (final node in from.rootElement.childElements) {
      final name = node.name.toString().toLowerCase();
      if (name == "class") {
        entities.add(EntityGenerator.parseNode(node));
      } else if (name == "serializer") {
        serializers.add(SerializerGenerator.parseNode(node));
      }
    }
  }
}
