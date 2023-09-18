import "package:analyzer/dart/element/element.dart";
import "package:build/src/builder/build_step.dart";
import "package:jack_gen/annotation/getit_unregister_annotate.dart";
import "package:jack_gen/src/get_it_unregister/visitor.dart";
import "package:source_gen/source_gen.dart";

typedef WriteBuffer = (List<String>, List<String>);

class GetItUnregisterGenerator extends GeneratorForAnnotation<GetItUnregister> {
  bool getAnnotationFields(Element element) {
    return TypeChecker.fromRuntime(GetItUnregister)
        .annotationsOf(element)
        .first
        .getField("isSingleton")!
        .toBoolValue()!;
  }

  String getItRegister(
    String type, {
    required bool lazy,
  }) {
    if (lazy) {
      return "getIt.registerLazySingleton(() => $type);";
    } else {
      return "getIt.registerSingleton($type);";
    }
  }

  String? writeNestedBuffers(
    WriteBuffer buffers,
    GetItKeyAnnotate value,
    String? dependType,
  ) {
    value.declared = true;
    String? staticVariableString;
    final variable = "${value.variableName}IsRegister";

    if (value.isRegistered) {
      staticVariableString = "static bool? $variable;";

      buffers.$1.addAll([
        "      $variable = getIt.isRegistered<${value.dataType}>();",
        "      if (!$variable!) {",
        "        ${getItRegister("${value.dataType}()", lazy: value.lazy)}",
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
        "        ${value.variableName} = ${value.dataType}(${dependType != null ? "getIt.call<$dependType>()" : ""});",
        "        ${getItRegister(value.variableName, lazy: value.lazy)}",
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
        "      ${value.variableName} = ${value.dataType}(${dependType != null ? "getIt.call<$dependType>()" : ""});",
        "      ${getItRegister(value.variableName, lazy: value.lazy)}",
        "",
      ]);

      buffers.$2.add("    getIt.unregister<${value.dataType}>();");
    }

    return staticVariableString;
  }

  String generateNestedKey(
    GetItKeyAnnotate value,
    List<GetItKeyAnnotate> unReg,
    WriteBuffer buffers,
    List<String> staticRegisterList,
  ) {
    if (value.dependencyIndex.isEmpty && !value.declared) {
      final staticVariable = writeNestedBuffers(buffers, value, null);
      if (staticVariable != null) {
        staticRegisterList.add(staticVariable);
      }
      return value.dataType;
    }

    if (!value.declared) {
      late String type;
      for (final j in value.dependencyIndex) {
        try {
          type = generateNestedKey(
            unReg.firstWhere((element) => element.index == j),
            unReg,
            buffers,
            staticRegisterList,
          );
        } catch (e) {
          throw "Dependency index hasn't own index! Careful bro, Fuck up 😅";
        }
      }

      final staticVariable = writeNestedBuffers(buffers, value, type);

      if (staticVariable != null) {
        staticRegisterList.add(staticVariable);
      }
    }

    return value.dataType;
  }

  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final visitor = Visitor<GetItUnregister>();
    element.visitChildren(visitor);

    final annotation = getAnnotationFields(element);

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
      generateNestedKey(
        i,
        unRegisteredIndex,
        (initBuffers, deInitBuffers),
        staticRegisterList,
      );
    }

    // Initialize buffers
    final buffer = StringBuffer()
      ..writeln("extension on ${visitor.className} {")
      ..writeln("  static bool isRegistered = false;");

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
      ..writeln("\n");

    print("");

    // De-Initialize buffers
    buffer
      ..writeln("  void deInit() {")
      ..writeln("    isRegistered = false;")
      ..writeln("\n");

    for (final buf in deInitBuffers) {
      buffer.writeln(buf);
    }

    buffer
      ..writeln("  }")
      ..writeln("}");

    print(visitor.nestedData);

    return buffer.toString();
  }
}
