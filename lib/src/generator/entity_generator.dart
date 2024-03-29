import 'package:recase/recase.dart';
import 'package:xml/xml.dart';

import '../common/helper_functions.dart';
import '../common/xml_helper.dart';
import '../model/entity.dart';
import '../model/field.dart';

class EntityGenerator {
  static Entity parseNode(XmlElement node) {
    final result = Entity(
        name: reqAttrValue(node, "name"),
        copyWith: asBool(optAttrValue(node, "copyWith", "true")),
        generateEntity: asBool(optAttrValue(node, "generateEntity", "true")),
        apiProxies: asSplitList(attrValue(node, "apiProxy")),
        mixins: asSplitList(attrValue(node, "mixin")));
    final serializers = attrValue(node, "serializers");
    if (serializers != null && serializers.trim().isNotEmpty) {
      result.serializers.addAll(asSplitList(serializers));
    }
    for (final child in node.childElements) {
      final field = _parseField(child);
      result.fields.add(field);
      if (field.isCustomType) {
        result.dependencies.add(field.type);
      } else if (field.isCollection && field.isValueCustomType) {
        result.dependencies.add(field.valueType!);
      }
    }
    return result;
  }

  static Field _parseField(XmlElement node) {
    var name = node.name.toString().toLowerCase();
    var isOptional = name.startsWith("optional");
    if (isOptional) {
      name = name.substring("optional".length);
    }
    final isFinal = asBool(optAttrValue(node, "final", "true"));
    late Field result;
    switch (name) {
      case "int":
      case "bool":
      case "double":
        result = Field(
          name: reqAttrValue(node, "name"),
          type: name,
          isOptional: isOptional,
          isFinal: isFinal,
        );
        break;
      case "datetime":
        result = Field(
          name: reqAttrValue(node, "name"),
          type: "DateTime",
          isOptional: isOptional,
          isFinal: isFinal,
        );
        break;
      case "string":
        result = Field(
          name: reqAttrValue(node, "name"),
          type: "String",
          isOptional: isOptional,
          isFinal: isFinal,
        );
        break;
      case "list":
        result = _parseListField(
          name: reqAttrValue(node, "name"),
          optional: isOptional,
          node: node,
          isFinal: isFinal,
        );
        break;
      case "map":
        result = _parseMapField(
          name: reqAttrValue(node, "name"),
          optional: isOptional,
          node: node,
          isFinal: isFinal,
        );
        break;
      case "field":
        {
          final expects = asSplitList(attrValue(node, "expectOnly"));
          var varType = reqAttrValue(node, "type");
          if (varType.endsWith("?")) {
            isOptional = true;
            varType = varType.substring(0, varType.length - 1);
          }
          result = Field(
            name: reqAttrValue(node, "name"),
            isOptional: isOptional,
            type: varType,
            isFinal: isFinal,
            expectEntities: expects,
          );
          break;
        }
      default:
        {
          final xmlName = node.name.toString();
          final rawName =
              isOptional ? xmlName.substring("optional".length) : xmlName;
          var varType = rawName == "dynamic" ? "dynamic" : rawName.pascalCase;
          final expects = asSplitList(attrValue(node, "expectOnly"));
          result = Field(
            name: optAttrValue(node, "name", rawName.camelCase)!,
            isOptional: isOptional,
            type: varType,
            isFinal: isFinal,
            expectEntities: expects,
          );
          break;
        }
    }
    //optional things
    result.comment = attrValue(node, "comment");
    return result;
  }

  static Field _parseListField({
    required String name,
    required bool optional,
    required XmlElement node,
    required bool isFinal,
  }) {
    var isPlain = asBool(optAttrValue(node, "plain", "true"));
    final expects = asSplitList(attrValue(node, "expectOnly"));
    final innerType = reqAttrValue(node, "innerType");
    if (expects.isNotEmpty ||
        innerType == "dynamic" ||
        !Field.innerDartTypes.contains(innerType)) {
      isPlain = false;
    }
    return Field.list(
      name: name,
      isOptional: optional,
      valueType: innerType,
      isPlain: isPlain,
      isFinal: isFinal,
      expectEntities: expects,
    );
  }

  static Field _parseMapField({
    required String name,
    required bool optional,
    required XmlElement node,
    required bool isFinal,
  }) {
    var isPlain = asBool(optAttrValue(node, "plain", "true"));
    final expects = asSplitList(attrValue(node, "expectOnly"));
    final innerType = reqAttrValue(node, "valueType");
    if (expects.isNotEmpty ||
        innerType == "dynamic" ||
        !Field.innerDartTypes.contains(innerType)) {
      isPlain = false;
    }
    return Field.map(
      name: name,
      isOptional: optional,
      valueType: innerType,
      keyType: attrValue(node, "keyType"),
      isPlain: isPlain,
      isFinal: isFinal,
      expectEntities: expects,
    );
  }
}
