// Scan ALL VS Code history entries for any file in this project edited TODAY before 12:00 +07
const fs = require('fs');
const path = require('path');
const historyDir = path.join(process.env.APPDATA, 'Code/User/History');

const cutoff = new Date('2026-05-23T05:00:00Z').getTime();
const todayStart = new Date('2026-05-22T17:00:00Z').getTime();

const projectRoot = process.cwd().replace(/\\/g, '/').toLowerCase();
console.log('Project root:', projectRoot);

const dirs = fs.readdirSync(historyDir);
const results = {};

for (const dir of dirs) {
  const ep = path.join(historyDir, dir, 'entries.json');
  if (!fs.existsSync(ep)) continue;
  let data;
  try { data = JSON.parse(fs.readFileSync(ep, 'utf8')); } catch(e) { continue; }
  const resource = decodeURIComponent(data.resource || '').replace(/\\/g, '/').toLowerCase();
  if (!resource.startsWith('file:///' + projectRoot)) continue;
  const relPath = resource.substring(('file:///' + projectRoot).length).replace(/^\/+/, '');
  if (relPath.includes('.history')) continue;
  if (relPath.includes('_backup_before_revert')) continue;

  let bestToday = null;
  let todayEntries = [];
  for (const e of data.entries) {
    if (e.timestamp >= cutoff) continue;
    if (e.timestamp >= todayStart) {
      todayEntries.push(e);
      if (!bestToday || e.timestamp > bestToday.timestamp) bestToday = e;
    }
  }
  if (!bestToday) continue;

  const resourceOrig = decodeURIComponent(data.resource || '').replace(/\\/g, '/');
  const idx = resourceOrig.toLowerCase().indexOf(projectRoot);
  const relOrig = resourceOrig.substring(idx + projectRoot.length).replace(/^\/+/, '');

  results[relOrig] = {
    ts: bestToday.timestamp,
    id: bestToday.id,
    dir,
    todayCount: todayEntries.length
  };
}

const list = Object.keys(results).map(k => ({path: k, ...results[k]}));
list.sort((a,b) => b.ts - a.ts);

console.log('TOTAL files edited today pre-12:00: ' + list.length);
console.log('');
for (const it of list) {
  const local = new Date(it.ts + 7*3600*1000).toISOString().replace('T', ' ').slice(0, 19);
  let cur = null, curSize = '?';
  try { cur = fs.readFileSync(it.path, 'utf8'); curSize = cur.length; } catch(e) { curSize = 'MISSING'; }
  const hist = fs.readFileSync(path.join(historyDir, it.dir, it.id), 'utf8');
  const same = (cur !== null && cur === hist) ? 'SAME' : 'DIFF';
  console.log('  ' + local + ' +07 [' + same + ', todays=' + it.todayCount + ']  ' + it.path + '  (cur=' + curSize + ', hist=' + hist.length + ')');
}
