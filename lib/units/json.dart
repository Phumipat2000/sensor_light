import 'dart:convert';

String getPrettyJSONString(jsonObject) {
  JsonEncoder encoder = const JsonEncoder.withIndent('  ');
  String jsonString = encoder.convert(json.decode(jsonObject));
  return jsonString;
}
