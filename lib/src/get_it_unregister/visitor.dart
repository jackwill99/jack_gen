import "package:analyzer/dart/element/element.dart";
import "package:analyzer/dart/element/visitor.dart";
import "package:jack_gen/annotation/getit_unregister_annotate.dart";
import "package:jack_gen/src/get_it_unregister/child_visitor.dart";
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
      final childVisitor = ChildVisitor();
      element.type.element?.visitChildren(childVisitor);

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

      if (dependencyIndex.length != childVisitor.parameters.length) {
        throw "Parameters of class constructor and dependencyIndexes are not same 🤷‍";
      }

      final object = GetItKeyAnnotate(
        index: index,
        dependencyIndex: dependencyIndex.map((e) => e.toIntValue()!).toList(),
        isRegistered: isRegistered,
        isRegisteredAndAssign: isRegisteredAndAssign,
        lazy: lazy,
        variableName: element.name,
        dataType: elementType,
        parameters: childVisitor.parameters,
      );

      nestedData.add(object);
    }
  }
}
