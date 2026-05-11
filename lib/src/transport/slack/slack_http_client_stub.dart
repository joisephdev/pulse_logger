/// HTTP client placeholder for runtimes without `dart:io`.
class PlatformSlackHttpClient {
  /// Posts [body] to [url] with [headers].
  Future<({int statusCode, String body})> post(
    Uri url,
    Map<String, String> headers,
    String body,
  ) {
    throw UnsupportedError(
      'The default Slack HTTP client is unavailable on this platform. '
      'Provide the SlackTransport.post override instead.',
    );
  }

  /// Releases resources held by the client.
  void close() {}
}
