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

    final buffer = StringBuffer()
      ..writeln("extension on ${visitor.className}{")
      ..writeln("  Future<void> deInit() async {");

    for (final element in visitor.printData.keys) {
      final String data = visitor.printData[element]!;
      if (data == visitor.className && annotation) {
        continue;
      }

      buffer.writeln("    getIt.unregister<$data>();");
    }

    buffer
      ..writeln("  }")
      ..writeln("}");

    return buffer.toString();
  }
}
