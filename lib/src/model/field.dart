class Field {
  final String name;
  final String type;
  final bool isOptional;
  final bool isFinal;

  //those fields have meaning only for maps and lists
  final String? valueType; //map + list
  final String? keyType; //map only
  //map + list, if true no extra code to serialize custom classes/collection in collection
  //plain should be used if types of values are: int, double, bool, String
  final bool isPlain;

  //map + list, if empty all known entities are expected to be present in collection otherwise
  //only those specified here are processed (reduce code for serializers)
  final List<String> expectEntities;

  String? comment;

  static const Set<String> innerDartTypes = {
    "int",
    "bool",
    "double",
    "String",
    "Map",
    "List"
  };

  Field(
      {required this.name,
      required this.type,
      required this.isOptional,
      required this.isFinal})
      : valueType = null,
        keyType = null,
        isPlain = true,
        expectEntities = [];

  Field.map(
      {required this.name,
      required this.isOptional,
      required this.keyType,
      required this.valueType,
      required this.isFinal,
      this.isPlain = true,
      this.expectEntities = const []})
      : type = "Map",
        assert(keyType != null),
        assert(valueType != null);

  Field.list(
      {required this.name,
      required this.isOptional,
      required this.valueType,
      required this.isFinal,
      this.isPlain = true,
      this.expectEntities = const []})
      : type = "List",
        keyType = null,
        assert(valueType != null);

  bool get isCustomType => !innerDartTypes.contains(type);

  bool get isValueCustomType =>
      (!isValueTypeDynamic) && (!innerDartTypes.contains(valueType!));

  bool get isValueTypeDynamic => valueType == 'dynamic';

  bool get isList => type == "List";

  bool get isMap => type == "Map";

  bool get isCollection => isList || isMap;
}
