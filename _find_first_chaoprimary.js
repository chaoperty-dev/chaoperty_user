// Find first occurrence of MyConstant.chaoPrimary in VS Code history (ANY date)
// For each file in the project, find the EARLIEST history entry that contains chaoPrimary
const fs = require('fs');
const path = require('path');
const historyDir = path.join(process.env.APPDATA, 'Code/User/History');

const dirs = fs.readdirSync(historyDir);
const projectRoot = process.cwd().replace(/\\/g, '/').toLowerCase();

const earliest = {}; // file -> earliest entry containing chaoPrimary
const latestWithout = {}; // file -> latest entry BEFORE first chaoPrimary entry (this is what we want to restore to)

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

  // Sort entries chronologically
  const sortedEntries = [...data.entries].sort((a,b) => a.timestamp - b.timestamp);
  let foundFirst = null;
  let lastBefore = null;
  for (const e of sortedEntries) {
    try {
      const content = fs.readFileSync(path.join(historyDir, dir, e.id), 'utf8');
      const has = content.includes('chaoPrimary') || content.includes('MyConstant');
      if (has && !foundFirst) {
        foundFirst = { ts: e.timestamp, id: e.id, dir };
        break;
      }
      if (!has) {
        lastBefore = { ts: e.timestamp, id: e.id, dir };
      }
    } catch(err) {}
  }
  if (foundFirst) {
    earliest[relPath] = foundFirst;
    if (lastBefore) latestWithout[relPath] = lastBefore;
  }
}

console.log('Files that have chaoPrimary or MyConstant in some VS Code history:\n');
const list = Object.keys(earliest).sort();
for (const fp of list) {
  const e = earliest[fp];
  const lb = latestWithout[fp];
  const local = new Date(e.ts + 7*3600*1000).toISOString().replace('T', ' ').slice(0, 19);
  const lbLocal = lb ? new Date(lb.ts + 7*3600*1000).toISOString().replace('T', ' ').slice(0, 19) : 'NONE-BEFORE';
  console.log('  FIRST chaoPrimary: ' + local);
  console.log('  LAST without:      ' + lbLocal);
  console.log('  ' + fp);
  console.log('');
}
console.log('TOTAL: ' + list.length);
