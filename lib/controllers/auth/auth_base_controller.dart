import 'package:conduit/conduit.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:webapp/model/user.dart';
import 'package:webapp/utils/app_utils.dart';

class AuthBaseController extends ResourceController {
  AuthBaseController(this.managedContext);

  final ManagedContext managedContext;
  
  String get jwtSecretKey => AppUtils.jwtSecretKey;


  Future<Tokens> updateToken(int userId, ManagedContext transaction) async {
    final refreshToken = getRefreshToken(jwtSecretKey, userId);

    /* 
    > Another victim @PrimaryKey <
    [WARNING] conduit: PostgreSQLSeverity.error : Specified parameter types do not match column parameter types in query
    
    > Workaround <
    await transaction.persistentStore.execute(
      "UPDATE users SET refresh_token=@refreshToken WHERE id = @id",
      substitutionValues: { "refreshToken": refreshToken, "id": userId});
    */

    final qUpdateTokens = Query<User>(transaction)
      ..values.refreshToken = refreshToken
      ..where((x) => x.id).equalTo(userId);

    await qUpdateTokens.updateOne();
      
    return Tokens(getAccessToken(jwtSecretKey, userId), refreshToken);
  }

  String getAccessToken(String secretKey, int userId) {
    final accessClaimSet = JwtClaim(maxAge: const Duration(hours: 1), otherClaims: {'id': userId});
    return issueJwtHS256(accessClaimSet, secretKey);
  }

  String getRefreshToken(String secretKey, int userId) {
    final refreshClaimSet = JwtClaim(maxAge: const Duration(days: 60), otherClaims: {'id': userId});
    return issueJwtHS256(refreshClaimSet, secretKey);
  }
}

class Tokens { 
  Tokens(this.accessToken, this.refreshToken); 
  String accessToken; String refreshToken;
}