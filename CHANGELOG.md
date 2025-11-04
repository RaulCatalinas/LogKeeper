# Changelog

## 1.0.0

- Initial version.

## 1.0.0+1

- Updated documentation.

## 1.1.0

### ✨ New Features (All 100% Optional)

This release adds several **optional configuration options** that improve flexibility while keeping LogKeeper’s original **zero-configuration philosophy** completely intact.  
If no configuration is provided, LogKeeper continues to work exactly as before.

- Added optional configuration method `LogKeeper.configure()`:
  - `logDirectory`: Custom directory for log files (default: `cwd/logs`)
  - `minLevelForProduction`: Minimum log level for production (default: `LogLevel.info`)
  - `fileNameDateFormat`: Custom date format for log file names (default: `yyyy-MM-dd_HH-mm-ss`)
  - `timestampFormat`: Custom date format for log message timestamps (default: `Hms()`)
  - `maxLogAgeDays`: Automatically deletes old log files older than N days (default: disabled)
  - `writeToFileInDevMode`: Whether to also write logs to file in development mode (default: **false**)

- Added automatic console output:
  - In **development mode**, LogKeeper now writes logs to the console by default.
  - In **production mode**, logs are written only to file (no console output).

### 🧱 Still Zero Configuration

If you simply call:

```dart
LogKeeper.info('App started');
await LogKeeper.saveLogs();
```

Everything will work exactly the same as in previous versions — no configuration required.

## 1.1.0+1

- Updated documentation.

## 1.1.0+2

- Unnecessary public method removed
