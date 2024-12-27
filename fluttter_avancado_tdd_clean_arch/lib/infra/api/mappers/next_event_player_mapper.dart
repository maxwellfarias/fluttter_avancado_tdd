
import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/next_event_player.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/api/mappers/mapper.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/types/json.dart';


final class NextEventPlayerMapper extends Mapper<NextEventPlayer>{
   @override
     NextEventPlayer toObject(Json json) => NextEventPlayer(
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
