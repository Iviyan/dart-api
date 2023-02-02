import 'dart:io';
import 'package:conduit/conduit.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

abstract class AppUtils {
  const AppUtils._();

  static String? _jwtSecretKey;
  static String get jwtSecretKey => _jwtSecretKey ??= Platform.environment['SECRET_KEY'] ?? 'SECRET_KEY';

  static int getIdFromHeader(String header) {
    final token = const AuthorizationBearerParser().parse(header);
    final jwtClaim = verifyJwtHS256Signature(token!, jwtSecretKey);
    final id = int.parse(jwtClaim['id'].toString());
    return id;
  }
}