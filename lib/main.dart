import 'package:api_client/app_router.dart';
import 'package:api_client/utils/api_utils.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiUtils.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final AppRouter router = AppRouter();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: router.generateRouter,
      initialRoute: pageSignIn,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      )
    );
  }
}