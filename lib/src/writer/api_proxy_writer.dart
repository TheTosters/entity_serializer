import 'package:entity_serializer/src/model/api_proxy_info.dart';
import 'package:entity_serializer/src/model/entity.dart';
import 'package:entity_serializer/src/writer/proxies/api_proxy_dedicated_writer.dart';
import 'package:entity_serializer/src/writer/proxies/json_serializable_proxy.dart';

const Map<String, ApiProxyDedicatedWriter> proxies = {
  "json_serializable": JsonSerializableProxy(),
};

class ApiProxyWriter {
  final Map<String, ApiProxyInfo> definedProxies;

  ApiProxyWriter(List<ApiProxyInfo> proxies)
      : definedProxies = {for (var e in proxies) e.alias: e};

  void writeProxyMethods({
    required Entity entity,
    required StringBuffer buffer,
    required String proxyAlias,
  }) {
    final proxyData = definedProxies[proxyAlias];
    if (proxyData == null) {
      throw Exception(
          "Can't write API proxy, unknown proxy definition with alias: $proxyAlias");
    }
    final writer = proxies[proxyData.proxyType];
    if (writer == null) {
      throw Exception(
          "Can't write API proxy, unknown proxy type with alias: $proxyAlias");
    }
    writer.writeProxyMethods(entity: entity, buffer: buffer, proxy: proxyData);
    buffer.writeln();
  }
}
