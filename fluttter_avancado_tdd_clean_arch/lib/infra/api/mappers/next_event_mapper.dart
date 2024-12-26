import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/next_event.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/api/mappers/next_event_player_mapper.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/types/json.dart';

final class NextEventMapper {
  static NextEvent toObject(Json json) => NextEvent(
        groupName: json['groupName'],
        date: DateTime.parse(json['date']),
        //Ao fazer o map, é preciso especificar o tipo de dado que será retornado, no caso, NextEventPlayer
        players: NextEventPlayerMapper.toList(json['players']),
      );
}