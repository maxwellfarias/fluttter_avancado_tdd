// ignore: library_annotations
//:Por padrão, quando se faz o teste de uma stream, o teste irá ficar aguardando por 30 segundos o expect se cumprir, para evitar esse tempo longo foi adicionado
//a flag timeout. Ao ser declarado dessa forma, todos os testes que tiveremc como parâmetro timeout, terão a duração de 1 segundo.
@Timeout(Duration(seconds: 1))


import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart/subjects.dart';

import '../../helpers/fakes.dart';

//No usecase não faz sentido se ter várias implementações dele porque o usecase já é genérico, ele já está abstraído de implementações. O que será feito é que
//ao invés do presenter depender diretamente do usecase, ele dependerá de uma função que tem a mesma assinatura que se quer chamar no usecase e quando for construir o presenter
//na camada de construção (composition root) será injetado uma função que tem a mesma assinatura dentro do presenter que será o usecase.
final class NextEventRxPresenter {
final Future<void> Function({required String groupId}) nextEventLoader;
final nextEventSubject = BehaviorSubject();
final isBusySubject = BehaviorSubject<bool>();

Stream get nextEventStream => nextEventSubject.stream;
Stream<bool> get isBusyStream => isBusySubject.stream;

NextEventRxPresenter({required this.nextEventLoader});

  Future<void> loadNextEvent({required String groupId, bool isReload = false}) async {
    try {
      if (isReload) isBusySubject.add(true);
      await nextEventLoader(groupId: groupId);
    } catch (error) {
      nextEventSubject.addError(error);
    } finally {
      if (isReload) isBusySubject.add(false);
    }
  }
}

final class NextEventLoaderSpy {
    int callCount = 0;
    String? groupId;
    Error? error;

    Future<void> call({required String groupId}) async {
        callCount ++;
        this.groupId = groupId;
        if (error != null) throw error!;
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
    await sut.loadNextEvent(groupId: groupId, isReload: true);
  });
}
