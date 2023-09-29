import 'package:flutter/material.dart';

class BackScreenButton extends StatelessWidget {
  BackScreenButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      onPressed: () => Navigator.of(context).pop(),
      icon: const Icon(
        Icons.keyboard_arrow_left_rounded,
      ),
    );
  }
}
