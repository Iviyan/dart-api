import 'package:webapp/webapp.dart';

Future main() async {
  final port = int.parse(Platform.environment["PORT"] ?? '8888');

  final app = Application<WebappChannel>()
    ..options.configurationFilePath = "config.yaml"
    ..options.port = port;

  await app.start(numberOfInstances: 1, consoleLogging: true);

  print("Application started on port: ${app.options.port}.");
  print("Use Ctrl-C (SIGINT) to stop running the application.");
}
