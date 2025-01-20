import 'package:fluttter_avancado_tdd_clean_arch/infra/mappers/mapper.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/types/json.dart';

import '../../mocks/fakes.dart';

final class MapperSpy<Dto> implements Mapper<Dto> {
  Dto toDtoOutput;
  Json? toDtoInput;
  int toDtoCallsCount = 0;

  Json toJsonOutput = anyJson();
  Dto? toJsonInput;
  int toJsonCallsCount = 0;

  MapperSpy({
    required this.toDtoOutput,
  });

  @override
  Dto toDto(Json json) {
    this.toDtoInput = json;
    toDtoCallsCount++;
    return toDtoOutput;
  }

  @override
  Json toJson(Dto dto) {
    this.toJsonInput = dto;
    toJsonCallsCount++;
    return toJsonOutput;
  }
}