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
