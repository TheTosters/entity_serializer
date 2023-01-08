import 'package:entity_serializer/entity_serializer.dart';
import 'package:entity_serializer/src/model/serializer.dart';
import 'package:entity_serializer/src/model/specialization_convert.dart';
import 'package:xml/xml.dart';

import '../common/xml_helper.dart';
import '../model/specialization_keep.dart';

class SerializerGenerator {
  static Serializer parseNode(XmlElement node) {
    final name = reqAttrValue(node, "name");
    final result = Serializer(name: name);
    final inherit = attrValue(node, "inheritFrom");
    if (inherit != null && inherit.trim().isNotEmpty) {
      result.templates.addAll(asSplitList(inherit));
    }

    for (final child in node.childElements) {
      final childNodeName = child.name.toString().toLowerCase();
      switch (childNodeName) {
        case 'specialization':
          _parseSpecializationNode(child, result);
          break;
        case 'keep':
          _parseKeepNode(child, result);
          break;
        default:
          throw Exception(
              "Unknown node '${node.name.toString()}' in serializer '$name'");
      }
    }

    return result;
  }

  static void _parseSpecializationNode(XmlElement node, Serializer serializer) {
    final serFunc = attrValue(node, "serialization");
    final deserFunc = attrValue(node, "deserialization");
    if ((serFunc == null || serFunc.isEmpty) &&
        (deserFunc == null || deserFunc.isEmpty)) {
      throw Exception(
          "Both 'serialization' and 'deserialization' attributes are empty"
          " in node '${node.name}', this make no sense.");
    }
    final importPath = reqAttrValue(node, "import");
    if (importPath.isEmpty) {
      throw Exception("Attribute 'import' is empty in node '${node.name}'");
    }
    final type = reqAttrValue(node, "type");
    serializer.addSpecialization(
        type,
        SpecializationConvert(
            inType: type,
            importPath: importPath,
            serializationFunc: serFunc,
            deserializationFunc: deserFunc,
            outType: attrValue(node, "outType")));
  }

  static void _parseKeepNode(XmlElement node, Serializer serializer) =>
      serializer.addSpecialization(
          reqAttrValue(node, "type"), SpecializationKeep());
}
