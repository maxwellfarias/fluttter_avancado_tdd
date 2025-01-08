import 'package:fluttter_avancado_tdd_clean_arch/infra/api/repositories/load_next_event_api_repo.dart';
import 'package:fluttter_avancado_tdd_clean_arch/main/factories/infra/api/adapters/http_adapter_factory.dart';

LoadNextEventApiRepository makeLoadNextEventApiRepository() {
    return LoadNextEventApiRepository(httpClient: makeHttpAdapter(), url: 'http://127.0.0.1:8080/api/groups/:groupId/next_event');
}