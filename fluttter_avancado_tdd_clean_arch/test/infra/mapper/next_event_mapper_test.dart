import 'package:flutter_test/flutter_test.dart';
import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/next_event.dart';
import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/next_event_player.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/mappers/next_event_mapper.dart';
import '../../mocks/fakes.dart';
import '../mocks/list_mapper_spy.dart';

void main() {
  late NextEventMapper sut;
  late ListMapperSpy<NextEventPlayer> playerMapper;

  setUp(() {
    playerMapper = ListMapperSpy<NextEventPlayer>(toDtoListOutput: anyNextEventPlayerList());
    sut = NextEventMapper(playerMapper: playerMapper);
  });

  test('should map to dto', () {
    final json = {
      "groupName": anyString(),
      "date": '2025-01-18T02:00:00.000',
      "players": anyJsonArr()
    };

    final dto = sut.toDto(json);

    expect(dto.groupName, json['groupName']);
    expect(dto.date, DateTime(2025, 1, 18, 2, 0), );
    expect(playerMapper.toDtoListInput, json['players']);
    expect(playerMapper.toDtoListCallsCount, 1);
    expect(dto.players, playerMapper.toDtoListOutput);
  });

   test('should map to json', () {
    final dto = NextEvent(
      groupName: anyString(),
      date: DateTime(2025, 1, 18, 2, 0),
      players: anyNextEventPlayerList(),
    );

    final json = sut.toJson(dto);

    expect(json['groupName'], dto.groupName);
    expect(json['date'], '2025-01-18T02:00:00.000');
    expect(playerMapper.toJsonListInput, dto.players);
    expect(json['players'], playerMapper.toJsonArrOutput);
    expect(playerMapper.toJsonArrCallsCount, 1);
  });
}
