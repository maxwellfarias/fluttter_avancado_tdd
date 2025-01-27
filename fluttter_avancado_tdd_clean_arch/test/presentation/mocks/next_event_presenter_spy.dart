//: A ideia é que o presenter faça também todo a lógica de ordenação dos dados, tirando qualquer lógica da UI
import 'package:fluttter_avancado_tdd_clean_arch/presentation/presenters/next_event_presenter.dart';
import 'package:rxdart/subjects.dart';

final class NextEventPresenterSpy implements NextEventPresenter {
  int loadCallsCount = 0;
  int disposeCallsCount = 0;
  bool isReload = false;
  String? groupId;

  //Poderia ter sido criado uma StreamController a fim de controlar a stream manualmente, mas o professor achou que não valeria a pena, pois há libs que facilitam trabalhar com streams de
  //uma forma mais prática e elegante. Nesse projeto será trabalhado com RxDart. BehaviorSubject do RxDart é praticamente uma versão do streamController que já trabalha com broadcast e tem
  //alguns métodos auxiliares que irão facilitar a nossa vida.
  //Geralmente numa stream é especificado o tipo de dados [Stream<type>] que se deseja, mas como não estamos testando o tipo de dados, não será especificado e o dart infere como dynamic. Esse getter
//irá expor a stream.
  var nextEventSubject = BehaviorSubject<NextEventViewModel>();
  var isBusySubject = BehaviorSubject<bool>();

/*
Por que não trabalhar com BLOC?
Eu pessolamente não gosto de trabalhar com lib onde não há a opção de obter a stream de dentro do componente que a lib está usando para gerenciar a sua stream. Libs que não te fornecem esse
acesso, assim como o Bloc, não dão a opção de extrair a stream do componente que ele gerencia, ele irá forçar que você use um componente dele na camada de UI para fazer esse refresh automático. Isso é bem ruim porque faz com que haja uma aclopamento de duas camadas para fazer o gerenciamento
de estados e se precisar mudar no futuro, pode dar um trabalho imenso. Por isso eu prefiro sempre usar libs que dão a possibilidade de se trabalhar com streams. Será usado o BehaviorSubject
para facilitar a minha vida, mas a minha camanda de UI não precisa saber disso, porque é independente de biblioteca.
 */
  @override
  Stream<NextEventViewModel> get nextEventStream => nextEventSubject.stream;

  @override
  Stream<bool> get isBusyStream => isBusySubject.stream;

//Está função alimenta uma stream de dados nextEventSubject. Foi criado um get nextEventStream a fim de ter acesso a essa stream a assim alimentar a minha camada de UI.
  void emitNextEvent([NextEventViewModel? viewModel]) {
    //Se viewModel for nulo, será emitido uma lista vazia
    nextEventSubject.add(viewModel ?? const NextEventViewModel());
  }
  void emitNextEventWith({
    List<NextEventPlayerViewModel> goalkeepers = const [],
    List<NextEventPlayerViewModel> players = const [],
    List<NextEventPlayerViewModel> out = const [],
    List<NextEventPlayerViewModel> doubt = const [],
  }) {
    nextEventSubject.add(NextEventViewModel(
      goalkeepers: goalkeepers,
      players: players,
      out: out,
      doubt: doubt,
    ));
  }

  void emitError() {
    nextEventSubject.addError(Error());
  }

  void emitIsBusy([bool isBusy = true]) {
    isBusySubject.add(isBusy);
  }

  @override
  Future<void> loadNextEvent({required String groupId, bool isReload = false}) async {
    loadCallsCount++;
    this.groupId = groupId;
    this.isReload = isReload;
  }

  @override
  void dispose() {
    disposeCallsCount++;
  }
}
