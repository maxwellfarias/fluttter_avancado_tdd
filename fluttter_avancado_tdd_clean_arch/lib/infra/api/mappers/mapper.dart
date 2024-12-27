import 'package:fluttter_avancado_tdd_clean_arch/infra/types/json.dart';

abstract base class Mapper<Entity> {
  List<Entity> toList(JsonArr arr) => arr.map(toObject).toList();

  Entity toObject(Json json);
}
