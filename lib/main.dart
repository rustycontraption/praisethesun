import 'package:flutter/material.dart';
import 'package:praisethesun/src/app.dart';
import 'package:provider/provider.dart';
import 'src/model/model.dart';
import 'src/services/logging_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  LoggingService.configureLogging();

  runApp(
    MultiProvider(
      providers: [
        Provider<LoggingService>(create: (context) => LoggingService()),
        ChangeNotifierProxyProvider<LoggingService, SunLocationModel>(
          create: (context) => SunLocationModel(
            loggingService: Provider.of<LoggingService>(context, listen: false),
          ),
          update: (context, loggingService, previous) =>
              previous ?? SunLocationModel(loggingService: loggingService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: TextTheme(bodySmall: TextStyle(fontSize: 12)),
      ),
      initialRoute: "/home",
      routes: {"/home": (context) => const SunApp()},
    );
  }
}
