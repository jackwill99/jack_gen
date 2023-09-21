// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// GetItUnregisterGenerator
// **************************************************************************

extension on Profile {
  static bool isRegistered = false;
  static bool? noKeyIsRegister;

  void init() {
    if (!isRegistered) {
      isRegistered = true;

      noKeyIsRegister = getIt.isRegistered<TestP>();
      if (!noKeyIsRegister!) {
        getIt.registerSingleton(TestP());
      }

      test = TestMalNaw(getIt.call<TestP>());
      getIt.registerLazySingleton(() => test);

      test2 = TestMal(getIt.call<TestMalNaw>(), t: getIt.call<TestP>());
      getIt.registerLazySingleton(() => test2);
    }
  }

  void deInit() {
    isRegistered = false;

    if (noKeyIsRegister != null && !noKeyIsRegister!) {
      getIt.unregister<TestP>();
      noKeyIsRegister = null;
    }

    getIt.unregister<TestMalNaw>();
    getIt.unregister<TestMal>();
  }
}
