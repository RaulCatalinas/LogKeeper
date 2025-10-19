import 'package:logkeeper/logkeeper.dart';

/// Demonstrates LogKeeper's zero-config behavior and automatic
/// timestamped session logging.
///
/// This example shows how LogKeeper automatically creates a new
/// log file in the "logs" directory for each execution, with a
/// timestamped filename like `2025-10-19_15-30-45.log`.
///
/// No setup or configuration is needed — just call the logging
/// methods and save when done.
Future<void> main() async {
  LogKeeper.info('Starting new log session');
  LogKeeper.warning('Cache directory not found, recreating...');
  LogKeeper.error('Failed to load preferences.json');
  LogKeeper.critical('Disk nearly full — user intervention required!');

  // Flush and close the current log file.
  await LogKeeper.saveLogs();

  print('✅ Logs saved automatically in the "logs" directory.');
}
