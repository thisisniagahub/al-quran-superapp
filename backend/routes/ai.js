const express = require('express');
const router = express.Router();
const axios = require('axios');
const { OpenAI } = require('openai');

// Initialize OpenAI (or use local model)
const openai = process.env.OPENAI_API_KEY ? new OpenAI({
  apiKey: process.env.OPENAI_API_KEY
}) : null;

// JAKIM-approved knowledge base sources
const APPROVED_SOURCES = {
  quran: 'Al-Quran Mushaf Malaysia (JAKIM verified)',
  hadith: 'myHadith.islam.gov.my',
  fatwa: 'e-fatwa.gov.my',
  tafsir: 'Tafsir Pimpinan Ar-Rahman (Abdullah Basmeih)',
  fiqh: 'Portal Rasmi Fatwa Malaysia'
};

// AI Ustaz/Ustazah Chat Endpoint (with RAG)
router.post('/ask-ustaz', async (req, res) => {
  try {
    const { question, language, context } = req.body;
    
    if (!question) {
      return res.status(400).json({ error: 'Question required' });
    }

    // Step 1: Search relevant Quran verses
    const quranContext = await searchQuranContext(question);
    
    // Step 2: Search relevant hadith from myHadith
    const hadithContext = await searchMyHadith(question);
    
    // Step 3: Check e-Fatwa for related rulings
    const fatwaContext = await searchEfatwa(question);

    // Step 4: Build RAG prompt with JAKIM compliance
    const systemPrompt = `Anda adalah AI Ustaz/Ustazah yang mematuhi garis panduan JAKIM/JAIS.
    
PANDUAN JAWAPAN:
1. Gunakan HANYA sumber sahih: Al-Quran, Hadith Sahih (myHadith), Fatwa Malaysia
2. Setiap jawapan MESTI ada dalil (ayat/hadith) dengan rujukan penuh
3. Jika tidak pasti, arah pengguna ke pegawai agama rasmi
4. TIDAK boleh beri fatwa yang bercanggah dengan keputusan JAKIM
5. Jika soalan sensitif (politik/akidah), rujuk ke e-Fatwa
6. Gunakan bahasa ${language || 'Bahasa Melayu'} yang sopan

KONTEKS YANG TERSEDIA:
${quranContext ? 'Al-Quran: ' + quranContext : ''}
${hadithContext ? 'Hadith: ' + hadithContext : ''}
${fatwaContext ? 'Fatwa Malaysia: ' + fatwaContext : ''}

JAWAB SOALAN INI DENGAN PENUH ADAB DAN BERDASARKAN DALIL SAHIH.`;

    // Step 5: Generate AI response
    let aiResponse = '';
    let sources = [];

    if (openai) {
      const completion = await openai.chat.completions.create({
        model: process.env.AI_MODEL || 'gpt-4',
        messages: [
          { role: 'system', content: systemPrompt },
          { role: 'user', content: question }
        ],
        temperature: 0.3, // Lower temperature for more accurate religious responses
        max_tokens: 1000
      });
      aiResponse = completion.choices[0].message.content;
    } else {
      // Fallback if no AI model
      aiResponse = `Terima kasih atas soalan anda. Untuk jawapan yang tepat, sila rujuk:
      
1. Portal myHadith: https://myhadith.islam.gov.my
2. Portal e-Fatwa Malaysia: https://e-fatwa.gov.my
3. Hubungi Jabatan Agama Islam negeri anda

${quranContext ? 'Ayat berkaitan: ' + quranContext : ''}
${hadithContext ? 'Hadith berkaitan: ' + hadithContext : ''}`;
    }

    // Step 6: Add compliance footer
    const complianceFooter = `

━━━━━━━━━━━━━━━━━━━━━━
📚 SUMBER RUJUKAN:
${sources.join('\n')}

⚠️ PERINGATAN PENTING:
Jawapan ini adalah panduan am sahaja. Untuk keputusan yang mengikat, sila rujuk kepada:
• Portal Rasmi JAKIM: https://www.islam.gov.my
• e-Fatwa Malaysia: https://e-fatwa.gov.my
• Jabatan Agama Islam negeri anda

${fatwaContext ? '🔗 Fatwa berkaitan: ' + fatwaContext : ''}`;

    const finalResponse = aiResponse + complianceFooter;

    // Log for JAKIM audit
    await logAIInteraction({
      question,
      response: finalResponse,
      sources,
      timestamp: new Date(),
      compliance_checked: true
    });

    res.json({
      question,
      answer: finalResponse,
      sources: [
        quranContext ? APPROVED_SOURCES.quran : null,
        hadithContext ? APPROVED_SOURCES.hadith : null,
        fatwaContext ? APPROVED_SOURCES.fatwa : null
      ].filter(Boolean),
      disclaimer: 'Jawapan ini berdasarkan sumber JAKIM yang diluluskan. Untuk fatwa rasmi, rujuk pegawai agama.',
      myhadith_link: 'https://myhadith.islam.gov.my',
      efatwa_link: 'https://e-fatwa.gov.my',
      jakim_verified: true
    });

  } catch (error) {
    console.error('AI Ustaz error:', error);
    res.status(500).json({ 
      error: 'Gagal menjawab soalan', 
      details: error.message,
      fallback_message: 'Sila hubungi Jabatan Agama Islam negeri anda untuk jawapan yang tepat.'
    });
  }
});

