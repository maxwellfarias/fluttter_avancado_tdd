abstract interface class NextEventPresenter {
  Stream<NextEventViewModel> get nextEventStream;
  Stream<bool> get isBusyStream;
  void dispose();
  Future<void> loadNextEvent({required String groupId, bool isReload});
}
//:Poderia dentro do presentation layer criar uma pasta chamada 'viewModel. O professor não vê como um problema em si, mas seria desnecessário
//uma vez que quando se coloca um arquivo dentro de pastas, a ideia seria reutilizar esse arquivo em outros locais do projeto, mas quando se
//pensa em MVP, MVC, estes são designers partterns de interface e sua funcionalidade é gerenciar uma UI, neste caso o presenter é o gerenciador
//da nossa tela, abaixo encontra-se um viewModel específico dessa tela e por isso dificilmente esse viewModel será reaproveitado em outra tela
//porque este é desenhado especificamente para a UI que ele se proproe. Devido a essa situação o professor prefere deixar tanto o presenter quanto
//o viewModel no mesmo arquivo.

//:O presenter é responsável por manipular os dados que vieram da API para que as informações sejam exibidas na tela de maneira adequada. Esse é o local
//ideal para que seja feita essa adaptação. Caso essa manipulação acontecesse em camadas superiores (useCase, Ropository) isso acabaria limitando a minha
//API a uma tela específica de um dispositivo mobile. Sendo necessário que o backend criasse uma nova rota para o web, uma vez que esse mesmo recurso poderia
// ser usado em uma página web que poderia estar monstrando mais informações do que o dispositivo mobile. Um outro exemplo seria implementar essa adaptação
//dentro de um usecase e esse serviço ser utilizado por outro presenter que não usaria 100% da adatação em sua UI.
final class NextEventViewModel {
  final List<NextEventPlayerViewModel> goalkeepers;
  final List<NextEventPlayerViewModel> players;
  final List<NextEventPlayerViewModel> out;
  final List<NextEventPlayerViewModel> doubt;

  const NextEventViewModel({
    this.goalkeepers = const [],
    this.players = const [],
    this.out = const [],
    this.doubt = const [],
  });
}

final class NextEventPlayerViewModel {
  final String name;
  final String initials;
  final String? photo;
  final String? position;
  final bool? isConfirmed;

  const NextEventPlayerViewModel({
    required this.name,
    required this.initials,
    this.photo,
    this.position,
    this.isConfirmed,
  });
}
