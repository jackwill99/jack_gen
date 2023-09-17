import 'package:jack_gen/annotation/getit_unregister_annotate.dart';

part 'main.g.dart';

@GetItUnregister(isSingleton: true)
class Profile {
  factory Profile() {
    return _instance;
  }

  Profile._();

  static final Profile _instance = Profile._();

  late TestMal noKey;

  @GetItKey(index: 0)
  late TestMalNaw test;

  @GetItKey(index: 1)
  late TestMalNaw test2;
}

class TestMal {}

class TestMalNaw {}
