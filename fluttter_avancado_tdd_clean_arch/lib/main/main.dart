import 'package:flutter/material.dart';
import 'package:fluttter_avancado_tdd_clean_arch/main/factories/ui/pages/next_event_page_factory.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.dark);
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: colorScheme,
        dividerTheme: const DividerThemeData(space: 0),
        appBarTheme: AppBarTheme(color: colorScheme.primaryContainer),
        useMaterial3: true,
      ),
      home: makeNextEventPage(),
    );
  }
}
/*
//:O hotReload não reconstroi o state, mas apenas reconstroi a tela o chamando novamente o metodo build. Dessa forma, os metodos de que fazer uma chamada no initState() para recuperar os
dados no servidor não seriam chamados. Isso faz com que após a reconstrução no build, o snapshot.connectionState fica no estado de awaiting, mostrando dessa forma o CircularProgressIndicator
para sempre, pois como a chamada a API não foi feita, os dados não retornarão e o snapshot.connectionState não mudará o seu estado.
 */