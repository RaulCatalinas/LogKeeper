import 'dart:convert' show utf8;
import 'dart:io' show Directory, File, FileMode, IOSink;

import 'package:intl/intl.dart' show DateFormat;
import 'package:path/path.dart' show join;

import 'log_level.dart' show LogLevel;

/// A simple file logger with automatic timestamping and session management.
///
/// LogKeeper provides a plug-and-play logging solution that automatically
/// writes timestamped log entries to disk. Each session creates a new log file
/// with a timestamp-based filename.
///
/// Example usage:
/// ```dart
/// LogKeeper.info('Application started');
/// LogKeeper.warning('Low memory detected');
/// LogKeeper.error('Connection failed');
/// LogKeeper.critical('System failure');
///
/// // Save and close log file when done
/// await LogKeeper.saveLogs();
/// ```
///
/// Log files are stored in a `logs/` directory relative to the application's
/// working directory. Each log file is named with the format:
/// `yyyy-MM-dd_HH-mm-ss.log`
class LogKeeper {
  static final _instance = LogKeeper._internal();

  static final _writeLogsTimestampFormatter = DateFormat.Hms();
  static final _filenameTimestampFormatter = DateFormat('yyyy-MM-dd_HH-mm-ss');

  late final Directory _logDir;
  late final File _logFile;

  IOSink? _sink;

  factory LogKeeper() {
    return _instance;
  }

  LogKeeper._internal() {
    _initializeLogger();
  }

  void _initializeLogger() {
    final filenameTimestamp = _filenameTimestampFormatter.format(
      DateTime.now(),
    );

    _logDir = Directory('logs');
    _logFile = File(join(_logDir.path, '$filenameTimestamp.log'));

    _logFile.createSync(recursive: true);
    _sink = _logFile.openWrite(mode: FileMode.append, encoding: utf8);
  }

  static void _writeLog(LogLevel level, String message) {
    _instance._sink?.writeln(
      '[${_writeLogsTimestampFormatter.format(DateTime.now())}] ${level.value}: $message',
    );
  }

  /// Logs an informational message.
  ///
  /// Use this for general information about application flow and state.
  ///
  /// Example:
  /// ```dart
  /// LogKeeper.info('User logged in successfully');
  /// LogKeeper.info('Database connection established');
  /// ```
  static void info(String message) => _writeLog(LogLevel.info, message);

  /// Logs a warning message.
  ///
  /// Use this for potentially harmful situations that don't prevent
  /// the application from functioning.
  ///
  /// Example:
  /// ```dart
  /// LogKeeper.warning('Disk space running low');
  /// LogKeeper.warning('API rate limit approaching');
  /// ```
  static void warning(String message) => _writeLog(LogLevel.warning, message);

  /// Logs an error message.
  ///
  /// Use this for error events that might still allow the application
  /// to continue running.
  ///
  /// Example:
  /// ```dart
  /// LogKeeper.error('Failed to fetch user data');
  /// LogKeeper.error('Network connection timeout');
  /// ```
  static void error(String message) => _writeLog(LogLevel.error, message);

  /// Logs a critical message.
  ///
  /// Use this for severe error events that will presumably lead the
  /// application to abort or require immediate attention.
  ///
  /// Example:
  /// ```dart
  /// LogKeeper.critical('Database corruption detected');
  /// LogKeeper.critical('Out of memory error');
  /// ```
  static void critical(String message) => _writeLog(LogLevel.critical, message);

  /// Flushes and closes the log file.
  ///
  /// This method should be called when you're done logging, typically
  /// before the application exits. It ensures all buffered log entries
  /// are written to disk and the file handle is properly closed.
  ///
  /// Example:
  /// ```dart
  /// void main() async {
  ///   LogKeeper.info('Application starting');
  ///   // ... application logic ...
  ///   LogKeeper.info('Application shutting down');
  ///   await LogKeeper.saveLogs();
  /// }
  /// ```
  ///
  /// Returns a [Future] that completes when the log file has been
  /// flushed and closed.
  static Future<void> saveLogs() async {
    if (_instance._sink != null) {
      await _instance._sink!.flush();
      await _instance._sink!.close();

      _instance._sink = null;
    }
  }
}
