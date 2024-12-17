import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/next_event.dart';
import 'package:fluttter_avancado_tdd_clean_arch/domain/repositories/load_next_event_repo.dart';

class NextEventLoader {
  final LoadNextEventRepository repo;
  NextEventLoader({required this.repo});

  Future<NextEvent> call({required String groupId}) async {
    return repo.loadNextEvent(groupId: groupId);
  }
}
