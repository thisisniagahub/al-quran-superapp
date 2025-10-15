class Surah {
  final int number;
  final String nameAr;
  final String nameEn;
  final String nameMs;
  final String nameId;
  final int ayahCount;
  final String revelation; // Makkah / Madinah
  final String sourceAttribution;
  
  Surah({
    required this.number,
    required this.nameAr,
    required this.nameEn,
    required this.nameMs,
    required this.nameId,
    required this.ayahCount,
    required this.revelation,
    this.sourceAttribution = 'Mushaf Malaysia (JAKIM)',
  });
  
  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'],
      nameAr: json['name_ar'],
      nameEn: json['name_en'],
      nameMs: json['name_ms'] ?? json['name_en'],
      nameId: json['name_id'] ?? json['name_en'],
      ayahCount: json['ayah_count'],
      revelation: json['revelation'] ?? 'Makkah',
      sourceAttribution: json['source_attribution'] ?? 'Mushaf Malaysia (JAKIM)',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name_ar': nameAr,
      'name_en': nameEn,
      'name_ms': nameMs,
      'name_id': nameId,
      'ayah_count': ayahCount,
      'revelation': revelation,
      'source_attribution': sourceAttribution,
    };
  }
}

class Ayah {
  final int surahId;
  final int number;
  final String textAr;
  final int? juz;
  final int? page;
  final Translation? translation;
  final String? audioUrl;
  final bool sourceVerified;
  
  Ayah({
    required this.surahId,
    required this.number,
    required this.textAr,
    this.juz,
    this.page,
    this.translation,
    this.audioUrl,
    this.sourceVerified = true,
  });
  
  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      surahId: json['surah_id'] ?? 0,
      number: json['number'],
      textAr: json['text_ar'],
      juz: json['juz'],
      page: json['page'],
      translation: json['translation'] != null 
          ? Translation.fromJson(json['translation']) 
          : null,
      audioUrl: json['audio_url'],
      sourceVerified: json['source_verified'] ?? true,
    );
  }
}

class Translation {
  final String text;
  final String translator;
  final String language;
  
  Translation({
    required this.text,
    required this.translator,
    required this.language,
  });
  
  factory Translation.fromJson(Map<String, dynamic> json) {
    return Translation(
      text: json['text'],
      translator: json['translator'] ?? 'Unknown',
      language: json['language'] ?? 'ms',
    );
  }
}

class Tafsir {
  final String text;
  final String source;
  final String scholar;
  final String language;
  
  Tafsir({
    required this.text,
    required this.source,
    required this.scholar,
    this.language = 'ms',
  });
  
  factory Tafsir.fromJson(Map<String, dynamic> json) {
    return Tafsir(
      text: json['text'],
      source: json['source'],
      scholar: json['scholar'],
      language: json['language'] ?? 'ms',
    );
  }
}
