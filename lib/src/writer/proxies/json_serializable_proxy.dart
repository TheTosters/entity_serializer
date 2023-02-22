import 'package:entity_serializer/src/model/api_proxy_info.dart';
import 'package:entity_serializer/src/model/entity.dart';
import 'package:entity_serializer/src/writer/proxies/api_proxy_dedicated_writer.dart';

class JsonSerializableProxy extends ApiProxyDedicatedWriter {
  const JsonSerializableProxy();

  @override
  void writeProxyMethods({
    required Entity entity,
    required StringBuffer buffer,
    required ApiProxyInfo proxy,
  }) {
    buffer.writeln(
        "  //proxy: json_serializable using '${proxy.serializerName}' serializer");
    buffer.writeln(
        "  factory ${entity.name}.fromJson(Map<String, dynamic> json) {");
    buffer.writeln(
        "    return json.to${entity.name}Using${proxy.serializerName}();");
    buffer.writeln("  }");
    buffer.writeln();
    buffer.writeln(
        "  Map<String, dynamic> toJson() => to${proxy.serializerName}();");
  }
}
