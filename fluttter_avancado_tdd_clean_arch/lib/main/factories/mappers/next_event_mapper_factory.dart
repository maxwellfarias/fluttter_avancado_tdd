import 'package:fluttter_avancado_tdd_clean_arch/infra/mappers/next_event_mapper.dart';
import 'package:fluttter_avancado_tdd_clean_arch/main/factories/mappers/next_event_player_mapper_factory.dart';

NextEventMapper makeNextEventMapper() => NextEventMapper(playerMapper: makeNextEventPlayerMapper());