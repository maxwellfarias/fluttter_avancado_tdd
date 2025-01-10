
import 'dart:convert';
import 'dart:typed_data';
import 'package:file/file.dart';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../mocks/fakes.dart';
import 'file_spy.dart';

final class CacheManagerAdapter {
  final BaseCacheManager client;
  const CacheManagerAdapter({required this.client});

  Future<dynamic> get({required String key}) async {
    final info = await client.getFileFromCache(key);
    if (info == null) return null;
    if (info.validTill.isBefore(DateTime.now()) || !await info.file.exists()) return null;
    try {
      final data = await info.file.readAsString();
      return jsonDecode(data);
    } catch (err) {
      return null;
    }
  }
}

class CacheManagerClientSpy implements BaseCacheManager {
  int getFileFromCacheCallsCount = 0;
  String? key;
  bool _isFileInfoEmpty = false;
  DateTime _validTill = DateTime.now().add(const Duration(seconds: 2));
  FileSpy file = FileSpy();


  void simulateEmptyInfo() => _isFileInfoEmpty = true;
  void simulateCacheOld() => _validTill = DateTime.now().subtract( const Duration(seconds: 2));

  @override
  Future<FileInfo?> getFileFromCache(String key, {bool ignoreMemCache = false}) async {
    getFileFromCacheCallsCount ++;
    this.key = key;
    return _isFileInfoEmpty ? null : FileInfo(file, FileSource.Cache, _validTill, '');
  }

  @override
  Future<void> dispose() => throw UnimplementedError();

  @override
  Future<FileInfo> downloadFile(String url, {String? key, Map<String, String>? authHeaders, bool force = false}) => throw UnimplementedError();

  @override
  Future<void> emptyCache() => throw UnimplementedError();

  @override
  Stream<FileInfo> getFile(String url, {String? key, Map<String, String>? headers}) => throw UnimplementedError();

  @override
  Future<FileInfo?> getFileFromMemory(String key) => throw UnimplementedError();

  @override
  Stream<FileResponse> getFileStream(String url,
      {String? key, Map<String, String>? headers, bool? withProgress}) => throw UnimplementedError();

  @override
  Future<File> getSingleFile(String url,
      {String? key, Map<String, String>? headers}) => throw UnimplementedError();

  @override
  Future<File> putFile(String url, Uint8List fileBytes, {String? key, String? eTag, Duration maxAge = const Duration(days: 30), String fileExtension = 'file'}) => throw UnimplementedError();

  @override
  Future<File> putFileStream(String url, Stream<List<int>> source, {String? key, String? eTag, Duration maxAge = const Duration(days: 30), String fileExtension = 'file'}) => throw UnimplementedError();

  @override
  Future<void> removeFile(String key) => throw UnimplementedError();
}

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

}
