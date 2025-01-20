//TESTE DE INTEGRACAO
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/api/adapters/http_adapter.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/api/repositories/load_next_event_api_repo.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/cache/adapters/cache_manager_adapter.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/cache/repositories/load_next_event_cache_repo.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/mappers/next_event_mapper.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/repositories/load_next_event_from_api_with_cache_fallback_repo.dart';
import 'package:fluttter_avancado_tdd_clean_arch/main/factories/infra/mappers/next_event_mapper_factory.dart';
import 'package:fluttter_avancado_tdd_clean_arch/presentation/rx/next_event_rx_presenter.dart';
import 'package:fluttter_avancado_tdd_clean_arch/ui/pages/next_event_page.dart';

import '../infra/api/mocks/client_spy.dart';
import '../infra/cache/mock/cache_manager_spy.dart';
import '../mocks/fakes.dart';

void main() {

  late ClientSpy client;
  late CacheManagerClientSpy cacheManager;
  late String key;
  late HttpAdapter httpClient;
  late CacheManagerAdapter cacheClient;
  late LoadNextEventApiRepository apiRepo;
  late LoadNextEventCacheRepository cacheRepo;
  late LoadNextEventFromApiWithCacheFallbackRepository repo;
  late NextEventMapper mapper;
  late NextEventRxPresenter presenter;
  late Widget sut;
  late String responseJson;

    setUp(() {
    key = anyString();
    client = ClientSpy();
    httpClient = HttpAdapter(client: client);
    mapper = makeNextEventMapper();
    apiRepo = LoadNextEventApiRepository(
      httpClient: httpClient,
      url: anyString(),
      mapper: mapper,
    );
    cacheManager = CacheManagerClientSpy();
    cacheClient = CacheManagerAdapter(client: cacheManager);
    cacheRepo = LoadNextEventCacheRepository(
        cacheClient: cacheClient, key: key, mapper: mapper);
        repo = LoadNextEventFromApiWithCacheFallbackRepository(
      cacheClient: cacheClient,
      key: key,
      loadNextEventFromApi: apiRepo.loadNextEvent,
      loadNextEventFromCache: cacheRepo.loadNextEvent,
      mappper: mapper,
    );
    presenter = NextEventRxPresenter(nextEventLoader: repo.loadNextEvent);
     sut = MaterialApp(
      home: NextEventPage(presenter: presenter, groupId: anyString()),
    );

    responseJson = '''
{
    "id": "1",
    "groupName": "Pelada Chega+",
    "date": "2024-01-11T11:10:00.000Z",
    "players": [{
      "id": "1",
      "name": "Cristiano Ronaldo",
      "position": "forward",
      "isConfirmed": true,
      "confirmationDate": "2024-01-10T11:07:00.000Z"
    }, {
      "id": "2",
      "name": "Lionel Messi",
      "position": "midfielder",
      "isConfirmed": true,
      "confirmationDate": "2024-01-10T11:08:00.000Z"
    }, {
      "id": "3",
      "name": "Dida",
      "position": "goalkeeper",
      "isConfirmed": true,
      "confirmationDate": "2024-01-10T09:10:00.000Z"
    }, {
      "id": "4",
      "name": "Romario",
      "position": "forward",
      "isConfirmed": true,
      "confirmationDate": "2024-01-10T11:10:00.000Z"
    }, {
      "id": "5",
      "name": "Claudio Gamarra",
      "position": "defender",
      "isConfirmed": false,
      "confirmationDate": "2024-01-10T13:10:00.000Z"
    }, {
      "id": "6",
      "name": "Diego Forlan",
      "position": "defender",
      "isConfirmed": false,
      "confirmationDate": "2024-01-10T14:10:00.000Z"
    }, {
      "id": "7",
      "name": "Zé Ninguém",
      "isConfirmed": false
    }, {
      "id": "8",
      "name": "Rodrigo Manguinho",
      "isConfirmed": false
    }, {
      "id": "9",
      "name": "Claudio Taffarel",
      "position": "goalkeeper",
      "isConfirmed": true,
      "confirmationDate": "2024-01-10T09:15:00.000Z"
    }]
  }
''';
  });
  testWidgets('should present api data', (tester) async {
    client.responseJson = responseJson;
    await tester.pumpWidget(sut);
    await tester.pump();
      /*
    //:De maneira prática, apenas comparando o primeiro nome aparecendo na tela, já seria o suficiente que o teste e2e está funcionando, o último teste
    não estava mais passando porque para encontrar o nome Claudio Gamarra seria necessário scrollar a tela a fim de encontrá-lo e é o que será feito
    expect(find.text('Cristiano Ronaldo'), findsOneWidget);
    expect(find.text('Lionel Messi'), findsOneWidget);
    expect(find.text('Claudio Gamarra'), findsOneWidget);
     */

    //ensureVisible faz o scroll para encontrar o elemento informado
    await tester.ensureVisible(find.text('Cristiano Ronaldo', skipOffstage: false));
    //atualiza a tela
    await tester.pump();
    expect(find.text('Cristiano Ronaldo'), findsOneWidget);

    await tester.ensureVisible(find.text('Lionel Messi', skipOffstage: false));
    await tester.pump();
    expect(find.text('Lionel Messi'), findsOneWidget);

    await tester.ensureVisible(find.text('Claudio Gamarra', skipOffstage: false));
    await tester.pump();
    expect(find.text('Claudio Gamarra'), findsOneWidget);
  });

  testWidgets('should present cache data', (tester) async {
    client.simulateServerError();
    cacheManager.file.simulateResponse(json: responseJson);
    await tester.pumpWidget(sut);
    await tester.pump();
    await tester.ensureVisible(find.text('Cristiano Ronaldo', skipOffstage: false));
    await tester.pump();
    expect(find.text('Cristiano Ronaldo'), findsOneWidget);
    await tester.ensureVisible(find.text('Lionel Messi', skipOffstage: false));
    await tester.pump();
    expect(find.text('Lionel Messi'), findsOneWidget);
    await tester.ensureVisible(find.text('Claudio Gamarra', skipOffstage: false));
    await tester.pump();
    expect(find.text('Claudio Gamarra'), findsOneWidget);
  });

  testWidgets('should present error message', (tester) async {
    client.simulateServerError();
    cacheManager.file.simulateInvalidResponse();
    await tester.pumpWidget(sut);
    await tester.pump();
    await tester.ensureVisible(find.text('Algo errado aconteceu, tente novamente.', skipOffstage: false));
    await tester.pump();
    expect(find.text('Algo errado aconteceu, tente novamente.'), findsOneWidget);
  });
}
