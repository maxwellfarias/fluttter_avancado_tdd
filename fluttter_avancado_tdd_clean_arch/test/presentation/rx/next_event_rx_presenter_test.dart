
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

//No usecase não faz sentido se ter várias implementações dele porque o usecase já é genérico, ele já está abstraído de implementações. O que será feito é que
//ao invés do presenter depender diretamente do usecase, ele dependerá de uma função que tem a mesma assinatura que se quer chamar no usecase e quando for construir o presenter
//na camada de construção (composition root) será injetado uma função que tem a mesma assinatura dentro do presenter que será o usecase.
final class NextEventRxPresenter {
final Future<void> Function({required String groupId}) nextEventLoader;

  const NextEventRxPresenter({required this.nextEventLoader});

  Future<void> loadNextEvent({required String groupId}) async {
    return nextEventLoader(groupId: groupId);
  }
}

final class NextEventLoaderSpy {
    int callCount = 0;
    String? groupId;

    Future<void> call({required String groupId}) async {
        callCount ++;
        this.groupId = groupId;
    }
}

void main(){
test('should get event data', () async {
    final nextEventLoader = NextEventLoaderSpy();
    final groupId = anyString();
    final sut = NextEventRxPresenter(nextEventLoader: nextEventLoader.call);
    await sut.loadNextEvent(groupId: groupId);
    expect(nextEventLoader.callCount, 1);
    expect(nextEventLoader.groupId, groupId);
});
}