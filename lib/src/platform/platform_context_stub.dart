/// Returns an empty platform context on runtimes without `dart:io`.
Map<String, dynamic> resolvePlatformContext() {
  return const <String, dynamic>{};
}
