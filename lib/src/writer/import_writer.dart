import 'package:collection/collection.dart';

class ImportWriter {
  Set<String> imports = {};
  Set<String> parts = {};

  void addImport(String import) {
    imports.add(import);
  }

  void addImports(Iterable<String> imports) {
    this.imports.addAll(imports);
  }

  void writeImports(StringBuffer buffer) {
    final withPkg = imports.where((e) => e.startsWith("package:")).sorted();
    final withoutPkg = imports.where((e) => !e.startsWith("package:")).sorted();
    for (final i in withPkg) {
      buffer.writeln("import '$i';");
    }
    if (withPkg.isNotEmpty) {
      buffer.writeln();
    }
    for (final i in withoutPkg) {
      buffer.writeln("import '$i';");
    }
    if (withoutPkg.isNotEmpty) {
      buffer.writeln();
    }
    if (parts.isNotEmpty) {
      for (final i in parts) {
        buffer.writeln("part '$i';");
      }
      buffer.writeln();
    }
  }

  void addPart(String path) {
    parts.add(path);
  }
}
