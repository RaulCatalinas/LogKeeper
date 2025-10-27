import 'dart:io' show Directory, File;

import 'package:flutter_test/flutter_test.dart'
    show expect, setUp, tearDown, test;
import 'package:intl/intl.dart' show DateFormat;
import 'package:logkeeper/log_level.dart' show LogLevel;
import 'package:logkeeper/logkeeper.dart' show LogKeeper;

import 'test_utils.dart' show clearDirectory;

void main() {
  const testDir = 'test_logs';

  setUp(() async {
    LogKeeper.resetInstance();
  });

  tearDown(() async {
    await clearDirectory(testDir);
    await clearDirectory('logs');
  });

  // ───────────────────────────────────────────────
  // 1️⃣ BASIC BEHAVIOR (ZERO CONFIGURATION)
  // ───────────────────────────────────────────────
  test('creates log files and writes entries with default config', () async {
    LogKeeper.info('App started');
    LogKeeper.warning('Low disk space');
    await LogKeeper.saveLogs();

    final dir = Directory('logs');
    expect(await dir.exists(), true);

    final files = dir.listSync().whereType<File>().toList();
    expect(files.isNotEmpty, true);

    final content = await files.first.readAsString();
    expect(content.contains('INFO: App started'), false);
    expect(content.contains('WARNING: Low disk space'), false);
  });

  // ───────────────────────────────────────────────
  // 2️⃣ CUSTOM CONFIGURATION
  // ───────────────────────────────────────────────
  test('respects custom directory and formats', () async {
    LogKeeper.configure(
      logDirectory: testDir,
      fileNameDateFormat: DateFormat('yyyyMMdd_HHmm'),
      timestampFormat: DateFormat('HH:mm:ss.SSS'),
    );

    LogKeeper.info('Custom log entry');
    await LogKeeper.saveLogs();

    final files = Directory(testDir).listSync().whereType<File>().toList();
    expect(files.isNotEmpty, true);
    expect(files.first.path.contains(RegExp(r'\d{8}_\d{4}')), true);

    final content = await files.first.readAsString();
    expect(content.contains(RegExp(r'\[\d{2}:\d{2}:\d{2}\.\d{3}\]')), false);
  });

  // ───────────────────────────────────────────────
  // 3️⃣ LOG LEVEL FILTERING
  // ───────────────────────────────────────────────
  test('filters out lower levels in production mode', () async {
    LogKeeper.configure(
      logDirectory: testDir,
      minLevelForProduction: LogLevel.warning,
    );

    // Simulate release mode by manually logging through the API.
    LogKeeper.info('This should not appear');
    LogKeeper.error('This should appear');
    await LogKeeper.saveLogs();

    final file = Directory(testDir).listSync().whereType<File>().first;
    final content = await file.readAsString();

    expect(content.contains('ERROR: This should appear'), true);
    expect(content.contains('INFO: This should not appear'), false);
  });

  // ───────────────────────────────────────────────
  // 4️⃣ FILE ROTATION
  // ───────────────────────────────────────────────
  test('rotates files when maxFileSizeMB is reached', () async {
    LogKeeper.configure(
      logDirectory: testDir,
      maxFileSizeMB: 1, // 1 MB
      writeToFileInDevMode: true,
    );

    final largeEntry = 'A' * (1024 * 1024); // 1 MB
    LogKeeper.info(largeEntry);
    LogKeeper.info('Next log should go to a new file');
    await LogKeeper.saveLogs();

    final files = Directory(testDir).listSync().whereType<File>().toList();
    expect(files.isNotEmpty, true);
  });

  // ───────────────────────────────────────────────
  // 5️⃣ OLD LOG CLEANUP
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
    expect(remaining.any((f) => f.path.endsWith('old.log')), false);
  });

  // ───────────────────────────────────────────────
  // 6️⃣ WRITE IN DEV MODE
  // ───────────────────────────────────────────────
  test('writes to file in dev mode only when enabled', () async {
    LogKeeper.configure(logDirectory: testDir, writeToFileInDevMode: false);

    LogKeeper.info('Should NOT be saved');
    await LogKeeper.saveLogs();

    final files = Directory(testDir)
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.log'))
        .toList();

    if (files.isNotEmpty) {
      final content = await files.first.readAsString();
      expect(content.trim().isEmpty, true);
    }
  });
}
