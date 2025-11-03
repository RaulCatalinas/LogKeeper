# LogKeeper

A simple, plug-and-play file logger for Dart with automatic timestamping and session management.

## Features

- ✨ **Zero Configuration** - Works out of the box, no setup required
- 📁 **Automatic File Management** - Creates timestamped log files for each session
- ⏰ **Built-in Timestamps** - Every log entry includes automatic timestamping
- 🎯 **Simple API** - Clean, intuitive methods for different log levels
- 💾 **Persistent Logging** - All logs are saved to disk automatically

## Getting Started

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  logkeeper: ^1.1.0
```

Then run:

```bash
flutter pub get
```

### Basic Usage (No Configuration Needed!)

```dart
import 'package:logkeeper/logkeeper.dart';

void main() async {
  // Just start logging - no setup required!
  LogKeeper.info('Application started');
  LogKeeper.warning('Low memory detected');
  LogKeeper.error('Connection failed');
  LogKeeper.critical('System failure');

  // Save logs before exiting
  await LogKeeper.saveLogs();
}
```

That's it! LogKeeper will automatically create a `logs/` directory and save all your logs.

### Custom Configuration (Optional)

If you need to customize LogKeeper's behavior, call `configure()` **before any logging operations** (as the first line in `main()`):

```dart
import 'package:intl/intl.dart';
import 'package:logkeeper/logkeeper.dart';
import 'package:logkeeper/log_level.dart';

void main() async {
  // Optional: customize if needed (call FIRST if you use it)
  LogKeeper.configure(
    logDirectory: 'custom_logs',
    minLevelForProduction: LogLevel.warning,
    fileNameDateFormat: DateFormat('yyyy_MM_dd-HH_mm'),
    timestampFormat: DateFormat('HH:mm:ss.SSS'),
    maxLogAgeDays: 7,
    writeToFileInDevMode: true,
  );

  // Now log as usual
  LogKeeper.info('Application started with custom config');
  
  await LogKeeper.saveLogs();
}
```

## Configuration Options

**All parameters are optional** - defaults work great for most cases:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `logDirectory` | `String` | `'logs'` | Directory where log files are saved |
| `minLevelForProduction` | `LogLevel` | `LogLevel.info` | Minimum level to log in production |
| `maxLogAgeDays` | `int?` | `null` | Auto-delete logs older than N days |
| `fileNameDateFormat` | `DateFormat` | `yyyy-MM-dd_HH-mm-ss` | Format for log file names |
| `timestampFormat` | `DateFormat` | `HH:mm:ss` | Format for timestamps in entries |
| `writeToFileInDevMode` | `bool` | `false` | Write to file in development mode |

## Log Levels

LogKeeper supports four log levels:

| Method | Use Case | Example |
|--------|----------|---------|
| `info()` | General information | `LogKeeper.info('User logged in')` |
| `warning()` | Potentially harmful situations | `LogKeeper.warning('Disk space low')` |
| `error()` | Error events | `LogKeeper.error('Network timeout')` |
| `critical()` | Severe errors | `LogKeeper.critical('Database corrupted')` |

## Log File Format

Log files are created in the log directory (default: `logs/`) with timestamps:

```plaintext
logs/
└── 2025-10-18_14-30-45.log
```

Each log entry includes automatic timestamps:

```plaintext
[14:30:45] INFO: Application started
[14:30:46] WARNING: Low memory detected
[14:30:47] ERROR: Connection failed
```

## Best Practices

### Always Save Logs

Call `saveLogs()` before your application exits to ensure all logs are written to disk:

```dart
void main() async {
  LogKeeper.info('App started');
  // ... your code ...
  await LogKeeper.saveLogs();  // Don't forget!
}
```

### If You Use configure(), Call It First

Configuration is **optional**, but if you do use it, call it before logging:

```dart
void main() async {
  LogKeeper.configure(/* settings */);  // If used, must be first
  LogKeeper.info('App started');        // Then log normally
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

### Do I need to configure LogKeeper?

**No!** LogKeeper works perfectly without any configuration. The defaults are sensible and work for most applications. Only use `configure()` if you need custom behavior.

### If I do configure, when should I call it?

If you choose to use `configure()`, call it as the **first line in `main()`**, before any logging operations.

### Where are log files stored?

By default, log files are stored in a `logs/` directory relative to your application's working directory. You can customize this with the `logDirectory` parameter.

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
