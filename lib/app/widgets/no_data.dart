import 'package:flutter/material.dart';

class NoDataWidget extends StatelessWidget {
  const NoDataWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/icons/empty-folder.png',
          height: 200,
          width: 150,
        ),
        const SizedBox(
          height: 20,
        ),
        const Text(
          'No data added yet',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        )
      ],
    );
  }
}
