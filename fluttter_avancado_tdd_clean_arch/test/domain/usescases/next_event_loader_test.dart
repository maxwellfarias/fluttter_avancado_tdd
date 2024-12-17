import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

class NextEventLoader {
  final LoadNextEventRepository repo;
  NextEventLoader({required this.repo});

  Future<void> call({required String groupId}) async {
    await repo.loadNextEvent(groupId: groupId);
  }
}

class LoadNextEventRepository {
  var callsCount = 0;
  String? groupId;
  Future<void> loadNextEvent({required String groupId}) async {
    this.groupId = groupId;
    //
    callsCount++;
  }
}

void main() {
  test('should load event data from a repository', () async {
    final groupId = Random().nextInt(50000).toString();
    final repo = LoadNextEventRepository();
    final sut = NextEventLoader(repo: repo);
    await sut(groupId: groupId);
    expect(repo.groupId, groupId);
  });

  test('should load event data from a repository', () async {
    //Esse test tem como objetivo evitar que se crie problemas de performance chamando uma API mais de uma vez de maneira desnecessária
    final groupId = Random().nextInt(50000).toString();
    final repo = LoadNextEventRepository();
    final sut = NextEventLoader(repo: repo);
    await sut(groupId: groupId);
    expect(repo.callsCount, 1);
  });
}
