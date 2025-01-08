import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/next_event.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/api/clients/http_get_client.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/api/mappers/next_event_mapper.dart';

class LoadNextEventApiRepository{
  final HttpGetClient httpClient;
  final String url;
  const LoadNextEventApiRepository({
    required this.httpClient,
    required this.url,
  });

  Future<NextEvent> loadNextEvent({required String groupId}) async {
    final event =
        await httpClient.get(url: url, params: {"groupId": groupId});
    return NextEventMapper().toObject(event);
  }
}
