/**
 * JAKIM/JAIS Compliance Validator Module
 * Based on 18 official JAKIM/JAIS PDF guidelines
 * 
 * Key Guidelines Implemented:
 * 1. Garis_Panduan_Kandungan_Berunsur_Islam_Dalam_Media_Baharu.pdf
 * 2. Garis_Panduan_Bahan_Penerbitan_Bercetak_Dan_Audio_Visual...pdf
 * 3. garis_panduan_program_motivasi_berunsur_islam.pdf
 * 4. Garisan_Panduan_Penapisan_Kandungan_Bahan-Bahan_Penyiaran...pdf
 * 5. Garisan_Panduan_Pembuatan_Pengendalian_Penjualan_Dan_Pelupusan_Ayat_Suci_Al-Quran.pdf
 * 6. Social_Media__ICT_dalam_Islam_1.pdf
 * 7. PTSI 2.0 V9 2025.pdf
 * 8. Nilai_MADANI_pocket_talk_JAKIM.pdf
 * ... and 10 more official documents
 */

const PROHIBITED_CONTENT = {
  // From Garis Panduan Akidah
  akidah_violations: [
    'khurafat', 'tahyul', 'karut', 'bid\'ah sesat',
    'syirik', 'pluralisme agama', 'liberalisme',
    'feminisme melampau', 'LGBT dalam Islam',
    'mempersoalkan Al-Quran', 'menghina nabi',
    'ajaran sesat', 'deviationist teaching'
  ],
  
  // From Hadith Guidelines
  hadith_violations: [
    'hadith maudhu', 'hadith palsu', 'fabricated hadith',
    'hadith tanpa sanad', 'hadith lemah untuk akidah',
    'mengarang hadith', 'mengubah matan hadith'
  ],
  
  // From Media Baharu Guidelines
  media_violations: [
    'gambar nabi', 'gambar malaikat', 'depiction of prophets',
    'muzik haram', 'aurat terdedah', 'khalwat',
    'unsur maksiat', 'judi', 'arak', 'dadah',
    'LGBT propaganda', 'ajakan murtad'
  ],
  
  // From Motivasi Berunsur Islam
  motivasi_violations: [
    'motivasi tanpa dalil', 'law of attraction Islam',
    'kekayaan tanpa usaha halal', 'mlm haram',
    'skim cepat kaya', 'syariah compliant scam',
    'perjudian agama', 'wang ghaib'
  ],
  
  // From Social Media ICT Guidelines
  social_media_violations: [
    'fitnah', 'hasad dengki', 'mengumpat online',
    'menyebarkan berita palsu', 'fake news agama',
    'memburukkan ulama', 'hina institusi agama',
    'ajak perpecahan umat', 'ekstremisme'
  ]
};

// Mandatory Source Attribution (from JAKIM Publishing Guidelines)
const REQUIRED_SOURCES = {
  quran: {
    text: 'Mushaf Malaysia (JAKIM)',
    url: 'https://www.islam.gov.my'
  },
  hadith: {
    text: 'myHadith Portal (JAKIM)',
    url: 'https://myhadith.islam.gov.my'
  },
  fatwa: {
    text: 'Portal Rasmi Fatwa Malaysia',
    url: 'https://e-fatwa.gov.my'
  },
  tafsir: {
    text: 'Tafsir approved by JAKIM',
    url: 'https://www.islam.gov.my'
  }
};

// Content Validation Functions
class JAKIMValidator {
  
  /**
   * Validate content for prohibited keywords
   * From: Garis Panduan Akidah & Media Baharu
   */
  static validateContent(text, type = 'general') {
    const violations = [];
    const lowerText = text.toLowerCase();
    
    // Check all prohibited categories
    for (const [category, keywords] of Object.entries(PROHIBITED_CONTENT)) {
      for (const keyword of keywords) {
        if (lowerText.includes(keyword.toLowerCase())) {
          violations.push({
            category,
            keyword,
            severity: this.getSeverity(category),
            action: 'block_or_review',
            guideline_ref: this.getGuidelineRef(category)
          });
        }
      }
    }
    
    return {
      is_compliant: violations.length === 0,
      violations,
      reviewed_at: new Date().toISOString(),
      validator: 'JAKIM Compliance Module v1.0'
    };
  }
  
