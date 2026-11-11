package app.quriva.nativeapp.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class ChapterRecitationResponse(
    @SerialName("audio_file") val audioFile: AudioFileDto? = null,
)

@Serializable
data class AudioFileDto(
    @SerialName("audio_url") val audioUrl: String? = null,
    val timestamps: List<VerseTimestampDto> = emptyList(),
)

@Serializable
data class VerseTimestampDto(
    @SerialName("verse_key") val verseKey: String = "",
    @SerialName("timestamp_from") val timestampFrom: Int = 0,
    @SerialName("timestamp_to") val timestampTo: Int = 0,
)

data class VerseTimestamp(
    val verseKey: String,
    val fromMs: Int,
    val toMs: Int,
) {
    val chapterId: Int get() = verseKey.substringBefore(':', "0").toIntOrNull() ?: 0
    val verseNumber: Int get() = verseKey.substringAfter(':', "0").toIntOrNull() ?: 0
}

data class ChapterAudioTimeline(
    val audioUrl: String?,
    val timestamps: List<VerseTimestamp>,
)

fun VerseTimestampDto.toDomain() = VerseTimestamp(
    verseKey = verseKey,
    fromMs = timestampFrom,
    toMs = timestampTo,
)

fun AudioFileDto.toDomain() = ChapterAudioTimeline(
    audioUrl = audioUrl,
    timestamps = timestamps.map { it.toDomain() },
)
