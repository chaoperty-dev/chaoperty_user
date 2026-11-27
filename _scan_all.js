const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const historyDir = path.join(process.env.APPDATA, 'Code/User/History');

// Cutoff: 2026-05-23 12:30 +07 = 05:30 UTC
const cutoff = new Date('2026-05-23T05:30:00Z').getTime();

const targets = [
  'lib/main.dart',
  'lib/CRC_16_Prompay/generate_qrcode.dart',
  'lib/Constant/Myconstant.dart',
  'lib/screen/home_screen.dart',
  'lib/screen/loginscreen.dart',
  'lib/screen/metercheck_screen.dart',
  'lib/screen/payhistory_screen.dart',
  'lib/screen/pay_bill_Mainscreen.dart',
  'lib/screen/pay_bill_PayMainscreen.dart',
  'lib/screen/pay_bill_screen.dart',
  'lib/screen/pay_bill_screen_Choice.dart',
  'lib/screen/pay_bill_SubMainscreen.dart',
  'lib/screen/pay_scan_bill_screen.dart',
  'lib/screen/pay_screen.dart',
  'lib/screen/pay_Tran_screen.dart',
  'lib/screen/personalinfo_screen.dart',
  'lib/screen_Intents/folw_EX.dart',
  'lib/screen_Intents/payment_intents_InvAll.dart',
  'lib/screen_Intents/payment_mainV2_InvAll.dart',
  'lib/screen_Intents/payment_subV2_InvAll.dart',
  'lib/screen_Intents/storeUp_payment_subV2_InvAll.dart',
  'lib/screen_Intents_V3/folw_EX.dart',
  'lib/screen_Intents_V3/payment_intents_InvAll.dart',
  'lib/screen_Intents_V3/payment_mainV3_InvAll.dart',
  'lib/screen_Intents_V3/payment_subV3_InvAll.dart',
  'lib/screen_Intents_V4/payment_subV4_InvAll.dart'
];

const dirs = fs.readdirSync(historyDir);

function getHeadContent(target) {
  try {
    return execSync('git show HEAD:"' + target + '"', { encoding: 'utf8' });
  } catch(e) { return null; }
}

function readCurrent(target) {
  try { return fs.readFileSync(target, 'utf8'); } catch(e) { return null; }
}

console.log('Target | LatestPre12:30 | CurrentMatches | HeadMatches');
console.log('-------|----------------|----------------|------------');

for (const target of targets) {
  let entries = [];
  for (const dir of dirs) {
    const ep = path.join(historyDir, dir, 'entries.json');
    if (!fs.existsSync(ep)) continue;
    try {
      const data = JSON.parse(fs.readFileSync(ep, 'utf8'));
      const res = decodeURIComponent(data.resource || '').replace(/\\/g, '/');
      if (res.endsWith(target) || res.includes('/' + target)) {
        for (const e of data.entries) {
          if (e.timestamp < cutoff) entries.push({ts: e.timestamp, id: e.id, dir});
        }
      }
    } catch(e) {}
  }
  entries.sort(function(a,b){ return b.ts - a.ts; });
  if (entries.length === 0) {
    console.log(target + ' | NO_HISTORY | - | -');
    continue;
  }
  const best = entries[0];
  const best_local = new Date(best.ts + 7*3600*1000).toISOString().replace('T', ' ').slice(0, 16);
  const histContent = fs.readFileSync(path.join(historyDir, best.dir, best.id), 'utf8');
  const cur = readCurrent(target);
  const head = getHeadContent(target);
  const matchCur = (cur !== null && cur === histContent) ? 'YES' : 'no';
  const matchHead = (head !== null && head === histContent) ? 'YES' : 'no';
  const onDisk = cur === null ? 'MISSING' : 'present';
  console.log(target + ' | ' + best_local + ' | cur=' + matchCur + ' | head=' + matchHead + ' | ' + onDisk);
}
