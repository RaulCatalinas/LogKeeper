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
import 'package:logkeeper/logkeeper.dart';

Future<void> main() async {
  LogKeeper.info('Starting application...');

  try {
    // Your application logic
    await connectToDatabase();
    LogKeeper.info('Database connection established');

    await loadUserData();
    LogKeeper.info('User data loaded successfully');

  } catch (e) {
    LogKeeper.error('Failed to initialize: $e');
  } finally {
    LogKeeper.info('Shutting down application');
    await LogKeeper.saveLogs();
  }
}

Future<void> connectToDatabase() async {
  // Database connection logic
}

Future<void> loadUserData() async {
  // Load user data logic
}
```

## Additional Examples

### 🔹 Zero-Config Session Example

Demonstrates how LogKeeper automatically manages timestamped sessions
and creates log files without any setup:

```dart
import 'package:logkeeper/logkeeper.dart';

Future<void> main() async {
  LogKeeper.info('Starting new log session');
  LogKeeper.warning('Cache directory not found, recreating...');
  LogKeeper.error('Failed to load preferences.json');
  LogKeeper.critical('Disk nearly full — user intervention required!');

  await LogKeeper.saveLogs();
  print('✅ Logs saved automatically in the "logs" directory.');
}
```
## 🔹 Integration Example

Shows how LogKeeper can be used in a realistic app lifecycle,
including async operations and error handling:

```dart
import 'dart:math';

import 'package:logkeeper/logkeeper.dart';

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
  LogKeeper.warning('Using default configuration (config.json missing)');
}

Future<void> fetchUserData() async {
  LogKeeper.info('Fetching user data...');
  await Future.delayed(Duration(milliseconds: 700));
  if (Random().nextBool()) {
    LogKeeper.error('Failed to reach API endpoint — retrying...');
  }
}

Future<void> performRiskyOperation() async {
  LogKeeper.info('Performing risky operation...');
  await Future.delayed(Duration(milliseconds: 400));
  if (Random().nextInt(10) > 7) {
    throw Exception('Critical system failure during operation');
  }
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

```
logs/
└── 2025-10-18_14-30-45.log
```

Each log entry follows this format:

```
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
