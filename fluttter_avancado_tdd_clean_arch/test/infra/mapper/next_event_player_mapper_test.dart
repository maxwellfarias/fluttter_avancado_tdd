import 'package:flutter_test/flutter_test.dart';
import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/next_event_player.dart';
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

  test('should map to dto with empty fields', () {
    final json = {
      "id": anyString(),
      "name": anyString(),
      "isConfirmed": anyBool()
    };

    final dto = sut.toDto(json);

    expect(dto.id, json['id']);
    expect(dto.name, json['name']);
    expect(dto.position, isNull);
    expect(dto.photo, isNull);
    expect(dto.confirmationDate, isNull);
    expect(dto.isConfirmed, json['isConfirmed']);
  });

  test('should map to json', () {
    final dto = NextEventPlayer(
      id: anyString(),
      name: anyString(),
      isConfirmed: anyBool(),
      confirmationDate: DateTime(2024, 1, 18, 2, 0),
      photo: anyString(),
      position: anyString(),
    );

    final json = sut.toJson(dto);

    expect(json['id'], dto.id);
    expect(json['name'], dto.name);
    expect(json['isConfirmed'], dto.isConfirmed);
    expect(json['confirmationDate'], '2024-01-18T02:00:00.000');
    expect(json['photo'], dto.photo);
    expect(json['position'], dto.position);
  });

  test('should map to json with empty fields', () {
    final dto = NextEventPlayer(
      id: anyString(),
      name: anyString(),
      isConfirmed: anyBool(),
    );

    final json = sut.toJson(dto);

    expect(json['id'], dto.id);
    expect(json['name'], dto.name);
    expect(json['isConfirmed'], dto.isConfirmed);
    expect(json['confirmationDate'], isNull);
    expect(json['photo'], isNull);
    expect(json['position'], isNull);
  });
}
