const fs = require('fs');
const path = require('path');
const historyDir = path.join(process.env.APPDATA, 'Code/User/History');

// Files to restore from VS Code history (pre-12:30 today)
const restoreFromHistory = [
  { target: 'lib/main.dart', id: 'EuTo.dart', dir: '-7734ee55', ts: '2026-05-23 11:15' }
];

// Find latest entry pre-12:30 for generate_qrcode.dart automatically
const cutoff = new Date('2026-05-23T05:30:00Z').getTime();
function findLatestPre(target) {
  const dirs = fs.readdirSync(historyDir);
  let best = null;
  for (const dir of dirs) {
    const ep = path.join(historyDir, dir, 'entries.json');
    if (!fs.existsSync(ep)) continue;
    try {
      const data = JSON.parse(fs.readFileSync(ep, 'utf8'));
      const res = decodeURIComponent(data.resource || '').replace(/\\/g, '/');
      if (res.endsWith(target) || res.includes('/' + target)) {
        for (const e of data.entries) {
          if (e.timestamp < cutoff && (!best || e.timestamp > best.ts)) {
            best = { ts: e.timestamp, id: e.id, dir };
          }
        }
      }
    } catch(e) {}
  }
  return best;
}

const qr = findLatestPre('lib/CRC_16_Prompay/generate_qrcode.dart');
if (qr) {
  restoreFromHistory.push({
    target: 'lib/CRC_16_Prompay/generate_qrcode.dart',
    id: qr.id, dir: qr.dir,
    ts: new Date(qr.ts + 7*3600*1000).toISOString().slice(0,16).replace('T',' ')
  });
}

for (const item of restoreFromHistory) {
  const src = path.join(historyDir, item.dir, item.id);
  if (!fs.existsSync(src)) {
    console.log('MISSING SRC: ' + src);
    continue;
  }
  const content = fs.readFileSync(src, 'utf8');
  fs.writeFileSync(item.target, content, 'utf8');
  console.log('RESTORED: ' + item.target + '  <-  ' + item.ts + '  (size=' + content.length + ')');
}
