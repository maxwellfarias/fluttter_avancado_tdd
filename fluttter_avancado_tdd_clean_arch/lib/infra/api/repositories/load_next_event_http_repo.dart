import 'dart:convert';

import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/domain_error.dart';
import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/next_event.dart';
import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/next_event_player.dart';
import 'package:fluttter_avancado_tdd_clean_arch/domain/repositories/load_next_event_repo.dart';
import 'package:http/http.dart';

class LoadNextEventHttpRepository implements LoadNextEventRepository {
  final Client httpClient;
  final String url;

  LoadNextEventHttpRepository({
    required this.httpClient,
    required this.url,
  });

  @override
  Future<NextEvent> loadNextEvent({required String groupId}) async {
    final uri = Uri.parse(url.replaceFirst(':groupId', groupId));
    final response = await httpClient.get(uri, headers: {
      'content-type': 'application/json',
      'accept': 'application/json',
    });
    switch (response.statusCode) {
      case 200:
        break;
      case 401:
        throw DomainError.sessionExpired;
      default:
        throw DomainError.unexpected;
    }

    final event = jsonDecode(response.body);
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

