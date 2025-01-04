//A viewModel deve conter somente as informações que são exigidas na view

import 'package:flutter/material.dart';
import 'package:fluttter_avancado_tdd_clean_arch/presentation/presenters/next_event_presenter.dart';
import 'package:fluttter_avancado_tdd_clean_arch/ui/components/player_photo.dart';
import 'package:fluttter_avancado_tdd_clean_arch/ui/components/player_position.dart';
import 'package:fluttter_avancado_tdd_clean_arch/ui/components/player_status.dart';

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

  Widget buildErrorLayout() => Column(
        children: [
          const Text('Algo errado aconteceu, tente novamente.'),
          ElevatedButton(
            onPressed: () => widget.presenter.reloadNextEvent(groupId: widget.groupId),
            child: const Text('Recarregar'),
          )
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<NextEventViewModel>(
          stream: widget.presenter.nextEventStream,
          //Toda vez que a stream receber dados, esses dados ficarão disponíveis no snapshot
          builder: (context, snapshot) {
            //Enquanto não estiver chegando os dados, o CircularProgressIndicator ficará disponível. Depois que o stream recebe um dado pela primeira vez, o estado da conexão
            //permanece ativo fazendo com que caso seja feita uma nova chamada, o CircularProgressIndicator não será exibido naturalmente. Se fosse forçar o ConnectionState
            //para um estado que ativasse o CircularProgressIndicator, isso iria deixar a tela com um efeito estranho com uma transição que pisca.
            if (snapshot.connectionState != ConnectionState.active) return const CircularProgressIndicator();
            if (snapshot.hasError) return buildErrorLayout();
            final viewModel = snapshot.data!;
            return ListView(
              children: [
                if (viewModel.goalkeepers.isNotEmpty)
                  ListSection(
                      title: 'DENTRO - GOLEIROS', items: viewModel.goalkeepers),
                if (viewModel.players.isNotEmpty)
                  ListSection(
                      title: 'DENTRO - JOGADORES', items: viewModel.players),
                if (viewModel.out.isNotEmpty)
                  ListSection(title: 'FORA', items: viewModel.out),
                if (viewModel.doubt.isNotEmpty)
                  ListSection(title: 'DÚVIDA', items: viewModel.doubt),
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
        ...items.map((player) => Row(
              children: [
                PlayerPhoto(
                  initials: player.initials,
                  photo: player.photo,
                ),
                Text(player.name),
                PlayerPosition(position: player.position),
                PlayerStatus(isConfirmed: player.isConfirmed),
              ],
            ))
      ],
    );
  }
}
