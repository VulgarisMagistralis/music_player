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
    }
}

class ArtworkProvider : ContentProvider() {
    override fun openFile(uri: Uri, mode: String): ParcelFileDescriptor? {
        val filePath = uri.path ?: return null
        val file = File(filePath)
        return ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
    }
    override fun getType(uri: Uri) = "image/jpeg"
    override fun onCreate() = true
    override fun query(uri: Uri, p: Array<String>?, s: String?, sA: Array<String>?, so: String?) = null
    override fun insert(uri: Uri, values: ContentValues?) = null
    override fun delete(uri: Uri, s: String?, sA: Array<String>?) = 0
    override fun update(uri: Uri, v: ContentValues?, s: String?, sA: Array<String>?) = 0
}
