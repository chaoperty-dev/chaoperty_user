// Check all VS Code history entries (today and recent) for MyConstant.chaoPrimary
const fs = require('fs');
const path = require('path');
const historyDir = path.join(process.env.APPDATA, 'Code/User/History');

const dirs = fs.readdirSync(historyDir);
const projectRoot = process.cwd().replace(/\\/g, '/').toLowerCase();
const cutoff = new Date('2026-05-23T05:00:00Z').getTime(); // 12:00 +07
const lastWeek = new Date('2026-05-16T00:00:00Z').getTime();

const results = {};
for (const dir of dirs) {
  const ep = path.join(historyDir, dir, 'entries.json');
  if (!fs.existsSync(ep)) continue;
  let data;
  try { data = JSON.parse(fs.readFileSync(ep, 'utf8')); } catch(e) { continue; }
  const resource = decodeURIComponent(data.resource || '').replace(/\\/g, '/').toLowerCase();
  if (!resource.startsWith('file:///' + projectRoot)) continue;
  const relPath = resource.substring(('file:///' + projectRoot).length).replace(/^\/+/, '');
  if (!relPath.endsWith('.dart')) continue;
  if (relPath.includes('.history')) continue;

  for (const e of data.entries) {
    if (e.timestamp < lastWeek || e.timestamp >= cutoff) continue;
    try {
      const content = fs.readFileSync(path.join(historyDir, dir, e.id), 'utf8');
      const hasChaoPrimary = content.includes('MyConstant.chaoPrimary');
      if (hasChaoPrimary) {
        if (!results[relPath] || e.timestamp > results[relPath].ts) {
          results[relPath] = { ts: e.timestamp, id: e.id, dir };
        }
      }
    } catch(err) {}
  }
}

console.log('Files with MyConstant.chaoPrimary in VS Code history (pre-12:00 today):');
const list = Object.entries(results).sort((a,b) => b[1].ts - a[1].ts);
for (const [fp, info] of list) {
  const local = new Date(info.ts + 7*3600*1000).toISOString().replace('T', ' ').slice(0, 19);
  console.log('  ' + local + ' +07  ' + fp);
}
console.log('\nTOTAL: ' + list.length);
