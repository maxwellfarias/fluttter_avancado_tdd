import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/next_event_player.dart';

import 'package:flutter_test/flutter_test.dart';

void main() {
  String initialsOf(String name) =>
      NextEventPlayer(id: '', name: name, isConfirmed: true).initials;

  test('shoul return the first letter of the first and last names', () {
    expect(initialsOf("Maxwell Farias"), 'MF');
    expect(initialsOf("Daniel Oliveira"), 'DO');
    expect(initialsOf("Danielle Rosa Calheiros Farias"), 'DF');
  });

  test('shoul return the first letter of the first name', () {
    expect(initialsOf("Maxwel"), 'MA');
    expect(initialsOf("R"), 'R');
  });

  test('shoul return to uppercase', () {
    expect(initialsOf("danielle"), 'DA');
    expect(initialsOf("eva calheiros"), 'EC');
    expect(initialsOf("r"), 'R');
  });

  test('shoul return "-" when name is empty', () {
    expect(initialsOf(''), '-');
  });

  test('shoul ignore extra whitespaces', () {
    expect(initialsOf('   Maxwell Farias '), 'MF');
    expect(initialsOf('   Maxwell     Farias '), 'MF');
    expect(initialsOf('    '), '-');
  });
}
