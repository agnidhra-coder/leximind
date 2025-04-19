import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileService {
  /// Creates and returns a local [File] according to the given [name] and
  /// [content].
  Future<File> createFile(String name, String content) async {
    final directory = await getApplicationDocumentsDirectory();
    print("directory: ${directory.path}");
    final file = File('${directory.path}/$name');
    file.writeAsStringSync(content);

    return file;
  }
}