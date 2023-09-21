import "package:analyzer/dart/element/element.dart";

class GetItUnregister {
  const GetItUnregister({this.isSingleton = true});

  final bool isSingleton;
}

class GetItKey {
  const GetItKey({
    required this.index,
    this.dependencyIndex = const [],
    this.lazy = true,
    this.isRegistered = false,
    this.isRegisteredAndAssign = false,
  });

  final int index;
  final List<int> dependencyIndex;
  final bool lazy;
  final bool isRegistered;
  final bool isRegisteredAndAssign;
}

class GetItKeyAnnotate extends GetItKey {
  GetItKeyAnnotate({
    required super.index,
    required super.dependencyIndex,
    required super.isRegistered,
    required super.isRegisteredAndAssign,
    required super.lazy,
    required this.parameters,
    required this.variableName,
    required this.dataType,
    this.declared = false,
  });

  bool declared;
  final String variableName;
  final String dataType;
  final List<ParameterElement> parameters;
}
