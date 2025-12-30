package com.ezra.musicplayer.my_music_player

import android.media.audiofx.Equalizer
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.ryanheise.audioservice.AudioServiceActivity

class MainActivity : AudioServiceActivity() {
    private val CHANNEL = "com.ezra.musicplayer/equalizer"
    private var equalizer: Equalizer? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "init" -> {
                    val sessionId = call.argument<Int>("sessionId")
                    if (sessionId != null) {
                        try {
                            if (equalizer != null) {
                                equalizer?.release()
                            }
                            equalizer = Equalizer(0, sessionId)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("INIT_ERROR", "Failed to init equalizer: ${e.message}", null)
                        }
                    } else {
                        result.error("INVALID_ARGS", "Session ID required", null)
                    }
                }
                "release" -> {
                    equalizer?.release()
                    equalizer = null
                    result.success(true)
                }
                "enable" -> {
                    val enable = call.argument<Boolean>("enable") ?: false
                    try {
                        equalizer?.enabled = enable
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ENABLE_ERROR", e.message, null)
                    }
                }
                "isEnabled" -> {
                    try {
                        result.success(equalizer?.enabled ?: false)
                    } catch (e: Exception) {
                         result.error("GET_ENABLED_ERROR", e.message, null)
                    }
                }
                "getBandLevelRange" -> {
                    try {
                        val range = equalizer?.bandLevelRange
                        if (range != null) {
                            result.success(listOf(range[0].toInt(), range[1].toInt()))
                        } else {
                            result.error("RANGE_ERROR", "Range unavailable", null)
                        }
                    } catch (e: Exception) {
                        result.error("RANGE_ERROR", e.message, null)
                    }
                }
                "getCenterBandFreqs" -> {
                    try {
                        val bands = equalizer?.numberOfBands ?: 0
                        val freqs = ArrayList<Int>()
                        for (i in 0 until bands) {
                            freqs.add(equalizer?.getCenterFreq(i.toShort()) ?: 0)
                        }
                        result.success(freqs)
                    } catch (e: Exception) {
                        result.error("FREQ_ERROR", e.message, null)
                    }
                }
                "getBandLevel" -> {
                    val band = call.argument<Int>("band")
                    if (band != null) {
                        try {
                            result.success(equalizer?.getBandLevel(band.toShort())?.toInt() ?: 0)
                        } catch (e: Exception) {
                            result.error("LEVEL_ERROR", e.message, null)
                        }
                    } else {
                        result.error("INVALID_ARGS", "Band index required", null)
                    }
                }
                "setBandLevel" -> {
                    val band = call.argument<Int>("band")
                    val level = call.argument<Int>("level")
                    if (band != null && level != null) {
                        try {
                            equalizer?.setBandLevel(band.toShort(), level.toShort())
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("SET_LEVEL_ERROR", e.message, null)
                        }
                    } else {
                        result.error("INVALID_ARGS", "Band and Level required", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onDestroy() {
        equalizer?.release()
        super.onDestroy()
    }
}
