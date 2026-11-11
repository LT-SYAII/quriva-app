package app.quriva.nativeapp.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class ChaptersResponse(
    val chapters: List<ChapterDto> = emptyList(),
)

@Serializable
data class ChapterDto(
    val id: Int,
    @SerialName("name_simple") val nameSimple: String = "",
    @SerialName("name_arabic") val nameArabic: String = "",
    @SerialName("revelation_place") val revelationPlace: String = "",
    @SerialName("verses_count") val versesCount: Int = 0,
    @SerialName("translated_name") val translatedName: TranslatedNameDto? = null,
)

@Serializable
data class TranslatedNameDto(
    val name: String = "",
)

data class Chapter(
    val id: Int,
    val nameSimple: String,
    val nameArabic: String,
    val revelationPlace: String,
    val versesCount: Int,
    val translatedName: String,
) {
    val revelationLabel: String
        get() = if (revelationPlace.equals("makkah", ignoreCase = true)) "Makkah" else "Madinah"
}

fun ChapterDto.toDomain(): Chapter = Chapter(
    id = id,
    nameSimple = nameSimple,
    nameArabic = nameArabic,
    revelationPlace = revelationPlace,
    versesCount = versesCount,
    translatedName = translatedName?.name?.ifBlank { nameSimple } ?: nameSimple,
)
