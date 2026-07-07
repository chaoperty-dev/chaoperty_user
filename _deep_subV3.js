// Deep search for payment_subV3 across ALL VS Code history (case-insensitive)
const fs = require('fs');
const path = require('path');
const historyDir = path.join(process.env.APPDATA, 'Code/User/History');

const dirs = fs.readdirSync(historyDir);
const matches = [];

for (const dir of dirs) {
  const ep = path.join(historyDir, dir, 'entries.json');
  if (!fs.existsSync(ep)) continue;
  let data;
  try { data = JSON.parse(fs.readFileSync(ep, 'utf8')); } catch(e) { continue; }
  const resource = decodeURIComponent(data.resource || '').replace(/\\/g, '/').toLowerCase();
  if (!resource.includes('payment_subv3')) continue;
  for (const e of data.entries) {
    matches.push({ ts: e.timestamp, id: e.id, dir, resource });
  }
}

matches.sort((a,b) => b.ts - a.ts);
console.log('payment_subV3 entries: ' + matches.length + '\n');
for (let i = 0; i < Math.min(matches.length, 40); i++) {
  const m = matches[i];
  const local = new Date(m.ts + 7*3600*1000).toISOString().replace('T', ' ').slice(0, 19);
  let sz = '?';
  let heightLine = '';
  try {
    const content = fs.readFileSync(path.join(historyDir, m.dir, m.id), 'utf8');
    sz = content.length;
    // Find the thai_qr_payment_2 block + the height line near it
    const idx = content.indexOf('thai_qr_payment_2');
    if (idx >= 0) {
      const segment = content.substring(idx, idx + 300);
      const heightMatch = segment.match(/height:\s*([0-9.]+)/);
      if (heightMatch) heightLine = 'height=' + heightMatch[1];
    }
  } catch(e){}
  console.log('  ' + local + ' +07  size=' + sz + '  ' + heightLine + '  id=' + m.id);
  console.log('      ' + m.resource);
}
