package com.example.womens_safety_platform_app

import android.Manifest
import android.content.pm.PackageManager
import android.telephony.SmsManager
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "womens_safety/sms"
    private val SMS_PERMISSION_REQUEST = 1001

    private var pendingPhone: String? = null
    private var pendingMessage: String? = null
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            if (call.method == "sendSms") {

                val phone = call.argument<String>("phone")
                val message = call.argument<String>("message")

                if (phone.isNullOrBlank() || message.isNullOrBlank()) {
                    result.error(
                        "INVALID_ARGUMENT",
                        "Phone number or message is missing",
                        null
                    )
                    return@setMethodCallHandler
                }

                if (ActivityCompat.checkSelfPermission(
                        this,
                        Manifest.permission.SEND_SMS
                    ) != PackageManager.PERMISSION_GRANTED
                ) {
                    pendingPhone = phone
                    pendingMessage = message
                    pendingResult = result

                    ActivityCompat.requestPermissions(
                        this,
                        arrayOf(Manifest.permission.SEND_SMS),
                        SMS_PERMISSION_REQUEST
                    )

                    return@setMethodCallHandler
                }

                sendSms(phone, message, result)
            }
        }
    }

    private fun sendSms(
        phone: String,
        message: String,
        result: MethodChannel.Result
    ) {
        try {
            val smsManager = SmsManager.getDefault()

            smsManager.sendTextMessage(
                phone,
                null,
                message,
                null,
                null
            )

            result.success(true)

        } catch (e: Exception) {
            result.error(
                "SMS_ERROR",
                e.message ?: "Failed to send SMS",
                null
            )
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(
            requestCode,
            permissions,
            grantResults
        )

        if (requestCode == SMS_PERMISSION_REQUEST) {

            val result = pendingResult
            val phone = pendingPhone
            val message = pendingMessage

            pendingResult = null
            pendingPhone = null
            pendingMessage = null

            if (grantResults.isNotEmpty() &&
                grantResults[0] == PackageManager.PERMISSION_GRANTED
            ) {

                if (result != null &&
                    phone != null &&
                    message != null
                ) {
                    sendSms(phone, message, result)
                }

            } else {
                result?.error(
                    "PERMISSION_DENIED",
                    "SMS permission was denied",
                    null
                )
            }
        }
    }
}