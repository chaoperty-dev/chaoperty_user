const fs = require('fs');
const path = require('path');
const historyDir = path.join(process.env.APPDATA, 'Code/User/History');
const target = 'lib/main.dart';
const dirs = fs.readdirSync(historyDir);
let entries = [];
for (const dir of dirs) {
  const ep = path.join(historyDir, dir, 'entries.json');
  if (!fs.existsSync(ep)) continue;
  try {
    const data = JSON.parse(fs.readFileSync(ep, 'utf8'));
    const res = decodeURIComponent(data.resource || '').replace(/\\/g, '/');
    if (res.endsWith(target) || res.includes('/' + target)) {
      for (const e of data.entries) entries.push({ts: e.timestamp, id: e.id, dir});
    }
  } catch(e) {}
}
entries.sort(function(a,b){ return b.ts - a.ts; });
console.log('TOTAL: ' + entries.length);
for (var i = 0; i < Math.min(entries.length, 30); i++) {
  var e = entries[i];
  var local = new Date(e.ts + 7*3600*1000).toISOString().replace('T', ' ').slice(0, 19);
  var sz = '';
  try { sz = fs.statSync(path.join(historyDir, e.dir, e.id)).size; } catch(err) { sz = '?'; }
  console.log('  ' + local + ' +07  size=' + sz + '  id=' + e.id + '  dir=' + e.dir);
}
