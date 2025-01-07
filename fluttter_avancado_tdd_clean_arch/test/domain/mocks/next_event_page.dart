import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/next_event.dart';
import 'package:fluttter_avancado_tdd_clean_arch/domain/repositories/load_next_event_repo.dart';

class LoadNextEventSpyRepository implements LoadNextEventRepository {
  //As propriedaes callsCount e groupId sao exclusivas para realizar os testes e nao irao para o codigo em producao
  var callsCount = 0;
  String? groupId;
  NextEvent? output;
  Error? error;

  @override
  Future<NextEvent> loadNextEvent({required String groupId}) async {
    this.groupId = groupId;
    callsCount++;
    if (error != null) throw error!;
    return output!;
  }
}