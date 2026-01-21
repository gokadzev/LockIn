package com.gokadzev.lockin

import android.content.Context
import android.os.Build
import android.os.PowerManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.util.*
import java.time.ZoneId

class MainActivity : FlutterActivity() {
	private val CHANNEL = "lockin/native_timezone"
	private val SYSTEM_CHANNEL = "lockin/native_system"

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

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SYSTEM_CHANNEL).setMethodCallHandler { call, result ->
			when (call.method) {
				"isIgnoringBatteryOptimizations" -> {
					try {
						result.success(isIgnoringBatteryOptimizations())
					} catch (e: Exception) {
						result.error("BATTERY_OPT_ERROR", e.message, null)
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

	private fun isIgnoringBatteryOptimizations(): Boolean {
		if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return true
		val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
		return powerManager.isIgnoringBatteryOptimizations(packageName)
	}
}
