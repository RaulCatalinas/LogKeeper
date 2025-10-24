import 'dart:io' show Directory;

import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:intl/intl.dart' show DateFormat;

import 'file_manager.dart';
import 'log_level.dart';

class LogKeeper {
  static final LogKeeper _instance = LogKeeper._internal();
  DateFormat _timestampFormatter = DateFormat.Hms();
  DateFormat _filenameFormatter = DateFormat('yyyy-MM-dd_HH-mm-ss');
  Directory _logDir = Directory("logs");
  LogLevel _minLevelForProduction = LogLevel.info;
  bool _writeToFileInDevMode = false;
  int? _maxFileSizeMB;
  int? _maxLogAgeDays;

  late final FileManager _fileManager;

  factory LogKeeper() => _instance;

  LogKeeper._internal() {
    _fileManager = FileManager(
      logDir: _logDir,
      filenameFormatter: _filenameFormatter,
      maxFileSizeMB: _maxFileSizeMB,
      maxLogAgeDays: _maxLogAgeDays,
    );
  }

  /// Optional configuration. If not called, sensible defaults are used.
  static void configure({
    String logDirectory = "logs",
    LogLevel? minLevelForProduction,
    int? maxFileSizeMB,
    int? maxLogAgeDays,
    DateFormat? fileNameDateFormat,
    DateFormat? timestampFormat,
    bool? writeToFileInDevMode,
  }) {
    _instance._logDir = Directory(logDirectory);
    _instance._minLevelForProduction = minLevelForProduction ?? LogLevel.info;
    _instance._maxFileSizeMB = maxFileSizeMB;
    _instance._maxLogAgeDays = maxLogAgeDays;
    _instance._filenameFormatter =
        fileNameDateFormat ?? DateFormat('yyyy-MM-dd_HH-mm-ss');
    _instance._timestampFormatter = timestampFormat ?? DateFormat.Hms();
    _instance._writeToFileInDevMode = writeToFileInDevMode ?? false;

    _instance._fileManager = FileManager(
      logDir: _instance._logDir,
      filenameFormatter: _instance._filenameFormatter,
      maxFileSizeMB: _instance._maxFileSizeMB,
    );
  }

  static void _writeLog(LogLevel level, String message) async {
    final timestamp = _instance._timestampFormatter.format(DateTime.now());
    final logEntry = '[$timestamp] ${level.toString()}: $message';

    final shouldWriteToFile = kReleaseMode
        ? level.value >= _instance._minLevelForProduction.value
        : _instance._writeToFileInDevMode;

    if (!kReleaseMode) {
      print(logEntry);
    }

    if (shouldWriteToFile) {
      await _instance._fileManager.write(logEntry);
    }
  }

  /// Logs an informational message.
  ///
  /// Use this for general information about application flow and state.
  ///
  /// Example:
  /// ```dart
  ///   LogKeeper.info('User logged in successfully');
  ///   LogKeeper.info('Database connection established');
  /// ```
  ///
  static void info(String message) => _writeLog(LogLevel.info, message);

  /// Logs a warning message.
  ///
  /// Use this for potentially harmful situations that don't prevent the application from functioning.
  ///
  /// Example:
  /// ```dart
  ///   LogKeeper.warning('Disk space running low');
  ///   LogKeeper.warning('API rate limit approaching');
  /// ````
  ///
  static void warning(String message) => _writeLog(LogLevel.warning, message);

  /// Logs an error message.
  ///
  /// Use this for error events that might still allow the application to continue running.
  ///
  /// Example:
  /// ```dart
  ///   LogKeeper.error('Failed to fetch user data');
  ///   LogKeeper.error('Network connection timeout');
  /// ```
  ///
  static void error(String message) => _writeLog(LogLevel.error, message);

  /// Logs a critical message.
  ///
  /// Use this for severe error events that will presumably lead the application to abort or require immediate attention.
  ///
  /// Example:
  /// ```dart
  ///   LogKeeper.critical('Database corruption detected');
  ///   LogKeeper.critical('Out of memory error');
  /// ```
  ///
  static void critical(String message) => _writeLog(LogLevel.critical, message);

  /// Flushes and closes the log file.
  ///
  /// This method should be called when you're done logging, typically before the application exits.
  ///
  /// It ensures all buffered log entries are written to disk and the file handle is properly closed.
  ///
  /// Example:
  ///  ```dart
  ///   void main() async {
  ///     LogKeeper.info('Application starting');
  ///     // ... application logic ...
  ///     LogKeeper.info('Application shutting down');
  ///     await LogKeeper.saveLogs();
  ///   }
  /// ```
  ///
  /// Returns a [Future] that completes when the log file has been flushed and closed.
  static Future<void> saveLogs() => _instance._fileManager.close();
}
