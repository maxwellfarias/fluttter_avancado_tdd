import 'package:flutter_test/flutter_test.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/adapters/cache_manager_adapter.dart';

import '../../../mocks/fakes.dart';
import '../mocks/cache_manager_spy.dart';

void main() {
  late String key;
  late CacheManagerClientSpy client;
  late CacheManagerAdapter sut;
  setUp(() {
    key = anyString();
    client = CacheManagerClientSpy();
    sut = CacheManagerAdapter(client: client);
  });

  test('should call getFileFromCache with correct input', () async {
    await sut.get(key: key);
    expect(client.key, key);
    expect(client.getFileFromCacheCallsCount, 1);
  });

  test('should return null if FileInfo is empty ', () async {
    client.simulateEmptyInfo();
    final json = await sut.get(key: key);
    expect(json, isNull);
  });

  test('should return null if cache is old ', () async {
    client.simulateCacheOld();
    final response = await sut.get(key: key);
    expect(response, isNull);
  });

 test('should call file.exists only once', () async {
    await sut.get(key: key);
    expect(client.file.existsCallsCount, 1);
  });

  test('should return null if file is empty', () async {
    client.file.simulateFileEmpty();
    final json = await sut.get(key: key);
    expect(json, isNull);
  });

  test('should call file.readAsString only once', () async {
    await sut.get(key: key);
    expect(client.file.readAsStringCallsCount, 1);
  });

  test('should return null if cache is invalid', () async {
    client.file.simulateInvalidResponse();
    await sut.get(key: key);
    expect(client.file.readAsStringCallsCount, 1);
  });

  test('should return json if cache is valid', () async {
    client.file.simulateResponse(json: '''
        {
            "key1": "value1",
            "key2": "value2"
        }
    ''');
   final json =  await sut.get(key: key);
    expect(json["key1"], "value1");
    expect(json["key2"], "value2");
  });

  test('should return null if file.readAsString fails', () async {
    client.file.simulateReadAsStringError();
    final json = await sut.get(key: key);
    expect(json, isNull);
  });

  test('should return null if file.exists fails', () async {
    client.file.simulateExistsError();
    final json = await sut.get(key: key);
    expect(json, isNull);
  });

  test('should return null if getFileFromCache fails', () async {
    client.simulateGetFileFromCacheError();
    final json = await sut.get(key: key);
    expect(json, isNull);
  });


}
