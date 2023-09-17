class GetItUnregister {
  const GetItUnregister({this.isSingleton = true});

  final bool isSingleton;
}

class GetItKey {
  const GetItKey({
    required this.index,
    this.dependencyIndex = const [],
    this.isRegistered = false,
    this.isRegisteredAndAssign = false,
  });

  final int index;
  final List<int> dependencyIndex;
  final bool isRegistered;
  final bool isRegisteredAndAssign;
}

class GetItKeyAnnotate extends GetItKey {
  GetItKeyAnnotate({
    required super.index,
    required super.dependencyIndex,
    required super.isRegistered,
    required super.isRegisteredAndAssign,
    required this.variableName,
    required this.dataType,
  });

  final String variableName;
  final String dataType;
}
