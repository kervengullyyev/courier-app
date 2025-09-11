package com.example.courier_app

import android.Manifest
import android.content.pm.PackageManager
import android.telephony.SmsManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "sms_channel"
    private val SMS_PERMISSION_REQUEST_CODE = 123

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "sendSMS" -> {
                    val phoneNumber = call.argument<String>("phoneNumber")
                    val message = call.argument<String>("message")
                    
                    if (phoneNumber != null && message != null) {
                        sendSMS(phoneNumber, message, result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Phone number and message are required", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun sendSMS(phoneNumber: String, message: String, result: MethodChannel.Result) {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.SEND_SMS) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.SEND_SMS), SMS_PERMISSION_REQUEST_CODE)
            result.error("PERMISSION_DENIED", "SMS permission not granted", null)
            return
        }

        try {
            val smsManager = SmsManager.getDefault()
            val dividedMessages = smsManager.divideMessage(message)
            
            if (dividedMessages.size > 1) {
                // Send multipart SMS
                smsManager.sendMultipartTextMessage(phoneNumber, null, dividedMessages, null, null)
                result.success("Multipart SMS sent successfully (${dividedMessages.size} parts)")
            } else {
                // Send single SMS
                smsManager.sendTextMessage(phoneNumber, null, message, null, null)
                result.success("SMS sent successfully")
            }
        } catch (e: Exception) {
            result.error("SMS_ERROR", "Failed to send SMS: ${e.message}", null)
        }
    }
}
