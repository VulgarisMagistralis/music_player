package com.cenkt.music_player

import android.graphics.Color
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.util.Log
import android.view.KeyEvent
import android.widget.RemoteViews

class MusicWidgetProvider : AppWidgetProvider() {

    companion object {
        const val PREFS = "music_widget"
        const val ACTION_MEDIA = "com.cenkt.music_player.WIDGET_MEDIA"
        const val EXTRA_ACTION = "action"

        const val PLAY = "play"
        const val PAUSE = "pause"
        const val PREV = "prev"
        const val NEXT = "next"

        const val KEY_TITLE = "title"
        const val KEY_ARTIST = "artist"
        const val KEY_ALBUM_ART = "album_art"
        const val KEY_IS_PLAYING = "is_playing"
        const val KEY_HAS_ITEM = "has_item"
        const val KEY_PLAYLIST = "playlist"
        const val KEY_POSITION_MS = "position_ms"
        const val KEY_DURATION_MS = "duration_ms"

        const val LOG_TAG = "MusicWidget"
        const val MEDIA_BUTTON_RECEIVER = "com.ryanheise.audioservice.MediaButtonReceiver"

        /** Re-render all instances of the widget from persisted state. */
        fun refreshAll(context: Context) {
            val mgr = AppWidgetManager.getInstance(context)
            val ids = mgr.getAppWidgetIds(ComponentName(context, MusicWidgetProvider::class.java))
            if (ids.isEmpty()) return
            MusicWidgetProvider().updateWidget(context, mgr, ids)
        }
    }

    private fun prefs(context: Context) = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    private fun pending(context: Context, action: String, code: Int): PendingIntent {
        val intent = Intent(context, MusicWidgetProvider::class.java)
            .setAction(ACTION_MEDIA)
            .putExtra(EXTRA_ACTION, action)
        return PendingIntent.getBroadcast(
            context,
            code,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
    }

    private fun openApp(context: Context): PendingIntent {
        val launch = context.packageManager.getLaunchIntentForPackage(context.packageName)
        return PendingIntent.getActivity(
            context,
            21,
            launch,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
    }

    private fun render(context: Context): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.widget_music_player)
        val p = prefs(context)
        val hasItem = p.getBoolean(KEY_HAS_ITEM, false)
        val isPlaying = p.getBoolean(KEY_IS_PLAYING, false)

        if (hasItem) {
            views.setTextViewText(R.id.widget_title, p.getString(KEY_TITLE, "Music Player"))
            views.setTextViewText(R.id.widget_artist, p.getString(KEY_ARTIST, ""))
            val art = p.getString(KEY_ALBUM_ART, "") ?: ""
            val bitmap = if (art.isNotBlank()) decodeArt(context, art) else null
            if (bitmap != null) views.setImageViewBitmap(R.id.widget_art, bitmap)
            else views.setImageViewResource(R.id.widget_art, R.drawable.ic_widget_note)
            val playlist = p.getString(KEY_PLAYLIST, "") ?: ""
            val positionMs = p.getInt(KEY_POSITION_MS, 0).coerceAtLeast(0)
            val durationMs = p.getInt(KEY_DURATION_MS, 0).coerceAtLeast(0)
            views.setTextViewText(R.id.widget_position, formatTime(positionMs))
            views.setTextViewText(R.id.widget_duration, formatTime(durationMs))
            val progress =
                if (durationMs > 0) ((positionMs.toLong() * 100) / durationMs).toInt().coerceIn(0, 100) else 0
            views.setProgressBar(R.id.widget_seek, 100, progress, false)
        } else {
            views.setTextViewText(R.id.widget_title, context.getString(R.string.widget_title_default))
            views.setTextViewText(R.id.widget_artist, "")
            views.setTextViewText(R.id.widget_position, "0:00")
            views.setTextViewText(R.id.widget_duration, "0:00")
            views.setProgressBar(R.id.widget_seek, 100, 0, false)
            views.setImageViewResource(R.id.widget_art, R.drawable.ic_widget_note)
        }

        views.setImageViewResource(
            R.id.widget_btn_play,
            if (isPlaying) R.drawable.ic_widget_pause_active else R.drawable.ic_widget_play,
        )

        val launch = openApp(context)
        views.setOnClickPendingIntent(R.id.widget_btn_prev, pending(context, PREV, 200))
        views.setOnClickPendingIntent(R.id.widget_btn_play, pending(context, if (isPlaying) PAUSE else PLAY, 201))
        views.setOnClickPendingIntent(R.id.widget_btn_next, pending(context, NEXT, 202))
        // Tapping the title, art, or the seek bar opens the app
        views.setOnClickPendingIntent(R.id.widget_title, launch)
        views.setOnClickPendingIntent(R.id.widget_art, launch)
        views.setOnClickPendingIntent(R.id.widget_seek, launch)

        return views
    }

