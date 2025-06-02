import 'package:flutter/material.dart';

class FileProvider extends ChangeNotifier {
  String? excelPath;
  String? wordTemplatePath;
  String? newFileName;
  String? outputPath;
  final List<Map<String, String>> mappings = [];

  void setExcelPath(String path) {
    excelPath = path;
    notifyListeners();
  }

  void setWordTemplatePath(String path) {
    wordTemplatePath = path;
    notifyListeners();
  }

  void setNewFileName(String name) {
    newFileName = name;
    notifyListeners();
  }

  void addMapping(String key, String cell) {
    mappings.add({'key': key, 'cell': cell});
    notifyListeners();
  }

  void setOutputPath(String path) {
    outputPath = path;
    notifyListeners();
  }

  void clear() {
    excelPath = null;
    wordTemplatePath = null;
    newFileName = null;
    outputPath = null;
    mappings.clear();
    notifyListeners();
  }
}