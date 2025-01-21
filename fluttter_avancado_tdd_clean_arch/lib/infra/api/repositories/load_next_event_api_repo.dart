import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/next_event.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/api/clients/http_get_client.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/mappers/mapper.dart';

class LoadNextEventApiRepository{
  final HttpGetClient httpClient;
  final String url;
  final DtoMapper<NextEvent> mapper;

  const LoadNextEventApiRepository({
    required this.httpClient,
    required this.url,
    required this.mapper
  });

  Future<NextEvent> loadNextEvent({required String groupId}) async {
    final event = await httpClient.get(url: url, params: {"groupId": groupId});
    return mapper.toDto(event);
  }
}

