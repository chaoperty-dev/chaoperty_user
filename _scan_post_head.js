// For files modified after 12:00 today, find latest history entry between
// HEAD commit time (2026-05-22 16:34 +07) and 12:00 today, and check if current differs.
const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const historyDir = path.join(process.env.APPDATA, 'Code/User/History');

// HEAD commit was at 2026-05-22 16:34:43 +07 = 2026-05-22 09:34:43 UTC
const headTime = new Date('2026-05-22T09:34:43Z').getTime();
const cutoff = new Date('2026-05-23T05:00:00Z').getTime(); // 12:00 +07

// Files modified post-12:00 today (from `find` earlier)
const files = [
  'lib/Api_V2/MyHeaders.dart',
  'lib/Constant/Myconstant.dart',
  'lib/CRC_16_Prompay/generate_qrcode.dart',
  'lib/main.dart',
  'lib/PDF/Choice/Sub_Agreement_Choice/pdf_SubAgreement_Choice.dart',
  'lib/PDF/Choice/Sub_Agreement_Choice/pdf_SubAgreement_Choice2.dart',
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
  'lib/screen/Screen_new/ui_view/running_view_pay.dart',
  'lib/screen_Intents/folw_EX.dart',
  'lib/screen_Intents/payment_intents_InvAll.dart',
  'lib/screen_Intents/payment_mainV2_InvAll.dart',
  'lib/screen_Intents/payment_subV2_InvAll.dart',
  'lib/screen_Intents/storeUp_payment_subV2_InvAll.dart',
  'lib/screen_Intents_V3/folw_EX.dart',
  'lib/screen_Intents_V3/payment_intents_InvAll.dart',
  'lib/screen_Intents_V3/payment_mainV3_InvAll.dart',
  'lib/screen_Intents_V3/payment_subV3_InvAll.dart',
  'lib/screen_Intents_V4/payment_subV4_InvAll.dart',
  'pubspec.yaml'
];

const dirs = fs.readdirSync(historyDir);

function findHistory(target) {
  let bestInWindow = null; // post-HEAD-commit and pre-cutoff
  let bestPreHead = null;  // any pre-HEAD-commit (fallback)
  let bestPreCutoff = null; // any pre-cutoff
  for (const dir of dirs) {
    const ep = path.join(historyDir, dir, 'entries.json');
    if (!fs.existsSync(ep)) continue;
    try {
      const data = JSON.parse(fs.readFileSync(ep, 'utf8'));
      const res = decodeURIComponent(data.resource || '').replace(/\\/g, '/').toLowerCase();
      const t = target.toLowerCase();
      if (!(res.endsWith(t) || res.includes('/' + t))) continue;
      for (const e of data.entries) {
        if (e.timestamp >= cutoff) continue;
        if (!bestPreCutoff || e.timestamp > bestPreCutoff.timestamp) bestPreCutoff = {...e, dir};
        if (e.timestamp >= headTime) {
          if (!bestInWindow || e.timestamp > bestInWindow.timestamp) bestInWindow = {...e, dir};
        } else {
          if (!bestPreHead || e.timestamp > bestPreHead.timestamp) bestPreHead = {...e, dir};
        }
      }
    } catch(e) {}
  }
  return { bestInWindow, bestPreHead, bestPreCutoff };
}

function getHead(target) {
  try { return execSync('git show HEAD:"' + target + '"', { encoding: 'utf8' }); } catch(e) { return null; }
}

console.log('File | InWindowEntry | CurMatches');
console.log('-----------------------------------');
for (const target of files) {
  let cur = null;
  try { cur = fs.readFileSync(target, 'utf8'); } catch(e) {}
  const head = getHead(target);
  const h = findHistory(target);

  const inWin = h.bestInWindow;
  const inWinLocal = inWin ? new Date(inWin.timestamp + 7*3600*1000).toISOString().slice(0,16).replace('T',' ') : 'NONE';

  let recommendation = '';
  if (inWin) {
    const winContent = fs.readFileSync(path.join(historyDir, inWin.dir, inWin.id), 'utf8');
    const matchesCur = cur === winContent;
    const matchesHead = head === winContent;
    if (matchesCur) recommendation = 'OK_ALREADY';
    else if (matchesHead) recommendation = 'OK_HEAD_EQUALS_WINDOW';
    else recommendation = 'RESTORE_FROM_WINDOW';
  } else {
    // No history in window - use HEAD
    if (cur === head) recommendation = 'OK_HEAD';
    else recommendation = 'RESTORE_TO_HEAD';
  }

  console.log('  ' + inWinLocal + '  ' + recommendation + '  ' + target);
}
