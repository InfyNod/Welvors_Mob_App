import 'package:flutter/material.dart';

class MarriageScreen extends StatelessWidget {
  const MarriageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 80.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_outline,
                size: 60,
                color: Colors.pink.shade200,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Marriage',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming Soon!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
