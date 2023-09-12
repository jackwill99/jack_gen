import "package:build/build.dart";
import "package:jack_gen/src/get_it_unregister/generator.dart";
import "package:source_gen/source_gen.dart";

Builder generateUnregister(BuilderOptions options) =>
    SharedPartBuilder([GetItUnregisterGenerator()], "getIt_unregister");
