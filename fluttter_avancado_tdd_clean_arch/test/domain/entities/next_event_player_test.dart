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
    final names = name.split(' ');
    final firstChar = names.first[0];
    final lastChar = names.last[0];
    return '$firstChar$lastChar';
  }
}

void main() {
  String initialsOf(String name) =>
      NextEventPlayer(id: '', name: name, isConfirmed: true).initials;

  test(
    'shoul return the first letter of the first and last names',
    () {
      expect(initialsOf("Maxwell Farias"), 'MF');
      expect(initialsOf("Daniel Oliveira"), 'DO');
      expect(initialsOf("Danielle Rosa Calheiros Farias"), 'DF');
    },
  );
}
