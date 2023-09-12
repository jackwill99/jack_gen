import "package:analyzer/dart/element/element.dart";
import "package:analyzer/dart/element/visitor.dart";

class Visitor<T> extends SimpleElementVisitor {
  String className = "";
  Map<String, String> printData = {};

  @override
  void visitConstructorElement(ConstructorElement element) {
    className = element.type.returnType.toString().replaceAll("*", "");
    super.visitConstructorElement(element);
  }

  @override
  void visitFieldElement(FieldElement element) {
    final elementType = element.type.toString();

    printData[element.name] = elementType.replaceAll("*", "");
  }
}
