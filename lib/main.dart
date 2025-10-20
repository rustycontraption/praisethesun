import 'package:flutter/material.dart';
import 'package:praisethesun/src/app.dart';
import 'package:provider/provider.dart';
import 'src/model.dart';
// import 'src/widgets/sun_map.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ChangeNotifierProvider(
      create: (context) => SunLocationModel(),
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
