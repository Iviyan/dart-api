import 'package:api_client/views/main_page.dart';
import 'package:flutter/material.dart';
import 'package:api_client/views/signin_page.dart';
import 'package:api_client/views/signup_page.dart';

const String pageSignIn = "signin";
const String pageSignUp = "signup";
const String pageMain = "main";

class AppRouter {
  Route<dynamic>? generateRouter(RouteSettings settings) {
    switch (settings.name) {
      case pageSignIn: return MaterialPageRoute(builder: (_) => const SignInPage());
      case pageSignUp: return MaterialPageRoute(builder: (_) => const SignUpPage());
      case pageMain: return MaterialPageRoute(builder: (_) => const MainPage());
    }
    return null;
  }
}