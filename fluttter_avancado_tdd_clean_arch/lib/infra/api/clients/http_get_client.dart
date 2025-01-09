import 'package:fluttter_avancado_tdd_clean_arch/infra/types/json.dart';

abstract interface class HttpGetClient {
  Future<dynamic> get({
    required String url,
    Json? headers,
    Json? params,
    Json? queryString,
  });
}
/*
//:Eu posso criar uma classe concreta que ira implementar somente o HttpGetClient ou eu posso fazer algo mais generico criando um http client implementando dentro dele varias interfaces.
Mesmo que eu coloque uma classe implementando 4 interfaces diferentes, não será aumentando o grau de complexidade na hora de criar a minha classe, porque
todos eles dependem da mesma lib não dependendo de nenhum componente interno do projeto porque eles são a ponta da arquitetura. O que seria diferente se fosse pego o NextEventLoader(usecase) para que este fosse um usecase generico focado em carregamento
com vários metodos como create, delete, load. Cada um desses metodos precisaria de um repositorio diferente e cada vez que eu colocasse mais coisas nessa classe
generica, seria aumentado a complexidade desse objeto.
 */
