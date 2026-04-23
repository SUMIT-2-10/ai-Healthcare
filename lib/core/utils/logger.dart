import 'package:logger/logger.dart';

final appLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 1,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
  level: Level.debug,
);

class AppLogger {
  static void d(String msg, [dynamic error]) =>
      appLogger.d(msg, error: error);

  static void i(String msg, [dynamic error]) =>
      appLogger.i(msg, error: error);

  static void w(String msg, [dynamic error]) =>
      appLogger.w(msg, error: error);

  static void e(String msg, [dynamic error, StackTrace? stackTrace]) =>
      appLogger.e(msg, error: error, stackTrace: stackTrace);
}
