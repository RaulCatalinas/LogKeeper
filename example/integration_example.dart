import 'dart:math';

import 'package:logkeeper/logkeeper.dart';

/// Demonstrates LogKeeper in a realistic application flow.
///
/// This example simulates an app lifecycle where LogKeeper records
/// key events, warnings, and errors automatically with timestamps.
///
/// Each run automatically creates a new log file inside the "logs"
/// directory (e.g., `2025-10-19_18-45-12.log`).
Future<void> main() async {
  LogKeeper.info('App started');

  try {
    await loadConfiguration();
    await fetchUserData();
    await performRiskyOperation();
    LogKeeper.info('All tasks completed successfully');
  } catch (e, s) {
    LogKeeper.critical('Unhandled exception: $e\n$s');
  } finally {
    await LogKeeper.saveLogs();
    print('✅ Log file saved in the "logs" directory.');
  }
}

Future<void> loadConfiguration() async {
  LogKeeper.info('Loading configuration...');
  await Future.delayed(Duration(milliseconds: 500));

  // Simulate a warning condition
  LogKeeper.warning('Using default configuration (config.json missing)');
}

Future<void> fetchUserData() async {
  LogKeeper.info('Fetching user data...');
  await Future.delayed(Duration(milliseconds: 700));

  // Simulate a non-fatal error
  if (Random().nextBool()) {
    LogKeeper.error('Failed to reach API endpoint — retrying...');
  }
}

Future<void> performRiskyOperation() async {
  LogKeeper.info('Performing risky operation...');
  await Future.delayed(Duration(milliseconds: 400));

  // Simulate a critical failure
  if (Random().nextInt(10) > 7) {
    throw Exception('Critical system failure during operation');
  }
}
