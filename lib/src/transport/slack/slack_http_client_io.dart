import 'dart:convert';
import 'dart:io';

/// HTTP client implementation for runtimes that support `dart:io`.
class PlatformSlackHttpClient {
  final HttpClient _client = HttpClient();

  /// Posts [body] to [url] with [headers].
  Future<({int statusCode, String body})> post(
    Uri url,
    Map<String, String> headers,
    String body,
  ) async {
    final request = await _client.postUrl(url);
    headers.forEach(request.headers.set);
    request.write(body);
    final response = await request.close();
    final responseBody = await utf8.decodeStream(response);
    return (statusCode: response.statusCode, body: responseBody);
  }

  /// Closes the owned HTTP client.
  void close() {
    _client.close(force: true);
  }
}
