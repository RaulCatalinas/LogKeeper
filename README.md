# LogKeeper

A simple, plug-and-play file logger for Dart with automatic timestamping and session management.

## Features

✨ **Zero Configuration** - Works out of the box, no setup required
📁 **Automatic File Management** - Creates timestamped log files for each session
⏰ **Built-in Timestamps** - Every log entry includes automatic timestamping
🎯 **Simple API** - Clean, intuitive methods for different log levels
💾 **Persistent Logging** - All logs are saved to disk automatically

## Getting Started

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  logkeeper: ^1.0.0
```

Then run:

```bash
dart pub get
```

Or with Flutter:

```bash
flutter pub get
```

### Basic Usage

```dart
import 'package:logkeeper/logkeeper.dart';

void main() async {
  // Log different levels of messages
  LogKeeper.info('Application started');
  LogKeeper.warning('Low memory detected');
  LogKeeper.error('Connection failed');
  LogKeeper.critical('System failure');

  // Save and close log file when done
  await LogKeeper.saveLogs();
}
```

## Complete Example

```dart
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
```

That's it! LogKeeper will automatically create a `logs/` directory and save all your logs.

## Log Levels

LogKeeper supports four log levels:

| Method | Use Case | Example |
|--------|----------|---------|
| `info()` | General information | `LogKeeper.info('User logged in')` |
| `warning()` | Potentially harmful situations | `LogKeeper.warning('Disk space low')` |
| `error()` | Error events | `LogKeeper.error('Network timeout')` |
| `critical()` | Severe errors | `LogKeeper.critical('Database corrupted')` |

## Log File Format

Log files are created in the `logs/` directory with the format:

```plaintext
logs/
└── 2025-10-18_14-30-45.log
```

Each log entry follows this format:

```plaintext
[14:30:45] INFO: Application started
[14:30:46] WARNING: Low memory detected
[14:30:47] ERROR: Connection failed
```

## Best Practices

### Always Save Logs

Remember to call `saveLogs()` before your application exits to ensure all logs are written to disk:

```dart
void main() async {
  LogKeeper.info('App started');
  // ... your code ...
  await LogKeeper.saveLogs();
}
```

### Use Appropriate Log Levels

Choose the right log level for each situation:

- **INFO**: Normal operations, state changes, milestones
- **WARNING**: Unusual situations that don't prevent functionality
- **ERROR**: Errors that affect functionality but allow recovery
- **CRITICAL**: Severe errors requiring immediate attention

### Be Descriptive

Write clear, actionable log messages:

```dart
// ❌ Bad
LogKeeper.error('Error');

// ✅ Good
LogKeeper.error('Failed to connect to database: connection timeout after 30s');
```

## FAQ

### Where are log files stored?

Log files are stored in a `logs/` directory relative to your application's working directory.

### Can I change the log directory?

Currently, LogKeeper uses a fixed `logs/` directory. Custom directory support may be added in a future version.

### How are log files named?

Log files use the format `yyyy-MM-dd_HH-mm-ss.log` based on when the logger is initialized.

### What happens if I don't call `saveLogs()`?

Some log entries may not be written to disk as they remain in the buffer. Always call `saveLogs()` before exiting.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you encounter any issues or have questions, please [open an issue](https://github.com/RaulCatalinas/Logkeeper/issues) on GitHub.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes in each version.
