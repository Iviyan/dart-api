import 'dart:io';

import 'package:api_client/models/login_response.dart';
import 'package:api_client/models/note.dart';
import 'package:api_client/models/refresh_token_response.dart';
import 'package:api_client/models/user.dart';
import 'package:api_client/utils/auth_interceptor.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

@sealed
class ApiUtils {

  // ignore: unused_element
  ApiUtils._();
  
  static const String baseUrl = "http://192.168.43.96:8888";
  //static const String baseUrl = "http://192.168.1.70:8888";

  static late Dio dio;
  static late Dio noAuthDio;
  static late SharedPreferences sharedPreferences;

  static String? accessToken;
  static JWT? accessTokenData;
  static DateTime? getAccessTokenExpiration() => DateTime.fromMillisecondsSinceEpoch(
    (accessTokenData?.payload["exp"] as int) * 1000);
  static String? refreshToken;

  static Future<void> init() async {
    await _initSharedPrefs();
    await _initDio();

    _loadTokens();
  }

  static Future<void> _initSharedPrefs() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  static Future<void> _initDio() async {   
    dio = Dio(
      BaseOptions(
          baseUrl: baseUrl,
          contentType: "application/json",
          connectTimeout: 5000,
          receiveTimeout: 15000,
          sendTimeout: 5000),
    );
    
    dio.interceptors.add(AuthInterceptor());

    noAuthDio = Dio(
      BaseOptions(
          baseUrl: baseUrl,
          contentType: "application/json",
          connectTimeout: 5000,
          receiveTimeout: 15000,
          sendTimeout: 5000),
    );
  }

  static void updateTokens({String? accessToken, String? refreshToken}) {
    if (accessToken != null) {
      ApiUtils.accessToken = accessToken;
      sharedPreferences.setString("accessToken", accessToken);
      accessTokenData = JWT.decode(accessToken);
    }
    if (refreshToken != null) {
      ApiUtils.refreshToken = refreshToken;
      sharedPreferences.setString("refreshToken", refreshToken);
    }
  }
  static void _loadTokens() {
    accessToken = sharedPreferences.getString('accessToken');
    refreshToken = sharedPreferences.getString('refreshToken');
  }

  static String handleError(DioError error) {
    if (error.type == DioErrorType.response) {
      return error.response?.statusCode != 500 ? error.response!.data["title"] : error.response!.statusMessage!;
    }
    return error.message;
  }

  static Future<Either<LoginResponse, String>> login(String login, String password) async {
    try {
      final response = await noAuthDio.post("/login",
        data: { 'login' : login, 'password' : password });
      
      final res = LoginResponse.fromJson(response.data);
      
      print("|LOGIN| >>> ${res}");

      updateTokens(accessToken: res.accessToken, refreshToken: res.refreshToken);
      print(sharedPreferences.getString('accessToken'));
    
      return Left(res);
    } on DioError catch (error) { return Right(handleError(error)); }
  }

  static Future<Either<RefreshTokenResponse, DioError>> refresh() async {
    try {
      final response = await noAuthDio.post("/refresh-token", queryParameters: { 'token': refreshToken });
      final res = RefreshTokenResponse.fromJson(response.data);
      updateTokens(accessToken: res.accessToken, refreshToken: res.refreshToken);
      print(sharedPreferences.getString('accessToken'));
     
      return Left(res);
    } on DioError catch (error) { return Right(error); }
  }

  static Future<Either<LoginResponse, String>> register(String login, String password, String name) async {
    try {
      final response = await noAuthDio.post("/register",
        data: { 'login' : login, 'password' : password, 'name': name });
      final res = LoginResponse.fromJson(response.data);
      updateTokens(accessToken: res.accessToken, refreshToken: res.refreshToken);
      print(sharedPreferences.getString('accessToken'));
    
      return Left(res);
    } on DioError catch (error) { return Right(handleError(error)); }
  }

  static Future<Either<User, String>> getProfile() async {
    try {
      final response = await dio.get("/user");
      final res = User.fromJson(response.data);    
      return Left(res);
    } on DioError catch (error) {
      return Right(handleError(error));
    }
  }

  static Future<String?> updateProfile({String? name, String? password}) async {
    try {
      final response = await dio.put("/user",
        data: { 'name' : name, 'password' : password });    
      return null;
    } on DioError catch (error) {
      return handleError(error);
    }
  }

  static Future<Either<List<Note>, String>> getNotes({
    String? name,
    bool includeDeleted = false,
    int count = 0,
    int lastId = 0
  }) async {
    try {
      final response = await dio.get("/notes",
        queryParameters: {"name": name, "include_deleted": includeDeleted, "count": count, "laast_id": lastId});
      final res = List<Note>.of((response.data as List<dynamic>).map((n) => Note.fromJson(n)));
      return Left(res);
    } on DioError catch (error) {
      return Right(handleError(error));
    }
  }

  static Future<String?> deleteNote(int id, {bool forever = true}) async {
    try {
      await dio.delete("/notes/$id", queryParameters: {"forever": forever});
      return null;
    } on DioError catch (error) {
      return handleError(error);
    }
  }

  static Future<Either<Note, String>> updateNote(int id, String name, String text, int categoryId) async {
    try {
      final response = await dio.put("/notes/$id",
        data: { 'name': name, 'text': text, "categoryId": categoryId });    
      return Left(Note.fromJson(response.data));
    } on DioError catch (error) {
      return Right(handleError(error));
    }
  }
  
  static Future<Either<Note, String>> createNote(String name, String text, int categoryId) async {
    try {
      final response = await dio.post("/notes",
        data: { 'name': name, 'text': text, "categoryId": categoryId });    
      return Left(Note.fromJson(response.data));
    } on DioError catch (error) {
      return Right(handleError(error));
    }
  }

}