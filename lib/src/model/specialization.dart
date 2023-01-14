abstract class Specialization {
  Map<String, String> aliases = {};

  String? get getImportPath;
  String processSerialization(String data);
  String processDeserialization(String data);
}
