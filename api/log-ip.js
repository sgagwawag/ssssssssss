// api/log-ip.js
export default async function handler(req, res) {
  try {
    const ip = req.headers['x-forwarded-for']
      ? req.headers['x-forwarded-for'].split(',')[0].trim()
      : req.headers['x-real-ip'] || 'نامشخص';

    let city = "نامشخص";
    let country = "نامشخص";
    let region = "نامشخص";

    try {
      const geoRes = await fetch(`https://ipapi.co/${ip}/json/`);
      if (geoRes.ok) {
        const geo = await geoRes.json();
        city = geo.city || "نامشخص";
        country = geo.country_name || geo.country || "نامشخص";
        region = geo.region || "نامشخص";
      }
    } catch (e) { }

    const message = `
🔴 بازدیدکننده جدید (کد وارد شد)

🌐 آدرس IP: ${ip}
🇮🇷 کشور: ${country}
🏙️ شهر: ${city}
📍 منطقه: ${region}
🔗 صفحه: ${req.headers.referer || 'مستقیم'}
📱 دستگاه: ${req.headers['user-agent']?.substring(0, 100) || 'نامشخص'}
⏰ زمان: ${new Date().toLocaleString('fa-IR')}
    `.trim();

    const BOT_TOKEN = "8797755900:AAFZYIce4vrR5YMQAB0Khz4oaQng2iDfe8M";
    const CHAT_ID = "8437897670";

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
  } catch (e) {
    return res.status(200).json({ success: false });
  }
}