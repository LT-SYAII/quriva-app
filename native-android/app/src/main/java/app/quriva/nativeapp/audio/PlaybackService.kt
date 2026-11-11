package app.quriva.nativeapp.audio

import android.app.PendingIntent
import android.content.Intent
import androidx.media3.common.AudioAttributes
import androidx.media3.common.MediaItem
import androidx.media3.common.MediaMetadata
import androidx.media3.common.Player
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.session.MediaSession
import androidx.media3.session.MediaSessionService
import app.quriva.nativeapp.MainActivity
import com.google.common.util.concurrent.Futures
import com.google.common.util.concurrent.ListenableFuture
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch

class PlaybackService : MediaSessionService() {
    private var player: ExoPlayer? = null
    private var mediaSession: MediaSession? = null
    private val serviceScope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)
    private var progressJob: Job? = null
    private var currentUrl: String? = null

    override fun onCreate() {
        super.onCreate()
        val audioAttrs = AudioAttributes.Builder()
            .setUsage(androidx.media3.common.C.USAGE_MEDIA)
            .setContentType(androidx.media3.common.C.AUDIO_CONTENT_TYPE_MUSIC)
            .build()

        val exo = ExoPlayer.Builder(this).build().apply {
            setAudioAttributes(audioAttrs, true)
            setHandleAudioBecomingNoisy(true)
            addListener(object : Player.Listener {
                override fun onIsPlayingChanged(isPlaying: Boolean) {
                    PlaybackState.updatePlaying(isPlaying)
                }
            })
        }
        player = exo

        val sessionActivityPendingIntent = PendingIntent.getActivity(
            this,
            0,
            Intent(this, MainActivity::class.java),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )

        mediaSession = MediaSession.Builder(this, exo)
            .setSessionActivity(sessionActivityPendingIntent)
            .setCallback(object : MediaSession.Callback {
                override fun onAddMediaItems(
                    mediaSession: MediaSession,
                    controller: MediaSession.ControllerInfo,
                    mediaItems: MutableList<MediaItem>,
                ): ListenableFuture<MutableList<MediaItem>> {
                    val updated = mediaItems.map { item ->
                        item.buildUpon().setUri(item.requestMetadata.mediaUri ?: item.localConfiguration?.uri).build()
                    }.toMutableList()
                    return Futures.immediateFuture(updated)
                }
            })
            .build()

        serviceScope.launch {
            PlaybackState.nowPlaying.collect { np ->
                if (np == null) {
                    stopProgress()
                    exo.stop()
                    exo.clearMediaItems()
                    currentUrl = null
                } else if (np.audioUrl.isNotBlank() && np.audioUrl != currentUrl) {
                    currentUrl = np.audioUrl
                    val meta = MediaMetadata.Builder()
                        .setTitle(np.chapterName)
                        .setArtist("Quriva")
                        .build()
                    val item = MediaItem.Builder()
                        .setUri(np.audioUrl)
                        .setMediaId("${np.chapterId}-${np.reciterId}")
                        .setMediaMetadata(meta)
                        .build()
                    exo.setMediaItem(item)
                    exo.prepare()
                    exo.playWhenReady = true
                    startProgress(exo)
                }
            }
        }
    }

    private fun startProgress(exo: ExoPlayer) {
        progressJob?.cancel()
        progressJob = serviceScope.launch {
            while (isActive) {
                PlaybackState.updatePosition(exo.currentPosition)
                val ts = PlaybackState.nowPlaying.value?.timestamps.orEmpty()
                if (ts.isNotEmpty()) {
                    val pos = exo.currentPosition.toInt()
                    val v = ts.firstOrNull { pos >= it.fromMs && pos <= it.toMs }?.verseNumber ?: -1
                    PlaybackState.updateActiveVerse(v)
                } else {
                    PlaybackState.updateActiveVerse(-1)
                }
                delay(250)
            }
        }
    }

    private fun stopProgress() {
        progressJob?.cancel()
        progressJob = null
    }

    override fun onGetSession(controllerInfo: MediaSession.ControllerInfo): MediaSession? = mediaSession

    override fun onTaskRemoved(rootIntent: Intent?) {
        val p = player
        if (p == null || !p.playWhenReady || p.mediaItemCount == 0) stopSelf()
    }

    override fun onDestroy() {
        stopProgress()
        mediaSession?.run { player.release(); release() }
        mediaSession = null
        player = null
        currentUrl = null
        serviceScope.cancel()
        super.onDestroy()
    }
}
