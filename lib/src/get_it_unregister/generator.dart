import "package:analyzer/dart/element/element.dart";
import "package:build/src/builder/build_step.dart";
import "package:jack_gen/annotation/getit_unregister_annotate.dart";
import "package:jack_gen/src/get_it_unregister/visitor.dart";
import "package:source_gen/source_gen.dart";

class GetItUnregisterGenerator extends GeneratorForAnnotation<GetItUnregister> {
  bool getAnnotationFields(Element element) {
    return TypeChecker.fromRuntime(GetItUnregister)
        .annotationsOf(element)
        .first
        .getField("isSingleton")!
        .toBoolValue()!;
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
          "  $element = $data();",
          "  getIt.registerLazySingleton(() => $data());",
        ],
      );

      deInitBuffers.add("  getIt.unregister<$data>();");
    }

    // Initialize buffers
    final buffer = StringBuffer()
      ..writeln("extension on ${visitor.className} {")
      ..writeln("  void init() {");

    for (final buf in initBuffers) {
      buffer.writeln(buf);
    }

    buffer
      ..writeln("  }")
      ..writeln("\n");

    print("");

    // De-Initialize buffers
    buffer.writeln("  void deInit() {");

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
