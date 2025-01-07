//:Por padrão, quando se faz o teste de uma stream, o teste irá ficar aguardando por 30 segundos o expect se cumprir, para evitar esse tempo longo foi adicionado
//a flag timeout. Ao ser declarado dessa forma, todos os testes que tiveremc como parâmetro timeout, terão a duração de 1 segundo.
// ignore: library_annotations
@Timeout(Duration(seconds: 1))

import 'package:dartx/dartx.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/next_event.dart';
import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/next_event_player.dart';
import 'package:fluttter_avancado_tdd_clean_arch/presentation/presenters/next_event_presenter.dart';
import 'package:rxdart/subjects.dart';

import '../../helpers/fakes.dart';

//No usecase não faz sentido se ter várias implementações dele porque o usecase já é genérico, ele já está abstraído de implementações. O que será feito é que
//ao invés do presenter depender diretamente do usecase, ele dependerá de uma função que tem a mesma assinatura que se quer chamar no usecase e quando for construir o presenter
//na camada de construção (composition root) será injetado uma função que tem a mesma assinatura dentro do presenter que será o usecase.
final class NextEventRxPresenter {
final Future<NextEvent> Function({required String groupId}) nextEventLoader;
final nextEventSubject = BehaviorSubject<NextEventViewModel>();
final isBusySubject = BehaviorSubject<bool>();

Stream<NextEventViewModel> get nextEventStream => nextEventSubject.stream;
Stream<bool> get isBusyStream => isBusySubject.stream;

NextEventRxPresenter({required this.nextEventLoader});

  Future<void> loadNextEvent({required String groupId, bool isReload = false}) async {
    try {
      if (isReload) isBusySubject.add(true);
      final event = await nextEventLoader(groupId: groupId);
      nextEventSubject.add(_mapEvent(event));
    } catch (error) {
      nextEventSubject.addError(error);
    } finally {
      if (isReload) isBusySubject.add(false);
    }
  }

  NextEventViewModel _mapEvent(NextEvent event) => NextEventViewModel(
      doubt: event.players
          .where((player) => player.confirmationDate == null)
          .sortedBy((player) => player.name)
          .map(_mapPlayer)
          .toList(),
      out: event.players
          .where((player) => player.confirmationDate != null && player.isConfirmed == false)
          .sortedBy((player) => player.confirmationDate!)
          .map(_mapPlayer)
          .toList(),
        goalkeepers: event.players
          .where((player) => player.confirmationDate != null && player.isConfirmed == true && player.position == 'goalkeeper')
          .sortedBy((player) => player.confirmationDate!)
          .map(_mapPlayer)
          .toList(),
  );

  NextEventPlayerViewModel _mapPlayer(NextEventPlayer player) =>
      NextEventPlayerViewModel(
        name: player.name,
        initials: player.initials,
        photo: player.photo,
        position: player.position,
        isConfirmed: player.confirmationDate == null ? null : false,
      );
}

final class NextEventLoaderSpy {
    int callCount = 0;
    String? groupId;
    Error? error;
    //Foi colocado um valor padrão, vazendo com que os testes anteriores não fossem quebrados
    NextEvent output = NextEvent(groupName: anyString(), date: anyDate(), players: []);

  void simulatePlayers(List<NextEventPlayer> players) => output = NextEvent(groupName: anyString(), date: anyDate(), players: players);


    Future<NextEvent> call({required String groupId}) async {
        callCount ++;
        this.groupId = groupId;
        if (error != null) throw error!;
        return output;
    }
}

