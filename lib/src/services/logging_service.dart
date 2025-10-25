import 'package:logging/logging.dart';

class LoggingService {
  static void configureLogging() {
    Logger.root.level = Level.INFO;

    Logger.root.onRecord.listen((record) {
      final timestamp = record.time.toIso8601String();
      final level = record.level.name;
      final loggerName = record.loggerName;

      print('[$timestamp] $level [$loggerName] ${record.message}');

      // Print stack trace for errors
      if (record.error != null) {
        print('Error: ${record.error}');
      }
      if (record.stackTrace != null) {
        print('Stack trace:\n${record.stackTrace}');
      }
    });
  }

  Logger getLogger(String name) {
    return Logger(name);
  }
}
