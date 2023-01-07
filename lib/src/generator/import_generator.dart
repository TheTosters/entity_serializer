import 'package:entity_serializer/src/common/xml_helper.dart';
import 'package:xml/xml.dart';

import '../model/import.dart';

class ImportGenerator {
  static Import parseNode(XmlElement node) {
    return Import(reqAttrValue(node, "package"));
  }
}