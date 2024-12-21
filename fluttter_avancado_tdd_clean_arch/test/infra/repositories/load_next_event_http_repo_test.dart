// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';

import '../../helpers/fakes.dart';

class LoadNextEventHttpRepository {
  final Client httpClient;
  final String url;

  LoadNextEventHttpRepository({
    required this.httpClient,
    required this.url,
  });

  Future<void> loadNextEvent({required String groupId}) async {
    final uri = Uri.parse(url.replaceFirst(':groupId', groupId));
    await httpClient.get(uri);
  }
}

//Interface segregation principle was violated here because the HttpClientSpy class has to implement all the methods of the Client interface even though it only uses the get method.
class HttpClientSpy implements Client {
  //Se fosse realizado chamada para outros métodos, seria interessante criar várias variáveis para armazenar o método chamado e a quantidade de chamadas
  String? method;
  String? url;
  int callsCount = 0;

  @override
  void close() {}

  @override
  Future<Response> delete(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    throw UnimplementedError();
  }

  @override
  Future<Response> get(Uri url, {Map<String, String>? headers}) async {
    method = 'get';
    callsCount++;
    this.url = url.toString();
    return Response('', 200);
  }

  @override
  Future<Response> head(Uri url, {Map<String, String>? headers}) {
    throw UnimplementedError();
  }

  @override
  Future<Response> patch(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    throw UnimplementedError();
  }

  @override
  Future<Response> post(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    throw UnimplementedError();
  }

  @override
  Future<Response> put(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    throw UnimplementedError();
  }

  @override
  Future<String> read(Uri url, {Map<String, String>? headers}) {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers}) {
    throw UnimplementedError();
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    throw UnimplementedError();
  }
}

void main() {
  test('should request with correct method', () async {
    final groupId = anyString();
    final httpClient = HttpClientSpy();
     const url = 'https://domain.com/api/groups/:groupId/next_event';
    final sut = LoadNextEventHttpRepository(httpClient: httpClient, url: url);
    await sut.loadNextEvent(groupId: groupId);
    expect(httpClient.method, 'get');
    expect(httpClient.callsCount, 1);
  });

  test('should request with correct url', () async {
    final groupId = anyString();
    //Na url abaixo foi colocado :groupId para simular um parâmetro que será substituído pelo valor de groupId. Adicionar : antes do nome do parâmetro é uma convenção do backend
    const url = 'https://domain.com/api/groups/:groupId/next_event';
    final httpClient = HttpClientSpy();
    final sut = LoadNextEventHttpRepository(httpClient: httpClient, url: url);
    await sut.loadNextEvent(groupId: groupId);
    expect(httpClient.url, 'https://domain.com/api/groups/${groupId}/next_event');
  });
}
