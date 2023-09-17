// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// GetItUnregisterGenerator
// **************************************************************************

extension on Profile {
  void init() {
    noKey = TestMal();
    getIt.registerLazySingleton(() => TestMal());
  }

  void deInit() {
    getIt.unregister<TestMal>();
  }
}
