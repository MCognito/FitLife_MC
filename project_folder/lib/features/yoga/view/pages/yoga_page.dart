import 'package:flutter/material.dart';

class YogaPage extends StatelessWidget {
  const YogaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yoga'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.self_improvement, size: 100),
            SizedBox(height: 16),
            Text(
              'Yoga Sessions',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 8),
            Text(
              'Coming Soon',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
