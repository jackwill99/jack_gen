import "package:analyzer/dart/element/element.dart";
import "package:build/src/builder/build_step.dart";
import "package:jack_gen/annotation/getit_unregister_annotate.dart";
import "package:jack_gen/src/get_it_unregister/service.dart";
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

  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    // Take and get the type annotation of children fields
    final visitor = Visitor<GetItUnregister>();
    element.visitChildren(visitor);

    final annotation = getAnnotationFields(element);

    final service = GetItUnregisterService();

    return service.generateCode(visitor, annotation: annotation).toString();
  }
}
