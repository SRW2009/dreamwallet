
import 'dart:html' as html;

import 'file_downloader_interface.dart';

class WebFileDownloader implements FileDownloader {
  const WebFileDownloader();

  @override
  Future<void> downloadFile(List<String> data) async {
    var blob = html.Blob(data, 'text/plain', 'native');

    html.AnchorElement(
      href: html.Url.createObjectUrlFromBlob(blob).toString(),
    )..setAttribute("download", "dreampay report.txt")..click();
  }
}

FileDownloader getFileDownloader() => const WebFileDownloader();