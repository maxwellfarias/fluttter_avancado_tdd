import 'package:flutter_test/flutter_test.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/mappers/next_event_player_mapper.dart';

import '../../mocks/fakes.dart';

void main() {
  late NextEventPlayerMapper sut;

  setUp((){
      sut = NextEventPlayerMapper();
    });

  test('should map to dto', () {
    final json = {
      "id": anyString(),
      "name": anyString(),
      "position": anyString(),
      "photo": anyString(),
      "confirmationDate": '2025-01-18T02:00:00.000',
      "isConfirmed": anyBool()
    };
    final dto = sut.toDto(json);
    expect(dto.id, json['id']);
    expect(dto.name, json['name']);
    expect(dto.position, json['position']);
    expect(dto.photo, json['photo']);
    expect(dto.confirmationDate, DateTime(2025, 1, 18, 2, 0));
    expect(dto.isConfirmed, json['isConfirmed']);
  });
}
