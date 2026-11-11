package app.quriva.nativeapp.data.api

import app.quriva.nativeapp.data.model.ChaptersResponse
import com.jakewharton.retrofit2.converter.kotlinx.serialization.asConverterFactory
import kotlinx.serialization.json.Json
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.http.GET
import retrofit2.http.Query
import java.util.concurrent.TimeUnit

interface QuranApi {
    @GET("chapters")
    suspend fun chapters(
        @Query("language") language: String = "en",
    ): ChaptersResponse

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
