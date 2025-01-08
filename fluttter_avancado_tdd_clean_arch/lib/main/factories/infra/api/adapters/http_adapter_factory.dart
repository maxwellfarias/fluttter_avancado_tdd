import 'package:fluttter_avancado_tdd_clean_arch/infra/api/adapters/http_adapter.dart';
import 'package:http/http.dart';

HttpAdapter makeHttpAdapter() {
    return HttpAdapter(client: Client());
}