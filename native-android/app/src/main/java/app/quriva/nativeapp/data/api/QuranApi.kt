package app.qurora.nativeapp.data.api

import app.quriva.nativeapp.data.model.ChapterRecitationResponse
import app.quriva.nativeapp.data.model.ChaptersResponse
import app.quriva.nativeapp.data.model.TranslationsResponse
import app.quriva.nativeapp.data.model.VersesResponse
import com.jakewharton.retrofit2.converter.kotlinx.serialization.asConverterFactory
import kotlinx.serialization.json.Json
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.http.GET
import retrofit2.http.Path
import retrofit2.http.Query
import java.util.concurrent.TimeUnit

interface QuranApi {
    @GET("chapters")
    suspend fun chapters(
        @Query("language") language: String = "en",
    ): ChaptersResponse

    @GET("quran/verses/uthmani")
    suspend fun versesUthmani(
        @Query("chapter_number") chapterNumber: Int,
    ): VersesResponse

    @GET("quran/translations/{translationId}")
    suspend fun translations(
        @Path("translationId") translationId: Int,
        @Query("chapter_number") chapterNumber: Int,
    ): TranslationsResponse

    @GET("chapter_recitations/{reciterId}/{chapterNumber}")
    suspend fun chapterRecitation(
        @Path("reciterId") reciterId: Int,
        @Path("chapterNumber") chapterNumber: Int,
        @Query("segments") segments: Boolean = true,
    ): ChapterRecitationResponse

    companion object {
        private const val BASE_URL = "https://api.quran.com/api/v4/"

        fun create(enableLogging: Boolean = false): QuranApi {
            val json = Json {
                ignoreUnknownKeys = true
                coerceInputValues = true
            }
            val clientBuilder = OkHttpClient.Builder()
                .connectTimeout(20, TimeUnit.SECONDS)
                .readTimeout(20, TimeUnit.SECONDS)
            if (enableLogging) {
                clientBuilder.addInterceptor(
                    HttpLoggingInterceptor().apply {
                        level = HttpLoggingInterceptor.Level.BASIC
                    },
                )
            }
            return Retrofit.Builder()
                .baseUrl(BASE_URL)
                .client(clientBuilder.build())
                .addConverterFactory(json.asConverterFactory("application/json".toMediaType()))
                .build()
                .create(QuranApi::class.java)
        }
    }
}
