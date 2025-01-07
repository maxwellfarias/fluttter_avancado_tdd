import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/next_event.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/api/mappers/mapper.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/api/mappers/next_event_player_mapper.dart';

final class NextEventMapper extends Mapper<NextEvent> {
  @override
  NextEvent toObject(dynamic json) => NextEvent(
        groupName: json['groupName'],
        date: DateTime.parse(json['date']),
        //Ao fazer o map, é preciso especificar o tipo de dado que será retornado, no caso, NextEventPlayer
        players: NextEventPlayerMapper().toList(json['players']),
      );
}
