import 'dart:convert';

import 'src/model/composition_test.dart';
import 'src/model/date_test.dart';
import 'src/model/list_test.dart';
import 'src/model/map_test.dart';

void checkListGen() {
  print("####### checkListGen\n");
  MyList myList = MyList(integers: [
    1,
    2,
    3
  ], strings: [
    "a",
    "b"
  ], customType: [
    MyTypeInList(val: 6),
    MyTypeInList(val: 3)
  ], dynamicType: [
    1,
    2.4,
    "a",
    MyTypeInList(val: 6),
    MyOtherInList(str: "str")
  ], expDynamicType: [
    MyTypeInList(val: 36),
    MyOtherInList(str: "str33")
  ]);
  JsonEncoder encoder = JsonEncoder.withIndent('  ');
  String prettyprint = encoder.convert(myList.toSer1());
  print(prettyprint);

  Map<String, dynamic> dec = jsonDecode(prettyprint);
  final result = dec.toMyListUsingSer1();
  print(result);
  print("\n\n");
}

void checkCompositeGen() {
  print("####### checkCompositeGen\n");
  Book book = Book(
    author: Author(name: "name", surname: "surname"),
    meta: Meta(
      country: Country(code: "code", extra: "extra"),
    ),
    pages: 10,
    superMeta: SuperMeta(version: 3),
  );
  JsonEncoder encoder = JsonEncoder.withIndent('  ');
  final maps = book.toSer1();
  String prettyprint = encoder.convert(maps);
  print(prettyprint);

  Map<String, dynamic> dec = jsonDecode(prettyprint);
  final result = dec.toBookUsingSer1();
  print(result);
  print("\n\n");
}

void checkMapGen() {
  print("####### checkMapGen\n");
  MyMap map = MyMap(
    integers: {"a": 1, "b": 2, "c": 3},
    strings: {"a": "1", "b": "2", "c": "3"},
    customType: {"a": MyType(val: 6), "b": MyType(val: 3)},
    dynamicType: {
      "a": 1,
      "b": 2.4,
      "c": "str",
      "d": MyType(val: 6),
      "e": MyOther(str: "str")
    },
    expDynamicType: {"a": MyType(val: 36), "b": MyOther(str: "str33")},
  );

  JsonEncoder encoder = JsonEncoder.withIndent('  ');
  final maps = map.toSer1();
  String prettyprint = encoder.convert(maps);
  print(prettyprint);

  Map<String, dynamic> dec = jsonDecode(prettyprint);
  final result = dec.toMyMapUsingSer1();
  print(result);
  print("\n\n");
}

void checkDateGen() {
  print("####### checkDateGen\n");
  TestEntity entity = TestEntity(date: DateTime(1999, 1, 2, 12, 30, 55));
  JsonEncoder encoder = JsonEncoder.withIndent('  ');
  final maps = entity.toIsoDate();
  String prettyprint = encoder.convert(maps);
  print(prettyprint);

  Map<String, dynamic> dec = jsonDecode(prettyprint);
  final result = dec.toTestEntityUsingIsoDate();
  print(result.date);
  print("\n\n");
}

void main() {
  checkListGen();
  checkCompositeGen();
  checkMapGen();
  checkDateGen();
}
