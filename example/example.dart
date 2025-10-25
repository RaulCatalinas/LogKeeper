import 'package:intl/intl.dart';
import 'package:logkeeper/log_level.dart';
import 'package:logkeeper/logkeeper.dart';

/// Example of how to use LogKeeper.
///
/// LogKeeper is a plug-and-play file logger for Dart and Flutter.
/// It works out of the box, no configuration required.
/// However, you can optionally customize its behavior if needed.
Future<void> main() async {
  // ─────────────────────────────
  // 1️⃣ ZERO-CONFIGURATION USAGE
  // ─────────────────────────────
  //
  // By default, LogKeeper:
  // • Logs messages with timestamps.
  // • Prints them to the console in development mode.
  // • Saves them to 'cwd/logs' in production mode.
  //
  // No setup required — just call LogKeeper and you're done.
  LogKeeper.info('Application started');
  LogKeeper.warning('Low disk space detected');
  LogKeeper.error('Failed to fetch user data');
  LogKeeper.critical('Unexpected system failure');

  // ─────────────────────────────
  // 2️⃣ OPTIONAL CONFIGURATION
  // ─────────────────────────────
  //
  // If you want more control, you can configure LogKeeper
  // using LogKeeper.configure().
  //
  // All parameters are optional — if you omit them, defaults are used.
  LogKeeper.configure(
    logDirectory: 'custom_logs', // custom directory for logs
    minLevelForProduction:
        LogLevel.warning, // filter lower levels in production
    maxFileSizeMB: 5, // auto-rotate files over 5 MB
    fileNameDateFormat: DateFormat('yyyy_MM_dd-HH_mm'),
    timestampFormat: DateFormat('HH:mm:ss.SSS'),
    maxLogAgeDays: 7, // delete logs older than 7 days
    writeToFileInDevMode: true, // also write to file in dev mode
  );

  LogKeeper.info('Configuration applied');
  LogKeeper.warning('Custom logging directory active');
  LogKeeper.error('Simulated error event');
  LogKeeper.critical('Simulated critical issue');

  // ─────────────────────────────
  // 3️⃣ CLEANUP AND SHUTDOWN
  // ─────────────────────────────
  //
  // Always call saveLogs() when the app is about to exit
  // to make sure all buffered logs are flushed to disk.
  await LogKeeper.saveLogs();

  print('✅ Logs saved successfully!');
}
