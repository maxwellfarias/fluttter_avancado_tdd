import 'dart:math';

import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/next_event_player.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/types/json.dart';

int anyInt([int max = 999999]) => Random().nextInt(max);
String anyString() => anyInt().toString();
bool anyBool() => Random().nextBool();
DateTime anyDate() => DateTime.fromMillisecondsSinceEpoch(Random().nextInt(anyInt()));
String anyIsoDate() => anyDate().toIso8601String();
Json anyJson() => {anyString(): anyString()};
JsonArr anyJsonArr() => List.generate(anyInt(5), (_) => anyJson());
NextEventPlayer anyNextEventPlayer() => NextEventPlayer(id: anyString(), name: anyString(), isConfirmed: anyBool());
List<NextEventPlayer> anyNextEventPlayerList() => List.generate(anyInt(5), (_) => anyNextEventPlayer());
