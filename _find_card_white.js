// Find all VS Code history entries TODAY that contain "Card" with white background
const fs = require('fs');
const path = require('path');
const historyDir = path.join(process.env.APPDATA, 'Code/User/History');

const todayStart = new Date('2026-05-22T17:00:00Z').getTime(); // 2026-05-23 00:00 +07
const cutoff = new Date('2026-05-23T05:00:00Z').getTime(); // 12:00 +07

const dirs = fs.readdirSync(historyDir);
const projectRoot = process.cwd().replace(/\\/g, '/').toLowerCase();

const results = [];
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
    if (e.timestamp < todayStart) continue;
    const fp = path.join(historyDir, dir, e.id);
    if (!fs.existsSync(fp)) continue;
    try {
      const content = fs.readFileSync(fp, 'utf8');
      // Look for Card with white background OR backgroundColor white
      const cardWhiteMatch = content.match(/Card\s*\(\s*[\s\S]{0,200}?color:\s*Colors\.white/);
      const bgWhiteMatch = content.match(/backgroundColor:\s*Colors\.white/);
      if (cardWhiteMatch || bgWhiteMatch) {
        const before = e.timestamp < cutoff;
        results.push({
          ts: e.timestamp,
          before,
          relPath,
          id: e.id,
          dir,
          cardWhite: !!cardWhiteMatch,
          bgWhite: !!bgWhiteMatch,
          size: content.length
        });
      }
    } catch(err) {}
  }
}

results.sort((a,b) => b.ts - a.ts);
console.log('Found ' + results.length + ' history entries TODAY with Card/backgroundColor=white\n');
for (const r of results) {
  const local = new Date(r.ts + 7*3600*1000).toISOString().replace('T', ' ').slice(0, 19);
  const tag = r.before ? '[PRE-12:00]' : '[POST-12:00]';
  const features = (r.cardWhite ? 'Card-white ' : '') + (r.bgWhite ? 'bg-white' : '');
  console.log('  ' + local + ' ' + tag + '  size=' + r.size + '  ' + features + '  ' + r.relPath);
}
