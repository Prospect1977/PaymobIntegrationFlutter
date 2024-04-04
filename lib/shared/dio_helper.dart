import 'package:dio/dio.dart';

import 'package:paymob_integration/shared/components/constants.dart' as con;
//import 'package:paymob_integration/shared/components/paymob.dart';

class DioHelper {
  static Dio? dio;
  static Dio? dioPayMob;
  static init() {
    dio = Dio(
      BaseOptions(
        baseUrl: '${con.baseUrl}/api/',
        receiveDataWhenStatusError: true,
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  static Future<Response?> getData({
    required String url,
    required Map<String, dynamic> query,
    String? token,
  }) async {
    dio!.options.headers = {
      'Authorization': 'Bearer $token',
    };

    return await dio!.get(
      url,
      queryParameters: query,
    );
  }

  static Future<Response> postData({
    required String url,
    Map<String, dynamic>? query,
    dynamic data,
    String? token,
  }) async {
    dio!.options.headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    return dio!.post(
      url,
      queryParameters: query,
      data: data,
    );
  }

  static Future<Response> postPaymobData({
    required String url,
    Map<String, dynamic>? query,
    dynamic data,
  }) async {
    dioPayMob?.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    return dioPayMob!.post(
      url,
      queryParameters: query,
      data: data,
    );
  }
}
