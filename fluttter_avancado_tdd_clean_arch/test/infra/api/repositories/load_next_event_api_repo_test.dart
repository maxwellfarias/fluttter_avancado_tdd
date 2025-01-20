import 'package:flutter_test/flutter_test.dart';
import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/next_event.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/api/repositories/load_next_event_api_repo.dart';
import '../../../mocks/fakes.dart';
import '../../../mocks/mapper_spy.dart';
import '../mocks/http_get_client_spy.dart';

void main() {
    //:Os nomes das propriedades que sao usadas nos testes são variáveis de controle.
  late MapperSpy<NextEvent> mapper;
  late String groupId;
  late String url;
  late HttpGetClientSpy httpClient;
  late LoadNextEventApiRepository sut;

  setUp(() {
    mapper = MapperSpy(toDtoOutput: anyNextEvent());
    groupId = anyString();
    url = anyString();
    httpClient = HttpGetClientSpy();
    sut = LoadNextEventApiRepository(httpClient: httpClient, url: url, mapper: mapper);
  });

  test('should call httpClient with correct input', () async {
    await sut.loadNextEvent(groupId: groupId);
    expect(httpClient.url, url);
    expect(httpClient.params, {"groupId": groupId});
    expect(httpClient.callsCount, 1);
  });

  test('should return next event on success', () async {
    final event = await sut.loadNextEvent(groupId: groupId);
    expect(mapper.toDtoInput, httpClient.response);
    expect(mapper.toDtoCallsCount, 1);
    expect(event, mapper.toDtoOutput);
  });

  test('should rethrow on error', () async {
    final error = Error();
    httpClient.error = error;
    final future = sut.loadNextEvent(groupId: groupId);
    expect(future, throwsA(error));
  });
}
