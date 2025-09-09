package com.gokadzev.lockin

import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.util.*
import java.time.ZoneId

class MainActivity : FlutterActivity() {
	private val CHANNEL = "lockin/native_timezone"

	override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)
		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
			when (call.method) {
				"getLocalTimezone" -> {
					try {
						val tz = getLocalTimezone()
						result.success(tz)
					} catch (e: Exception) {
						result.error("TZ_ERROR", e.message, null)
					}
				}
				else -> result.notImplemented()
			}
		}
	}

	private fun getLocalTimezone(): String {
		return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
			ZoneId.systemDefault().id
		} else {
			TimeZone.getDefault().id
		}
	}
}
