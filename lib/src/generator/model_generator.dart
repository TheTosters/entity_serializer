import 'package:entity_serializer/src/common/xml_helper.dart';

import 'entity_generator.dart';
import 'import_generator.dart';
import 'package:xml/xml.dart';

import '../model/entity.dart';
import '../model/import.dart';
import '../model/serializer.dart';
import 'serializer_generator.dart';

class Model {
  final List<Serializer> serializers = [];
  final List<Entity> entities = [];
  final List<Import> imports = [];

  bool get isNotEmpty => serializers.isNotEmpty || entities.isNotEmpty;
}

class ModelGenerator {
  ModelGenerator({
    required XmlDocument from,
    required Model model,
    required String Function(String filename) readFileFunc,
  }) {
    final rootName = from.rootElement.name.toString().toLowerCase();
    if (rootName == "spec") {
      _handleSpecRoot(from, model);
    } else if (rootName == "composition") {
      _handleCompositionRoot(from, model, readFileFunc);
    }
  }

  ModelGenerator.partial({required XmlDocument from, required Model model}) {
    final rootName = from.rootElement.name.toString().toLowerCase();
    if (rootName == "serializers") {
      _handleSerializersRoot(from, model);
    } else if (rootName == "entities") {
      _handleEntitiesRoot(from, model);
    } else {
      throw Exception(
          "Unsupported root: '${from.rootElement.name.toString()}'");
    }
  }

  void _handleCompositionRoot(
    XmlDocument from,
    Model model,
    String Function(String filename) readFileFunc,
  ) {
    for (final node in from.rootElement.childElements) {
      final name = node.name.toString().toLowerCase();
      if (name == "include") {
        final partXmlStr = readFileFunc(reqAttrValue(node, "file"));
        final document = XmlDocument.parse(partXmlStr);
        ModelGenerator.partial(from: document, model: model);
      }
    }
  }

  void _handleSerializersRoot(XmlDocument from, Model model) {
    final List<Serializer> serializerTemplates = [];
    for (final node in from.rootElement.childElements) {
      final name = node.name.toString().toLowerCase();
      if (name == "serializer") {
        model.serializers.add(SerializerGenerator.parseNode(node));
      } else if (name == "serializertemplate") {
        serializerTemplates.add(SerializerGenerator.parseNode(node));
      } else {
        throw Exception("Unknown node with name: '${node.name.toString()}'");
      }
    }
    //propagate templates across serializers
    for (var serializer in model.serializers) {
      serializer.inherit(serializerTemplates);
    }
  }

  void _handleEntitiesRoot(XmlDocument from, Model model) {
    for (final node in from.rootElement.childElements) {
      final name = node.name.toString().toLowerCase();
      if (name == "class") {
        model.entities.add(EntityGenerator.parseNode(node));
      } else if (name == "import") {
        model.imports.add(ImportGenerator.parseNode(node));
      } else {
        throw Exception("Unknown node with name: '${node.name.toString()}'");
      }
    }
  }

  void _handleSpecRoot(XmlDocument from, Model model) {
    final List<Serializer> serializerTemplates = [];
    for (final node in from.rootElement.childElements) {
      final name = node.name.toString().toLowerCase();
      if (name == "class") {
        model.entities.add(EntityGenerator.parseNode(node));
      } else if (name == "serializer") {
        model.serializers.add(SerializerGenerator.parseNode(node));
      } else if (name == "serializertemplate") {
        serializerTemplates.add(SerializerGenerator.parseNode(node));
      } else if (name == "import") {
        model.imports.add(ImportGenerator.parseNode(node));
      } else {
        throw Exception("Unknown node with name: '${node.name.toString()}'");
      }
    }
    //propagate templates across serializers
    for (var serializer in model.serializers) {
      serializer.inherit(serializerTemplates);
    }
  }
}
