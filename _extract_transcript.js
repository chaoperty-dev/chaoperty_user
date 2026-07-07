const fs = require('fs');
const readline = require('readline');

const logPath = 'C:\\Users\\Jittr\\.gemini\\antigravity-ide\\brain\\5e8690a7-a260-40dd-86f4-865ae51068b8\\.system_generated\\logs\\transcript.jsonl';

const targets = ['payment_subV3_InvAll', 'payment_subV4_InvAll', 'payment_mainV3_InvAll'];
const hits = [];

const rl = readline.createInterface({
  input: fs.createReadStream(logPath, { encoding: 'utf8' }),
  crlfDelay: Infinity
});

let lineNo = 0;
rl.on('line', (line) => {
  lineNo++;
  for (const t of targets) {
    if (line.includes(t)) {
      let data;
      try { data = JSON.parse(line); } catch(e) { continue; }
      // Find height near thai_qr_payment_2
      let heights = [];
      let totalSecs = null;
      const s = JSON.stringify(data);
      // Look for all thai_qr_payment_2 followed by height
      const re = /thai_qr_payment_2[\s\S]{0,800}?height:\s*([0-9.]+)/g;
      let m;
      while ((m = re.exec(s)) !== null) heights.push(m[1]);
      // Look for _totalSecs
      const tm = s.match(/_totalSecs\s*=\s*(\d+)/);
      if (tm) totalSecs = tm[1];
      hits.push({
        line: lineNo,
        target: t,
        size: line.length,
        kind: data.type || data.role || data.kind || 'unknown',
        heights: heights.slice(0,3).join(','),
        totalSecs,
        ts: data.timestamp || data.time || data.created_at || ''
      });
      break;
    }
  }
});

rl.on('close', () => {
  console.log('Total hits: ' + hits.length + '\n');
  // Group by target
  for (const t of targets) {
    const tHits = hits.filter(h => h.target === t);
    console.log('=== ' + t + ' (' + tHits.length + ' hits) ===');
    for (const h of tHits.slice(-15)) {
      console.log('  line=' + h.line + '  size=' + h.size + '  kind=' + h.kind + '  heights=[' + h.heights + ']  totalSecs=' + h.totalSecs + '  ts=' + h.ts);
    }
    console.log('');
  }
});
