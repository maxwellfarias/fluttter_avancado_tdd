import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/next_event.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/types/json.dart';

import 'mapper.dart';
import 'next_event_player_mapper.dart';

final class NextEventMapper extends Mapper<NextEvent> {
  @override
  NextEvent toObject(dynamic json) => NextEvent(
        groupName: json['groupName'],
        date: json['date'],
        players: NextEventPlayerMapper().toList(json['players']),
      );

      Json toJson(NextEvent event) => {
        'groupName': event.groupName,
        'date': event.date,
        'players': NextEventPlayerMapper().toJsonArr(event.players)
      };
}