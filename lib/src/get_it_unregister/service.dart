import "package:analyzer/dart/element/element.dart";
import "package:jack_gen/annotation/getit_unregister_annotate.dart";
import "package:jack_gen/src/get_it_unregister/generator.dart";
import "package:jack_gen/src/get_it_unregister/visitor.dart";

class GetItUnregisterService {
  String _getItRegister(
    String type, {
    required bool lazy,
  }) {
    if (lazy) {
      return "getIt.registerLazySingleton(() => $type);";
    } else {
      return "getIt.registerSingleton($type);";
    }
  }

  String _generateParameters(List<ParameterElement> params) {
    return params
        .map(
          (e) => e.isPositional
              ? "getIt.call<${e.type.toString()}>()"
              : "${e.name} : getIt.call<${e.type.toString()}>()",
        )
        .join(",");
  }

  String? _writeNestedBuffers(
    WriteBuffer buffers,
    GetItKeyAnnotate value,
    List<String>? dependType,
  ) {
    value.declared = true;
    String? staticVariableString;
    final variable = "${value.variableName}IsRegister";

    print(
      "$dependType and ${value.parameters.map((e) => e.toString()).toList()}",
    );
    print(_generateParameters(value.parameters));

    if (value.isRegistered) {
      staticVariableString = "static bool? $variable;";

      buffers.$1.addAll([
        "      $variable = getIt.isRegistered<${value.dataType}>();",
        "      if (!$variable!) {",
        "        ${_getItRegister("${value.dataType}()", lazy: value.lazy)}",
        "      }",
        "",
      ]);

      buffers.$2.addAll([
        "      if ($variable != null && !$variable!) {",
        "        getIt.unregister<${value.dataType}>();",
        "        $variable = null;",
        "      }",
        "",
      ]);
    } else if (value.isRegisteredAndAssign) {
      staticVariableString = "static bool? $variable;";

      buffers.$1.addAll([
        "      $variable = getIt.isRegistered<${value.dataType}>();",
        "      if (!$variable!) {",
        "        ${value.variableName} = ${value.dataType}(${dependType != null ? _generateParameters(value.parameters) : ""});",
        "        ${_getItRegister(value.variableName, lazy: value.lazy)}",
        "      }",
        "",
      ]);

      buffers.$2.addAll([
        "      if ($variable != null && !$variable!) {",
        "        getIt.unregister<${value.dataType}>();",
        "        $variable = null;",
        "      }",
        "",
      ]);
    } else {
      buffers.$1.addAll([
        "      ${value.variableName} = ${value.dataType}(${dependType != null ? _generateParameters(value.parameters) : ""});",
        "      ${_getItRegister(value.variableName, lazy: value.lazy)}",
        "",
      ]);

      buffers.$2.add("    getIt.unregister<${value.dataType}>();");
    }

    return staticVariableString;
  }

  String _generateNestedKey(
    GetItKeyAnnotate value,
    List<GetItKeyAnnotate> unReg,
    WriteBuffer buffers,
    List<String> staticRegisterList,
  ) {
    if (value.dependencyIndex.isEmpty && !value.declared) {
      final staticVariable = _writeNestedBuffers(buffers, value, null);
      if (staticVariable != null) {
        staticRegisterList.add(staticVariable);
      }
      return value.dataType;
    }

    if (!value.declared) {
      final type = <String>[];
      for (final j in value.dependencyIndex) {
        try {
          final tempType = _generateNestedKey(
            unReg.firstWhere((element) => element.index == j),
            unReg,
            buffers,
            staticRegisterList,
          );
          type.add(tempType);
        } catch (e) {
          throw "Dependency index hasn't own index! Careful bro, Fuck up 😅";
        }
      }

      final staticVariable = _writeNestedBuffers(buffers, value, type);

      if (staticVariable != null) {
        staticRegisterList.add(staticVariable);
      }
    }

    return value.dataType;
  }

  StringBuffer generateCode(
    Visitor<GetItUnregister> visitor, {
    required bool annotation,
  }) {
    final initBuffers = <String>[];
    final deInitBuffers = <String>[];

    for (final element in visitor.readyData.keys) {
      final String data = visitor.readyData[element]!;
      if (data == visitor.className && annotation) {
        continue;
      }

      initBuffers.addAll(
        [
          "      $element = $data();",
          "      getIt.registerLazySingleton(() => $data());",
          "",
        ],
      );

      deInitBuffers.add("    getIt.unregister<$data>();");
    }

    // nested List key generate
    final unRegisteredIndex = visitor.nestedData;
    final staticRegisterList = <String>[];
    for (final i in unRegisteredIndex) {
      if (i.declared) {
        continue;
      }
      _generateNestedKey(
        i,
        unRegisteredIndex,
        (initBuffers, deInitBuffers),
        staticRegisterList,
      );
    }

    // Initialize buffers
    final buffer = StringBuffer()
      ..writeln("extension on ${visitor.className} {")
      ..writeln(
        "  static bool isRegistered = false;",
      );

    for (final i in staticRegisterList) {
      buffer.writeln("  $i");
    }

    buffer
      ..writeln("\n")
      ..writeln("  void init() {")
      ..writeln("    if (!isRegistered) {")
      ..writeln("      isRegistered = true;")
      ..writeln("\n");

    for (final buf in initBuffers) {
      buffer.writeln(buf);
    }

    buffer
      ..writeln("    }")
      ..writeln("  }")
      ..writeln("\n")

      // De-Initialize buffers
      ..writeln("  void deInit() {")
      ..writeln("    isRegistered = false;")
      ..writeln("\n");

    for (final buf in deInitBuffers) {
      buffer.writeln(buf);
    }

    buffer
      ..writeln("  }")
      ..writeln("}");

    return buffer;
  }
}
