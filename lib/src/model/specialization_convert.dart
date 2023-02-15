import 'package:entity_serializer/src/model/specialization.dart';

class SpecializationConvert extends Specialization {
  final String inType;
  final String? importPath;
  final String? serializationFunc;
  final String? deserializationFunc;
  final String outType;

  SpecializationConvert({
    required this.inType,
    this.importPath,
    required this.serializationFunc,
    required this.deserializationFunc,
    String? outType,
  }) : outType = outType ?? 'String';

  @override
  String processSerialization(String data) {
    if (serializationFunc == null) {
      throw Exception(
          "No serialization function is given for specialization but serialization"
          " is requested for type $inType");
    }
    return "${serializationFunc!}($data)";
  }

  @override
  String processDeserialization(String data) {
    if (deserializationFunc == null) {
      throw Exception(
          "No deserialization function is given for specialization but deserialization"
          " is requested for type $inType");
    }
    return "${deserializationFunc!}($data as $outType)";
  }

  @override
  String? get getImportPath => importPath;
}
