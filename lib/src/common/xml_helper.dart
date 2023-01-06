import 'package:collection/collection.dart';
import 'package:xml/xml.dart';

String? attrValue(XmlElement node, String name) =>
    node.attributes.firstWhereOrNull((p0) => p0.name.toString() == name)?.value;

String? optAttrValue(XmlElement node, String name, String defVal) =>
    attrValue(node, name) ?? defVal;

String reqAttrValue(XmlElement node, String name) {
  final attr = node.attributes.firstWhereOrNull((a) => a.name.toString() == name);
  if (attr == null) {
    throw Exception("No required '$name' attribute on node ${node.toXmlString()}");
  }
  return attr.value;
}