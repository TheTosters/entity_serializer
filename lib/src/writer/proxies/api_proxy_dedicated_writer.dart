import 'package:entity_serializer/src/model/api_proxy_info.dart';
import 'package:entity_serializer/src/model/entity.dart';

abstract class ApiProxyDedicatedWriter {
  const ApiProxyDedicatedWriter();

  void writeProxyMethods({
    required Entity entity,
    required StringBuffer buffer,
    required ApiProxyInfo proxy,
  });
}
