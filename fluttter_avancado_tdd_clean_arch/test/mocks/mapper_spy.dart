import 'package:fluttter_avancado_tdd_clean_arch/infra/mappers/mapper.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/types/json.dart';

final class MapperSpy<Dto> implements Mapper<Dto> {
  Dto toDtoOutput;
  Json? toDtoInput;
  int toDtoCallsCount = 0;

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
  Json toJson(Dto dto) => throw UnimplementedError();
}