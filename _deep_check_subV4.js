// Deep check for payment_subV4_InvAll.dart across ALL of VS Code history
const fs = require('fs');
const path = require('path');
const historyDir = path.join(process.env.APPDATA, 'Code/User/History');

const dirs = fs.readdirSync(historyDir);
console.log('Searching across ' + dirs.length + ' history directories...\n');

const matches = [];
for (const dir of dirs) {
  const ep = path.join(historyDir, dir, 'entries.json');
  if (!fs.existsSync(ep)) continue;
  let data;
  try { data = JSON.parse(fs.readFileSync(ep, 'utf8')); } catch(e) { continue; }
  const resource = decodeURIComponent(data.resource || '').replace(/\\/g, '/');
  // Search ANY path that contains payment_subV4
  if (!resource.toLowerCase().includes('payment_subv4')) continue;
  for (const e of data.entries) {
    matches.push({ ts: e.timestamp, id: e.id, dir, resource });
  }
}

matches.sort((a,b) => b.ts - a.ts);
console.log('Total entries found: ' + matches.length + '\n');
for (let i = 0; i < Math.min(matches.length, 40); i++) {
  const m = matches[i];
  const local = new Date(m.ts + 7*3600*1000).toISOString().replace('T', ' ').slice(0, 19);
  let sz = '?';
  try { sz = fs.statSync(path.join(historyDir, m.dir, m.id)).size; } catch(e){}
  console.log('  ' + local + ' +07  size=' + sz + '  id=' + m.id + '  dir=' + m.dir);
  console.log('      ' + m.resource);
}
