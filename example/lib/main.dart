import 'package:get_it/get_it.dart';
import 'package:jack_gen/annotation/getit_unregister_annotate.dart';

part 'main.g.dart';

final getIt = GetIt.instance;

@GetItUnregister(isSingleton: true)
class Profile {
  factory Profile() {
    return _instance;
  }

  Profile._();

  static final Profile _instance = Profile._();

  @GetItKey(index: 1, dependencyIndex: [0])
  late TestMalNaw test;

  @GetItKey(index: 0, isRegistered: true, lazy: false)
  late TestP noKey;

  @GetItKey(index: 2, dependencyIndex: [1])
  late TestMal test2;
}

class TestMal {
  TestMal(this.n);

  final TestMalNaw n;
}

class TestMalNaw {
  TestMalNaw(this.t);

  final TestP t;
}

class TestP {}
