import 'package:fluttter_avancado_tdd_clean_arch/infra/api/clients/http_get_client.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/types/json.dart';

import '../../../mocks/fakes.dart';

final class HttpGetClientSpy implements HttpGetClient {
  String? url;
  int callsCount = 0;
  Json? params;
  Json? queryString;
  Json? headers;
  dynamic response = anyJson();
  Error? error;

  @override
  Future get({required String url, Json? headers, Json? params, Json? queryString}) async {
    callsCount++;
    this.url = url;
    this.params = params;
    if (error != null) {
      throw error!;
    }
    return response;
  }
}
