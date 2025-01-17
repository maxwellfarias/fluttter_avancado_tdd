import 'dart:math';

int anyInt() => Random().nextInt(999999);
String anyString() => anyInt().toString();
bool anyBool() => Random().nextBool();
DateTime anyDate() => DateTime.fromMillisecondsSinceEpoch(Random().nextInt(anyInt()));
String anyIsoDate() => anyDate().toIso8601String();