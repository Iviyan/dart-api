import 'package:api_client/utils/api_utils.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthInterceptor extends QueuedInterceptor {
  SharedPreferences? sharedPreferences;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    super.onRequest(options, handler);

    print("|ONREQ|> ");

    if(ApiUtils.accessToken == null) return;

    if (ApiUtils.getAccessTokenExpiration()!.isBefore(DateTime.now())) {
      print("|ONREQ|> REFRESH");
      final tokens = await ApiUtils.refresh();
      tokens.fold((res) {}, (err) {
        handler.reject(err);
      });
      if (tokens.isRight()) return;
    }

    options.headers["Authorization"] = "Bearer ${ApiUtils.accessToken}";
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    super.onError(err, handler);

    if (err.response?.statusCode == 403 || err.response?.statusCode == 401) {
      final tokens = await ApiUtils.refresh();
      await tokens.fold((res) async {
        handler.resolve(await _retry(err.requestOptions));
      }, (err) {
        handler.reject(err);
      });
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers, 
      contentType: requestOptions.contentType,
      extra: requestOptions.extra,
      followRedirects: requestOptions.followRedirects,
      listFormat: requestOptions.listFormat,
      maxRedirects: requestOptions.maxRedirects,
      receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
      receiveTimeout: requestOptions.receiveTimeout,
      requestEncoder: requestOptions.requestEncoder,
      responseDecoder: requestOptions.responseDecoder,
      responseType: requestOptions.responseType,
      sendTimeout: requestOptions.sendTimeout,
      validateStatus: requestOptions.validateStatus
    );
    return ApiUtils.noAuthDio.request<dynamic>(requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options: options,
        cancelToken: requestOptions.cancelToken,
        onReceiveProgress: requestOptions.onReceiveProgress,
        onSendProgress: requestOptions.onSendProgress);
  }
}