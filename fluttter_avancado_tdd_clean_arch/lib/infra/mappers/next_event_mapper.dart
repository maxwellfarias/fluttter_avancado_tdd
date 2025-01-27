import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/next_event.dart';
import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/next_event_player.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/types/json.dart';

import 'mapper.dart';

final class NextEventMapper implements Mapper<NextEvent> {
  final ListMapper<NextEventPlayer> playerMapper;

  const NextEventMapper({required this.playerMapper});

  @override
  NextEvent toDto(Json json) => NextEvent(
        groupName: json['groupName'],
        date: DateTime.parse(json['date']),
        players: playerMapper.toDtoList(json['players']),
      );

  @override
  Json toJson(NextEvent dto) => {
        'groupName': dto.groupName,
        'date': dto.date.toIso8601String(),
        'players': playerMapper.toJsonArr(dto.players)
      };
}


    interface class TMP {
void foo(){}
}

abstract  class AbstractClass {
  void abstractMethod();

  void concreteMethod() {
    print('Concrete method in abstract class');
  }
}

