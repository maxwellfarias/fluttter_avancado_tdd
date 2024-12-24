
import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/next_event_player.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/types/json.dart';


class NextEventPlayerMapper {
  static List<NextEventPlayer> toList(JsonArr arr) =>
      arr.map(NextEventPlayerMapper.toObject).toList();

  static NextEventPlayer toObject(Json json) => NextEventPlayer(
      id: json['id'],
      name: json['name'],
      isConfirmed: json['isConfirmed'],
      position: json['position'],
      photo: json['photo'],
      confirmationDate:
          //tryParse retorna null se não conseguir converter a string para DateTime, como é possivel que a data venha nula, foi colocado ?? '' para evitar erro.
          DateTime.tryParse(
        json['confirmationDate'] ?? '',
      ));
}
