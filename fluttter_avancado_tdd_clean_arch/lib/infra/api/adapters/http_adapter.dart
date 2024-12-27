import 'dart:convert';

import 'package:dartx/dartx.dart';
import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/errors.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/api/clients/http_get_client.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/types/json.dart';
import 'package:http/http.dart';

//:A função dessa classe é criar uma camada de abstração entre o Repository e o DataSource, neste caso o Client, colocando toda a conversão de valores para DTO
//vindos do Client para ser passado ao Repository, preparando a URL na formatação correta, fazendo o lançamento de erros de acordo com o status code. O critério
//usado para saber se esse Adapter é necessário foi analisar se quando fosse criado outros Repositories que usassem essa mesma Lib do Http, todos esses serviços
//ofertados por esse Adapter teriam que ser refeitos no Repository
final class HttpAdapter implements HttpGetClient {
  final Client client;

  const HttpAdapter({required this.client});

//:Por ser um treinamento, foi colocado a queryString apenas para mostrar como essa funcionalidade poderia ser implementada,
//na prática, isso fere o YAGNI principle ("You Aren't Gonna Need It"), um vez que só deve ser implementado algo que de fato
//será usado.
  @override
  Future<T> get<T>(
      {required String url,
      Map<String, String>? headers,
      Map<String, String?>? params,
      Map<String, String>? queryString}) async {
    final response = await client.get(
        _buildUri(url: url, params: params, queryString: queryString),
        headers: _buildHeaders(url: url, headers: headers));
    return _handleResponse<T>(response);
  }

  T _handleResponse<T>(Response response) {
    switch (response.statusCode) {
      case 200:
        {
          //: O jsonDecode retorna um valor dynamic, esse valor pode ser de dois tipos, um Map ou uma lista de Maps. Pode ser feito um casting dentro desse adapter ou usando o Mapper
          //que foi criado para converter esses dados na camada do Repository. Se o tipo genérico não for informado quando chamar a função 'get, o dart irá inferir o valor de acordo
          //com quem irá recebê-lo: Json data = client.get(url: url) - Nesse caso o genérico passado será do tipo json. Se não for especificado, a função assumirá que o valor genérico é
          //dynamic. Quando o valor genérico atribuído fosse do tipo JsonArr e não fosse feito o casting abaixo, seria gerado um erro: type 'List<dynamic>' is not a subtype of type 'FutureOr<List<Map<String, dynamic>>>'
          //porque em dart não é possível fazer casting de uma list da seguinte forma: List<B> as List<A>. Isso se dá devido à invariância em coleções.
          //O Dart tenta garantir que os elementos da lista sejam compatíveis. Isso falha, pois List<B> e List<A> são considerados tipos distintos, mesmo que B seja um subtipo de A.
          //Assim, é necessário fazer o casting de uma lista por meio de uma iteração de cada elemento e em seguida retornando uma lista.
          final data = jsonDecode(response.body);
          return (T == JsonArr)
              ? data.map<Json>((e) => e as Json).toList()
              : data;
        }
      case 401:
        throw SessionExpired();
      default:
        throw UnexpectedError();
    }
  }

  Map<String, String> _buildHeaders({
    required String url,
    Map<String, String>? headers,
  }) {
    return (headers ?? {})
      ..addAll({'content-type': 'application/json', 'accept': 'application/json'});
  }

  Uri _buildUri(
      {required String url,
      required Map<String, String?>? params,
      Map<String, String>? queryString}) {
    url = params?.keys
            .fold(url, (result, key) => result.replaceFirst(':$key', params[key] ?? ''))
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
