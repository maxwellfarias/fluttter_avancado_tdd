import 'package:flutter_test/flutter_test.dart';
import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/next_event.dart';
import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/next_event_player.dart';

import '../../../helpers/fakes.dart';

class LoadNextEventApiRepository {
  final HttpGetClient httpClient;
  final String url;
  LoadNextEventApiRepository({
    required this.httpClient,
    required this.url,
  });

  Future<NextEvent> loadNextEvent({required String groupId}) async {
    final event = await httpClient.get(url: url, params: {"groupId": groupId});
    return NextEvent(
      groupName: event['groupName'],
      date: DateTime.parse(event['date']),
      //Ao fazer o map, é preciso especificar o tipo de dado que será retornado, no caso, NextEventPlayer
      players: event['players']
          .map<NextEventPlayer>((player) => NextEventPlayer(
              id: player['id'],
              name: player['name'],
              isConfirmed: player['isConfirmed'],
              position: player['position'],
              photo: player['photo'],
              confirmationDate:
                  //tryParse retorna null se não conseguir converter a string para DateTime, como é possivel que a data venha nula, foi colocado ?? '' para evitar erro.
                  DateTime.tryParse(player['confirmationDate'] ?? '')))
          .toList(),
    );
  }
}

abstract class HttpGetClient {
    //O retorno foi colocado como dinamico, porque ele pode ser um Map ou um array com varios Maps dentron dele.
  Future<dynamic> get({required String url, Map<String, String>? params});
}

class HttpGetClientSpy implements HttpGetClient {
  String? url;
  int callsCount = 0;
  Map<String, String>? params;
  dynamic response;

  @override
  Future<dynamic> get(
      {required String url, Map<String, String>? params}) async {
    callsCount++;
    this.url = url;
    this.params = params;
    return response;
  }
}

void main() {
  late String groupId;
  late String url;
  late HttpGetClientSpy httpClient;
  late LoadNextEventApiRepository sut;

  setUp(() {
    groupId = anyString();
    url = anyString();
    httpClient = HttpGetClientSpy();
    httpClient.response =
    {
      "groupName": "any name",
      "date": "2024-08-30T10:30:00",
      "players": [
        {
          "id": "id 1",
          "name": "name 1",
          "isConfirmed": true
        },
        {
          "id": "id 2",
          "name": "name 2",
          "position": "position 2",
          "photo": "photo 2",
          "confirmationDate": "2024-08-29T11:00:00",
          "isConfirmed": true
        }
      ]
    }
    ;
    sut = LoadNextEventApiRepository(httpClient: httpClient, url: url);
  });

  test('should call httpClient with correct input', () async {
    await sut.loadNextEvent(groupId: groupId);
    expect(httpClient.url, url);
    expect(httpClient.params, {"groupId": groupId});
    expect(httpClient.callsCount, 1);
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
