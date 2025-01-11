import 'package:flutter_test/flutter_test.dart';

import '../../mocks/fakes.dart';

final class LoadNextEventFromApiWithFallbackRepository {
  final Future<void> Function({required String groupId}) loadNextEventFromApi;

  const LoadNextEventFromApiWithFallbackRepository({
    required this.loadNextEventFromApi,
  });

  Future<void> loadNextEvent({required String groupId}) async {
    await loadNextEventFromApi(groupId: groupId);
  }
}

final class LoadNextEventRepositorySpy {
    String? groupId;
    int callsCount = 0;

    Future<void> loadNextEvent({required String groupId}) async {
        this.groupId = groupId;
        callsCount++;
    }
}
void main(){
    test('should load event data from api repo', () async {
        final groupId = anyString();
        final apiRepo = LoadNextEventRepositorySpy();
        final sut = LoadNextEventFromApiWithFallbackRepository(loadNextEventFromApi: apiRepo.loadNextEvent);
        await sut.loadNextEvent(groupId: groupId);
        expect(apiRepo.groupId, groupId);
        expect(apiRepo.callsCount, 1);
    });
}