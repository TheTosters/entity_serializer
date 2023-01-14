import '../writer/import_writer.dart';
import 'field.dart';
import 'specialization.dart';

class Serializer {
  final String name;
  final Map<String, Specialization> _specializations = {};
  final List<String> templates = [];

  Serializer({required this.name});

  void addSpecialization(String type, Specialization spec) => _specializations[type] = spec;

  bool hasSpecialization(Field field) => _specializations.containsKey(_getFieldType(field));

  String handleSerialization(Field field, String variable) =>
      _specializations[_getFieldType(field)]!.processSerialization(variable);

  String handleDeserialization(Field field, String variable) =>
      _specializations[_getFieldType(field)]!.processDeserialization(variable);

  String _getFieldType(Field field) => "${field.type}${field.isOptional ? "?" : ""}";

  void collectImports(ImportWriter collector) {
    for (final spec in _specializations.values) {
      final path = spec.getImportPath;
      if (path != null) {
        collector.addImport(path);
      }
    }
  }

  void inherit(List<Serializer> serializerTemplates) {
    for (final inh in templates) {
      for (final template in serializerTemplates) {
        if (template.name == inh) {
          _inheritFrom(template);
        }
      }
    }
  }

  void _inheritFrom(Serializer template) {
    for (final ent in template._specializations.entries) {
      _specializations.putIfAbsent(ent.key, () => ent.value);
    }
  }

  String nameFor(Field field) {
    final spec = _specializations[_getFieldType(field)];
    String? result = spec?.aliases[field.name];
    result ??= field.name;
    return result;
  }
}
