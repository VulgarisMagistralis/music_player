package com.cenkt.music_player

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
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

        // Width of the album-art cell in widget_music_player.xml, in dp.
        const val ART_CELL_DP = 36

        /**
         * Fallbacks used until the Dart side pushes the app's resolved theme (see applyTheme).
         * These mirror the app's own defaults — black background, white text, teal accent —
         * so the tile already looks like the app before the first push arrives.
         */
        const val DEFAULT_BACKGROUND = "#FF121212"
        const val DEFAULT_TEXT = "#FFFFEEEE"
        const val DEFAULT_ACCENT = "#FF03DAC5"

        /** Re-render all instances of the widget from persisted state. */
        fun refreshAll(context: Context) {
            val mgr = AppWidgetManager.getInstance(context)
            val ids = mgr.getAppWidgetIds(ComponentName(context, MusicWidgetProvider::class.java))
            if (ids.isEmpty()) return
            renderWidget(context, mgr, ids)
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
                val positionMs = p.getInt(KEY_POSITION_MS, 0).coerceAtLeast(0)
                val durationMs = p.getInt(KEY_DURATION_MS, 0).coerceAtLeast(0)
                views.setTextViewText(R.id.widget_position, formatTime(positionMs))
                views.setTextViewText(R.id.widget_duration, formatTime(durationMs))
                val progress =
                    if (durationMs > 0) ((positionMs.toLong() * 100) / durationMs).toInt().coerceIn(0, 100) else 0
                views.setProgressBar(R.id.widget_seek, 100, progress, false)
            } else {
                views.setTextViewText(R.id.widget_title, context.getString(R.string.widget_title_default))
                // No track in the queue — show the playlist that the session is bound to
                // ("All Songs", "Favourites", ...) instead of an empty second line.
                views.setTextViewText(R.id.widget_artist, p.getString(KEY_PLAYLIST, "") ?: "")
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

        /** Largest power-of-two inSampleSize keeping both decoded sides >= [targetPx]. */
        private fun computeSampleSize(width: Int, height: Int, targetPx: Int): Int {
            var sample = 1
            while (sample < 16 && width / (sample * 2) >= targetPx && height / (sample * 2) >= targetPx) {
                sample *= 2
            }
            return sample
        }

        private fun decodeArt(context: Context, encoded: String): Bitmap? {
            // album_art is stored as a content:// URI (artwork authority) whose path segment
            // is the plain file path of the cached thumbnail. The provider behind that
            // authority is not registered, so resolve the file path and decode directly —
            // the widget runs in the app process and can read its own cache files.
            val uri = try {
                Uri.parse(encoded)
            } catch (e: Throwable) {
                return null
            }
            var path = if (uri.scheme == "content" || uri.scheme == "file") uri.path else encoded
            if (path.isNullOrBlank()) return null
            // The path may be percent-encoded (e.g. %20 for spaces) — decode before file IO.
            path = Uri.decode(path) ?: path
            val file = java.io.File(path)
            if (!file.isFile) {
                Log.w(LOG_TAG, "art file missing: $path")
                return null
            }
            // The art cell is only 36dp — decoding a full-resolution album cover wastes
            // 10-20x the memory, so probe bounds first and decode with inSampleSize.
            val targetPx = (ART_CELL_DP * context.resources.displayMetrics.density).toInt()
            val opts = BitmapFactory.Options().apply { inJustDecodeBounds = true }
            try {
                context.contentResolver.openInputStream(uri)?.use {
                    BitmapFactory.decodeStream(it, null, opts)
                }
            } catch (e: Throwable) {
                // Resolver not available — bounds will be probed from the file below.
            }
            if (opts.outWidth <= 0 || opts.outHeight <= 0) {
                BitmapFactory.decodeFile(path, opts)
            }
            if (opts.outWidth <= 0 || opts.outHeight <= 0) {
                Log.w(LOG_TAG, "could not probe art bounds: $path")
                return null
            }
            opts.inJustDecodeBounds = false
            opts.inSampleSize = computeSampleSize(opts.outWidth, opts.outHeight, targetPx)
            // Prefer the resolver (correct whenever the authority IS registered), then fall back
            // to reading the resolved path directly — which is the case this widget relies on.
            // The artwork authority is NOT registered, so the resolver THROWS
            // FileNotFoundException ("No content provider") rather than returning null; the
            // `?:` below therefore never runs. Catch the throw and decode the file directly.
            return try {
                context.contentResolver.openInputStream(uri)?.use {
                    BitmapFactory.decodeStream(it, null, opts)
                } ?: BitmapFactory.decodeFile(path, opts)
            } catch (e: Throwable) {
                Log.w(LOG_TAG, "resolver decode failed for $encoded ($e); decoding file directly")
                try {
                    BitmapFactory.decodeFile(path, opts)
                } catch (e2: Throwable) {
                    Log.w(LOG_TAG, "could not decode art file $path: $e2")
                    null
                }
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

        /**
         * Overlay the user-chosen theme colors on top of [views] (produced by [render]).
         * Operates on the SAME RemoteViews so the transport PendingIntents and the real
         * song text / seek progress are preserved — only colors are overridden.
         * Colors come from the `HomeWidgetPreferences` prefs written by the home_widget
         * plugin (same keys saveWidgetData uses: widget_background / widget_text / widget_accent).
         */
        private fun applyTheme(context: Context, views: RemoteViews): RemoteViews {
            val preferences = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
            val backgroundColor = readColor(preferences.getString("widget_background", null), DEFAULT_BACKGROUND)
            val textColor = readColor(preferences.getString("widget_text", null), DEFAULT_TEXT)
            val accentColor = readColor(preferences.getString("widget_accent", null), DEFAULT_ACCENT)

            views.setTextColor(R.id.widget_title, textColor)
            views.setTextColor(R.id.widget_artist, textColor)
            views.setTextColor(R.id.widget_position, textColor)
            views.setTextColor(R.id.widget_duration, textColor)
            // The root's default background is @drawable/widget_bg (a rounded card). There is
            // no public RemoteViews API to tint a shape drawable's solid color at runtime, so
            // a user-chosen background is applied flat via setBackgroundColor, which replaces
            // the card with a solid color — the launcher canvas then shows through the corners.
            views.setInt(R.id.widget_root, "setBackgroundColor", backgroundColor)
            // Transport icons are vector drawables with a fixed white fill, so they would keep
            // rendering white no matter which theme the user picked. ImageView#setColorFilter(int)
            // is public, so RemoteViews' setInt reflection can reach it. Every render re-sets
            // these buttons to a drawable (never a bitmap), so the filter is always reapplied and
            // never goes stale.
            views.setInt(R.id.widget_btn_prev, "setColorFilter", accentColor)
            views.setInt(R.id.widget_btn_play, "setColorFilter", accentColor)
            views.setInt(R.id.widget_btn_next, "setColorFilter", accentColor)
            // Seek-bar accent is intentionally NOT set here: every RemoteViews API that recolors
            // a ProgressBar's fill (setProgressTintList, setProgressDrawable,
            // setProgressBackgroundTintList) is @hide / framework-internal, so stock Android
            // offers no public way to tint the fill at runtime. It stays static via
            // android:progressTint in widget_music_player.xml (@color/widget_accent).
            return views
        }

        /** Parse a color written by the Dart side, falling back to [fallback] on a malformed value. */
        private fun readColor(raw: String?, fallback: String): Int = try {
            Color.parseColor(raw ?: fallback)
        } catch (e: IllegalArgumentException) {
            Log.w(LOG_TAG, "unparseable widget color '$raw', falling back to $fallback")
            Color.parseColor(fallback)
        }

        /**
         * Single render path: the song state from [render] and the theme from [applyTheme] are
         * always published in the SAME RemoteViews, so the two can never disagree (a separate
         * unthemed update would also decode the album art twice per change).
         */
        private fun renderWidget(context: Context, mgr: AppWidgetManager, ids: IntArray) {
            val views = applyTheme(context, render(context))
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
        renderWidget(context, appWidgetManager, appWidgetIds)
    }

    override fun onEnabled(context: Context) {
        refreshAll(context)
        Log.d(LOG_TAG, "widget placed on home screen")
    }

    override fun onDisabled(context: Context) {
        Log.d(LOG_TAG, "widget removed from home screen")
    }
}
