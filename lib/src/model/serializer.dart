import 'field.dart';
import 'specialization.dart';

class Serializer {
  final String name;
  final Map<String, Specialization> _specializations = {};

  Serializer({required this.name});

  void addSpecialization(String type, Specialization spec) => _specializations[type] = spec;

  bool hasSpecialization(Field field) =>
      _specializations.containsKey(_getFieldType(field));

  String handleSerialization(Field field, String variable) =>
      _specializations[_getFieldType(field)]!.processSerialization(variable);

  String handleDeserialization(Field field, String variable) =>
      _specializations[_getFieldType(field)]!.processDeserialization(variable);

  String _getFieldType(Field field) => "${field.type}${field.isOptional ? "?" : ""}";

  void collectImports(Set<String> imports) {
    for (final spec in _specializations.values) {
      final path = spec.getImportPath;
      if (path != null) {
        imports.add("import '$path';");
      }
    }
  }
}
