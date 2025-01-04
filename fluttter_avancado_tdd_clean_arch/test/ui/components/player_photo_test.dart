import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttter_avancado_tdd_clean_arch/ui/components/player_photo.dart';
import 'package:network_image_mock/network_image_mock.dart';


void main() {
  testWidgets('should present initials when there is no photo', (tester) async {
    await tester.pumpWidget(
        const MaterialApp(home: PlayerPhoto(initials: 'RO', photo: null)));
    expect(find.text('RO'), findsOne);
  });
  testWidgets('should hide initials when there is photo', (tester) async {
    //:mockNetworkImagesFor permite que sejam realizados testes para urls de imagens, caso constrário seria lançado um erro
    mockNetworkImagesFor(() async {
      await tester.pumpWidget(const MaterialApp(
          home: PlayerPhoto(initials: 'RO', photo: 'http://any-url.com')));
      expect(find.text('RO'), findsNothing);
    });
  });
}