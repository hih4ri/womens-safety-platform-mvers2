import 'package:flutter/services.dart';

class SmsService {
  static const MethodChannel _channel =
      MethodChannel('womens_safety/sms');

  static Future<bool> sendSms({
    required String phone,
    required String message,
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'sendSms',
        {
          'phone': phone,
          'message': message,
        },
      );

      return result ?? false;
    } on PlatformException {
      return false;
    }
  }
}