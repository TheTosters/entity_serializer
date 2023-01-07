import 'specialization.dart';

class Serializer {
  final String name;
  final Map<String, Specialization> _specializations = {};

  Serializer({required this.name});

  void addSpecialization(String type, Specialization spec) =>
      _specializations[type] = spec;

  bool hasSpecialization(String type) => _specializations.containsKey(type);

  String handleSerialization(String type, String variable) =>
      _specializations[type]!.processSerialization(variable);

  String handleDeserialization(String type, String variable) =>
      _specializations[type]!.processDeserialization(variable);

  void collectImports(Set<String> imports) {
    for (final spec in _specializations.values) {
      final path = spec.getImportPath;
      if (path != null) {
        imports.add("import '$path';");
      }
    }
  }
}
