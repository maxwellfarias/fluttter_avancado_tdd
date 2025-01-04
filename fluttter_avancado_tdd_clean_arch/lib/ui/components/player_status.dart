import 'package:flutter/material.dart';

final class PlayerStatus extends StatelessWidget {
  final bool? isConfirmed;

  Color getColor() => switch (isConfirmed) {
        true => Colors.teal,
        false => Colors.pink,
        null => Colors.blueGrey
      };

  const PlayerStatus({super.key, this.isConfirmed});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 16,
      width: 16,
      decoration: BoxDecoration(shape: BoxShape.circle, color: getColor()),
    );
  }
}
