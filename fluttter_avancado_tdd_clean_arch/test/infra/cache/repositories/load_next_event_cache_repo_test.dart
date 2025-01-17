import 'package:flutter_test/flutter_test.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/cache/repositories/load_next_event_cache_repo.dart';

import '../../../mocks/fakes.dart';
import 'mocks/cache_get_client_spy.dart';

void main() {
  late String groupId;
  late String key;
  late CacheGetClientSpy cacheClient;
  late LoadNextEventCacheRepository sut;

  setUp(() {
    groupId = anyString();
    key = anyString();
    cacheClient = CacheGetClientSpy();
    cacheClient.response = {
      "groupName": "any name",
      "date": '2024-08-30T10:30:00.000',
      "players": [
        {"id": "id 1", "name": "name 1", "isConfirmed": true},
        {
          "id": "id 2",
          "name": "name 2",
          "position": "position 2",
          "photo": "photo 2",
          "confirmationDate": '2024-08-29T11:00:00.000',
          "isConfirmed": true
        }
      ]
    };
    sut = LoadNextEventCacheRepository(cacheClient: cacheClient, key: key);
  });

  test('should call CacheClient with correct input', () async {
    await sut.loadNextEvent(groupId: groupId);
    expect(cacheClient.key, '$key:$groupId');
    expect(cacheClient.callsCount, 1);
  });

   test('should return next event with success', () async {
    final event = await sut.loadNextEvent(groupId: groupId);
    expect(event.groupName, 'any name');
    expect(event.date, DateTime(2024, 8, 30, 10, 30));
    expect(event.players[0].id, 'id 1');
    expect(event.players[0].name, 'name 1');
    expect(event.players[0].isConfirmed, true);
    expect(event.players[1].id, 'id 2');
    expect(event.players[1].name, 'name 2');
    expect(event.players[1].position, 'position 2');
    expect(event.players[1].photo, 'photo 2');
    expect(event.players[1].confirmationDate, DateTime(2024, 8, 29, 11, 0));
    expect(event.players[1].isConfirmed, true);
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