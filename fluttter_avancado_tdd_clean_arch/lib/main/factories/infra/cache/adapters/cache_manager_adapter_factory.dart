import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/cache/adapters/cache_manager_adapter.dart';

CacheManagerAdapter makeCacheManagerAdapter() {
  return CacheManagerAdapter(client: DefaultCacheManager());
}
