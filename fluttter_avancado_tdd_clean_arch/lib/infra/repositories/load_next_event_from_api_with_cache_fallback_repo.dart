import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/errors.dart';
import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/next_event.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/cache/clients/cache_save_client.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/mappers/mapper.dart';

typedef LoadNextEventRepository = Future<NextEvent> Function({required String groupId});

final class LoadNextEventFromApiWithCacheFallbackRepository {
  final LoadNextEventRepository loadNextEventFromApi;
  final LoadNextEventRepository loadNextEventFromCache;
  final CacheSaveClient cacheClient;
  final JsonMapper<NextEvent> mappper;
  final String key;

  const LoadNextEventFromApiWithCacheFallbackRepository({
    required this.loadNextEventFromApi,
    required this.loadNextEventFromCache,
    required this.cacheClient,
    required this.mappper,
    required this.key,
  });

  Future<NextEvent> loadNextEvent({required String groupId}) async {
    try {
      final event = await loadNextEventFromApi(groupId: groupId);
      await cacheClient.save(key: '$key:$groupId', value: mappper.toJson(event));
      return event;
    } on SessionExpiredError {
      rethrow;
    } catch (error) {
      return loadNextEventFromCache(groupId: groupId);
    }
  }
}
