import 'package:fluttter_avancado_tdd_clean_arch/infra/types/json.dart';

// abstract base class Mapper<Entity> {
//   List<Entity> toList(dynamic arr) => arr.map<Entity>(toObject).toList();

//   Entity toObject(dynamic json);
// }

abstract interface class DtoMapper<Dto> {
    Dto toDto(Json json);
}

abstract interface class JsonMapper<Dto> {
    Json toJson(Dto dto);
}

abstract interface class Mapper<Dto> implements DtoMapper<Dto>, JsonMapper<Dto>{}

mixin DtoListMapper<Dto> implements DtoMapper<Dto> {
    List<Dto> toDtoList(dynamic arr) => arr.map<Dto>(toDto).toList();
}

mixin JsonArrMapper<Dto> implements JsonMapper<Dto>{
    JsonArr toJsonArr(List<Dto> list) => list.map(toJson).toList();
}

abstract base class ListMapper<Dto> with DtoListMapper<Dto>, JsonArrMapper<Dto> {}

/*
A herança multipla no dart é feito com o auxilio do mixin. A classe que faz uso do Mixin recebe as propriedades de metodos dele.
 */

/*
//: No nosso caso valia a pena usar a nossa entidade na camada de infra, devido a nossa entidade ser uma entidade burra, anémica, sem regra de negócio. No nosso caso, ela tem uma regra
de negócio, mas é uma regra interna que não precisa ser executada fora do domínio, ou seja, não tem chance, por exemplo, na camada de infra executar uma regra de negócio. Na prática a
minha entidade é como se fosse um DTO.

Abaixo estava a classe base que estava sendo usada, o problema é que nem todos os mappers usam o método toList, como é o caso do NextEventMapper que converte o Json em NextEvent. A fim de
evitar que uma classe herde um método que não será utilizado, foram criados 3 interfaces a fim de que as classes que fazem os mappers utilizem somente as funcionalidades que realmente
precisem.

abstract base class Mapper<Entity> {
    List<Entity> toList(dynamic arr) => arr.map<Entity>(toObject).toList();

    Entity toObject(dynamic json);
    }
*/