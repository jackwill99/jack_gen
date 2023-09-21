import "package:analyzer/dart/element/element.dart";
import "package:analyzer/dart/element/visitor.dart";

class ChildVisitor extends SimpleElementVisitor {
  late List<ParameterElement> parameters;

  @override
  void visitConstructorElement(ConstructorElement element) {
    parameters = element.parameters;
    return super.visitConstructorElement(element);
  }
}
