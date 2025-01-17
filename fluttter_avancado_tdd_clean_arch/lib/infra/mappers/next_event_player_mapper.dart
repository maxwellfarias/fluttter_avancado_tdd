import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/next_event_player.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/types/json.dart';

import 'mapper.dart';

final class NextEventPlayerMapper extends ListMapper<NextEventPlayer> {
    //:O parâmetro toDto(dynamic json) precisa obrigatoriamente ser do tipo dynamic, pois quando é feito o 'return jsonDecode(response.body)' no HttpAdapter,
    //o jsonDecode converte todo array (neste caso a propriedade players) em um valor dynamic.
  @override
  NextEventPlayer toDto(dynamic json) => NextEventPlayer(
        id: json['id'],
        name: json['name'],
        isConfirmed: json['isConfirmed'],
        position: json['position'],
        photo: json['photo'],
        confirmationDate: DateTime.tryParse(json['confirmationDate'] ?? ''),
      );

  @override
  Json toJson(NextEventPlayer player) => {
        'id': player.id,
        'name': player.name,
        'isConfirmed': player.isConfirmed,
        'position': player.position,
        'photo': player.photo,
        'confirmationDate': player.confirmationDate?.toIso8601String()
      };
}