  /**
   * Validate Quran quote usage
   * From: Garisan_Panduan_Pembuatan_Pengendalian_Penjualan_Dan_Pelupusan_Ayat_Suci_Al-Quran.pdf
   */
  static validateQuranQuote(data) {
    const issues = [];
    
    // Must have source attribution
    if (!data.source_attribution) {
      issues.push({
        type: 'missing_attribution',
        message: 'WAJIB: Petikan ayat mesti ada sumber rujukan (Mushaf Malaysia / JAKIM)',
        severity: 'critical',
        guideline: 'Garisan Panduan Ayat Suci Al-Quran (JAKIM)'
      });
    }
    
    // Must have Surah & Ayah reference
    if (!data.surah_number || !data.ayah_number) {
      issues.push({
        type: 'missing_reference',
        message: 'WAJIB: Mesti ada rujukan Surah dan Ayat yang lengkap',
        severity: 'critical'
      });
    }
    
    // Translation must be credited
    if (data.translation && !data.translator_name) {
      issues.push({
        type: 'missing_translator',
        message: 'WAJIB: Terjemahan mesti nyatakan nama penterjemah',
        severity: 'high'
      });
    }
    
    // Cannot be used for commercial without permission
    if (data.commercial_use && !data.jakim_permission) {
      issues.push({
        type: 'commercial_violation',
        message: 'Penggunaan komersial ayat Al-Quran memerlukan kebenaran JAKIM',
        severity: 'high',
        action: 'require_permission'
      });
    }
    
    // Must not alter the Arabic text
    if (data.arabic_text_modified) {
      issues.push({
        type: 'text_alteration',
        message: 'HARAM: Mengubah teks Arab Al-Quran adalah dilarang',
        severity: 'critical',
        action: 'block_immediately'
      });
    }
    
    return {
      is_valid: issues.length === 0,
      issues,
      recommendation: issues.length > 0 ? 
        'Rujuk Garisan Panduan JAKIM sebelum menerbitkan' : 
        'Compliant dengan garis panduan JAKIM',
      required_attribution: REQUIRED_SOURCES.quran
    };
  }
  
  /**
   * Validate Hadith authenticity
   * From: myHadith + Garis Panduan Hadith
   */
  static validateHadith(hadithData) {
    const warnings = [];
    
    // Check grade (Sahih, Hasan, Daif, Maudhu)
    if (hadithData.grade === 'Maudhu' || hadithData.grade === 'fabricated') {
      return {
        is_valid: false,
        warnings: [{
          type: 'fabricated_hadith',
          message: 'HADITH MAUDHU (PALSU) - DILARANG SEBAR!',
          severity: 'critical',
          action: 'block_immediately',
          guideline: 'Hadith palsu tidak boleh disebarkan walaupun untuk tujuan baik'
        }],
        myhadith_verification_required: true
      };
    }
    
    if (hadithData.grade === 'Daif') {
      warnings.push({
        type: 'weak_hadith',
        message: 'Hadith Daif - Gunakan dengan berhati-hati',
        severity: 'medium',
        guideline: 'Hadith daif boleh untuk fadilat amalan, BUKAN untuk akidah/hukum'
      });
    }
    
    // Must have myHadith verification
    if (!hadithData.myhadith_verified) {
      warnings.push({
        type: 'unverified',
        message: 'Hadith belum disahkan melalui myHadith.my',
        severity: 'high',
        action: 'require_myhadith_check',
        link: 'https://myhadith.islam.gov.my'
      });
    }
    
    // Must have sanad (chain of narration) for serious usage
    if (!hadithData.sanad && hadithData.usage_type === 'hukm') {
      warnings.push({
        type: 'missing_sanad',
        message: 'Untuk hukum, hadith mesti ada sanad yang jelas',
        severity: 'high'
      });
    }
    
    return {
      is_valid: warnings.filter(w => w.severity === 'critical').length === 0,
      warnings,
      myhadith_link: 'https://myhadith.islam.gov.my',
      required_attribution: REQUIRED_SOURCES.hadith
    };
  }
  
