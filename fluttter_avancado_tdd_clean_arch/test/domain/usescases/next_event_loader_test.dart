import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/next_event.dart';
import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/next_event_player.dart';
import 'package:fluttter_avancado_tdd_clean_arch/domain/usecases/next_event_loader.dart';

import 'package:flutter_test/flutter_test.dart';

import '../../mocks/fakes.dart';
import '../mocks/next_event_page.dart';

void main() {
  late String groupId;
  late LoadNextEventSpyRepository repo;
  late NextEventLoader sut;

  setUp(() {
    groupId = anyString();
    repo = LoadNextEventSpyRepository();
    repo.output = NextEvent(
      groupName: 'Any group name',
      date: DateTime.now(),
      players: [
        NextEventPlayer(
            id: 'any id 1',
            name: 'any name 1',
            isConfirmed: true,
            photo: '',
            position: 'any position 1',
            confirmationDate: DateTime.now()),
        NextEventPlayer(
            id: 'any id 2',
            name: 'any name 2',
            isConfirmed: false,
            photo: '',
            position: 'any position 2',
            confirmationDate: DateTime.now()),
      ],
    );
    sut = NextEventLoader(repo: repo);
  });
  test('should load event data from a repository', () async {
    await sut(groupId: groupId);
    expect(repo.groupId, groupId);
    expect(repo.callsCount, 1);
  });

  test('should return event data on success', () async {
    //A vantagem de comparar os valores com base nos campos permite que posteriormente caso seja modificado o retorno de um DTO para uma entity
    //o teste ira continuar funcionando do mesmo modo.
    final event = await sut(groupId: groupId);
    expect(event.groupName, repo.output?.groupName);
    expect(event.date, repo.output?.date);
    expect(event.players.length, 2);
    expect(event.players[0].id, repo.output?.players[0].id);
    expect(event.players[0].name, repo.output?.players[0].name);
    expect(event.players[0].initials, isNotEmpty);
    expect(event.players[0].photo, repo.output?.players[0].photo);
    expect(event.players[0].position, repo.output?.players[0].position);
    expect(event.players[0].isConfirmed, repo.output?.players[0].isConfirmed);
    expect(event.players[0].confirmationDate,
        repo.output?.players[0].confirmationDate);
    expect(event.players[1].id, repo.output?.players[1].id);
    expect(event.players[1].name, repo.output?.players[1].name);
    expect(event.players[1].initials, isNotEmpty);
    expect(event.players[1].photo, repo.output?.players[1].photo);
    expect(event.players[1].position, repo.output?.players[1].position);
    expect(event.players[1].isConfirmed, repo.output?.players[1].isConfirmed);
    expect(event.players[1].confirmationDate,
        repo.output?.players[1].confirmationDate);
  });

  test('should rethrow on error', () async {
    //Esse teste garante que nao sera colocado um try catch aqui, pois este erro nao sera tratado nesse momento.
    final error = Error();
    repo.error = error;
    final future = sut(groupId: groupId);
    expect(future, throwsA(error));
  });
}
