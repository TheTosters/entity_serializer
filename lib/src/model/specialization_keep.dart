import 'specialization.dart';

class SpecializationKeep extends Specialization {
  //No processing is expected, just return this same variable which we get here
  @override
  String processDeserialization(String data) => data;

  //No processing is expected, just return this same variable which we get here
  @override
  String processSerialization(String data) => data;

  @override
  String? get getImportPath => null;
}
