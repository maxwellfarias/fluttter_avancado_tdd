//A viewModel deve conter somente as informações que são exigidas na view

import 'dart:async';

import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
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
  late final StreamSubscription<bool> _isBusySubscription;

  @override
  void initState() {
    widget.presenter.loadNextEvent(groupId: widget.groupId);
    //:O listener permanece ativo porque é gerenciado pela StreamSubscription, que não depende diretamente do ciclo de vida do widget. Enquanto você não cancela
    //manualmente a StreamSubscription (chamando .cancel()), ela continua ativa. Para evitar problemas de vazamento, cancele o listener no método dispose.
    _isBusySubscription = widget.presenter.isBusyStream.listen((isBusy)=> isBusy ? showLoading() : hideLoading());
    super.initState();
  }

  @override
  void dispose() {
    _isBusySubscription.cancel();
     widget.presenter.dispose();
    super.dispose();
  }
//:O hotReload não reconstroi o state, mas apenas reconstroi a tela o chamando novamente o metodo build. Dessa forma, os metodos de que fazer uma chamada no initState()
//para recuperar os dados no servidor não seriam chamados. Isso faz com que após a reconstrução no build, o snapshot.connectionState fica no estado de awaiting, mostrando dessa
//forma o CircularProgressIndicator para sempre, pois como a chamada a API não foi feita, os dados não retornarão e o snapshot.connectionState não mudará o seu estado.
//O didUpdateWidget é chamado quando o build é recarregado no hotReload, fazendo novamente a chamada API. Isso agiliza a construção do layout da tela, mas precisa ser retirado
//antes de commitar.
  void showLoading() => showDialog(
        context: context,
        builder: (context) => const SimpleDialog(
        children: [
          Column(
            spacing: 16,
            children: [
              Text('Aguarde...'),
              CircularProgressIndicator(),
            ],
          )
        ]),
      );
//maybePop realizar o pop quando for possivel
  void hideLoading() => Navigator.of(context).maybePop();

  Widget buildErrorLayout() => Center(
    child: Column(
        spacing: 16,
        mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Algo errado aconteceu, tente novamente.', style: context.textStyles.bodyLarge,),
            ElevatedButton(
              onPressed: () => widget.presenter.loadNextEvent(groupId: widget.groupId, isReload: true),
              child: Text('RECARREGAR', style: context.textStyles.labelLarge,),
            )
          ],
        ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Próximo Jogo'),
      ),
      body: StreamBuilder<NextEventViewModel>(
          stream: widget.presenter.nextEventStream,
          //Toda vez que a stream receber dados, esses dados ficarão disponíveis no snapshot
          builder: (context, snapshot) {
            //Enquanto não estiver chegando os dados, o CircularProgressIndicator ficará disponível. Depois que o stream recebe um dado pela primeira vez, o estado da conexão
            //permanece ativo fazendo com que caso seja feita uma nova chamada, o CircularProgressIndicator não será exibido naturalmente. Se fosse forçar o ConnectionState
            //para um estado que ativasse o CircularProgressIndicator, isso iria deixar a tela com um efeito estranho com uma transição que pisca.
            if (snapshot.connectionState != ConnectionState.active) return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError) return buildErrorLayout();
            final viewModel = snapshot.data!;
            return RefreshIndicator(
                onRefresh: () async => widget.presenter.loadNextEvent(groupId: widget.groupId, isReload: true),
              child: ListView(
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
              ),
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
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 32),
          child: Row(
            children: [
              Expanded(
                  child: Text(
                title,
                style: context.textStyles.titleSmall,
              )),
              Text(items.length.toString(),
                  style: context.textStyles.titleSmall),
            ],
          ),
        ),
        const Divider(),
        ...items
            .map((player) => Container(
                color: context.colors.scheme.onSurface.withValues(alpha: 0.03),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      PlayerPhoto(
                        initials: player.initials,
                        photo: player.photo,
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              player.name,
                              style: context.textStyles.labelLarge,
                            ),
                            PlayerPosition(position: player.position),
                          ],
                        ),
                      ),
                      PlayerStatus(isConfirmed: player.isConfirmed),
                    ],
                  ),
                ))
            .separatedBy(const Divider(indent: 82)),
        const Divider()
      ],
    );
  }
}
