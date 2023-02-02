import 'package:conduit/conduit.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:webapp/controllers/auth/auth_base_controller.dart';
import 'package:webapp/model/user.dart';
import 'package:webapp/utils/app_response.dart';

class AuthRefreshController extends AuthBaseController {
  AuthRefreshController(super.managedContext);

  @Operation.post()
  Future<Response> refreshToken(
      @Bind.query("token") String refreshToken) async {
    try {
      final jwtClaim = verifyJwtHS256Signature(refreshToken, jwtSecretKey);

      try { jwtClaim.validate(); } on JwtException 
      { return AppResponse.unauthorized(title: 'Invalid token');}

      final id = int.parse(jwtClaim['id'].toString());
      
      final user = await (Query<User>(managedContext)
      ..where((x) => x.id).equalTo(id)).fetchOne();

      if (user!.refreshToken != refreshToken) {
        return AppResponse.unauthorized(title: 'Invalid token');
      }

      final tokens = await updateToken(id, managedContext);
      return Response.ok({
        'refreshToken': tokens.refreshToken,
        'accessToken': tokens.accessToken
      });
    } on QueryException catch (e) {
      return AppResponse.serverError(e, message: e.message);
    }
  }
}