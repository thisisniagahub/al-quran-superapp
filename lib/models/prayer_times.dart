class PrayerTimes {
  final String zone;
  final String zoneName;
  final DateTime date;
  final String? hijriDate;
  final Times times;
  final String source;
  final String calculationMethod;
  final bool jakimVerified;
  
  PrayerTimes({
    required this.zone,
    required this.zoneName,
    required this.date,
    this.hijriDate,
    required this.times,
    required this.source,
    this.calculationMethod = 'JAKIM Standard',
    this.jakimVerified = true,
  });
  
  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    return PrayerTimes(
      zone: json['zone'],
      zoneName: json['zone_name'],
      date: DateTime.parse(json['date']),
      hijriDate: json['hijri_date'],
      times: Times.fromJson(json['times']),
      source: json['source'],
      calculationMethod: json['calculation_method'] ?? 'JAKIM Standard',
      jakimVerified: json['jakim_verified'] ?? true,
    );
  }
}

class Times {
  final String imsak;
  final String fajr;
  final String syuruk;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  
  Times({
    required this.imsak,
    required this.fajr,
    required this.syuruk,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });
  
  factory Times.fromJson(Map<String, dynamic> json) {
    return Times(
      imsak: json['imsak'],
      fajr: json['fajr'],
      syuruk: json['syuruk'] ?? json['sunrise'],
      dhuhr: json['dhuhr'],
      asr: json['asr'],
      maghrib: json['maghrib'],
      isha: json['isha'],
    );
  }
  
  List<PrayerTime> toList() {
    return [
      PrayerTime(name: 'Imsak', time: imsak),
      PrayerTime(name: 'Subuh', time: fajr),
      PrayerTime(name: 'Syuruk', time: syuruk),
      PrayerTime(name: 'Zohor', time: dhuhr),
      PrayerTime(name: 'Asar', time: asr),
      PrayerTime(name: 'Maghrib', time: maghrib),
      PrayerTime(name: 'Isyak', time: isha),
    ];
  }
}

class PrayerTime {
  final String name;
  final String time;
  
  PrayerTime({required this.name, required this.time});
}

class QiblaDirection {
  final double latitude;
  final double longitude;
  final double qiblaDirection;
  final String directionText;
  
  QiblaDirection({
    required this.latitude,
    required this.longitude,
    required this.qiblaDirection,
    required this.directionText,
  });
  
  factory QiblaDirection.fromJson(Map<String, dynamic> json) {
    return QiblaDirection(
      latitude: json['location']['lat'].toDouble(),
      longitude: json['location']['lng'].toDouble(),
      qiblaDirection: json['qibla_direction'].toDouble(),
      directionText: json['direction_text'],
    );
  }
}
