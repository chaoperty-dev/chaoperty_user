// Scan ALL VS Code history entries for any file edited TODAY (2026-05-23) before 12:00 +07
const fs = require('fs');
const path = require('path');
const historyDir = path.join(process.env.APPDATA, 'Code/User/History');

// Cutoff: 2026-05-23 12:00 +07 = 05:00 UTC
const cutoff = new Date('2026-05-23T05:00:00Z').getTime();
// Start of today: 2026-05-23 00:00 +07 = 2026-05-22 17:00 UTC
const todayStart = new Date('2026-05-22T17:00:00Z').getTime();

const projectRoot = process.cwd().replace(/\\/g, '/').toLowerCase();
console.log('Project root:', projectRoot);
console.log('Today window: ' + new Date(todayStart).toISOString() + ' .. ' + new Date(cutoff).toISOString());
console.log('');

const dirs = fs.readdirSync(historyDir);
// Map: file path -> { ts, id, dir, allEntriesToday: [] }
const results = {};

for (const dir of dirs) {
  const ep = path.join(historyDir, dir, 'entries.json');
  if (!fs.existsSync(ep)) continue;
  let data;
  try { data = JSON.parse(fs.readFileSync(ep, 'utf8')); } catch(e) { continue; }
  const resource = decodeURIComponent(data.resource || '').replace(/\\/g, '/').toLowerCase();
  // Must be inside project root and inside lib/ or be pubspec.yaml
  if (!resource.startsWith('file:///' + projectRoot)) continue;
  // Strip "file:///" prefix and project root
  const relPath = resource.substring(('file:///' + projectRoot).length).replace(/^\/+/, '');
  if (!relPath.startsWith('lib/') && relPath !== 'pubspec.yaml') continue;
  if (relPath.includes('.history')) continue;

  // Find best entry pre-cutoff, prefer ones from today
  let bestToday = null;
  let bestAny = null;
  let todayEntries = [];
  for (const e of data.entries) {
    if (e.timestamp >= cutoff) continue;
    if (!bestAny || e.timestamp > bestAny.timestamp) bestAny = e;
    if (e.timestamp >= todayStart) {
      todayEntries.push(e);
      if (!bestToday || e.timestamp > bestToday.timestamp) bestToday = e;
    }
  }
  if (!bestToday) continue; // we only care about files edited TODAY pre-12:00

  // Use original-case path from data.resource
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

// Sort by timestamp desc
const list = Object.keys(results).map(k => ({path: k, ...results[k]}));
list.sort((a,b) => b.ts - a.ts);

console.log('Files edited today BEFORE 12:00 (latest entry shown):');
console.log('');
for (const it of list) {
  const local = new Date(it.ts + 7*3600*1000).toISOString().replace('T', ' ').slice(0, 19);
  // Compare with current file
  let curSize = '?', cur = null;
  try { cur = fs.readFileSync(it.path, 'utf8'); curSize = cur.length; } catch(e) {}
  const hist = fs.readFileSync(path.join(historyDir, it.dir, it.id), 'utf8');
  const same = (cur !== null && cur === hist) ? 'SAME' : 'DIFF';
  console.log('  ' + local + ' +07 [' + same + ', todays=' + it.todayCount + ']  ' + it.path + '  (cur=' + curSize + ', hist=' + hist.length + ')');
}
