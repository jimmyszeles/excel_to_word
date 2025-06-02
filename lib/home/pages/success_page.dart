import 'dart:io';

import 'package:flutter/material.dart';
import 'package:process_run/process_run.dart';
import 'package:provider/provider.dart';

import '../../core/providers/file_provider.dart';

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final fileProvider = context.read<FileProvider>();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.green, size: 100),
            const SizedBox(height: 20),
            const Text('Translation Successful!', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (fileProvider.outputPath != null) {
                  if (Platform.isWindows) {
                    await Shell().run('start "" "${fileProvider.outputPath!}"');
                  }
                }
              },
              child: const Text('Open File'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                fileProvider.clear();
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
