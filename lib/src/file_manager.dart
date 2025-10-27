import 'dart:convert' show utf8;
import 'dart:io' show Directory, File, FileMode, IOSink;

import 'package:intl/intl.dart' show DateFormat;
import 'package:path/path.dart' show join;

class FileManager {
  final Directory logDir;
  final DateFormat filenameFormatter;
  final int? maxFileSizeMB;
  final int? maxLogAgeDays;

  late File _logFile;
  IOSink? _sink;

  FileManager({
    required this.logDir,
    required this.filenameFormatter,
    this.maxFileSizeMB,
    this.maxLogAgeDays,
  }) {
    _initialize();
    _cleanupOldLogs();
  }

  Future<void> _cleanupOldLogs() async {
    if (maxLogAgeDays == null || !await logDir.exists()) return;

    final files = logDir.listSync().whereType<File>().where(
      (f) => f.path.endsWith('.log'),
    );

    final now = DateTime.now();

    for (final file in files) {
      final lastModified = await file.lastModified();
      final age = now.difference(lastModified).inDays;

      if (age <= maxLogAgeDays!) continue;

      await file.delete();
    }
  }

  void _initialize() {
    final filename = filenameFormatter.format(DateTime.now());
    _logFile = File(join(logDir.path, '$filename.log'));
    _logFile.createSync(recursive: true);
    _sink = _logFile.openWrite(mode: FileMode.append, encoding: utf8);
  }

  Future<void> write(String message) async {
    _sink?.writeln(message);
    await _checkFileSize();
  }

  Future<void> _checkFileSize() async {
    if (maxFileSizeMB == null || !await _logFile.exists()) return;

    final sizeInBytes = await _logFile.length();
    final sizeInMB = sizeInBytes / (1024 * 1024);

    if (sizeInMB < maxFileSizeMB!) return;

    await close();
    _initialize();
  }

  Future<void> close() async {
    await _sink?.flush();
    await _sink?.close();
  }
}
