enum LogLevel {
  info,
  warning,
  error,
  critical;

  int get value => index;

  @override
  String toString() => name.toUpperCase();
}
