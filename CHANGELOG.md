## 0.0.5

- allow to use field of type dynamic in entities

## 0.0.4

- Feature: compose single model from multiple xml files
- Improvement: Better handling of int and double in deserialization

## 0.0.3

- Bugfix: optional values generation fix
- Feature: Serialization field alias per serializer specialization

## 0.0.2

- Improvement: import generation
- Feature: Introduce serializerTemplate as a common part for many serializers
- Bugfix: support nullable types
- Improvement: serializer node documentation in readme
- Feature: select which serializers are used per entity (attribute serializers on class node)
- Feature: skip entity class creation on demand, only serialization generation (attribute generateEntity="false" on class node)
- Feature: custom imports defined on xml level (import node)
- Feature: type now can be given in xml node name, no need to use field node
- Feature: add comment to generated field (attribute comment on field node)
- Improvement: more helper functions (duration)

## 0.0.1

- Initial version.
