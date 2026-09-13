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

## 1.1.1

### Fix

- Fixed unnecessary `.log` file creation in development mode

## 1.2.0

### Added

- **colorizeConsoleOutput**: Colorized console output for better log readability
  - Log levels now have distinct colors for easier visual identification
  - Colors can be disabled via configuration option

## 1.3.0

### Fix

- Resolved `FileSystemException: Creation failed, path = 'logs' (OS Error: Read-only file system, errno = 30)` on Android and other environments where the process working directory is not writable. The default log directory is now created under the application support directory from `path_provider` instead of a relative `logs` folder next to the current working directory.

### Added

- **`LogKeeper.logDirectoryPath`**: read-only getter that returns the absolute directory where log files are written. It is `null` until a custom directory is set with `configure`, or until `ensureLogDirectoryPath` or the first log write initializes the default support-directory `logs` folder.
- **`LogKeeper.ensureLogDirectoryPath()`**: returns a `Future<String>` with that same absolute path and guarantees initialization (including the internal file manager) without requiring a prior log call. Prefer this when you need a non-null path before any logging.

## 1.4.0

### Added

- **`LogKeeper.flushLogs()`**: writes buffered log entries to disk without closing the underlying file sink, unlike `saveLogs()`. Safe to call as many times as needed throughout an app's lifetime — intended for apps that pass through background/foreground repeatedly during a single session (e.g. most mobile apps), where calling `saveLogs()` more than once would throw since the sink is already closed. Use `saveLogs()` only once, right before the app truly exits.

### Changed

- `LogKeeper.configure()` now only has effect the first time it's called, before any log write. Calling it again afterward is ignored (with a warning logged) instead of silently updating internal settings without recreating the underlying file manager, which previously left behavior inconsistent with what was actually configured.

### Fixed

- Fixed a race condition where a log call (`info`/`warning`/`error`/`critical`) immediately followed by `saveLogs()` or `flushLogs()` could close or flush the file sink before the log entry had actually been written, throwing `Bad state: StreamSink is bound to a stream`. Writes are now processed through an internal ordered queue, so `saveLogs()`/`flushLogs()` always wait for all previously requested writes to complete first — no `await` needed on the logging calls themselves.
- Fixed a race condition in `FileManager` where old-log cleanup (`maxLogAgeDays`) ran asynchronously inside the constructor without being awaited, so the file manager could be considered ready before cleanup had actually finished.
- A single failed log write no longer breaks all subsequent writes for the rest of the session — errors are now contained per write instead of propagating through the internal write queue.
