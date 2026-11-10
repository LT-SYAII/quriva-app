# Data licenses for Quriva

Quriva's source code is MIT-licensed (see `LICENSE`). The Quranic content it
displays arrives from third-party providers with their own terms; Quriva as
a *client* does not redistribute or re-license that content. This file
records the compliance approach so contributions follow the same rules.

## Content licenses (provider-specific)

| Content | Provider | Notes |
|---|---|---|
| Arabic Uthmani text | Quran.com (API v4) | Served through the published public API. |
| Chapter metadata | Quran.com (API v4) | Served through the published public API. |
| Translation: Saheeh International | Quran.com resources | Shown as-is with author attribution. |
| Translation: Indonesian Islamic Affairs Ministry (Kemenag) | Quran.com resources | Official Indonesian translation; shown as-is. |
| Other translations chosen by the user | Respective authors via Quran.com | Quriva does not modify or re-host them. |
| Surah info (e.g. Tafhim al-Qur'an) | Maududi / via Quran.com | Quoted in-app with the API-provided source string. |
| Recitations | Reciters via Quranicaudio | Paused, played and seeked — always streamed, never copied. |

## Rules for this project

1. Never embed Quranic text, translations, tafsir or audio inside the app
   or any release artifact.
2. Always display the source/author attribution where content appears.
3. Keep `ATTRIBUTIONS.md` in sync whenever a source endpoint changes.
4. Any "offline export" feature must clearly state that the files belong to
   their original providers and must carry the attributions above.
5. Content integrity: do not programmatically rewrite Arabic text; if the
   data shape changes, verify against the provider before shipping.

## When in doubt

Contact the provider, keep attribution, and prefer the published API.
Legal questions belong to the project maintainers with local counsel.
