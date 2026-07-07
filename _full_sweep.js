// For ALL project files with any VS Code history entry AFTER 12:00 today (= AI touched it),
// find the LATEST history entry BEFORE 12:00 (any date), and check if current content matches.
const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const historyDir = path.join(process.env.APPDATA, 'Code/User/History');

const cutoff = new Date('2026-05-23T05:00:00Z').getTime(); // 12:00 +07
const aiWindowEnd = new Date('2026-05-23T17:00:00Z').getTime(); // end of today

const projectRoot = process.cwd().replace(/\\/g, '/').toLowerCase();
const dirs = fs.readdirSync(historyDir);
const filesTouchedByAI = {};

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
  if (relPath.startsWith('_')) continue; // skip our scratch scripts

  // Check: any entry between cutoff and end of today?
  let aiTouched = false;
  let latestPre = null;
  for (const e of data.entries) {
    if (e.timestamp >= cutoff && e.timestamp <= aiWindowEnd) aiTouched = true;
    if (e.timestamp < cutoff) {
      if (!latestPre || e.timestamp > latestPre.timestamp) latestPre = {...e, dir};
    }
  }
  if (!aiTouched) continue;

  const resourceOrig = decodeURIComponent(data.resource || '').replace(/\\/g, '/');
  const idx = resourceOrig.toLowerCase().indexOf(projectRoot);
  const relOrig = resourceOrig.substring(idx + projectRoot.length).replace(/^\/+/, '');

  filesTouchedByAI[relOrig] = { latestPre, hadAIEntries: true };
}

function getHead(target) {
  try { return execSync('git show HEAD:"' + target + '"', { encoding: 'utf8' }); } catch(e) { return null; }
}

console.log('Files VS Code recorded AI editing TODAY after 12:00: ' + Object.keys(filesTouchedByAI).length);
console.log('');
console.log('LATEST_PRE_12:00 | CURRENT_MATCHES | FILE');
console.log('---------------------------------------------');
for (const target of Object.keys(filesTouchedByAI)) {
  const info = filesTouchedByAI[target];
  let cur = null;
  try { cur = fs.readFileSync(target, 'utf8'); } catch(e) {}
  if (!info.latestPre) {
    console.log('  NONE_FOUND   ?   ' + target);
    continue;
  }
  const histContent = fs.readFileSync(path.join(historyDir, info.latestPre.dir, info.latestPre.id), 'utf8');
  const head = getHead(target);
  const tsLocal = new Date(info.latestPre.timestamp + 7*3600*1000).toISOString().slice(0,16).replace('T',' ');
  let status = '';
  if (cur === histContent) status = 'CUR=HIST(ok)';
  else if (head === histContent) status = 'HIST=HEAD(cur differs!)';
  else status = 'CUR_DIFFERS_FROM_HIST';
  console.log('  ' + tsLocal + '  ' + status + '  ' + target);
}
