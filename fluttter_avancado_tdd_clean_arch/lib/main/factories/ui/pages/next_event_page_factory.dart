import 'package:flutter/material.dart';
import 'package:fluttter_avancado_tdd_clean_arch/main/factories/infra/repositories/load_next_event_from_api_with_cache_fallback_repo_factory.dart';
import 'package:fluttter_avancado_tdd_clean_arch/presentation/rx/next_event_rx_presenter.dart';
import 'package:fluttter_avancado_tdd_clean_arch/ui/pages/next_event_page.dart';

Widget makeNextEventPage() {
  final repo = makeLoadNextEventFromApiWithCacheFallbackRepository();
  //: Seguindo a lógica, como o presenter não será usado em mais nenhuma página, o construtor dele será adicionado aqui mesmo, não sendo necessário
  //criar uma pasta factory
  final presenter = NextEventRxPresenter(nextEventLoader: repo.loadNextEvent);
  //:Foi adicionado uma lógica no backend para que somente um grupo com este id: 'valid_id' seja válido, apenas para verificar se o backend está rodando corretamente.
  return NextEventPage(presenter: presenter, groupId: 'valid_id');
}