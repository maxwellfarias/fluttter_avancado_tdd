import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

final class NextEventPage extends StatefulWidget {
  final NextEventPresenter presenter;
  final String groupId;
  const NextEventPage({required this.presenter, super.key, required this.groupId});

  @override
  State<NextEventPage> createState() => _NextEventPageState();
}

class _NextEventPageState extends State<NextEventPage> {
  @override
  void initState() {
    widget.presenter.loadNextEvent(groupId: widget.groupId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}

abstract interface class NextEventPresenter {
  void loadNextEvent({required String groupId});
}

final class NextEventPresenterSpy implements NextEventPresenter {
  int loadCallsCount = 0;
  String? groupId;

  @override
  void loadNextEvent({required String groupId}) {
    loadCallsCount++;
    this.groupId = groupId;
  }
}

void main() {
  testWidgets('should load event data on page init', (tester) async {
    final presenter = NextEventPresenterSpy();
    final groupId = anyString();
    //Os widgets que estão sendon testados precisam estar dentro de um material app
    final sut = MaterialApp(home: NextEventPage(presenter: presenter, groupId: groupId));
    //Constroi o widget como emulando a aplicação dele em uma tela.

    await tester.pumpWidget(sut);
    expect(presenter.loadCallsCount, 1);
    expect(presenter.groupId, groupId);
  });
}
