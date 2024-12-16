import 'package:flutter_test/flutter_test.dart';

class NextEventPlayer {
  final String id;
  final String name;
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
  });

  String getInitials() {
    final names = name.split(' ');
    return '${names[0][0]}${names[1][0]}';
  }
}

void main() {
  test('shoul return the first letter of the first and last names', () {
    final player = NextEventPlayer(
      id: '',
      name: 'Maxwell Farias',
      isConfirmed: true,
    );
    expect(player.getInitials(), 'MF');
  });
}
