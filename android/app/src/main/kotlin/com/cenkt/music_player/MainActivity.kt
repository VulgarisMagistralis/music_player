package com.cenkt.music_player
import android.content.ContentProvider
import android.content.ContentValues
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.ParcelFileDescriptor
import androidx.annotation.RequiresApi
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : AudioServiceActivity(){
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.attributes = window.attributes.apply {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                layoutInDisplayCutoutMode = android.view.WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_ALWAYS
            }
        }
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.R) {
            window.setDecorFitsSystemWindows(false)
        }
    }

    private fun isAutomotive(): Boolean {
        return packageManager.hasSystemFeature(PackageManager.FEATURE_AUTOMOTIVE)
    }

    private fun getUriFromPath(path: String): String {
        val file = java.io.File(path)
        return if (file.exists()) {
            androidx.core.content.FileProvider.getUriForFile(
                this,
                "com.cenkt.music_player.fileprovider",
                file
            ).toString()
        } else {
            ""
        }
    }

    private val fileProviderChannel = "com.cenkt.music_player.fileprovider"
    private val platformChannel = "com.cenkt.music_player/platform"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, fileProviderChannel).setMethodCallHandler { call, result ->
            android.util.Log.d("FLUTTER_BRIDGE", "Received call: ${call.method} with args: ${call.arguments}")
            if (call.method == "getUriForFile") {
                val path = call.argument<String>("path")
                if (path != null) {
                   val uri= getUriFromPath(path)
                    if (uri.isEmpty()) {
                        result.error("INVALID_PATH", "File doesn't exist", null)
                        return@setMethodCallHandler
                    }
                    result.success(uri)
                } else {
                    result.error("INVALID_PATH", "Path is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, platformChannel).setMethodCallHandler { call, result ->
            when (call.method) {
                "isAutomotive" -> result.success(isAutomotive())
                else -> result.notImplemented()
            }
        }
        // Home screen widget state bridge: Dart pushes {title, artist, album_art, is_playing, has_item}.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.cenkt.music_player/widget").setMethodCallHandler { call, result ->
            if (call.method == "updateWidget") {
                val args = call.arguments as? Map<*, *>
                val playing = (args?.get(MusicWidgetProvider.KEY_IS_PLAYING) as? Boolean) ?: false
                val playlist = (args?.get(MusicWidgetProvider.KEY_PLAYLIST) as? String) ?: ""
                // Dart ints arrive as Long on the Android side — accept either.
                val positionMs = (args?.get(MusicWidgetProvider.KEY_POSITION_MS) as? Long)
                    ?: (args?.get(MusicWidgetProvider.KEY_POSITION_MS) as? Int)?.toLong()
                    ?: 0L
                val durationMs = (args?.get(MusicWidgetProvider.KEY_DURATION_MS) as? Long)
                    ?: (args?.get(MusicWidgetProvider.KEY_DURATION_MS) as? Int)?.toLong()
                    ?: 0L
                val edit = getSharedPreferences(MusicWidgetProvider.PREFS, MODE_PRIVATE).edit()
                edit.putString(MusicWidgetProvider.KEY_TITLE, (args?.get(MusicWidgetProvider.KEY_TITLE) as? String) ?: "")
                edit.putString(MusicWidgetProvider.KEY_ARTIST, (args?.get(MusicWidgetProvider.KEY_ARTIST) as? String) ?: "")
                edit.putString(MusicWidgetProvider.KEY_ALBUM_ART, (args?.get(MusicWidgetProvider.KEY_ALBUM_ART) as? String) ?: "")
                edit.putBoolean(MusicWidgetProvider.KEY_IS_PLAYING, playing)
                edit.putBoolean(MusicWidgetProvider.KEY_HAS_ITEM, (args?.get(MusicWidgetProvider.KEY_HAS_ITEM) as? Boolean) ?: false)
                edit.putString(MusicWidgetProvider.KEY_PLAYLIST, playlist)
                edit.putInt(MusicWidgetProvider.KEY_POSITION_MS, positionMs.toInt().coerceAtLeast(0))
                edit.putInt(MusicWidgetProvider.KEY_DURATION_MS, durationMs.toInt().coerceAtLeast(0))
                edit.apply()
                MusicWidgetProvider.refreshAll(this)
                result.success(true)
                android.util.Log.d("MusicWidget", "state updated via channel: playing=$playing hasItem=${args?.get(MusicWidgetProvider.KEY_HAS_ITEM)} playlist='$playlist' pos=$positionMs dur=$durationMs")
            } else {
                result.notImplemented()
            }
        }
    }
}