  /**
   * Validate AI-generated Islamic content
   * From: Social Media ICT dalam Islam + PTSI 2.0
   */
  static validateAIContent(aiResponse) {
    const checks = [];
    
    // AI cannot give fatwa
    const fatwaKeywords = ['hukum', 'halal', 'haram', 'wajib', 'sunat', 'makruh'];
    const hasFatwaLanguage = fatwaKeywords.some(k => aiResponse.toLowerCase().includes(k));
    
    if (hasFatwaLanguage && !aiResponse.includes('rujuk ulama')) {
      checks.push({
        type: 'ai_fatwa_violation',
        message: 'AI TIDAK BOLEH beri fatwa! Mesti arah pengguna rujuk ulama/JAKIM',
        severity: 'critical',
        required_disclaimer: 'Untuk keputusan hukum yang mengikat, sila rujuk e-Fatwa atau mufti negeri anda'
      });
    }
    
    // Must cite sources
    const hasSources = aiResponse.includes('Quran') || 
                      aiResponse.includes('Hadith') || 
                      aiResponse.includes('Surah');
    
    if (!hasSources) {
      checks.push({
        type: 'no_dalil',
        message: 'Jawapan agama mesti ada dalil (Al-Quran/Hadith)',
        severity: 'high',
        guideline: 'Setiap pandangan Islam mesti bersandarkan dalil sahih'
      });
    }
    
    // Must have JAKIM disclaimer
    const requiredDisclaimer = 'Jawapan ini adalah panduan am. Untuk keputusan rasmi, rujuk JAKIM/Jabatan Agama';
    if (!aiResponse.includes('rujuk') && !aiResponse.includes('JAKIM')) {
      checks.push({
        type: 'missing_disclaimer',
        message: 'WAJIB: AI response mesti ada disclaimer rujuk pihak berkuasa',
        severity: 'critical',
        required_text: requiredDisclaimer
      });
    }
    
    // Cannot contradict JAKIM fatwa
    // (In production: check against e-Fatwa database)
    
    return {
      is_compliant: checks.filter(c => c.severity === 'critical').length === 0,
      checks,
      required_disclaimer: requiredDisclaimer,
      efatwa_link: REQUIRED_SOURCES.fatwa.url,
      audit_log_required: true
    };
  }
  
  /**
   * Validate motivational Islamic content
   * From: garis_panduan_program_motivasi_berunsur_islam.pdf
   */
  static validateMotivationalContent(content) {
    const redFlags = [];
    
    // Check for prohibited MLM/money scheme keywords
    const mlmKeywords = ['passive income', 'cepat kaya', 'tanpa modal', 'income automatik', 
                        'dapat jutaan', 'binary', 'network marketing'];
    
    for (const keyword of mlmKeywords) {
      if (content.toLowerCase().includes(keyword)) {
        redFlags.push({
          type: 'mlm_scheme_detected',
          keyword,
          message: 'Kandungan motivasi tidak boleh promosi skim wang haram/MLM',
          severity: 'high',
          guideline: 'Garis Panduan MLM JAKIM'
        });
      }
    }
    
    // Motivasi must have Islamic basis
    const islamicTerms = ['Allah', 'Rasulullah', 'Al-Quran', 'Hadith', 'doa', 'tawakkal'];
    const hasIslamicBasis = islamicTerms.some(term => content.includes(term));
    
    if (!hasIslamicBasis) {
      redFlags.push({
        type: 'non_islamic_motivation',
        message: 'Motivasi berunsur Islam mesti ada rujukan Al-Quran/Hadith',
        severity: 'medium',
        guideline: 'Garis Panduan Program Motivasi Berunsur Islam'
      });
    }
    
    return {
      is_compliant: redFlags.filter(r => r.severity === 'high').length === 0,
      red_flags: redFlags,
      guideline_ref: 'garis_panduan_program_motivasi_berunsur_islam.pdf'
    };
  }
  
  /**
   * Add required attribution footer
   * From: Publishing & Media Guidelines
   */
  static addAttributionFooter(contentType, data) {
    const source = REQUIRED_SOURCES[contentType];
    
    const footer = `

━━━━━━━━━━━━━━━━━━━━━━
📚 SUMBER: ${source.text}
🔗 ${source.url}

⚠️ DISCLAIMER:
Maklumat ini adalah panduan am sahaja. 
Untuk keputusan yang mengikat, sila rujuk:
• Portal Rasmi JAKIM: https://www.islam.gov.my
• e-Fatwa Malaysia: https://e-fatwa.gov.my
• myHadith: https://myhadith.islam.gov.my
• Jabatan Agama Islam negeri anda

📱 Aplikasi ini mematuhi Garis Panduan JAKIM/JAIS
`;
    
    return footer;
  }
  
  // Helper functions
  static getSeverity(category) {
    const criticalCategories = ['akidah_violations', 'hadith_violations'];
    return criticalCategories.includes(category) ? 'critical' : 'high';
  }
  
  static getGuidelineRef(category) {
    const refs = {
      akidah_violations: 'Garis_Panduan_Akidah_JAKIM.pdf',
      hadith_violations: 'myHadith.islam.gov.my Guidelines',
      media_violations: 'Garis_Panduan_Kandungan_Berunsur_Islam_Dalam_Media_Baharu.pdf',
      motivasi_violations: 'garis_panduan_program_motivasi_berunsur_islam.pdf',
      social_media_violations: 'Social_Media__ICT_dalam_Islam_1.pdf'
    };
    return refs[category] || 'JAKIM General Guidelines';
  }
}

module.exports = JAKIMValidator;
