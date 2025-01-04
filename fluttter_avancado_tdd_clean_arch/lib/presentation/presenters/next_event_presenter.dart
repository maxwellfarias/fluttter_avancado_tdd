abstract interface class NextEventPresenter {
  Stream<NextEventViewModel> get nextEventStream;
  void loadNextEvent({required String groupId});
}
//:Poderia dentro do presentation layer criar uma pasta chamada 'viewModel. O professor não vê como um problema em si, mas seria desnecessário
//uma vez que quando se coloca um arquivo dentro de pastas, a ideia seria reutilizar esse arquivo em outros locais do projeto, mas quando se
//pensa em MVP, MVC, estes são designers partterns de interface e sua funcionalidade é gerenciar uma UI, neste caso o presenter é o gerenciador
//da nossa tela, abaixo encontra-se um viewModel específico dessa tela e por isso dificilmente esse viewModel será reaproveitado em outra tela
//porque esse desenhado especificamente para a UI que ele se proproe. Devido a essa situação o professo prefere deixar tanto o presenter quanto
//o viewModel no mesmo arquivo.
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
  final String? position;
  final bool? isConfirmed;

  const NextEventPlayerViewModel({
    required this.name,
     this.position,
     this.isConfirmed,
  });
}