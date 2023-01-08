String dateTimeToIsoStr(DateTime date) => date.toIso8601String();

String? optDateTimeToIsoStr(DateTime? date) => date?.toIso8601String();

DateTime dateTimeFromIsoStr(String data) => DateTime.parse(data);

DateTime? optDateTimeFromIsoStr(String? data) =>
    data != null ? DateTime.parse(data) : null;

int dateTimeToEpoc(DateTime date) => date.millisecondsSinceEpoch;

int? optDateTimeToEpoc(DateTime? date) => date?.millisecondsSinceEpoch;

DateTime dateTimeFromEpoc(int epocMillis) =>
    DateTime.fromMillisecondsSinceEpoch(epocMillis);

DateTime? optDateTimeFromEpoc(int? epocMillis) =>
    epocMillis != null ? DateTime.fromMillisecondsSinceEpoch(epocMillis) : null;

Duration durationFromIntSec(int inValue) => Duration(seconds: inValue);

Duration? optDurationFromIntSec(int? inValue) =>
    inValue != null ? Duration(seconds: inValue) : null;

int durationToIntSec(Duration inValue) => inValue.inSeconds;

int? optDurationToIntSec(Duration? inValue) => inValue?.inSeconds;

bool asBool(String? val) {
  return val == "true" || val == "1";
}

List<String> asSplitList(String? val) {
  return val != null ? val.split(",").map((e) => e.trim()).toList() : [];
}
