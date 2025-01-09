import 'package:fluttter_avancado_tdd_clean_arch/infra/cache/clients/cache_get_client.dart';

final class CacheGetClientSpy implements CacheGetClient {
  String? key;
  int callsCount = 0;
  Error? error;
  dynamic response;

  @override
  Future<dynamic> get({required String key}) async {
    callsCount++;
    this.key = key;
    if (error != null) throw error!;
    return response;
  }
}