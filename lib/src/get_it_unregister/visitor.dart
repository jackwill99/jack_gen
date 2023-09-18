import "package:analyzer/dart/element/element.dart";
import "package:analyzer/dart/element/visitor.dart";
import "package:jack_gen/annotation/getit_unregister_annotate.dart";
import "package:source_gen/source_gen.dart";

class Visitor<T> extends SimpleElementVisitor {
  String className = "";
  Map<String, String> readyData = {};
  List<GetItKeyAnnotate> nestedData = [];

  final uniqueIndex = <int>[];

  @override
  void visitConstructorElement(ConstructorElement element) {
    className = element.type.returnType.toString().replaceAll("*", "");
    super.visitConstructorElement(element);
  }

  @override
  void visitFieldElement(FieldElement element) {
    final attribute =
        TypeChecker.fromRuntime(GetItKey).annotationsOf(element).firstOrNull;
    final elementType = element.type.toString().replaceAll("*", "");

    if (attribute == null) {
      readyData[element.name] = elementType;
    } else {
      final index = attribute.getField("index")!.toIntValue()!;

      if (uniqueIndex.contains(index)) {
        throw "Duplicate Index Key! Fuck up bro 😎";
      } else {
        uniqueIndex.add(index);
      }

      final dependencyIndex =
          attribute.getField("dependencyIndex")!.toListValue()!;
      final isRegistered = attribute.getField("isRegistered")!.toBoolValue()!;
      final isRegisteredAndAssign =
          attribute.getField("isRegisteredAndAssign")!.toBoolValue()!;
      final lazy = attribute.getField("lazy")!.toBoolValue()!;

      final object = GetItKeyAnnotate(
        index: index,
        dependencyIndex: dependencyIndex.map((e) => e.toIntValue()!).toList(),
        isRegistered: isRegistered,
        isRegisteredAndAssign: isRegisteredAndAssign,
        lazy: lazy,
        variableName: element.name,
        dataType: elementType,
      );

      nestedData.add(object);
    }
  }
}
