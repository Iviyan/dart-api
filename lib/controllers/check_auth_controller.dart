import 'dart:async';
import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:webapp/utils/app_response.dart';
import 'package:webapp/utils/app_utils.dart';

class CheckAuthController extends Controller {
  @override
  FutureOr<RequestOrResponse?> handle(Request request) {
    try {
      final header = request.raw.headers.value(HttpHeaders.authorizationHeader);
      if (header == null) return Response.unauthorized();

      final token = const AuthorizationBearerParser().parse(header);

      final jwtClaim = verifyJwtHS256Signature(token ?? '', AppUtils.jwtSecretKey);
      jwtClaim.validate();

      request.attachments["userId"] = int.parse(jwtClaim["id"].toString());

      return request;
    } on JwtException catch (e) {
      return AppResponse.unauthorized(title: 'Invalid token', details: e.message);
    }
  }
}
