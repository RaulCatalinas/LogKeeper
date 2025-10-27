import 'dart:io' show Directory;

/// Deletes the given directory if it exists.
Future<void> clearDirectory(String path) async {
  final dir = Directory(path);
  if (await dir.exists()) {
    await dir.delete(recursive: true);
  }
}
