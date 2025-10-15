const express = require('express');
const router = express.Router();
const axios = require('axios');
const cheerio = require('cheerio');
const NodeCache = require('node-cache');
const cache = new NodeCache({ stdTTL: 43200 }); // 12 hours cache

// e-Solat zones for Malaysia
const ESOLAT_ZONES = {
  // Selangor
  'SGR01': 'Gombak, Petaling, Sepang, Hulu Langat, Hulu Selangor, Rawang',
  'SGR02': 'Kuala Selangor, Sabak Bernam',
  'SGR03': 'Klang, Kuala Langat',
  // Kuala Lumpur
  'WLY01': 'Kuala Lumpur',
  // Johor
  'JHR01': 'Pulau Aur dan Pemanggil',
  'JHR02': 'Johor Bahru, Kota Tinggi, Mersing',
  'JHR03': 'Kluang, Pontian',
  'JHR04': 'Batu Pahat, Muar, Segamat, Gemas',
  // Add more zones...
};

// Get prayer times for Malaysia (e-Solat JAKIM)
router.get('/times/malaysia', async (req, res) => {
  try {
    const { zone, date } = req.query; // zone: SGR01, date: YYYY-MM-DD
    
    if (!zone) {
      return res.status(400).json({ 
        error: 'Zone parameter required', 
        available_zones: Object.keys(ESOLAT_ZONES),
        example: 'SGR01 (Gombak/Petaling)'
      });
    }

    const cacheKey = `prayer_${zone}_${date || 'today'}`;
    const cached = cache.get(cacheKey);
    if (cached) return res.json(cached);

    // Scrape e-Solat (JAKIM official source)
    const targetDate = date || new Date().toISOString().split('T')[0];
    const [year, month, day] = targetDate.split('-');
    
    // e-Solat URL format
    const url = `https://www.e-solat.gov.my/index.php?r=esolatApi/TakwimSolat&period=duration&datestart=${targetDate}&dateend=${targetDate}&zone=${zone}`;
    
    const response = await axios.get(url);
    const data = response.data;

    if (!data.prayerTime || data.prayerTime.length === 0) {
      return res.status(404).json({ error: 'Prayer times not found for this zone/date' });
    }

    const prayerData = data.prayerTime[0];
    
    const result = {
      zone: zone,
      zone_name: ESOLAT_ZONES[zone] || zone,
      date: targetDate,
      hijri_date: prayerData.hijri || null,
      times: {
        imsak: prayerData.imsak,
        fajr: prayerData.fajr,
        syuruk: prayerData.syuruk,
        dhuhr: prayerData.dhuhr,
        asr: prayerData.asr,
        maghrib: prayerData.maghrib,
        isha: prayerData.isha
      },
      source: 'e-Solat JAKIM (Official Malaysia)',
      source_url: 'https://www.e-solat.gov.my',
      calculation_method: 'JAKIM Standard',
      jakim_verified: true
    };

    cache.set(cacheKey, result);
    res.json(result);
  } catch (error) {
    res.status(500).json({ 
      error: 'Failed to fetch prayer times from e-Solat', 
      details: error.message,
      fallback: 'Please check zone code or use manual calculation'
    });
  }
});

// Get prayer times for Indonesia (Kemenag calculation)
router.get('/times/indonesia', async (req, res) => {
  try {
    const { city, date } = req.query;
    
    if (!city) {
      return res.status(400).json({ 
        error: 'City parameter required',
        examples: ['jakarta', 'surabaya', 'medan', 'bandung']
      });
    }

    const cacheKey = `prayer_id_${city}_${date || 'today'}`;
    const cached = cache.get(cacheKey);
    if (cached) return res.json(cached);

    // Use Aladhan API with Indonesian Ministry calculation method
    const targetDate = date || new Date().toISOString().split('T')[0];
    const response = await axios.get(`https://api.aladhan.com/v1/timingsByCity/${targetDate}`, {
      params: {
        city: city,
        country: 'Indonesia',
        method: 11 // Kementerian Agama Indonesia
      }
    });

    const timings = response.data.data.timings;
    
    const result = {
      city: city.charAt(0).toUpperCase() + city.slice(1),
      country: 'Indonesia',
      date: targetDate,
      hijri_date: response.data.data.date.hijri.date,
      times: {
        imsak: timings.Imsak,
        fajr: timings.Fajr,
        syuruk: timings.Sunrise,
        dhuhr: timings.Dhuhr,
        asr: timings.Asr,
        maghrib: timings.Maghrib,
        isha: timings.Isha
      },
      source: 'Aladhan API',
      calculation_method: 'Kementerian Agama Indonesia',
      verified: true
    };

    cache.set(cacheKey, result);
    res.json(result);
  } catch (error) {
    res.status(500).json({ 
      error: 'Failed to fetch prayer times for Indonesia', 
      details: error.message 
    });
  }
});

// Get Qibla direction
router.get('/qibla', async (req, res) => {
  try {
    const { lat, lng } = req.query;
    
    if (!lat || !lng) {
      return res.status(400).json({ error: 'Latitude and longitude required' });
    }

    // Calculate Qibla direction (Kaaba: 21.4225, 39.8262)
    const kaabaLat = 21.4225;
    const kaabaLng = 39.8262;
    
    const latitude = parseFloat(lat);
    const longitude = parseFloat(lng);
    
    // Formula for Qibla direction
    const dLng = (kaabaLng - longitude) * Math.PI / 180;
    const lat1 = latitude * Math.PI / 180;
    const lat2 = kaabaLat * Math.PI / 180;
    
    const y = Math.sin(dLng);
    const x = Math.cos(lat1) * Math.tan(lat2) - Math.sin(lat1) * Math.cos(dLng);
    let qiblaDirection = Math.atan2(y, x) * 180 / Math.PI;
    qiblaDirection = (qiblaDirection + 360) % 360;

    res.json({
      location: { lat: latitude, lng: longitude },
      kaaba: { lat: kaabaLat, lng: kaabaLng },
      qibla_direction: Math.round(qiblaDirection * 100) / 100,
      direction_text: getCardinalDirection(qiblaDirection),
      source: 'Mathematical calculation',
      accuracy_note: 'For precise direction, use device compass calibration'
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to calculate Qibla', details: error.message });
  }
});

// Helper function
function getCardinalDirection(degrees) {
  const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
  const index = Math.round(degrees / 45) % 8;
  return directions[index];
}

// Get list of Malaysia zones
router.get('/zones/malaysia', (req, res) => {
  res.json({
    zones: Object.entries(ESOLAT_ZONES).map(([code, name]) => ({
      code,
      name
    })),
    source: 'e-Solat JAKIM',
    note: 'Use zone code in /times/malaysia endpoint'
  });
});

module.exports = router;
