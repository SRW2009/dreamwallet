
import 'file_downloader_stub.dart'
  if (dart.library.io) 'android_file_downloader.dart'
  if (dart.library.html) 'web_file_downloader.dart';

abstract class FileDownloader {
  Future<void> downloadFile(List<String> data);

  factory FileDownloader() => getFileDownloader();
}