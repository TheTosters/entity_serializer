import 'field.dart';

class Entity {
  final String name;
  final bool copyWith;
  final bool generateEntity;
  final List<String> dependencies = [];
  final List<Field> fields = [];
  final List<String> serializers = [];
  final List<String> apiProxies;

  Entity(
      {required this.name,
      required this.copyWith,
      required this.generateEntity,
      required this.apiProxies});
}
