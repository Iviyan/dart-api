import 'package:webapp/controllers/auth/auth_login_controller.dart';
import 'package:webapp/controllers/auth/auth_refresh_controller.dart';
import 'package:webapp/controllers/auth/auth_reg_controller.dart';
import 'package:webapp/controllers/check_auth_controller.dart';
import 'package:webapp/controllers/notes_controller.dart';
import 'package:webapp/controllers/users_controller.dart';
import 'package:webapp/model/note.dart';
import 'package:webapp/webapp.dart';
import 'package:yaml/yaml.dart';

/// This type initializes an application.
///
/// Override methods in this class to set up routes and initialize services like
/// database connections. See http://conduit.io/docs/http/channel/.
class WebappChannel extends ApplicationChannel {

  late final ManagedContext managedContext;

  /// Initialize services in this method.
  ///
  /// Implement this method to initialize services, read values from [options]
  /// and any other initialization required before constructing [entryPoint].
  ///
  /// This method is invoked prior to [entryPoint] being accessed.
  @override
  Future prepare() async {
    final persistentStore = _initDatabase();

    managedContext = ManagedContext(ManagedDataModel.fromCurrentMirrorSystem(), persistentStore);

    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
    
    return super.prepare();
  }

  PersistentStore _initDatabase() {
    print(Directory.current);

    final configFile = File('database.yaml');
    dynamic yamlConfig;
    try {
      final yamlString = configFile.readAsStringSync();
      yamlConfig = loadYaml(yamlString);
    // ignore: empty_catches
    } catch(ex) {}

    final fail = (String msg) => throw Exception("The DB configuration was skipped. ($msg)");
    final getYamlKey = (String key) => yamlConfig != null ? yamlConfig[key].toString() : null;

    final username = Platform.environment['DB_USERNAME'] ?? getYamlKey('username') ?? fail("DB_USERNAME | username");
    final password = Platform.environment['DB_PASSWORD'] ?? getYamlKey('password') ?? fail("DB_PASSWORD | password");
    final host = Platform.environment['DB_HOST'] ?? getYamlKey('host') ?? '127.0.0.1';
    final port = int.parse(Platform.environment['DB_PORT'] ?? getYamlKey('port') ?? '5432');
    final databaseName = Platform.environment['DB_NAME'] ?? getYamlKey('databaseName') ?? fail("DB_NAME | databaseName");

    return PostgreSQLPersistentStore(username, password, host, port, databaseName);
  }

  /// Construct the request channel.
  ///
  /// Return an instance of some [Controller] that will be the initial receiver
  /// of all [Request]s.
  ///
  /// This method is invoked after [prepare].
  @override
  Controller get entryPoint {
    final router = Router();

    router
      ..route('login').link(() => AuthLoginController(managedContext))
      ..route('register').link(() => AuthRegController(managedContext))
      ..route('refresh-token').link(() => AuthRefreshController(managedContext))
      ..route('user')
        .link(CheckAuthController.new)!
        .link(() => UsersController(managedContext))
      ..route('notes/[:id]')
        .link(CheckAuthController.new)!
        .link(() => NotesController(managedContext))
      ..route('notes-history')
        .link(CheckAuthController.new)!
        .linkFunction((request) async => Response.ok(await Query<NoteHistoryRecord>(managedContext).fetch()));

    return router;
  }
}
