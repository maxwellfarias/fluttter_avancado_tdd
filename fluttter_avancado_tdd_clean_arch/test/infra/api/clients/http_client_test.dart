import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';

import '../../../helpers/fakes.dart';
import 'client_spy.dart';

//:Já existe uma classe em dart com esse nome, ela tambem faz requisicoes HTTP, contudo a propria documentacao dessa classe recomenda que seja usada a lib externa do HTTP
//Devido a isso, é preciso ter cuidado com o import, para não usar a classe própria do dart. HttpClient é um adapter
class HttpClient {
  final Client client;

  HttpClient({required this.client});

  Future<void> get({required String url, Map<String, String>? headers}) async {
    final allHeaders = (headers ?? {})..addAll(
        {'content-type': 'application/json', 'accept': 'application/json'});
    await client.get(Uri.parse(url), headers: allHeaders);
  }
}

void main() {
  late ClientSpy client;
  late HttpClient sut;
  late String url;

  setUp(() {
    url = anyString();
    client = ClientSpy();
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
  });
}
