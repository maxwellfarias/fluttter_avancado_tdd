import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/next_event.dart';
import 'package:fluttter_avancado_tdd_clean_arch/domain/repositories/load_next_event_repo.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/api/clients/http_get_client.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/api/mappers/next_event_mapper.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/types/json.dart';

class LoadNextEventApiRepository implements LoadNextEventRepository {
  final HttpGetClient httpClient;
  final String url;
  LoadNextEventApiRepository({
    required this.httpClient,
    required this.url,
  });

  @override
  Future<NextEvent> loadNextEvent({required String groupId}) async {
    final event =
        await httpClient.get<Json>(url: url, params: {"groupId": groupId});
    return NextEventMapper.toObject(event);
  }
}
