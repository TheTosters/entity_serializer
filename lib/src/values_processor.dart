import 'package:collection/collection.dart';

import 'model/entity.dart';
import 'model/field.dart';

class ValuesProcessor {
  final String name;
  late final bool consumesAll;
  bool usedOnList = false;
  bool usedOnMap = false;
  bool usedOnDynamic = false;
  Set<String> types = {};

  ValuesProcessor(
      {required this.name,
      required Field field,
      required List<Entity> entities}) {
    if (field.expectEntities.isEmpty) {
      //accept all possible known entities
      types.addAll(entities.map((e) => e.name));
      consumesAll = true;
    } else {
      types.addAll(field.expectEntities);
      consumesAll = false;
    }
  }

  bool match(Field f, bool exact) =>
      (consumesAll && !exact) ||
      SetEquality<String>().equals(types, f.expectEntities.toSet());
}
