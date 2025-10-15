const express = require('express');
const router = express.Router();
const { createCanvas, loadImage, registerFont } = require('canvas');
const fs = require('fs');
const path = require('path');

// Share Quote Generator (with JAKIM compliance metadata)
router.post('/generate-card', async (req, res) => {
  try {
    const { 
      surah_number, 
      ayah_start, 
      ayah_end, 
      text_ar, 
      translation, 
      translator_name,
      template_id,
      language 
    } = req.body;

    if (!surah_number || !ayah_start || !text_ar) {
      return res.status(400).json({ error: 'Surah, ayah, and Arabic text required' });
    }

    // Template selection
    const templates = {
      'minimalist': { bg: '#F5F5DC', font: 'black', border: true },
      'green': { bg: '#2D5F3F', font: 'white', border: false },
      'batik': { bg: 'batik-pattern.jpg', font: 'white', overlay: true },
      'calligraphy': { bg: '#1A1A1A', font: 'gold', calligraphic: true }
    };

    const template = templates[template_id] || templates['minimalist'];

    // Canvas setup (Instagram Square: 1080x1080)
    const width = 1080;
    const height = 1080;
    const canvas = createCanvas(width, height);
    const ctx = canvas.getContext('2d');

    // Background
    if (template.bg.endsWith('.jpg')) {
      // Load background image
      const bgImage = await loadImage(path.join(__dirname, '../assets', template.bg));
      ctx.drawImage(bgImage, 0, 0, width, height);
      if (template.overlay) {
        ctx.fillStyle = 'rgba(0,0,0,0.5)';
        ctx.fillRect(0, 0, width, height);
      }
    } else {
      ctx.fillStyle = template.bg;
      ctx.fillRect(0, 0, width, height);
    }

    // Border (if template has border)
    if (template.border) {
      ctx.strokeStyle = '#2D5F3F';
      ctx.lineWidth = 10;
      ctx.strokeRect(40, 40, width - 80, height - 80);
    }

    // Arabic Text (main quote)
    ctx.fillStyle = template.font;
    ctx.font = 'bold 48px Amiri'; // Arabic font (install Amiri font)
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    
    // Wrap Arabic text if too long
    const arabicLines = wrapText(ctx, text_ar, width - 200);
    const lineHeight = 70;
    const startY = height / 2 - (arabicLines.length * lineHeight) / 2;
    
    arabicLines.forEach((line, i) => {
      ctx.fillText(line, width / 2, startY + i * lineHeight);
    });

    // Translation (if provided)
    if (translation) {
      ctx.font = '28px Arial';
      ctx.fillStyle = template.font === 'white' ? '#E0E0E0' : '#555';
      const transLines = wrapText(ctx, translation, width - 200);
      const transStartY = startY + (arabicLines.length * lineHeight) + 50;
      
      transLines.forEach((line, i) => {
        ctx.fillText(line, width / 2, transStartY + i * 40);
      });
    }

    // JAKIM Compliance Footer (MANDATORY)
    ctx.font = '22px Arial';
    ctx.fillStyle = template.font === 'white' ? '#CCC' : '#666';
    const ayahRef = ayah_end ? `${ayah_start}-${ayah_end}` : ayah_start;
    const footerText = `Surah ${surah_number}:${ayahRef}`;
    ctx.fillText(footerText, width / 2, height - 180);

    // Source attribution
    ctx.font = '18px Arial';
    const sourceText = translator_name ? 
      `Terjemahan: ${translator_name}` : 
      'Sumber: Mushaf Malaysia (JAKIM)';
    ctx.fillText(sourceText, width / 2, height - 140);

    // App watermark (small)
    ctx.font = '16px Arial';
    ctx.fillStyle = template.font === 'white' ? '#AAA' : '#888';
    ctx.fillText('Al-Quran SuperApp • islam.gov.my', width / 2, height - 100);

    // Disclaimer (JAKIM requirement)
    ctx.font = '14px Arial';
    ctx.fillStyle = template.font === 'white' ? '#999' : '#777';
    ctx.fillText('Untuk panduan lanjut, rujuk ulama atau JAKIM', width / 2, height - 60);

    // Save to file
    const uploadsDir = path.join(__dirname, '../uploads/share-cards');
    if (!fs.existsSync(uploadsDir)) {
      fs.mkdirSync(uploadsDir, { recursive: true });
    }

    const filename = `quote_${surah_number}_${ayah_start}_${Date.now()}.png`;
    const filepath = path.join(uploadsDir, filename);
    const buffer = canvas.toBuffer('image/png');
    fs.writeFileSync(filepath, buffer);

    // Return URL
    const imageUrl = `/uploads/share-cards/${filename}`;

    res.json({
      success: true,
      image_url: imageUrl,
      surah: surah_number,
      ayah: ayahRef,
      template: template_id,
      compliance: {
        source_attribution: true,
        jakim_disclaimer: true,
        watermark: true
      },
      download_url: `${req.protocol}://${req.get('host')}${imageUrl}`,
      share_text: `${footerText}\n\n${translation || ''}\n\nDari Al-Quran SuperApp`
    });

  } catch (error) {
    console.error('Share card generation error:', error);
    res.status(500).json({ error: 'Failed to generate share card', details: error.message });
  }
});

// Get available templates
router.get('/templates', (req, res) => {
  res.json({
    templates: [
      { id: 'minimalist', name: 'Minimalist', preview: '/assets/templates/minimalist.jpg' },
      { id: 'green', name: 'Islamic Green', preview: '/assets/templates/green.jpg' },
      { id: 'batik', name: 'Batik Malaysia', preview: '/assets/templates/batik.jpg' },
      { id: 'calligraphy', name: 'Calligraphy Dark', preview: '/assets/templates/calligraphy.jpg' }
    ],
    sizes: [
      { name: 'Instagram Square', width: 1080, height: 1080 },
      { name: 'Instagram Story', width: 1080, height: 1920 },
      { name: 'WhatsApp Status', width: 1080, height: 1920 },
      { name: 'Facebook Post', width: 1200, height: 630 }
    ],
    compliance_note: 'Semua template mengandungi source attribution & JAKIM disclaimer (mandatory)'
  });
});

// Helper function to wrap text
function wrapText(ctx, text, maxWidth) {
  const words = text.split(' ');
  const lines = [];
  let currentLine = '';

  words.forEach(word => {
    const testLine = currentLine + word + ' ';
    const metrics = ctx.measureText(testLine);
    
    if (metrics.width > maxWidth && currentLine !== '') {
      lines.push(currentLine.trim());
      currentLine = word + ' ';
    } else {
      currentLine = testLine;
    }
  });
  
  if (currentLine) {
    lines.push(currentLine.trim());
  }

  return lines;
}

module.exports = router;
