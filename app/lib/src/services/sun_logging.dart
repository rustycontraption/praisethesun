import 'package:logging/logging.dart';
export 'package:logging/logging.dart' show Logger, Level;

class SunLogging {
  static String _formatTimestamp(DateTime time) {
    final year = time.year.toString();
    final month = time.month.toString().padLeft(2, '0');
    final day = time.day.toString().padLeft(2, '0');
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final second = time.second.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute:$second';
  }

  static void configureLogging() {
    Logger.root.level = Level.INFO;

    Logger.root.onRecord.listen((record) {
      final timestamp = _formatTimestamp(record.time);
      final loggerName = record.loggerName;

      String colorCode;
      String resetCode = '\x1B[0m';

      switch (record.level) {
        case Level.SEVERE:
          colorCode = '\x1B[31m'; // Red
          print(
            '$colorCode[ERROR] [$timestamp] [$loggerName] ${record.message}$resetCode',
          );
          break;
        case Level.WARNING:
          colorCode = '\x1B[33m'; // Yellow
          print(
            '$colorCode[WARN]  [$timestamp] [$loggerName] ${record.message}$resetCode',
          );
          break;
        case Level.INFO:
          colorCode = '\x1B[32m'; // Green
          print(
            '$colorCode[INFO]  [$timestamp] [$loggerName] ${record.message}$resetCode',
          );
          break;
        default:
          print('[DEBUG] [$timestamp] [$loggerName] ${record.message}');
      }

      // Print stack trace for errors
      if (record.error != null) {
        print('Error: ${record.error}');
      }
      if (record.stackTrace != null) {
        print('Stack trace:\n${record.stackTrace}');
      }
    });
  }

  static Logger getLogger(String name) {
    return Logger(name);
  }
}
