import 'package:fluttter_avancado_tdd_clean_arch/infra/mappers/mapper.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/types/json.dart';

import '../../mocks/fakes.dart';

final class ListMapperSpy<Dto> extends ListMapper<Dto> {
    //: Como já tem uma parte de testes verificando se o mapeamento está sendo feito de maneira correta, esses testes se preocupam apenas em receber os inputs corretos
    //e retornar O TIPO CORRETO não necessitando mais de fazer um novo teste no mapeamento.
  dynamic toDtoListInput;
  int toDtoListCallsCount = 0;
  List<Dto> toDtoListOutput;

  List<Dto>? toJsonListInput;
  int toJsonArrCallsCount = 0;
  JsonArr toJsonArrOutput = anyJsonArr();

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
  JsonArr toJsonArr(List<Dto> list) {
    this.toJsonListInput = list;
    toJsonArrCallsCount++;
    return toJsonArrOutput;
  }

  @override
  Dto toDto(Json json) => throw UnimplementedError();

  @override
  Json toJson(Dto dto) => throw UnimplementedError();
}
