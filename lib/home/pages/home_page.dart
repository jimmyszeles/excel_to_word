import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/file_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final fileProvider = context.watch<FileProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Select Files')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['xlsx']);
                if (result != null) {
                  fileProvider.setExcelPath(result.files.single.path!);
                }
              },
              child: Text(fileProvider.excelPath != null ? 'Excel: ${fileProvider.excelPath!.split('/').last}' : 'Pick Excel File'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['docx']);
                if (result != null) {
                  fileProvider.setWordTemplatePath(result.files.single.path!);
                }
              },
              child: Text(fileProvider.wordTemplatePath != null ? 'Word Template: ${fileProvider.wordTemplatePath!.split('/').last}' : 'Pick Word Template'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: (fileProvider.excelPath != null && fileProvider.wordTemplatePath != null)
                  ? () => Navigator.pushNamed(context, '/configure')
                  : null,
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
