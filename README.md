# Entity serializer
[![Pub Package](https://img.shields.io/pub/v/entity_serializer.svg)](https://pub.dev/packages/yet_another_layout_builder)
[![GitHub Issues](https://img.shields.io/github/issues/TheTosters/entity_serializer.svg)](https://github.com/TheTosters/entity_serializer/issues)
[![GitHub Forks](https://img.shields.io/github/forks/TheTosters/entity_serializer.svg)](https://github.com/TheTosters/entity_serializer/network)
[![GitHub Stars](https://img.shields.io/github/stars/TheTosters/entity_serializer.svg)](https://github.com/TheTosters/entity_serializer/stargazers)
[![GitHub License](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/TheTosters/entity_serializer/blob/master/LICENSE)

Another package which make process of building data classes and serializers, a little less 
frustrating. Unless you don't have very specific needs you probably want to stick with 
[freezed](https://pub.dev/packages/freezed) or [json_serializable](https://pub.dev/packages/json_serializable)
another great tool which inspired me is [dtogen](https://github.com/qyre-ab/dtogen) check it out
before trying this one.

## What problem this package is solving?

Mostly my frustration :) I run into problem where I got several data classes and then I needed to
create a lot of DTO classes. Several for server-client JSON communication and another DTO to have
MongoDB storage. So when I got for example `Foo` data class I was forced to create `FooJson` and 
`FooDB` plus make some magic to serialize in different way for Json and DB. 
I fast got to moment when I need to create a lot of boilerplate code to keep all together and in the
end my frustration won. This package solves my problem, hope it will be useful to somebody else.

## How it works?

All data classes (POJO style) should be described in simple xml file. In mentioned file is also
definition for one or multiple serializers which can operate on data classes. Then you run builder
or use cli tool to generate `.dart` files which can be included in your project. From this moment
you can perform serialization / deserialization of data classes using dedicated serializers. So this
allows you to have for example `Foo` class and simply serialize it to `Map<String, dynamic>` for
Json and for DB, where in both cases some rules of serialization can be different. There are no 
intermediate DTO classes used. Just extensions for `List<dynamic>` and `Map<String, dynamic>` plus 
extensions for data classes.

## Limitations

At current moment (and probably future) there is no support to embedded collections. So it's not
possible to have List of Maps, nor Maps of Maps, etc. If you need such thing please wrap map in some
extra custom type.
There are probably a lot of other limitations which I'm not aware yet but... This package will be
developed/extended until all my needs are satisfied, but for sure it will not be constant developed
in the way freezed is. Feel free to make feature request or deliver Pull-Requests if you added
something which was useful for you.

## CLI version

Please note existence of `cli_main.dart` file. It allows you to compile and have this tool as a 
stand alone application, not bound to build_runner. All needed information how to use it is 
displayed when you call it with `-h` switch. For most situations you will probably call something
like:
```cli_main -i data_model/list_test.xml -o sources/gen.dart```
or
```cli_main -s -i data_model/list_test.xml -o sources/```

## Xml description

Here is brief description of xml format used to generate everything. Let's go with some examples
and descriptions:
```xml
<?xml version="1.0"?>
<spec>
    <serializer name="Ser1"/>

    <class name="Book">
        <string name="name"/>
    </class>
</spec>
```
This is the most simple xml which has any meaning. We are defining one serializer which will be 
named `Ser1` and one data class named `Book`. As expected `Book` class will have just one `String` 
field named `name`. For class `Book` serialization extensions will be generated.

### Node class

Each data class which need to be generated need to be put into `class` node inside xml. Following
attributes are available for this node:
- name - mandatory, tells what is name of new class, should be PascalCase typed.
- copyWith - optional, default: true. Tells if new created class should have `@CopyWith` annotation

To create fields for newly created class child-nodes described later can be added. Each child-node
support following attributes:
- name - required, tells how field should be named, apply to Dart language naming restrictions
- final - optional, default: true. If set make class field `final`.

example:
```xml
<?xml version="1.0"?>
<spec>
    <class name="Book">
        <string name="name"/>
        <string name="author" final="false"/>
    </class>
</spec>
```
will result in
```dart
@CopyWith()
class Book {
  final String name;
  String author;

  MyType({
    required this.name,
    required this.author,
  });
}
```

Additionally each node name can be prefixed with `Optional` word, this adds `?` optional suffix for
generated field. Example
```xml
<?xml version="1.0"?>
<spec>
    <class name="Book">
        <string name="name"/>
        <optionalString name="descr"/>
    </class>
</spec>
```
will result in
```dart
@CopyWith()
class Book {
  final String name;
  final String? descr;

  MyType({
    required this.name,
    this.descr,
  });
}
```

#### class children: for plain Dart types

Following nodes are reserved for plain Dart types: `int`, `double`, `bool`, `String`
Here is example of usage in xml
```xml
<?xml version="1.0"?>
<spec>
    <class name="Book">
        <string name="str1"/>
        <optionalString name="str2"/>
        <int name="int1"/>
        <optionalInt name="int2"/>
        <double name="dbl1"/>
        <optionalDouble name="dbl2"/>
        <bool name="bool1"/>
        <optionalBool name="bool2"/>
    </class>
</spec>
```

### class children: collection - list

For Dart `List` type specialized node is required, it has all properties described above plus 
mandatory attribute `innerType`, refer to this example:
```xml
<class name="MyList">
    <list name="integers" innerType="int"/>
    <list name="customType" innerType="MyType"/>
    <list name="dynamicType" innerType="dynamic"/>
    <list name="expDynamicType" innerType="dynamic" expectOnly="MyType,MyOther"/>
</class>
```

It's worth noting that `innerType` can point to `dynamic` this will generate extra code to handle
all data types class from this xml. If you want to limit class detection in dynamic list then 
attribute `expectOnly` comes to play. You can specify only those types you want to be handled.

### class children: collection - map

For Dart `Map` type specialized node is required, it has all properties described above plus
two mandatory attributes `keyType` and `valueType`. Behaviour of `valueType` is this same as
`innerType` in List node. Here is simple example:

```xml
<class name="MyMap">
    <map name="integers" keyType="String" valueType="int"/>
    <map name="strings" keyType="String" valueType="String"/>
    <map name="customType" keyType="String" valueType="MyType"/>
    <map name="dynamicType" keyType="String" valueType="dynamic"/>
    <map name="expDynamicType" keyType="String" valueType="dynamic" expectOnly="MyType,MyOther"/>
</class>
```

### class children: field

Most universal child node of class node is `field` which allows you to put variable of any type
into class. It has two mandatory attributes `name` and `type`. And looks like:

```xml
<class name="Book" copyWith="false">
    <field name="author" type="Author"/>
    <field name="meta" type="Meta?"/>
    <optionalField name="extra" type="String"/>
</class>
```

### class children: any name

If you want to use your custom data class as a type for variable in other classes just put it name.
Please look into this small example:
```xml
<spec>
    <class name="Book" copyWith="false">
        <field name="author" type="Author"/>
        <field name="meta" type="Meta"/>
        <Meta name="anotherMeta"/>
        <meta name="andAnotherMeta"/>
    </class>

    <class name="Author" copyWith="false">
        <string name="name"/>
        <string name="surname"/>
    </class>

    <class name="Meta" copyWith="false">
        <String name="country"/>
    </class>
</spec>
```