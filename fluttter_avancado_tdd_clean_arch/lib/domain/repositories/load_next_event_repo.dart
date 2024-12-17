import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/next_event.dart';

abstract class LoadNextEventRepository {
  Future<NextEvent> loadNextEvent({required String groupId});
}
