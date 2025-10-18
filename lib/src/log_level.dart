enum LogLevel {
  info('INFO'),
  warning('WARNING'),
  error('ERROR'),
  critical('CRITICAL');

  const LogLevel(this.value);
  final String value;
}
