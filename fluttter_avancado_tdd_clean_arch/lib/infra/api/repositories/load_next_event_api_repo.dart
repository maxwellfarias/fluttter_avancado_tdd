import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/next_event.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/api/clients/http_get_client.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/api/mappers/next_event_mapper.dart';

class LoadNextEventApiRepository{
  final HttpGetClient httpClient;
  final String url;
  const LoadNextEventApiRepository({
    required this.httpClient,
    required this.url,
  });

  Future<NextEvent> loadNextEvent({required String groupId}) async {
    final event =
        await httpClient.get(url: url, params: {"groupId": groupId});
    return NextEventMapper().toObject(event);
  }
}

/*
//: Composite Design Pattern
Elementos:
1. Componente: Seria a interface que eles implementam. Se o useCase não tivesse sido excluído, seria a interface que o seria injetada no useCase. Como no projeto
não existe essa classe abstrata, o nosso componente será a assinatura da função 'Future<NextEvent> loadNextEvent({required String groupId})' que será injetada no Presenter.
2. Composite: Elemento que implementa o componente (interface), este possui filhos (leafs). Os leafs serão injetados no composite
3. Leaf: Em nosso caso temos dois leafs, o LoadNextEventApiRepository e o LoadNextEventCacheRepository, eles são responsáveis por implementar o componente (interface), mas eles
não possuem filhos do mesmo tipo.

Não é interessante criar a pasta com nome composite, porque no projeto podem existir outros composites (adapters, usecase...), gerando assim uma confusão. O professor indica criar
uma pasta com o nome repositories (uma vez que este composite é uma abstração dos repositories). A fim de não gerar ambiquidade, foi ao criar um composite, é fundamental que o seu
nome seja bem descritivo, mesmo que eles fiquem longos 'load_next_event_from_api_with_cache_fallback_repo.dart', assim o nome deixa claro que a API será consumida e em caso de falha
será usado o cache.

 */