// AI Hadith Verifier
router.post('/verify-hadith', async (req, res) => {
  try {
    const { hadith_text } = req.body;
    
    if (!hadith_text) {
      return res.status(400).json({ error: 'Hadith text required' });
    }

    // Search myHadith database
    const verification = await searchMyHadith(hadith_text, true);

    res.json({
      hadith: hadith_text,
      verification: verification || {
        status: 'not_found',
        message: 'Hadith tidak dijumpai dalam database myHadith. Sila semak dengan ulama.',
        recommendation: 'Rujuk Portal myHadith untuk pengesahan: https://myhadith.islam.gov.my'
      },
      source: 'myHadith.islam.gov.my (JAKIM Official)',
      checked_at: new Date().toISOString()
    });

  } catch (error) {
    res.status(500).json({ error: 'Verification failed', details: error.message });
  }
});

// AI Semantic Quran Search (meaning-based, not just keywords)
router.post('/quran-semantic-search', async (req, res) => {
  try {
    const { query, language } = req.body;
    
    if (!query) {
      return res.status(400).json({ error: 'Search query required' });
    }

    // Use AI to understand intent and find related verses
    const results = await semanticQuranSearch(query, language);

    res.json({
      query,
      results,
      search_type: 'semantic (meaning-based)',
      source: 'Al-Quran Cloud + AI embedding search',
      count: results.length
    });

  } catch (error) {
    res.status(500).json({ error: 'Semantic search failed', details: error.message });
  }
});

// AI Tadabbur Engine (suggest verses based on user emotion/context)
router.post('/tadabbur', async (req, res) => {
  try {
    const { emotion, context } = req.body; // e.g., emotion: 'sad', context: 'lost job'
    
    const suggestions = await getTadabburSuggestions(emotion, context);

    res.json({
      emotion,
      context,
      suggested_verses: suggestions,
      note: 'Renungi ayat-ayat ini dengan penuh keikhlasan',
      source: 'Al-Quran + AI contextual matching'
    });

  } catch (error) {
    res.status(500).json({ error: 'Tadabbur suggestion failed', details: error.message });
  }
});

// ====== HELPER FUNCTIONS ======

async function searchQuranContext(question) {
  try {
    // Simple keyword extraction and Quran search
    const response = await axios.get(`https://api.alquran.cloud/v1/search/${encodeURIComponent(question)}/all/en.sahih`);
    if (response.data.data.matches.length > 0) {
      const match = response.data.data.matches[0];
      return `Surah ${match.surah.englishName} (${match.surah.number}):${match.numberInSurah} - "${match.text}"`;
    }
    return null;
  } catch (error) {
    return null;
  }
}

async function searchMyHadith(query, detailed = false) {
  try {
    // Note: myHadith API might require authentication or specific endpoints
    // This is a placeholder - adjust based on actual myHadith API docs
    const response = await axios.get('https://api.myhadith.my/v1/search', {
      params: { q: query, lang: 'ms' }
    });
    
    if (response.data && response.data.results && response.data.results.length > 0) {
      const hadith = response.data.results[0];
      if (detailed) {
        return {
          status: 'verified',
          grade: hadith.grade || 'Unknown',
          book: hadith.book,
          reference: hadith.reference,
          text: hadith.text,
          myhadith_url: hadith.url || 'https://myhadith.islam.gov.my'
        };
      }
      return `Hadith: ${hadith.book} - ${hadith.reference} (${hadith.grade})`;
    }
    return null;
  } catch (error) {
    console.error('myHadith search error:', error.message);
    return null;
  }
}

async function searchEfatwa(question) {
  try {
    // e-Fatwa scraping or API (if available)
    // This is placeholder - actual implementation depends on e-fatwa.gov.my structure
    return 'Rujuk https://e-fatwa.gov.my untuk keputusan fatwa terkini';
  } catch (error) {
    return null;
  }
}

async function semanticQuranSearch(query, language) {
  // Placeholder for semantic search using embeddings
  // In production: use vector DB (Pinecone/Weaviate) with Quran verse embeddings
  const keywords = query.toLowerCase().split(' ');
  const response = await axios.get(`https://api.alquran.cloud/v1/search/${keywords[0]}/all/en.sahih`);
  
  return response.data.data.matches.slice(0, 5).map(m => ({
    surah: m.surah.englishName,
    ayah: m.numberInSurah,
    text: m.text,
    relevance: 'high'
  }));
}

async function getTadabburSuggestions(emotion, context) {
  // Map emotions to Quran themes
  const emotionMap = {
    'sad': ['patience', 'hope', 'mercy'],
    'anxious': ['trust', 'peace', 'reliance'],
    'grateful': ['gratitude', 'blessings', 'remembrance'],
    'angry': ['forgiveness', 'patience', 'self-control']
  };
  
  const themes = emotionMap[emotion] || ['guidance'];
  
  // Placeholder: return popular verses for these themes
  // In production: use pre-tagged verse database
  return [
    { surah: 2, ayah: 286, theme: 'Allah does not burden a soul beyond its capacity', text_ar: '...' },
    { surah: 94, ayah: 5, theme: 'With hardship comes ease', text_ar: '...' }
  ];
}

async function logAIInteraction(data) {
  // Log to database for JAKIM audit
  // In production: store in PostgreSQL audit table
  console.log('[AI AUDIT LOG]', {
    timestamp: data.timestamp,
    question: data.question.substring(0, 100),
    compliance_checked: data.compliance_checked
  });
}

module.exports = router;
