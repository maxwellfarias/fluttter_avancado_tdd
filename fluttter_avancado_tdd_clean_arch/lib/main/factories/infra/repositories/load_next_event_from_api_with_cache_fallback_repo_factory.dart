import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/next_event.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/repositories/load_next_event_from_api_with_cache_fallback_repo.dart';
import 'package:fluttter_avancado_tdd_clean_arch/main/factories/infra/api/repositories/load_next_event_api_repo_factory.dart';
import 'package:fluttter_avancado_tdd_clean_arch/main/factories/infra/cache/adapters/cache_manager_adapter_factory.dart';
import 'package:fluttter_avancado_tdd_clean_arch/main/factories/infra/cache/repositories/load_next_event_cache_repo_factory.dart';
import 'package:fluttter_avancado_tdd_clean_arch/main/factories/infra/mappers/next_event_mapper_factory.dart';

typedef LoadNextEventRepository = Future<NextEvent> Function(
    {required String groupId});

LoadNextEventFromApiWithCacheFallbackRepository makeLoadNextEventFromApiWithCacheFallbackRepository() {
  return LoadNextEventFromApiWithCacheFallbackRepository(
      cacheClient: makeCacheManagerAdapter(),
      key: 'next_event',
      loadNextEventFromApi: makeLoadNextEventCacheRepository().loadNextEvent,
      loadNextEventFromCache: makeLoadNextEventApiRepository().loadNextEvent,
      mappper: makeNextEventMapper());
}
