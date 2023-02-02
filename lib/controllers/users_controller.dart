import 'package:webapp/model/user.dart';
import 'package:webapp/utils/app_response.dart';

import '../webapp.dart';
class UsersController extends ResourceController {
  UsersController(this.managedContext);

  final ManagedContext managedContext;

  @Operation.get()
  Future<Response> getProfile() async {
    try {
      final userId = request!.attachments["userId"] as int;
      final user = await managedContext.fetchObjectWithID<User>(userId);
      if (user == null) {
        return AppResponse.unauthorized();
      }

      return Response.ok({"id": user.id, "login": user.login, "name": user.name,});
    } catch (e) {
      return AppResponse.serverError(e, message: 'Error getting user profile');
    }
  }

  @Operation.put()
  Future<Response> updateProfile(@Bind.body() EditProfileRequest data) async {
    final userId = request!.attachments["userId"] as int;

    final qUpdateUser = Query<User>(managedContext)
      ..where((x) => x.id).equalTo(userId);
    
    if (data.name != null) {
      qUpdateUser.values.name = data.name!;
    }

    if (data.password != null) {
      final salt = generateRandomSalt();
      final passwordHash = generatePasswordHash(data.password!, salt);

      qUpdateUser.values.passwordHash = passwordHash;
      qUpdateUser.values.passwordSalt = salt;
    }

    final user = await qUpdateUser.updateOne();

    return Response.ok({"name": user!.name});
  }
}
