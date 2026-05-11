import 'dart:io';

/// Returns platform context properties from the `dart:io` runtime.
Map<String, dynamic> resolvePlatformContext() {
  return <String, dynamic>{
    'platform': Platform.operatingSystem,
    'platform_version': Platform.operatingSystemVersion,
  };
}
