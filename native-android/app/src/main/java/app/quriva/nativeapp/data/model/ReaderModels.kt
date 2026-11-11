package app.quriva.nativeapp.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class VersesResponse(
    val verses: List<VerseDto> = emptyList(),
)

@Serializable
data class VerseDto(
    @SerialName("verse_key") val verseKey: String = "",
    @SerialName("text_uthmani") val textUthmani: String = "",
)

@Serializable
data class TranslationsResponse(
    val translations: List<TranslationDto> = emptyList(),
)

@Serializable
data class TranslationDto(
    val text: String = "",
)

data class ReaderVerse(
    val chapterId: Int,
    val number: Int,
    val arabic: String,
    val translation: String,
) {
    val key: String get() = "$chapterId:$number"
}

fun VerseDto.toReaderVerse(chapterId: Int, translation: String): ReaderVerse {
    val number = verseKey.substringAfter(':', "0").toIntOrNull() ?: 0
    return ReaderVerse(
        chapterId = chapterId,
        number = number,
        arabic = textUthmani,
        translation = translation,
    )
}
