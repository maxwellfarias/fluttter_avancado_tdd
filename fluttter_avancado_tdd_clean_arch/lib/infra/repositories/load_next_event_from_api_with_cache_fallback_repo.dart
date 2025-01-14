import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/next_event.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/cache/clients/cache_save_client.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/mappers/next_event_mapper.dart';

final class LoadNextEventFromApiWithCacheFallbackRepository {
  final Future<NextEvent> Function({required String groupId}) loadNextEventFromApi;
  final Future<NextEvent> Function({required String groupId}) loadNextEventFromCache;
  final CacheSaveClient cacheClient;
  final String key;

  const LoadNextEventFromApiWithCacheFallbackRepository({
    required this.loadNextEventFromApi,
    required this.loadNextEventFromCache,
    required this.cacheClient,
    required this.key,
  });

  Future<NextEvent> loadNextEvent({required String groupId}) async {
    try {
      final event = await loadNextEventFromApi(groupId: groupId);
      final json = NextEventMapper().toJson(event);
      await cacheClient.save(key: '$key:$groupId', value: json);
      return event;
    } catch (e) {
      try {
        return await loadNextEventFromCache(groupId: groupId);
      } catch (e) {
        rethrow;
      }
    }
  }
}