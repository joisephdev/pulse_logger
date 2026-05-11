/// Redacts sensitive values from structured event metadata.
///
/// Example:
/// ```dart
/// final sanitizer = DataSanitizer(additionalSensitiveKeys: ['session_cookie']);
/// final safe = sanitizer.sanitize({'token': 'secret'});
/// ```
class DataSanitizer {
  /// Creates a sanitizer that merges built-in keys with user-provided keys.
  DataSanitizer({
    Iterable<String> additionalSensitiveKeys = const <String>[],
    this.redactKeysBySubstring = true,
  }) : _sensitiveKeys = <String>{
          for (final key in defaultSensitiveKeys) key.toLowerCase(),
          for (final key in additionalSensitiveKeys) key.toLowerCase(),
        };

  /// Built-in sensitive keys redacted from event properties.
  static const List<String> defaultSensitiveKeys = <String>[
    'token',
    'access_token',
    'refresh_token',
    'authorization',
    'password',
    'secret',
    'webhook',
    'credential',
    'card_number',
    'cvv',
    'api_key',
    'private_key',
  ];

  /// Marker used when a value has been redacted.
  static const String redactedValue = '[REDACTED]';

  /// Whether keys containing sensitive fragments should be redacted.
  final bool redactKeysBySubstring;

  final Set<String> _sensitiveKeys;

  /// Returns a sanitized copy of [properties] without mutating the input map.
  Map<String, dynamic> sanitize(Map<String, dynamic> properties) {
    return <String, dynamic>{
      for (final entry in properties.entries)
        entry.key: _sanitizeValue(entry.key, entry.value),
    };
  }

  dynamic _sanitizeValue(String key, dynamic value) {
    if (_isSensitiveKey(key)) {
      return redactedValue;
    }

    if (value is Map<String, dynamic>) {
      return sanitize(value);
    }

    if (value is Map) {
      return <String, dynamic>{
        for (final entry in value.entries)
          entry.key.toString():
              _sanitizeValue(entry.key.toString(), entry.value),
      };
    }

    if (value is List) {
      return value.map<dynamic>((dynamic item) {
        if (item is Map<String, dynamic>) {
          return sanitize(item);
        }
        if (item is Map) {
          return <String, dynamic>{
            for (final entry in item.entries)
              entry.key.toString():
                  _sanitizeValue(entry.key.toString(), entry.value),
          };
        }
        return item;
      }).toList(growable: false);
    }

    return value;
  }

  bool _isSensitiveKey(String key) {
    final normalizedKey = key.toLowerCase();
    if (_sensitiveKeys.contains(normalizedKey)) {
      return true;
    }
    return redactKeysBySubstring && _sensitiveKeys.any(normalizedKey.contains);
  }
}
