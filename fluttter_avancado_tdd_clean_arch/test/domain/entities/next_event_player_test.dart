import 'package:flutter_test/flutter_test.dart';

class NextEventPlayer {
  final String id;
  final String name;
  late final String initials;
  final String? photo;
  final String? position;
  final bool isConfirmed;
  final DateTime? confirmationDate;

  NextEventPlayer({
    required this.id,
    required this.name,
    this.photo,
    this.position,
    required this.isConfirmed,
    this.confirmationDate,
  }) {
    initials = _getInitials();
  }

  String _getInitials() {
    final names = name.toUpperCase().split(' ');
    final firstChar = names.first.split('').firstOrNull ?? '-';
    final lastChar = names.last.split('').elementAtOrNull(names.length == 1 ? 1 : 0 ) ?? '';
    return '$firstChar$lastChar';
  }
}

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
}
