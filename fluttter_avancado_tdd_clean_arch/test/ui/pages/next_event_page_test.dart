// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart/subjects.dart';

import '../../helpers/fakes.dart';

//A viewModel deve conter somente as informações que são exigidas na view
final class NextEventViewModel {
  final List<NextEventPlayerViewModel> goalkeepers;
  final List<NextEventPlayerViewModel> players;

  const NextEventViewModel({
    this.goalkeepers = const [],
    this.players = const []
  });
}

final class NextEventPlayerViewModel {
  final String name;

  const NextEventPlayerViewModel({
    required this.name,
  });
}

final class NextEventPage extends StatefulWidget {
  final NextEventPresenter presenter;
  final String groupId;
  const NextEventPage(
      {required this.presenter, super.key, required this.groupId});

  @override
  State<NextEventPage> createState() => _NextEventPageState();
}

class _NextEventPageState extends State<NextEventPage> {
  @override
  void initState() {
    widget.presenter.loadNextEvent(groupId: widget.groupId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<NextEventViewModel>(
          stream: widget.presenter.nextEventStream,
          //Toda vez que a stream receber dados, esses dados ficarão disponíveis no snapshot
          builder: (context, snapshot) {
            //Enquanto não estiver chegando os dados, o CircularProgressIndicator ficará disponível
            if (snapshot.connectionState != ConnectionState.active) return const CircularProgressIndicator();
            if (snapshot.hasError) return const SizedBox.shrink();
            final viewModel = snapshot.data!;
            return ListView(
              children: [
                if (viewModel.goalkeepers.isNotEmpty) ListSection(title: 'DENTRO - GOLEIROS', items: viewModel.goalkeepers),
                if (viewModel.players.isNotEmpty) ListSection(title: 'DENTRO - JOGADORES', items: viewModel.players),
              ],
            );
          }),
    );
  }
}

final class ListSection extends StatelessWidget {
  final String title;
  final List<NextEventPlayerViewModel> items;
  const ListSection({
    required this.title,
    required this.items,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title),
        Text(items.length.toString()),
        ...items.map((player) => Text(
              player.name,
            ))
      ],
    );
  }

}

//: A ideia é que o presenter faça também todo a lógica de ordenação dos dados, tirando qualquer lógica da UI
abstract interface class NextEventPresenter {
  Stream<NextEventViewModel> get nextEventStream;
  void loadNextEvent({required String groupId});
}

final class NextEventPresenterSpy implements NextEventPresenter {
  int loadCallsCount = 0;
  String? groupId;

  //Poderia ter sido criado uma StreamController a fim de controlar a stream manualmente, mas o professor achou que não valeria a pena, pois há libs que facilitam trabalhar com streams de
  //uma forma mais prática e elegante. Nesse projeto será trabalhado com RxDart. BehaviorSubject do RxDart é praticamente uma versão do streamController que já trabalha com broadcast e tem
  //alguns métodos auxiliares que irão facilitar a nossa vida.
  //Geralmente numa stream é especificado o tipo de dados [Stream<type>] que se deseja, mas como não estamos testando o tipo de dados, não será especificado e o dart infere como dynamic. Esse getter
//irá expor a stream.
  var nextEventSubject = BehaviorSubject<NextEventViewModel>();

/*
Por que não trabalhar com BLOC?
Eu pessolamente não gosto de trabalhar com lib onde não há a opção de obter a stream de dentro do componente que a lib está usando para gerenciar a sua stream. Libs que não te fornecem esse
acesso, assim como o Bloc, não dão a opção de extrair a atream do componente que ele gerencia, ele irá forçar que você use um componente dele na camada de UI para fazer esse refresh automático. Isso é bem ruim porque faz com que haja uma aclopamento de duas camadas para fazer o gerenciamento
de estados e se precisar mudar no futuro, pode dar um trabalho imenso. Por isso eu prefiro sempre usar libs que dão a possibilidade de se trabalhar com streams. Será usado o BehaviorSubject
para facilitar a minha vida, mas a minha camanda de UI não precisa saber disso, porque é independente de biblioteca.
 */
  @override
  Stream<NextEventViewModel> get nextEventStream => nextEventSubject.stream;

//Está função alimenta uma stream de dados nextEventSubject. Foi criado um get nextEventStream a fim de ter acesso a essa stream a assim alimentar a minha camada de UI.
  void emitNextEvent([NextEventViewModel? viewModel]) {
    //Se viewModel for nulo, será emitido uma lista vazia
    nextEventSubject.add(viewModel ?? const NextEventViewModel());
  }
  void emitNextEventWith({
    List<NextEventPlayerViewModel> goalkeepers = const [],
    List<NextEventPlayerViewModel> players = const [],
  }) {
    nextEventSubject.add(NextEventViewModel(goalkeepers: goalkeepers, players: players));
  }

