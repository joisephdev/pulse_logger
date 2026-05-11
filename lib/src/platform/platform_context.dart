import 'platform_context_stub.dart'
    if (dart.library.io) 'platform_context_io.dart';

/// Returns platform context properties when supported by the current runtime.
Map<String, dynamic> platformContext() => resolvePlatformContext();
