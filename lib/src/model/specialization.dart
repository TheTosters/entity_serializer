abstract class Specialization {
  String? get getImportPath;
  String processSerialization(String data);
  String processDeserialization(String data);
}
