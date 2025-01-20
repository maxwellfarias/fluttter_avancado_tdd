import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/errors.dart';
import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/next_event.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/cache/clients/cache_get_client.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/mappers/mapper.dart';

class LoadNextEventCacheRepository {
  final CacheGetClient cacheClient;
  final String key;
  final Mapper<NextEvent> mapper;

  const LoadNextEventCacheRepository({
    required this.cacheClient,
    required this.key,
    required this.mapper
  });

  Future<NextEvent> loadNextEvent({required String groupId}) async {
   final json = await cacheClient.get(key: '$key:$groupId');
   if (json == null) throw UnexpectedError();
   return mapper.toDto(json);
  }
}