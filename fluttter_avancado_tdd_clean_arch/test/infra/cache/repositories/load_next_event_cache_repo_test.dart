import 'package:flutter_test/flutter_test.dart';
import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/next_event.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/cache/repositories/load_next_event_cache_repo.dart';

import '../../../mocks/fakes.dart';
import '../../mocks/mapper_spy.dart';
import '../mock/cache_get_client_spy.dart';

void main() {
  late String groupId;
  late String key;
  late CacheGetClientSpy cacheClient;
  late MapperSpy<NextEvent> mapper;
  late LoadNextEventCacheRepository sut;

  setUp(() {
    groupId = anyString();
    key = anyString();
    cacheClient = CacheGetClientSpy();
    mapper = MapperSpy(toDtoOutput: anyNextEvent());
    sut = LoadNextEventCacheRepository(cacheClient: cacheClient, key: key, mapper: mapper);
  });

  test('should call CacheClient with correct input', () async {
    await sut.loadNextEvent(groupId: groupId);
    expect(cacheClient.key, '$key:$groupId');
    expect(cacheClient.callsCount, 1);
  });

   test('should return next event with success', () async {
    final event = await sut.loadNextEvent(groupId: groupId);
    expect(mapper.toDtoInput, cacheClient.response);
    expect(mapper.toDtoCallsCount, 1);
    expect(event, mapper.toDtoOutput);
  });

  test('should rethrow on error', () async {
    final error = Error();
    cacheClient.error = error;
    final future = sut.loadNextEvent(groupId: groupId);
    expect(future, throwsA(error));
  });

}

/*
//: O professor não aconselha utilizar o mesmo mapper usado no httpRepository para o cacheRepository mesmo quando ambos são iguais porque:
1. Não faz sentido o cache conhecer sobre a API acoplando essas informações.
2. Pensando em um cenário (que não é o nosso caso) que o mapper da API estivesse fazendo o mapeamento dos dados sem usar o anti corruption layer não fazendo o devido tratamento
de uma estrutura de dados que não foi bem feita, seja porque não estão vindo como gostaríamos ou porque estão em português, reutilizar esse mesmo mapper acabaria replicando
esse problema em outra parte do código. Isso acontece principalmente quando se faz necessário utilizar APIs de terceiros que não temos nenhum controle.
 */