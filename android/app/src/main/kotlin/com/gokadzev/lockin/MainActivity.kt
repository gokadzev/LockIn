/*
 *     Copyright (C) 2026 Valeri Gokadze
 *
 *     LockIn is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     LockIn is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */


package com.gokadzev.lockin

import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.PowerManager
import android.net.Uri
import android.provider.Settings
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
				"requestIgnoreBatteryOptimizations" -> {
					try {
						requestIgnoreBatteryOptimizations()
						result.success(true)
					} catch (e: Exception) {
						result.error("BATTERY_OPT_REQUEST_ERROR", e.message, null)
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

	private fun requestIgnoreBatteryOptimizations() {
		if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return
		val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
		intent.data = Uri.parse("package:$packageName")
		intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
		startActivity(intent)
	}
}
