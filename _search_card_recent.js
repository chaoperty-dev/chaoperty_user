// Find recent history entries (today + yesterday) where 'Card' or 'background' was changed
// Look for transitions: entry N has no white card, entry N+1 has white card
const fs = require('fs');
const path = require('path');
const historyDir = path.join(process.env.APPDATA, 'Code/User/History');

const dirs = fs.readdirSync(historyDir);
const projectRoot = process.cwd().replace(/\\/g, '/').toLowerCase();
const twoDaysAgo = new Date('2026-05-21T17:00:00Z').getTime();
const cutoff = new Date('2026-05-23T05:00:00Z').getTime();

const fileEntries = {};
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
    if (e.timestamp < twoDaysAgo || e.timestamp >= cutoff) continue;
    if (!fileEntries[relPath]) fileEntries[relPath] = [];
    fileEntries[relPath].push({ ts: e.timestamp, id: e.id, dir });
  }
}

// For each file, sort entries chronologically and look for first appearance of "Colors.white" related to Card
console.log('Looking for "first appearance of card/white" transitions...\n');
for (const fp of Object.keys(fileEntries)) {
  const arr = fileEntries[fp].sort((a,b) => a.ts - b.ts);
  let prevHasCardWhite = null;
  for (const e of arr) {
    const content = fs.readFileSync(path.join(historyDir, e.dir, e.id), 'utf8');
    // Look for Card with color white nearby OR Container with white backgroundColor
    const hasCardWhite = /Card\s*\([^)]{0,500}color:\s*Colors\.white/s.test(content) ||
                        /color:\s*Colors\.white[^,]{0,100}.*Card/s.test(content);
    if (prevHasCardWhite === false && hasCardWhite) {
      const local = new Date(e.ts + 7*3600*1000).toISOString().replace('T', ' ').slice(0, 19);
      console.log('  TRANSITION: ' + local + '  ' + fp);
    }
    prevHasCardWhite = hasCardWhite;
  }
}
console.log('\nDone.');
