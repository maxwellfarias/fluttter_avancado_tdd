import 'dart:convert';

import 'package:dartx/dartx.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/domain_error.dart';
import 'package:http/http.dart';

import '../../../helpers/fakes.dart';
import 'client_spy.dart';

//:Já existe uma classe em dart com esse nome, ela tambem faz requisicoes HTTP, contudo a propria documentacao dessa classe recomenda que seja usada a lib externa do HTTP
//Devido a isso, é preciso ter cuidado com o import, para não usar a classe própria do dart. HttpClient é um adapter
class HttpClient {
  final Client client;

  HttpClient({required this.client});

//:Por ser um treinamento, foi colocado a queryString apenas para mostrar como essa funcionalidade poderia ser implementada,
//na prática, isso fere o YAGNI principle ("You Aren't Gonna Need It"), um vez que só deve ser implementado algo que de fato
//será usado.
  Future<T> get<T>(
      {required String url,
      Map<String, String>? headers,
      Map<String, String?>? params,
      Map<String, String>? queryString}) async {
    final allHeaders = (headers ?? {})
      ..addAll(
          {'content-type': 'application/json', 'accept': 'application/json'});
    final uri = _buildUri(url: url, params: params, queryString: queryString);
    final response = await client.get(uri, headers: allHeaders);
    switch (response.statusCode) {
      case 200:
        return jsonDecode(response.body);
      case 401:
        throw DomainError.sessionExpired;
      default:
        throw DomainError.unexpected;
    }
  }

  Uri _buildUri(
      {required String url,
      required Map<String, String?>? params,
      Map<String, String>? queryString}) {
    url = params?.keys
            .fold(
              url,
              (result, key) => result.replaceFirst(':$key', params[key] ?? ''),
            )
            .removeSuffix('/') ??
        url;
    //: Foi utilizado a lib dartx a fim de remover um determinado caracter, caso este exista.
    //fold faz com que a cada interação, o valor que é retonado acumule no campo 'result' que é reusado a cada interação.
    url = queryString?.keys
            .fold('$url?', (result, key) => '$result$key=${queryString[key]}&')
            .removeSuffix('&') ??
        url;

    return Uri.parse(url);
  }
}

void main() {
  late ClientSpy client;
  late HttpClient sut;
  late String url;

  setUp(() {
    url = anyString();
    client = ClientSpy();
    client.responseJson = '''
    {
      "key1": "value1",
      "key2": "value2"
    }
    ''';
    sut = HttpClient(client: client);
  });

//:É possível fazer a criação de grupos a fim de organizar melhor os testes. Além de melhorar o legibilidade, economiza da declaração da descrição dos testes sem precisar por
//exemplo usar should request with correct method on get, por entende-se que todos os testes já é no contexto do on get.
  group('get', () {
    test('should request with correct method', () async {
      await sut.get(url: url);
      expect(client.method, 'get');
      expect(client.callsCount, 1);
    });

    test('should request with correct method', () async {
      await sut.get(url: url);
      expect(client.url, url);
    });

    test('should request with default headers', () async {
      await sut.get(url: url);
      expect(client.headers?['content-type'], 'application/json');
      expect(client.headers?['accept'], 'application/json');
    });

    test('should append headers', () async {
      await sut.get(url: url, headers: {'h1': 'value 1', 'h2': 'value 2'});
      expect(client.headers?['h1'], 'value 1');
      expect(client.headers?['h2'], 'value 2');
    });

    test('should request with correct params', () async {
      url = 'http://anyurl.com/users/:p1/:p2';
      await sut.get(url: url, params: {'p1': 'v1', 'p2': 'v2'});
      expect(client.url, 'http://anyurl.com/users/v1/v2');
    });

    test('should request with optional param', () async {
      url = 'http://anyurl.com/users/:p1/:p2';
      await sut.get(url: url, params: {'p1': 'v1', 'p2': null});
      expect(client.url, 'http://anyurl.com/users/v1');
    });

    test('should request with invalid params', () async {
      url = 'http://anyurl.com/users/:p1/:p2';
      await sut.get(url: url, params: {'p3': 'v3'});
      expect(client.url, 'http://anyurl.com/users/:p1/:p2');
    });

    test('should request with correct queryStrings', () async {
      url = 'http://anyurl.com/users/:p1/:p2';
      await sut.get(url: url, queryString: {'q1': 'v1', 'q2': 'v2'});
      expect(client.url, '$url?q1=v1&q2=v2');
    });

    test('should request with correct queryStrings and params', () async {
      url = 'http://anyurl.com/users/:p3/:p4';
      await sut.get(
          url: url,
          queryString: {'q1': 'v1', 'q2': 'v2'},
          params: {'p3': 'v3', 'p4': 'v4'});
      expect(client.url, 'http://anyurl.com/users/v3/v4?q1=v1&q2=v2');
    });

    test('should throw UnexpextedError on 400', () async {
      client.simulateBadRequestError();
      final future = sut.get(url: url);
      expect(future, throwsA(DomainError.unexpected));
    });

    test('should throw UnexpextedError on 401', () async {
      client.simulateUnauthorizedError();
      final future = sut.get(url: url);
      expect(future, throwsA(DomainError.sessionExpired));
    });

    test('should throw UnexpextedError on 403', () async {
      client.simulateForbiddenError();
      final future = sut.get(url: url);
      expect(future, throwsA(DomainError.unexpected));
    });

    test('should throw UnexpextedError on 404', () async {
      client.simulateNotFoundError();
      final future = sut.get(url: url);
      expect(future, throwsA(DomainError.unexpected));
    });
    test('should throw UnexpextedError on 500', () async {
      client.simulateServerError();
      final future = sut.get(url: url);
      expect(future, throwsA(DomainError.unexpected));
    });

    test('should return a map', () async {
      final data = await sut.get(url: url);
      expect(data['key1'], 'value1');
      expect(data['key2'], 'value2');
    });
  });
}