void main(){
    late NextEventLoaderSpy nextEventLoader;
    late String groupId;
    late NextEventRxPresenter sut;

    setUp((){
        nextEventLoader = NextEventLoaderSpy();
        groupId = anyString();
        sut = NextEventRxPresenter(nextEventLoader: nextEventLoader.call);
    });


test('should get event data', () async {
    await sut.loadNextEvent(groupId: groupId);
    expect(nextEventLoader.callCount, 1);
    expect(nextEventLoader.groupId, groupId);
});

test('should emit correct events on reload with error', () async {
    //:Quando faz-se um teste de uma stream, a ordem convencial de testes acaba mundando para a seguinte forma: Arrange -> Assert -> Action
    nextEventLoader.error = Error();
    sut.nextEventStream.listen(null, onError: (error){
        expect(error, nextEventLoader.error);
        //Foi feito um teste invalido com o seguinte assert -> expect(error, ''); A finalidade foi esperar que o teste não passasse com um erro só para
        //garantir que o expect estava sendo executado dentro dessa closure.
    });
    await sut.loadNextEvent(groupId: groupId, isReload: true);
});

test('should emit correct events on reload with error', () async {
    //:Quando faz-se um teste de uma stream, a ordem convencial de testes acaba mundando para a seguinte forma: Arrange -> Assert -> Action
    nextEventLoader.error = Error();
    //Adicionei o teste anterior que faz a mesma coisa que esse como pode ser feito da maneira tradicional de maneira menos verbosa (syntactic sugar).
    expectLater(sut.nextEventStream, emitsError(nextEventLoader.error));
    //Garante que os valores emitidos estejam em uma determinada ordem
    expectLater(sut.isBusyStream, emitsInOrder([true, false]));
    await sut.loadNextEvent(groupId: groupId, isReload: true);
  });

test('should emit correct events on load with error', () async {
    nextEventLoader.error = Error();
    expectLater(sut.nextEventStream, emitsError(nextEventLoader.error));
    //Ao colocar o neverCalled no listen, sera gerado uma falha no teste
    //neverCalled Returns a function that causes the test to fail if it's called.
    sut.isBusyStream.listen(neverCalled);
    await sut.loadNextEvent(groupId: groupId);
  });

  test('should emit correct events on reload with success', () async {
    expectLater(sut.isBusyStream, emitsInOrder([true, false]));
    expectLater(sut.nextEventStream, emits(const TypeMatcher<NextEventViewModel>()));
    await sut.loadNextEvent(groupId: groupId, isReload: true);
  });

  test('should emit correct events on load with success', () async {
    sut.isBusyStream.listen(neverCalled);
    expectLater(sut.nextEventStream, emits(const TypeMatcher<NextEventViewModel>()));
    await sut.loadNextEvent(groupId: groupId);
  });

  test('should build doubt list sorted by name', () async {
    nextEventLoader.simulatePlayers ([
        NextEventPlayer(id: anyString(), name: 'D', isConfirmed: anyBool()),
        NextEventPlayer(id: anyString(), name: 'C', isConfirmed: anyBool()),
        NextEventPlayer(id: anyString(), name: 'A', isConfirmed: anyBool()),
        NextEventPlayer(id: anyString(), name: 'B', isConfirmed: anyBool(), confirmationDate: anyDate())
    ]);
    sut.nextEventStream.listen((event){
        expect(event.doubt.length, 3);
        expect(event.doubt[0].name, 'A');
        expect(event.doubt[1].name, 'C');
        expect(event.doubt[2].name, 'D');
    });
    await sut.loadNextEvent(groupId: groupId);
  });

  test('should map doubt player', () async {
    final player = NextEventPlayer(id: anyString(), name: anyString(), isConfirmed: anyBool(), photo: anyString(), position: anyString());
    nextEventLoader.simulatePlayers ([player]);
    sut.nextEventStream.listen((event){
        expect(event.doubt[0].name, player.name);
        expect(event.doubt[0].initials, player.initials);
        expect(event.doubt[0].isConfirmed, null);
        expect(event.doubt[0].photo, player.photo);
        expect(event.doubt[0].position, player.position);
    });
    await sut.loadNextEvent(groupId: groupId);
  });

  test('should build out list sorted by confirmation date', () async {
    nextEventLoader.simulatePlayers ([
        NextEventPlayer(id: anyString(), name: 'D', isConfirmed: false, confirmationDate: DateTime(2025, 1, 1, 10)),
        NextEventPlayer(id: anyString(), name: 'C', isConfirmed: anyBool()),
        NextEventPlayer(id: anyString(), name: 'E', isConfirmed: true, confirmationDate: DateTime(2025, 1, 1, 11)),
        NextEventPlayer(id: anyString(), name: 'A', isConfirmed: false, confirmationDate: DateTime(2025, 1, 1, 11)),
        NextEventPlayer(id: anyString(), name: 'B', isConfirmed: false, confirmationDate: DateTime(2025, 1, 1, 9))
    ]);
    sut.nextEventStream.listen((event){
        expect(event.out.length, 3);
        expect(event.out[0].name, 'B');
        expect(event.out[1].name, 'D');
        expect(event.out[2].name, 'A');
    });
    await sut.loadNextEvent(groupId: groupId);
  });

  test('should map out player', () async {
    final player = NextEventPlayer(id: anyString(), name: anyString(), isConfirmed: false, photo: anyString(), position: anyString(), confirmationDate: anyDate());
    nextEventLoader.simulatePlayers ([player]);
    sut.nextEventStream.listen((event){
        expect(event.out[0].name, player.name);
        expect(event.out[0].initials, player.initials);
        expect(event.out[0].isConfirmed, player.isConfirmed);
        expect(event.out[0].photo, player.photo);
        expect(event.out[0].position, player.position);
    });
    await sut.loadNextEvent(groupId: groupId);
  });

  test('should build goalkeepers list sorted by confirmation date', () async {
    nextEventLoader.simulatePlayers ([
        NextEventPlayer(id: anyString(), name: 'D', isConfirmed: true, confirmationDate: DateTime(2025, 1, 1, 10), position: 'goalkeeper'),
        NextEventPlayer(id: anyString(), name: 'C', isConfirmed: anyBool()),
        NextEventPlayer(id: anyString(), name: 'E', isConfirmed: true, confirmationDate: DateTime(2025, 1, 1, 11), position: 'defender'),
        NextEventPlayer(id: anyString(), name: 'A', isConfirmed: false, confirmationDate: DateTime(2025, 1, 1, 9)),
        NextEventPlayer(id: anyString(), name: 'B', isConfirmed: true, confirmationDate: DateTime(2025, 1, 1, 12)),
        NextEventPlayer(id: anyString(), name: 'F', isConfirmed: true, confirmationDate: DateTime(2025, 1, 1, 8), position: 'goalkeeper')
    ]);
    sut.nextEventStream.listen((event){
        expect(event.goalkeepers.length, 2);
        expect(event.goalkeepers[0].name, 'F');
        expect(event.goalkeepers[1].name, 'D');
    });
    await sut.loadNextEvent(groupId: groupId);
  });
}
