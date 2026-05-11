import 'slack_http_client_stub.dart'
    if (dart.library.io) 'slack_http_client_io.dart';

/// Platform-specific HTTP client used by the Slack transport.
typedef SlackHttpClient = PlatformSlackHttpClient;
