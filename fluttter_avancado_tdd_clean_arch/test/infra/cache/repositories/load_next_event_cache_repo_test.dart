import 'package:flutter_test/flutter_test.dart';
import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/next_event.dart';
import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/next_event_player.dart';


import '../../../mocks/fakes.dart';

final class CacheGetClientSpy implements CacheGetClient {
  String? key;
  int callsCount = 0;
  dynamic response;

  @override
  Future<dynamic> get({required String key}) async {
    callsCount++;
    this.key = key;
    return response;
  }
}

abstract interface class CacheGetClient {
  Future<dynamic> get({ required String key});
}

class LoadNextEventCacheRepository {
  final CacheGetClient cacheClient;
  final String key;

  const LoadNextEventCacheRepository({
    required this.cacheClient,
    required this.key,
  });

  Future<NextEvent> loadNextEvent({required String groupId}) async {
   final json = await cacheClient.get(key: '$key:$groupId');
   return NextEventMapper().toObject(json);
  }
}

final class NextEventMapper extends Mapper<NextEvent> {
  @override
  NextEvent toObject(dynamic json) => NextEvent(
        groupName: json['groupName'],
        date: json['date'],
        //Ao fazer o map, é preciso especificar o tipo de dado que será retornado, no caso, NextEventPlayer
        players: NextEventPlayerMapper().toList(json['players']),
      );
}
abstract base class Mapper<Entity> {
  List<Entity> toList(dynamic arr) => arr.map<Entity>(toObject).toList();

  Entity toObject(dynamic json);
}

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
      "date": DateTime(2024, 8, 30, 10, 30),
      "players": [
        {"id": "id 1", "name": "name 1", "isConfirmed": true},
        {
          "id": "id 2",
          "name": "name 2",
          "position": "position 2",
          "photo": "photo 2",
          "confirmationDate": DateTime(2024, 8, 29, 11, 0),
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

}

/*
//: O professor não aconselha utilizar o mesmo mapper usado no httpRepository para o cacheRepository mesmo quando ambos são iguais porque:
1. Não faz sentido o cache conhecer sobre a API acoplando essas informações.
2. Pensando em um cenário (que não é o noss caso) que o mapper da API estivesse fazendo o mapeamento dos dados sem usar o anti corruption layer não fazendo o devido tratamento
de uma estrutura de dados que não foi bem feitaa, seja porque não estão vindo como gostaríamos ou porque estão em português, reutilizar esse mesmo mapper acabaria replicando
esse problema em outra parte do código.
 */