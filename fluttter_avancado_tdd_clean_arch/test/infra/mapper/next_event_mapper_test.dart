import 'package:flutter_test/flutter_test.dart';
import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/next_event_player.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/mappers/mapper.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/mappers/next_event_mapper.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/types/json.dart';
import '../../mocks/fakes.dart';


final class ListMapperSpy<Dto> extends ListMapper<Dto> {
  dynamic toDtoListInput;
  int toDtoListCallsCount = 0;
  List<Dto> toDtoListOutput;

  ListMapperSpy({
    required this.toDtoListOutput,
  });

  @override
  List<Dto> toDtoList(dynamic arr) {
    toDtoListCallsCount++;
    this.toDtoListInput = arr;
    return toDtoListOutput;
  }

  @override
  Dto toDto(Json json) => throw UnimplementedError();

  @override
  Json toJson(Dto dto) => throw UnimplementedError();
}

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
}
