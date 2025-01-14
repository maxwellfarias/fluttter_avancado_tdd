import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/next_event.dart';

import '../../mocks/fakes.dart';

//Por ser um mock de uma implementação genérica (tanto faz se está usando um cache ou API), uma pasta de mock em um ambiente mais genérico foi criado
final class LoadNextEventRepositorySpy {
    String? groupId;
    int callsCount = 0;
    NextEvent output = NextEvent(groupName: anyString(), date: anyDate(), players: []);
    Object? error;

    Future<NextEvent> loadNextEvent({required String groupId}) async {
        this.groupId = groupId;
        callsCount++;
        if (error != null) throw error!;
        return output;
    }
}