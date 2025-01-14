abstract interface class CacheSaveClient {
    //value é dynamic porque pode ser salvo um json ou um array de json
    Future<void> save({required String key, required dynamic value});
}