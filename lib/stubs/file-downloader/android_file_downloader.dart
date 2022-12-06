
import 'dart:io';

import 'package:file_picker/file_picker.dart';

import 'file_downloader_interface.dart';

class AndroidFileDownloader implements FileDownloader {
  const AndroidFileDownloader();

  @override
  Future<void> downloadFile(List<String> data) async {
    final dir = await FilePicker.platform.getDirectoryPath();

    if (dir != null) {
      final file = File('$dir/dreampay report.txt');
      await file.writeAsString(data.join());
    }
  }
}

FileDownloader getFileDownloader() => const AndroidFileDownloader();