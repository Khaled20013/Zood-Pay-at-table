import 'package:json_annotation/json_annotation.dart';

part 'localized_name_model.g.dart';

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

/// Reads ids / references that may arrive as a number or a string.
String jsonString(Object? value) => value?.toString() ?? '';

String? jsonStringOrNull(Object? value) => value?.toString();

/// `{ "name": "Olaya", "name_localized": "العليا" }`
@JsonSerializable(fieldRename: FieldRename.snake)
class LocalizedNameModel {
  const LocalizedNameModel({required this.name, this.nameLocalized});

  factory LocalizedNameModel.fromJson(Map<String, dynamic> json) =>
      _$LocalizedNameModelFromJson(json);

  @JsonKey(defaultValue: '')
  final String name;
  final String? nameLocalized;

  String resolve(String languageCode) =>
      localizedText(name, nameLocalized, languageCode);

  Map<String, dynamic> toJson() => _$LocalizedNameModelToJson(this);
}