  void emitError() {
    nextEventSubject.addError(Error());
  }

  @override
  void loadNextEvent({required String groupId}) {
    loadCallsCount++;
    this.groupId = groupId;
  }
}

void main() {
  late NextEventPresenterSpy presenter;
  late String groupId;
  late Widget sut;

  setUp(() {
    presenter = NextEventPresenterSpy();
    groupId = anyString();
    //Os widgets que estão sendon testados precisam estar dentro de um material app
    sut = MaterialApp(
        home: NextEventPage(presenter: presenter, groupId: groupId));
    //Constroi o widget como emulando a aplicação dele em uma tela.
  });
  testWidgets('should load event data on page init', (tester) async {
    await tester.pumpWidget(sut);
    expect(presenter.loadCallsCount, 1);
    expect(presenter.groupId, groupId);
  });
  testWidgets('should present spinner while data is loading', (tester) async {
    await tester.pumpWidget(sut);
    expect(find.byType(CircularProgressIndicator), findsOne);
  });
  testWidgets('should hide spinner on load success', (tester) async {
    await tester.pumpWidget(sut);
    expect(find.byType(CircularProgressIndicator), findsOne);
    //Esse será o método que informa que os dados foram carregados, em seu parametro será colocado os valores que serão carregados na tela.
    //Como nesse teste não será verificado nenhuma valor, esse parametro será opcional.
    presenter.emitNextEvent();
    //tester.pump() força a atualização da tela.
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('should hide spinner on load error', (tester) async {
    await tester.pumpWidget(sut);
    expect(find.byType(CircularProgressIndicator), findsOne);
    //Esse será o método que informa que os dados foram carregados, em seu parametro será colocado os valores que serão carregados na tela.
    //Como nesse teste não será verificado nenhuma valor, esse parametro será opcional.
    presenter.emitError();
    //tester.pump() força a atualização da tela.
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('should present goalkeepers section', (tester) async {
    await tester.pumpWidget(sut);
    presenter.emitNextEventWith(goalkeepers: const[
      NextEventPlayerViewModel(name: 'Rodrigo'),
      NextEventPlayerViewModel(name: 'Rafael'),
      NextEventPlayerViewModel(name: 'Pedro'),
    ]);
    await tester.pump();
    expect(find.text('DENTRO - GOLEIROS'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Rodrigo'), findsOneWidget);
    expect(find.text('Rafael'), findsOneWidget);
    expect(find.text('Pedro'), findsOneWidget);
  });
  //
  testWidgets('should hide all sections', (tester) async {
    await tester.pumpWidget(sut);
    presenter.emitNextEvent();
    await tester.pump();
    expect(find.text('DENTRO - GOLEIROS'), findsNothing);
    expect(find.text('DENTRO - PLAYERS'), findsNothing);
  });
  testWidgets('should present players section', (tester) async {
    await tester.pumpWidget(sut);
    presenter.emitNextEventWith(players: const [
      NextEventPlayerViewModel(name: 'Rodrigo'),
      NextEventPlayerViewModel(name: 'Rafael'),
      NextEventPlayerViewModel(name: 'Pedro'),
    ]);
    await tester.pump();
    expect(find.text('DENTRO - JOGADORES'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Rodrigo'), findsOneWidget);
    expect(find.text('Rafael'), findsOneWidget);
    expect(find.text('Pedro'), findsOneWidget);
  });
}
