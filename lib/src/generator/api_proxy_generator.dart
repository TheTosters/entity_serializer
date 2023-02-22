import 'package:entity_serializer/src/common/xml_helper.dart';
import 'package:entity_serializer/src/model/api_proxy_info.dart';
import 'package:xml/xml.dart';

class ApiProxyGenerator {
  static ApiProxyInfo parseNode(XmlElement node) {
    return ApiProxyInfo(
      serializerName: reqAttrValue(node, "serializer"),
      alias: reqAttrValue(node, "name"),
      proxyType: reqAttrValue(node, "type"),
    );
  }
}
