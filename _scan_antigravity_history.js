// Scan Antigravity IDE's Local History for project files
const fs = require('fs');
const path = require('path');
const historyDir = path.join(process.env.APPDATA, 'Antigravity/User/History');

if (!fs.existsSync(historyDir)) {
  console.log('Antigravity history dir not found:', historyDir);
  process.exit(1);
}

const dirs = fs.readdirSync(historyDir);
console.log('Total Antigravity history directories: ' + dirs.length);

const targets = ['payment_subv3', 'payment_subv4', 'payment_mainv3', 'main.dart', 'generate_qrcode', 'payment_subv2', 'pubspec.yaml'];

const found = {};
for (const dir of dirs) {
  const ep = path.join(historyDir, dir, 'entries.json');
  if (!fs.existsSync(ep)) continue;
  let data;
  try { data = JSON.parse(fs.readFileSync(ep, 'utf8')); } catch(e) { continue; }
  const resource = decodeURIComponent(data.resource || '').replace(/\\/g, '/').toLowerCase();

  for (const target of targets) {
    if (resource.includes(target)) {
      if (!found[target]) found[target] = [];
      for (const e of data.entries) {
        found[target].push({ ts: e.timestamp, id: e.id, dir, resource });
      }
      break;
    }
  }
}

for (const target of targets) {
  console.log('\n=== ' + target + ' ===');
  if (!found[target]) {
    console.log('  (no entries)');
    continue;
  }
  found[target].sort((a,b) => b.ts - a.ts);
  for (let i = 0; i < Math.min(found[target].length, 15); i++) {
    const m = found[target][i];
    const local = new Date(m.ts + 7*3600*1000).toISOString().replace('T', ' ').slice(0, 19);
    let sz = '?';
    let heightInfo = '';
    try {
      const content = fs.readFileSync(path.join(historyDir, m.dir, m.id), 'utf8');
      sz = content.length;
      const idx = content.indexOf('thai_qr_payment_2');
      if (idx >= 0) {
        const segment = content.substring(idx, idx + 300);
        const hm = segment.match(/height:\s*([0-9.]+)/);
        if (hm) heightInfo = ' [thai_qr height=' + hm[1] + ']';
      }
    } catch(e){}
    console.log('  ' + local + ' +07  size=' + sz + heightInfo + '  id=' + m.id);
  }
  console.log('  TOTAL: ' + found[target].length);
}
