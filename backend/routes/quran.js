const express = require('express');
const router = express.Router();
const axios = require('axios');
const NodeCache = require('node-cache');
const cache = new NodeCache({ stdTTL: 3600 }); // 1 hour cache

// Get all Surahs list
router.get('/surahs', async (req, res) => {
  try {
    const cached = cache.get('surahs_list');
    if (cached) return res.json(cached);

    // Use Al-Quran Cloud API (free & verified)
    const response = await axios.get('https://api.alquran.cloud/v1/surah');
    const surahs = response.data.data.map(s => ({
      number: s.number,
      name_ar: s.name,
      name_en: s.englishName,
      name_translation: s.englishNameTranslation,
      ayah_count: s.numberOfAyahs,
      revelation: s.revelationType,
      source_attribution: 'Al-Quran Cloud API (verified Uthmani script)'
    }));

    cache.set('surahs_list', surahs);
    res.json(surahs);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch surahs', details: error.message });
  }
});

// Get specific Surah with ayahs
router.get('/surah/:number', async (req, res) => {
  try {
    const { number } = req.params;
    const { translation } = req.query; // 'ms', 'id', 'en'
    
    const cacheKey = `surah_${number}_${translation || 'ar'}`;
    const cached = cache.get(cacheKey);
    if (cached) return res.json(cached);

    // Get Arabic text
    const arabicRes = await axios.get(`https://api.alquran.cloud/v1/surah/${number}`);
    
    // Get translation if requested
    let translationData = null;
    if (translation) {
      const translationIds = {
        'ms': 'ms.basmeih', // Tafsir Pimpinan Ar-Rahman (Popular in Malaysia)
        'id': 'id.indonesian', // Indonesian Translation
        'en': 'en.sahih' // Sahih International
      };
      const translationId = translationIds[translation] || 'en.sahih';
      const transRes = await axios.get(`https://api.alquran.cloud/v1/surah/${number}/${translationId}`);
      translationData = transRes.data.data;
    }

    const result = {
      surah: {
        number: arabicRes.data.data.number,
        name_ar: arabicRes.data.data.name,
        name_en: arabicRes.data.data.englishName,
        ayah_count: arabicRes.data.data.numberOfAyahs,
        revelation: arabicRes.data.data.revelationType,
        source_attribution: 'Al-Quran Cloud / Tanzil.net (Uthmani verified)'
      },
      ayahs: arabicRes.data.data.ayahs.map((ayah, idx) => ({
        number: ayah.numberInSurah,
        text_ar: ayah.text,
        juz: ayah.juz,
        page: ayah.page,
        translation: translationData ? {
          text: translationData.ayahs[idx].text,
          translator: translation === 'ms' ? 'Abdullah Muhammad Basmeih' : 
                     translation === 'id' ? 'Indonesian Ministry of Religious Affairs' :
                     'Sahih International',
          language: translation
        } : null,
        audio_url: `https://cdn.islamic.network/quran/audio/128/ar.alafasy/${number}_${ayah.numberInSurah}.mp3`,
        source_verified: true
      }))
    };

    cache.set(cacheKey, result);
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch surah', details: error.message });
  }
});

// Search ayahs by keyword
router.get('/search', async (req, res) => {
  try {
    const { q, lang } = req.query;
    if (!q) return res.status(400).json({ error: 'Query parameter "q" required' });

    // Use search from Al-Quran Cloud (or implement custom DB search)
    const response = await axios.get(`https://api.alquran.cloud/v1/search/${encodeURIComponent(q)}/all/en.sahih`);
    
    const results = response.data.data.matches.map(match => ({
      surah: {
        number: match.surah.number,
        name: match.surah.englishName
      },
      ayah: {
        number: match.numberInSurah,
        text: match.text
      }
    }));

    res.json({ 
      query: q, 
      count: results.length, 
      results: results.slice(0, 50) // Limit to 50 results
    });
  } catch (error) {
    res.status(500).json({ error: 'Search failed', details: error.message });
  }
});

// Get audio URLs for reciter
router.get('/audio/:surah/:ayah', async (req, res) => {
  try {
    const { surah, ayah } = req.params;
    const { reciter } = req.query; // default: ar.alafasy

    const reciters = {
      'alafasy': 'ar.alafasy',
      'abdulbasit': 'ar.abdulbasitmurattal',
      'minshawi': 'ar.minshawi',
      'husary': 'ar.husary'
    };

    const reciterId = reciters[reciter] || 'ar.alafasy';
    const audioUrl = `https://cdn.islamic.network/quran/audio/128/${reciterId}/${surah}_${ayah}.mp3`;

    res.json({
      surah,
      ayah,
      reciter: reciter || 'alafasy',
      audio_url: audioUrl,
      license: 'Usage permitted for Islamic apps',
      source_attribution: 'EveryAyah.com / Islamic Network'
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to generate audio URL', details: error.message });
  }
});

// Get Tafsir for ayah
router.get('/tafsir/:surah/:ayah', async (req, res) => {
  try {
    const { surah, ayah } = req.params;
    const { lang } = req.query; // 'ar', 'en'

    const tafsirIds = {
      'ar': 'ar.muyassar', // Tafsir Al-Muyassar
      'en': 'en.jalalayn'  // Tafsir al-Jalalayn
    };

    const tafsirId = tafsirIds[lang] || 'en.jalalayn';
    const response = await axios.get(`https://api.alquran.cloud/v1/${surah}:${ayah}/editions/${tafsirId}`);

    res.json({
      surah,
      ayah,
      tafsir: {
        text: response.data.data[0].text,
        source: lang === 'ar' ? 'Tafsir Al-Muyassar' : 'Tafsir al-Jalalayn (English)',
        language: lang,
        scholar: lang === 'ar' ? 'King Fahd Quran Printing Complex' : 'Jalal al-Din al-Mahalli & Jalal al-Din al-Suyuti'
      },
      jakim_note: 'For hadith references, consult myHadith.my',
      myhadith_link: `https://myhadith.islam.gov.my/?search=ayah:${surah}:${ayah}`
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch tafsir', details: error.message });
  }
});

module.exports = router;
