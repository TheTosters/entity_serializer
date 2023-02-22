import 'package:entity_serializer/src/common/xml_helper.dart';
import 'package:entity_serializer/src/generator/api_proxy_generator.dart';
import 'package:entity_serializer/src/model/api_proxy_info.dart';

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
  final List<ApiProxyInfo> proxies = [];

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
        final ser = SerializerGenerator.parseNode(node);
        if (model.serializers.any((element) => element.name == ser.name)) {
          throw Exception(
              "Serializer with name '${ser.name} is already defined!");
        }
        model.serializers.add(ser);
      } else if (name == "serializertemplate") {
        final ser = SerializerGenerator.parseNode(node);
        if (serializerTemplates.any((element) => element.name == ser.name)) {
          throw Exception(
              "Serializer template with name '${ser.name} is already defined!");
        }
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
        final cls = EntityGenerator.parseNode(node);
        if (model.entities.any((element) => element.name == cls.name)) {
          throw Exception("Entity with name '${cls.name} is already defined!");
        }
        model.entities.add(cls);
      } else if (name == "import") {
        model.imports.add(ImportGenerator.parseNode(node));
      } else if (name == "proxy") {
        final proxy = ApiProxyGenerator.parseNode(node);
        if (model.proxies.any((element) => element.alias == proxy.alias)) {
          throw Exception(
              "Api proxy with name '${proxy.alias} is already defined!");
        }
        model.proxies.add(proxy);
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
        final cls = EntityGenerator.parseNode(node);
        if (model.entities.any((element) => element.name == cls.name)) {
          throw Exception("Entity with name '${cls.name} is already defined!");
        }
        model.entities.add(cls);
      } else if (name == "serializer") {
        final ser = SerializerGenerator.parseNode(node);
        if (model.serializers.any((element) => element.name == ser.name)) {
          throw Exception(
              "Serializer with name '${ser.name} is already defined!");
        }
        model.serializers.add(ser);
      } else if (name == "serializertemplate") {
        final ser = SerializerGenerator.parseNode(node);
        if (serializerTemplates.any((element) => element.name == ser.name)) {
          throw Exception(
              "Serializer template with name '${ser.name} is already defined!");
        }
        serializerTemplates.add(SerializerGenerator.parseNode(node));
      } else if (name == "import") {
        model.imports.add(ImportGenerator.parseNode(node));
      } else if (name == "proxy") {
        final proxy = ApiProxyGenerator.parseNode(node);
        if (model.proxies.any((element) => element.alias == proxy.alias)) {
          throw Exception(
              "Api proxy with name '${proxy.alias} is already defined!");
        }
        model.proxies.add(proxy);
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
