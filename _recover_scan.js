const fs = require('fs');
const path = require('path');
const historyDir = path.join(process.env.APPDATA, 'Code/User/History');

// 2026-05-23 12:30 +07 = 2026-05-23 05:30 UTC
const cutoff = new Date('2026-05-23T05:30:00Z').getTime();
console.log('Cutoff timestamp (12:30 +07):', cutoff, '=', new Date(cutoff).toISOString());

const targets = [
  'lib/screen_Intents/payment_subV2_InvAll.dart',
  'lib/screen_Intents_V3/payment_mainV3_InvAll.dart',
  'lib/screen_Intents_V3/payment_subV3_InvAll.dart',
  'lib/screen_Intents_V4/payment_subV4_InvAll.dart',
  'pubspec.yaml'
];

if (!fs.existsSync(historyDir)) {
  console.log('NO HISTORY DIR:', historyDir);
  process.exit(1);
}

const dirs = fs.readdirSync(historyDir);

for (const target of targets) {
  console.log('\n=== ' + target + ' ===');
  let entries = [];
  for (const dir of dirs) {
    const ep = path.join(historyDir, dir, 'entries.json');
    if (!fs.existsSync(ep)) continue;
    try {
      const data = JSON.parse(fs.readFileSync(ep, 'utf8'));
      const res = decodeURIComponent(data.resource || '').replace(/\\/g, '/');
      if (res.endsWith(target) || res.includes('/' + target)) {
        for (const e of data.entries) {
          entries.push({ts: e.timestamp, id: e.id, dir});
        }
      }
    } catch(e) {}
  }
  entries.sort(function(a,b){ return b.ts - a.ts; });
  for (var i = 0; i < Math.min(entries.length, 20); i++) {
    var e = entries[i];
    var local = new Date(e.ts + 7*3600*1000).toISOString().replace('T', ' ').slice(0, 19);
    var marker = e.ts < cutoff ? '[BEFORE-12:30]' : '[AFTER-12:30] ';
    var sz = '';
    try {
      sz = fs.statSync(path.join(historyDir, e.dir, e.id)).size;
    } catch(err) { sz = '?'; }
    console.log('  ' + marker + ' ' + local + ' +07  size=' + sz + '  id=' + e.id + '  dir=' + e.dir);
  }
  console.log('  TOTAL entries: ' + entries.length);
}
