// Find first occurrence of chaoPrimary specifically (not just MyConstant)
const fs = require('fs');
const path = require('path');
const historyDir = path.join(process.env.APPDATA, 'Code/User/History');

const dirs = fs.readdirSync(historyDir);
const projectRoot = process.cwd().replace(/\\/g, '/').toLowerCase();

const earliest = {};
const latestWithout = {};

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

  const sortedEntries = [...data.entries].sort((a,b) => a.timestamp - b.timestamp);
  let foundFirst = null;
  let lastBefore = null;
  for (const e of sortedEntries) {
    try {
      const content = fs.readFileSync(path.join(historyDir, dir, e.id), 'utf8');
      const has = content.includes('chaoPrimary');
      if (has && !foundFirst) {
        foundFirst = { ts: e.timestamp, id: e.id, dir };
      }
      if (!has && !foundFirst) {
        lastBefore = { ts: e.timestamp, id: e.id, dir };
      }
    } catch(err) {}
  }
  if (foundFirst) {
    if (!earliest[relPath] || foundFirst.ts < earliest[relPath].ts) {
      earliest[relPath] = foundFirst;
      latestWithout[relPath] = lastBefore;
    }
  }
}

console.log('Files that EVER had chaoPrimary (sorted by first occurrence):\n');
const list = Object.keys(earliest).sort((a,b) => earliest[a].ts - earliest[b].ts);
let withRecoveryPoint = 0;
let withoutRecoveryPoint = 0;
for (const fp of list) {
  const e = earliest[fp];
  const lb = latestWithout[fp];
  const local = new Date(e.ts + 7*3600*1000).toISOString().replace('T', ' ').slice(0, 19);
  if (lb) {
    const lbLocal = new Date(lb.ts + 7*3600*1000).toISOString().replace('T', ' ').slice(0, 19);
    console.log('  [HAS_RECOVERY] first=' + local + '  recover_from=' + lbLocal + '  ' + fp);
    withRecoveryPoint++;
  } else {
    console.log('  [NO_RECOVERY]  first=' + local + '  (no entry before chaoPrimary)  ' + fp);
    withoutRecoveryPoint++;
  }
}
console.log('\nTOTAL files with chaoPrimary in history: ' + list.length);
console.log('  Recoverable (have entry before): ' + withRecoveryPoint);
console.log('  Not recoverable (chaoPrimary in oldest entry): ' + withoutRecoveryPoint);
