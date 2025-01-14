import 'package:fluttter_avancado_tdd_clean_arch/infra/cache/clients/cache_save_client.dart';

class CacheSaveClientMock implements CacheSaveClient {
  int callsCount = 0;
  String? key;
  dynamic value;

  @override
  Future<void> save({required String key, required dynamic value}) async {
    this.key = key;
    this.value = value;
    callsCount ++;
  }
}