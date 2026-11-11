package app.quriva.nativeapp.audio

import android.content.ComponentName
import android.content.Context
import androidx.core.content.ContextCompat
import androidx.media3.session.MediaController
import androidx.media3.session.SessionToken
import com.google.common.util.concurrent.ListenableFuture
import com.google.common.util.concurrent.MoreExecutors

object PlaybackController {
    @Volatile private var controllerFuture: ListenableFuture<MediaController>? = null
    @Volatile private var controller: MediaController? = null

    fun ensure(context: Context) {
        if (controller != null || controllerFuture != null) return
        ContextCompat.startForegroundService(context, android.content.Intent(context, PlaybackService::class.java))
        val token = SessionToken(context, ComponentName(context, PlaybackService::class.java))
        val future = MediaController.Builder(context, token).buildAsync()
        controllerFuture = future
        future.addListener({
            try { controller = future.get() } catch (_: Exception) {}
        }, MoreExecutors.directExecutor())
    }

    fun play(context: Context, now: NowPlaying) {
        ensure(context)
        PlaybackState.updateNowPlaying(now)
        // service observes nowPlaying; controller will pick up once ready
        controller?.play()
    }

    fun toggle() {
        val c = controller ?: return
        if (c.isPlaying) c.pause() else c.play()
    }

    fun pause() { controller?.pause() }
    fun resume() { controller?.play() }
    fun seekTo(ms: Long) { controller?.seekTo(ms) }
    fun stop() {
        controller?.stop()
        PlaybackState.updateNowPlaying(null)
    }
}


    fun retry(context: Context) {
        val np = PlaybackState.nowPlaying.value ?: return
        PlaybackState.updateError(null)
        // trigger reload by clearing current tracking in service via re-emitting same nowPlaying
        PlaybackState.updateNowPlaying(null)
        PlaybackState.updateNowPlaying(np)
        ensure(context)
    }
