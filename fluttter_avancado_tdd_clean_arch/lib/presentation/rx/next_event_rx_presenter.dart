//No usecase não faz sentido se ter várias implementações dele porque o usecase já é genérico, ele já está abstraído de implementações. O que será feito é que
//ao invés do presenter depender diretamente do usecase, ele dependerá de uma função que tem a mesma assinatura que se quer chamar no usecase e quando for construir o presenter
//na camada de construção (composition root) será injetado uma função que tem a mesma assinatura dentro do presenter que será o repository.
import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/next_event.dart';
import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/next_event_player.dart';
import 'package:fluttter_avancado_tdd_clean_arch/presentation/presenters/next_event_presenter.dart';

import 'package:rxdart/subjects.dart';
import 'package:dartx/dartx.dart';
final class NextEventRxPresenter implements NextEventPresenter {
final Future<NextEvent> Function({required String groupId}) nextEventLoader;
final nextEventSubject = BehaviorSubject<NextEventViewModel>();
final isBusySubject = BehaviorSubject<bool>();

  @override
  Stream<NextEventViewModel> get nextEventStream => nextEventSubject.stream;

  @override
  Stream<bool> get isBusyStream => isBusySubject.stream;

  NextEventRxPresenter({required this.nextEventLoader});

  @override
  void dispose() {
    nextEventSubject.close();
    isBusySubject.close();
  }

  @override
  Future<void> loadNextEvent(
      {required String groupId, bool isReload = false}) async {
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
      players: event.players
          .where((player) => player.confirmationDate != null && player.isConfirmed == true && player.position != 'goalkeeper')
          .sortedBy((player) => player.confirmationDate!)
          .map(_mapPlayer)
          .toList());

  NextEventPlayerViewModel _mapPlayer(NextEventPlayer player) =>
      NextEventPlayerViewModel(
        name: player.name,
        initials: player.initials,
        photo: player.photo,
        position: player.position,
        isConfirmed: player.confirmationDate == null ? null : player.isConfirmed,
      );
}