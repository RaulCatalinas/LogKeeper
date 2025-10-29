import 'dart:io' show Directory, File;

import 'package:flutter_test/flutter_test.dart'
    show expect, tearDown, test, group, isTrue, isFalse;
import 'package:intl/intl.dart' show DateFormat;
import 'package:logkeeper/logkeeper.dart' show LogKeeper;

void main() {
  const testDir = 'test_logs';

  group('LogKeeper tests', () {
    tearDown(() async {
      await LogKeeper.saveLogs();
      await LogKeeper.resetInstance();
    });

    // ───────────────────────────────────────────────
    // 1️⃣ BASIC BEHAVIOR (ZERO CONFIGURATION)
    // ───────────────────────────────────────────────
    test('creates log files and writes entries with default config', () async {
      LogKeeper.info('App started');
      LogKeeper.warning('Low disk space');
      await LogKeeper.saveLogs();

      final dir = Directory('logs');
      expect(await dir.exists(), isTrue);

      final files = dir.listSync().whereType<File>().toList();
      expect(files.isNotEmpty, isTrue);

      final content = await files.first.readAsString();

      expect(content.contains('INFO: App started'), isFalse);
      expect(content.contains('WARNING: Low disk space'), isFalse);
    });

    // ───────────────────────────────────────────────
    // 2️⃣ CUSTOM CONFIGURATION
    // ───────────────────────────────────────────────
    test('respects custom directory and formats', () async {
      LogKeeper.configure(
        logDirectory: testDir,
        fileNameDateFormat: DateFormat('yyyyMMdd_HHmm'),
        timestampFormat: DateFormat('HH:mm:ss.SSS'),
        writeToFileInDevMode: true,
      );

      LogKeeper.info('Custom log entry');
      await LogKeeper.saveLogs();

      final files = Directory(testDir).listSync().whereType<File>().toList();
      expect(files.isNotEmpty, isTrue);
      expect(files.first.path.contains(RegExp(r'\d{8}_\d{4}')), isTrue);

      final content = await files.first.readAsString();
      expect(content.contains(RegExp(r'\[\d{2}:\d{2}:\d{2}\.\d{3}\]')), isTrue);
    });

    // ───────────────────────────────────────────────
    // 3️⃣ OLD LOG CLEANUP
    // ───────────────────────────────────────────────
    test('deletes old log files when maxLogAgeDays is set', () async {
      // Create an old log file manually.
      final oldDir = Directory(testDir);
      await oldDir.create(recursive: true);

      final oldFile = File('${oldDir.path}/old.log');
      await oldFile.create();
      await oldFile.writeAsString('Old log file');

      final oldTime = DateTime.now().subtract(const Duration(days: 10));
      await oldFile.setLastModified(oldTime);

      LogKeeper.configure(
        logDirectory: testDir,
        maxLogAgeDays: 7,
        writeToFileInDevMode: true,
      );

      LogKeeper.info('Trigger cleanup');
      await LogKeeper.saveLogs();

      final remaining = oldDir.listSync().whereType<File>().toList();
      expect(remaining.any((f) => f.path.endsWith('old.log')), isFalse);
    });

    // ───────────────────────────────────────────────
    // 4️⃣ WRITE IN DEV MODE
    // ───────────────────────────────────────────────
    test('writes to file in dev mode only when enabled', () async {
      LogKeeper.configure(logDirectory: testDir);

      LogKeeper.info('Should NOT be saved');
      await LogKeeper.saveLogs();

      final dir = Directory(testDir);

      if (await dir.exists()) {
        final files = dir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.log'))
            .toList();

        if (files.isNotEmpty) {
          final content = await files.first.readAsString();
          expect(content.trim().isEmpty, isTrue);
        }
      }
    });
  });
}
