// ignore_for_file: unused_element

import 'package:conduit/conduit.dart';
import 'package:conduit_common/src/openapi/documentable.dart';
import 'package:conduit_open_api/src/v3/schema.dart';
import 'package:webapp/model/note.dart';

class User extends ManagedObject<_User> implements _User {}

@Table(name: "users", useSnakeCaseColumnName: true)
class _User { 
  _User({this.id = 0, this.login = "", this.passwordHash = "", this.passwordSalt = "", this.name = "", this.refreshToken});

  // Nullable because | type 'Null' is not a subtype of type 'int' | ..where((x) => x.id)
  // @primaryKey cause <...> in query
  // [WARNING] conduit: PostgreSQLSeverity.error : Specified parameter types do not match column parameter types in query
  @Column(primaryKey: true) int? id;
  // Nullable because | type 'Null' is not a subtype of type 'String' | in ..where((x) => x.login)
  @Column(unique: true) String? login; 
  @Column() String? passwordHash;
  @Column() String? passwordSalt;
  @Column() String? name;
  @Column(nullable: true) String? refreshToken;

  ManagedSet<Note>? notes;

  /*
  || user.toResponceMap()
  >> NoSuchMethodError: Class 'User' has no instance method 'toResponceMap' with matching arguments.
  Map<String, dynamic> toResponceMap() => { "id": id, "login": login, "name": name };
  */
}

// Without Serializable, it is impossible to use a model for binding.
class LoginRequest implements Serializable {
  LoginRequest({this.login, this.password});

  String? login;
  String? password;

  @override
  Map<String, dynamic>? asMap() => {"login": login, "password": password};

  @override APISchemaObject documentSchema(APIDocumentContext context) => throw UnimplementedError();
  @override void read(Map<String, dynamic> object, {Iterable<String>? accept, Iterable<String>? ignore, Iterable<String>? reject, Iterable<String>? require}) => readFromMap(object);

  @override
  void readFromMap(Map<String, dynamic> object) {
    login = object["login"] as String;
    password = object["password"] as String;
  }
}

class RegisterRequest implements Serializable {
  String? login;
  String? password;
  String? name;

  @override
  Map<String, dynamic>? asMap() => {"login": login, "password": password, "name": name};

  @override APISchemaObject documentSchema(APIDocumentContext context) => throw UnimplementedError();
  @override void read(Map<String, dynamic> object, {Iterable<String>? accept, Iterable<String>? ignore, Iterable<String>? reject, Iterable<String>? require}) => readFromMap(object);

  @override
  void readFromMap(Map<String, dynamic> object) {
    login = object["login"]as String?;
    password = object["password"] as String?;
    name = object["name"] as String?;
  }
}


class EditProfileRequest implements Serializable {
  String? password;
  String? name;

  @override
  Map<String, dynamic>? asMap() => {"password": password, "name": name};

  @override APISchemaObject documentSchema(APIDocumentContext context) => throw UnimplementedError();
  @override void read(Map<String, dynamic> object, {Iterable<String>? accept, Iterable<String>? ignore, Iterable<String>? reject, Iterable<String>? require}) => readFromMap(object);

  @override
  void readFromMap(Map<String, dynamic> object) {
    password = object["password"] as String?;
    name = object["name"] as String?;
  }
}