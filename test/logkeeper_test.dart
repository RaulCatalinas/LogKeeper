import 'dart:io' show Directory, File;

import 'package:flutter_test/flutter_test.dart'
    show expect, tearDown, test, group, isTrue, isFalse;
import 'package:intl/intl.dart' show DateFormat;
import 'package:logkeeper/logkeeper.dart' show LogKeeper;

import 'test_utils.dart' show clearDirectory;

void main() {
  const testDir = 'test_logs';

  group('LogKeeper', () {
    tearDown(() async {
      await LogKeeper.saveLogs();
      await Future.delayed(Duration(milliseconds: 100));
      await clearDirectory('logs');
      await clearDirectory(testDir);
      await LogKeeper.resetInstance();
    });

    test('does not write to file in dev mode by default', () async {
      LogKeeper.info('Should not be written');
      await LogKeeper.saveLogs();

      final dir = Directory('logs');
      if (await dir.exists()) {
        final files = dir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.log'))
            .toList();

        if (files.isEmpty) {
          final content = await files.first.readAsString();
          expect(content.trim().isEmpty, isTrue);
        }
      }
    });

    test('writes to custom directory when configured', () async {
      LogKeeper.configure(logDirectory: testDir, writeToFileInDevMode: true);

      LogKeeper.info('Test message');
      await LogKeeper.saveLogs();

      expect(await Directory(testDir).exists(), isTrue);

      final files = Directory(testDir)
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.log'))
          .toList();

      expect(files.isNotEmpty, isTrue);

      final content = await files.first.readAsString();
      expect(content.contains('Test message'), isTrue);
    });

    test('applies custom file name format', () async {
      LogKeeper.configure(
        logDirectory: testDir,
        fileNameDateFormat: DateFormat('yyyyMMdd_HHmm'),
        writeToFileInDevMode: true,
      );

      LogKeeper.info('Test');
      await LogKeeper.saveLogs();

      final files = Directory(testDir).listSync().whereType<File>().toList();
      expect(files.isNotEmpty, isTrue);

      final fileName = files.first.path;
      expect(fileName.contains(RegExp(r'\d{8}_\d{4}\.log')), isTrue);
    });

    test('applies custom timestamp format', () async {
      LogKeeper.configure(
        logDirectory: testDir,
        timestampFormat: DateFormat('HH:mm:ss.SSS'),
        writeToFileInDevMode: true,
      );

      LogKeeper.info('Test');
      await LogKeeper.saveLogs();

      final file = Directory(testDir).listSync().whereType<File>().first;
      final content = await file.readAsString();

      expect(content.contains(RegExp(r'\[\d{2}:\d{2}:\d{2}\.\d{3}\]')), isTrue);
    });

    test('applies multiple custom formats simultaneously', () async {
      LogKeeper.configure(
        logDirectory: testDir,
        fileNameDateFormat: DateFormat('yyyy-MM-dd'),
        timestampFormat: DateFormat('yyyy-MM-dd HH:mm:ss'),
        writeToFileInDevMode: true,
      );

      LogKeeper.info('Multi format test');
      await LogKeeper.saveLogs();

      final files = Directory(testDir).listSync().whereType<File>().toList();
      expect(files.isNotEmpty, isTrue);

      final fileName = files.first.path;
      expect(fileName.contains(RegExp(r'\d{4}-\d{2}-\d{2}\.log')), isTrue);

      final content = await files.first.readAsString();
      expect(
        content.contains(RegExp(r'\[\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\]')),
        isTrue,
      );
    });

    test('writes all log levels with correct labels', () async {
      LogKeeper.configure(logDirectory: testDir, writeToFileInDevMode: true);

      LogKeeper.info('Info message');
      LogKeeper.warning('Warning message');
      LogKeeper.error('Error message');
      LogKeeper.critical('Critical message');
      await LogKeeper.saveLogs();

      final file = Directory(testDir).listSync().whereType<File>().first;
      final content = await file.readAsString();

      expect(content.contains('INFO: Info message'), isTrue);
      expect(content.contains('WARNING: Warning message'), isTrue);
      expect(content.contains('ERROR: Error message'), isTrue);
      expect(content.contains('CRITICAL: Critical message'), isTrue);
    });

    test('deletes old log files when maxLogAgeDays is set', () async {
      final oldDir = Directory(testDir);
      await oldDir.create(recursive: true);

      final oldFile = File('${oldDir.path}/old.log');
      await oldFile.writeAsString('Old log');
      await oldFile.setLastModified(
        DateTime.now().subtract(const Duration(days: 10)),
      );

      LogKeeper.configure(
        logDirectory: testDir,
        maxLogAgeDays: 7,
        writeToFileInDevMode: true,
      );

      LogKeeper.info('New log');
      await LogKeeper.saveLogs();

      final files = oldDir.listSync().whereType<File>().toList();
      expect(files.any((f) => f.path.endsWith('old.log')), isFalse);
    });
  });
}
