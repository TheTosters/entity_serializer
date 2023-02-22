class ApiProxyInfo {
  ///Alias is used in xml class attribute apiProxy.
  final String alias;

  ///Corresponds to specialized [ApiProxyDedicatedWriter] refer to source [ApiProxyWriter] map
  ///of proxies.
  final String proxyType;

  ///Which serializer should be used in this proxy.
  final String serializerName;

  ApiProxyInfo(
      {required this.alias,
      required this.proxyType,
      required this.serializerName});
}
