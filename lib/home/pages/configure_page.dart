import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/file_provider.dart';
import '../../core/services/translation_service.dart';

class ConfigurePage extends StatefulWidget {
  const ConfigurePage({super.key});

  @override
  State<ConfigurePage> createState() => _ConfigurePageState();
}

class _ConfigurePageState extends State<ConfigurePage> {
  final _keyController = TextEditingController();
  final _cellController = TextEditingController();
  final _fileNameController = TextEditingController();

  @override
  void dispose() {
    _keyController.dispose();
    _cellController.dispose();
    _fileNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fileProvider = context.watch<FileProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Configure Translation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _fileNameController,
              decoration: const InputDecoration(labelText: 'New File Name'),
              onChanged: fileProvider.setNewFileName,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _keyController,
                    decoration: const InputDecoration(labelText: 'Placeholder Key'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _cellController,
                    decoration: const InputDecoration(labelText: 'Excel Cell'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (_keyController.text.isNotEmpty && _cellController.text.isNotEmpty) {
                      fileProvider.addMapping(_keyController.text, _cellController.text);
                      _keyController.clear();
                      _cellController.clear();
                    }
                  },
                )
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: fileProvider.mappings.length,
                itemBuilder: (context, index) {
                  final map = fileProvider.mappings[index];
                  return ListTile(
                    title: Text('Replace [${map['key']}] with ${map['cell']}'),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: fileProvider.newFileName != null && fileProvider.mappings.isNotEmpty
                  ? () async {
                final path = await TranslationService.translateAndSave(
                  excelPath: fileProvider.excelPath!,
                  wordTemplatePath: fileProvider.wordTemplatePath!,
                  newFileName: fileProvider.newFileName!,
                  mappings: fileProvider.mappings,
                );
                fileProvider.setOutputPath(path);
                if (context.mounted) Navigator.pushNamed(context, '/success');
              }
                  : null,
              child: const Text('Translate & Save'),
            )
          ],
        ),
      ),
    );
  }
}