    private fun formatTime(ms: Int): String {
        val totalSec = ms / 1000
        val m = totalSec / 60
        val s = totalSec % 60
        return String.format("%d:%02d", m, s)
    }

    private fun decodeArt(context: Context, encoded: String): Bitmap? {
        // album_art is stored as a content:// URI (artwork authority) whose path segment
        // is the plain file path of the cached thumbnail. The provider behind that
        // authority is not registered, so resolve the file path and decode directly —
        // the widget runs in the app process and can read its own cache files.
        var path = try {
            val uri = Uri.parse(encoded)
            if (uri.scheme == "content" || uri.scheme == "file") uri.path else encoded
        } catch (e: Throwable) {
            return null
        }
        if (path.isNullOrBlank()) return null
        // The path may be percent-encoded (e.g. %20 for spaces) — decode before file IO.
        path = Uri.decode(path) ?: path
        val file = java.io.File(path)
        if (!file.isFile) {
            Log.w(LOG_TAG, "art file missing: $path")
            return null
        }
        return try {
            BitmapFactory.decodeFile(path)
        } catch (e: Throwable) {
            Log.w(LOG_TAG, "could not decode art: $e")
            null
        }
    }

    /**
     * Drive transport controls through the app's existing [MediaButtonReceiver]
     * (com.ryanheise.audioservice.MediaButtonReceiver). This is the exact same media-key
     * path audio_service uses for hardware buttons, so it reliably reaches the active
     * PlaybackState even when the app is backgrounded or not in the foreground.
     */
    private fun performTransport(context: Context, action: String) {
        val keycode = when (action) {
            PLAY -> KeyEvent.KEYCODE_MEDIA_PLAY
            PAUSE -> KeyEvent.KEYCODE_MEDIA_PAUSE
            PREV -> KeyEvent.KEYCODE_MEDIA_PREVIOUS
            NEXT -> KeyEvent.KEYCODE_MEDIA_NEXT
            else -> {
                Log.w(LOG_TAG, "unknown action: $action")
                return
            }
        }

        val keyEvent = KeyEvent(KeyEvent.ACTION_DOWN, keycode)
        val intent = Intent(Intent.ACTION_MEDIA_BUTTON)
            .setComponent(ComponentName(context, MEDIA_BUTTON_RECEIVER))
            .putExtra(Intent.EXTRA_KEY_EVENT, keyEvent)

        try {
            context.sendBroadcast(intent)
            Log.d(LOG_TAG, "sent media button keycode=$keycode (action=$action)")
        } catch (e: Throwable) {
            Log.e(LOG_TAG, "failed to send media button event: $e", e)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == ACTION_MEDIA) {
            val a = intent.getStringExtra(EXTRA_ACTION) ?: return
            performTransport(context, a)
            refreshAll(context)
        }
    }

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        updateWidget(context, appWidgetManager, appWidgetIds)
        val views = updateWidgetTheme(context)
        for (widgetId in appWidgetIds) {
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun updateWidgetTheme(context: Context): RemoteViews {
        val preferences = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val backgroundColor = Color.parseColor(
            preferences.getString(
                "widget_background", "#202124"
            ) ?: "#202124"
        )

        val textColor = Color.parseColor(
            preferences.getString(
                "widget_text", "#FFFFFF"
            ) ?: "#FFFFFF"
        )

        val accentColor = Color.parseColor(
            preferences.getString(
                "widget_accent", "#1a3c5e"
            ) ?: "#1a3c5e"
        )
        val views = RemoteViews(context.packageName, R.layout.widget_music_player)
        views.setTextViewText(R.id.widget_title, "Song title")
        // views.setBoolean(R.id.widget_title, "setSelected", true)
        views.setTextColor(R.id.widget_title, textColor)

        views.setTextViewText(R.id.widget_artist, "Artist name")
        views.setTextColor(R.id.widget_artist, textColor)

        views.setTextColor(R.id.widget_position, textColor)
        views.setTextColor(R.id.widget_duration, textColor)
        views.setInt(R.id.widget_root, "setBackgroundColor", backgroundColor)
        views.setProgressBar(R.id.widget_seek, 100, 35, false)
        return views
    }

    private fun updateWidget(context: Context, mgr: AppWidgetManager, ids: IntArray) {
        val views = render(context)
        mgr.updateAppWidget(ids, views)
        Log.d(
            LOG_TAG,
            "rendered widget ids=${ids.toList()} hasItem=${
                prefs(context).getBoolean(
                    KEY_HAS_ITEM,
                    false
                )
            } isPlaying=${prefs(context).getBoolean(KEY_IS_PLAYING, false)}"
        )
    }

    override fun onEnabled(context: Context) {
        refreshAll(context)
        Log.d(LOG_TAG, "widget placed on home screen")
    }

    override fun onDisabled(context: Context) {
        Log.d(LOG_TAG, "widget removed from home screen")
    }
}
