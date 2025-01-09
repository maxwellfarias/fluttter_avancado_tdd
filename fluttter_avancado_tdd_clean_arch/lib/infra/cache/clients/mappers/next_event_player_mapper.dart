import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/next_event_player.dart';

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
}