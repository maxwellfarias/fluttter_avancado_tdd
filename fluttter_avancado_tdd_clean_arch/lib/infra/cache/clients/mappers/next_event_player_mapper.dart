import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/next_event_player.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/types/json.dart';

import 'mapper.dart';

final class NextEventPlayerMapper extends Mapper<NextEventPlayer> {
  @override
  NextEventPlayer toObject(dynamic json) => NextEventPlayer(
        id: json['id'],
        name: json['name'],
        isConfirmed: json['isConfirmed'],
        position: json['position'],
        photo: json['photo'],
        confirmationDate: json['confirmationDate'],
      );

      Json toJson(NextEventPlayer player) => {
        'id': player.id,
        'name': player.name,
        'isConfirmed': player.isConfirmed,
        'position': player.position,
        'photo': player.photo,
        'confirmationDate': player.confirmationDate
      };

      JsonArr toJsonArr(List<NextEventPlayer> players) => players.map(toJson).toList();

}