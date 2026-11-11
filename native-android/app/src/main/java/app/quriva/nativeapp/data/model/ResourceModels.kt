package app.quriva.nativeapp.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class RecitersResponse(val recitations: List<ReciterDto> = emptyList())

@Serializable
data class ReciterDto(
    val id: Int,
    @SerialName("reciter_name") val reciterName: String = "Unknown reciter",
    val style: String? = null,
)

data class Reciter(val id: Int, val name: String, val style: String?) {
    val displayName: String get() = if (style.isNullOrBlank()) name else "$name ($style)"
}

fun ReciterDto.toDomain() = Reciter(id, reciterName, style)

@Serializable
data class TranslationsResponseList(val translations: List<TranslationResourceDto> = emptyList())

@Serializable
data class TranslationResourceDto(
    val id: Int,
    val name: String = "Unknown translation",
    @SerialName("author_name") val authorName: String = "",
    @SerialName("language_name") val languageName: String = "",
)

data class TranslationResource(
    val id: Int,
    val name: String,
    val authorName: String,
    val languageName: String,
)

fun TranslationResourceDto.toDomain() = TranslationResource(id, name, authorName, languageName)

@Serializable
data class ChapterInfoResponse(@SerialName("chapter_info") val chapterInfo: ChapterInfoDto? = null)

@Serializable
data class ChapterInfoDto(
    @SerialName("short_text") val shortText: String = "",
    val text: String = "",
    val source: String = "",
)

data class ChapterInfo(val shortText: String, val textHtml: String, val source: String)

fun ChapterInfoDto.toDomain() = ChapterInfo(shortText, text, source)

@Serializable
data class SearchResponse(val search: SearchPageDto = SearchPageDto())

@Serializable
data class SearchPageDto(
    val query: String = "",
    @SerialName("total_results") val totalResults: Int = 0,
    @SerialName("current_page") val currentPage: Int = 1,
    @SerialName("total_pages") val totalPages: Int = 1,
    val results: List<SearchResultDto> = emptyList(),
)

@Serializable
data class SearchResultDto(
    @SerialName("verse_key") val verseKey: String = "",
    val text: String = "",
    val translations: List<SearchTranslationDto> = emptyList(),
)

@Serializable
data class SearchTranslationDto(val name: String = "", val text: String = "")

data class SearchResult(
    val verseKey: String,
    val arabicText: String,
    val translationText: String,
) {
    val chapterId: Int get() = verseKey.substringBefore(':', "0").toIntOrNull() ?: 0
    val verseNumber: Int get() = verseKey.substringAfter(':', "0").toIntOrNull() ?: 0
}

fun SearchResultDto.toDomain() = SearchResult(
    verseKey = verseKey,
    arabicText = text,
    translationText = translations.firstOrNull()?.text.orEmpty(),
)
