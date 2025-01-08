import 'package:flutter/material.dart';
import 'package:fluttter_avancado_tdd_clean_arch/main/factories/infra/api/ui/pages/next_event_page_factory.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: makeNextEventPage(),
    );
  }
}
/*
EXCLUISÃO DO USECASE
//:Se você decidir trabalhar com DTOs, você não quer que a sua entidade passe para a camada de estrutura e para a camada de apresentação, mas sim que ela fique presa no domínio.
O fluxo deveria ser:
1. Usecase chama o Repository
2. repository retorna um DTO
3. A usecase transforma o DTO retornado em uma entidade e executa uma regra de negócio se tiver
4. A usecase retorna um OUTRO DTO para a Presenter

O usecase nunca trabalharia o seu input e output com entidades. Se fosse seguir essa abordagem acima, o usecase faz sentido existir, pois ele pegaria dados do DTO de infraestrutura,
criaria a entidade e converter em outro DTO de saida. Até então, o usecase implementado no código está apenas repassando a chamada do presenter para o repository, não existindo inteligência
nenhuma. No projeto foi definido que uma vez que as entidades não têm regra, não tem problema liberar que a entidade passe passe para a camada de estrutura e apresentação, mas com isso
o usecase perde a sua função. Se tivesse um usecase que precisasse chamar dois repositórios, ele faria sentido em existir. Como o usecase atualmente está apenas repassando uma chamada, ele
está sendo um enti-pattern chamado middleman, isso acontece quando uma classe simplemente chama outra, sendo dessa forma desnecessária a sua existência. Como o usecase está apenas fazendo
essa intermediação, ele pode ser excluído e pode ser passado diferetamente a função do repository para o construtor do presenter (repo.loadNextEvent) [trabalho orientado a função e não mais a interface].
Na prática, quando se usa o clean arch no front-end em que as entidades dificilmente terão regras de nogócio, elas serão DTOs, os usecases não precisarão existir em 99% dos casos, pois eles
irão apenas repassar chamadas. Isso inclusive pode ter um pequeno problema de performance por ter mais uma classe no meio e vai gerar mais trabalho para uma coisa que não serve para nada.
A própria documentação do flutter com relação a arquitetura, trás também essa abordagem.

 */