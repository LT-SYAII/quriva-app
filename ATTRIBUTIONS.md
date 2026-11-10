# Content & data attributions for Quriva

Quriva does not bundle Quran content. Everything is fetched at runtime from
the sources listed below and cached locally on the user's device. This file
explains exactly where every type of content comes from and how it must be
credited. Last verified: 2026-11-10.

## 1. Quran text (Arabic, Uthmani)

- Endpoint: `GET https://api.quran.com/api/v4/quran/verses/uthmani`
- Used in: Reader screen (all ayat), Search results.
- Provider: **Quran.com** official API (v4).

## 2. Chapter (surah) metadata

- Endpoint: `GET https://api.quran.com/api/v4/chapters?language=en|id`
- Fields used: id, name_simple, name_arabic, revelation_place,
  verses_count, translated_name.
- Provider: **Quran.com** official API (v4).

## 3. Translations

- Endpoint: `GET https://api.quran.com/api/v4/quran/translations/{id}?chapter_number=N`
- Endpoint list: `GET https://api.quran.com/api/v4/resources/translations?language=en`
- Defaults in Quriva: id **20** = *Saheeh International* (English),
  id **33** = *Ministry of Islamic Affairs, Kingdom of Saudi Arabia*
  (Indonesian, "Indonesian Islamic Affairs Ministry" on Quran.com).
- Users may select other translations offered by Quran.com; each translation
  remains the work of its named author/publisher, performed and attributed
  by Quran.com. Quriva displays translations as-is and does not modify the
  content of these works.

## 4. Surah background info

- Endpoint: `GET https://api.quran.com/api/v4/chapters/{id}/info?language=en`
- Example source indicated by the API: *Sayyid Abul Ala Maududi —
  Tafhim al-Qur'an — The Meaning of the Quran*.
- Quriva renders this text as plain text and shows the API-provided source
  string on screen (e.g. "Source: … — via Quran.com API").

## 5. Search

- Endpoint: `GET https://api.quran.com/api/v4/search?q=…&size=…&page=…&language=en`
- Results include the Arabic text and the translation texts of the
  translators listed above. Attribution stays intact.

## 6. Recitations (audio)

- Endpoint: `GET https://api.quran.com/api/v4/chapter_recitations/{reciter_id}/{chapter}`
- The API returns a single mp3 per surah, hosted by **Quranicaudio**
  (`download.quranicaudio.com`) on behalf of Quran.com.
- Reciters keep the copyright of their own recordings. Quriva only streams;
  it does not copy or redistribute audio files. The selected reciter and
  their recitation are always shown in the playback UI.

## 7. Trademark & affiliation note

- "Quran.com", "Quranicaudio", "The Noble Qur'an" and reciter names belong
  to their respective owners. Quriva is an independent, unaffiliated
  open-source client that gratefully uses their published API.
- Modifications of the Quranic text by machine conversion are avoided. Any
  future change of source must (a) keep the original text unchanged,
  (b) record the source and date here, and (c) revive the integrity tests.
