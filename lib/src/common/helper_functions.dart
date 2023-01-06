
String dateTimeToIsoStr(DateTime date) => date.toIso8601String();

DateTime dateTimeFromIsoStr(String data) => DateTime.parse(data);

int dateTimeToEpoc(DateTime date) => date.millisecondsSinceEpoch;

DateTime dateTimeFromEpoc(int epocMillis) => DateTime.fromMillisecondsSinceEpoch(epocMillis);

bool asBool(String? val) {
  return val == "true" || val == "1";
}

List<String> asSplitList(String? val) {
  return val != null ? val.split(",").map((e) => e.trim()).toList() : [];
}