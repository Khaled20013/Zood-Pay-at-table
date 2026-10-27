import 'path_selector_base.dart';

/// Picks the text to show: in Arabic `*_localized` when it is not empty,
/// otherwise the default text.
String localizedText(String text, String? localized, String languageCode) {
  if (languageCode == 'ar' &&
      localized != null &&
      localized.trim().isNotEmpty) {
    return localized;
  }
  return text;
}

/// Resolves `{ "name": "Olaya", "name_localized": "العليا" }` at [path].
String? localizedNameAt(
  Map<String, dynamic>? json,
  String path,
  String languageCode,
) {
  final node = json?.select<Map<String, dynamic>>(path);
  if (node == null) return null;
  return localizedText(
    jsonString(node['name']),
    jsonStringOrNull(node['name_localized']),
    languageCode,
  );
}

/// Reads ids / references that may arrive as a number or a string.
String jsonString(Object? value) => value?.toString() ?? '';

String? jsonStringOrNull(Object? value) => value?.toString();

double jsonDouble(Object? value, {double fallback = 0}) => switch (value) {
  num() => value.toDouble(),
  String() => double.tryParse(value) ?? fallback,
  _ => fallback,
};

int jsonInt(Object? value, {int fallback = 0}) => switch (value) {
  int() => value,
  num() => value.toInt(),
  String() => int.tryParse(value) ?? fallback,
  _ => fallback,
};

List<String> jsonStringList(Object? value) => value is List
    ? [for (final item in value) jsonString(item)]
    : const <String>[];

/// The list at [path] as JSON objects, skipping anything else.
List<Map<String, dynamic>> jsonObjects(Map<String, dynamic>? json, String path) {
  final list = json?.select<List<dynamic>>(path) ?? const [];
  return [for (final item in list) if (item is Map<String, dynamic>) item];
}
