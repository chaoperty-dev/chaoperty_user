// Search transcript for any content with thai_qr_payment_2 + height
const fs = require('fs');
const readline = require('readline');

const logPath = 'C:\\Users\\Jittr\\.gemini\\antigravity-ide\\brain\\5e8690a7-a260-40dd-86f4-865ae51068b8\\.system_generated\\logs\\transcript.jsonl';

const rl = readline.createInterface({
  input: fs.createReadStream(logPath, { encoding: 'utf8' }),
  crlfDelay: Infinity
});

let lineNo = 0;
const hits = [];

rl.on('line', (line) => {
  lineNo++;
  // Look for thai_qr_payment_2 (escape-tolerant)
  if (!line.includes('thai_qr_payment_2')) return;
  // Find heights near it — handle escaped quotes too
  const segments = [];
  let idx = 0;
  while ((idx = line.indexOf('thai_qr_payment_2', idx)) !== -1) {
    segments.push(line.substring(idx, idx + 600));
    idx += 20;
  }
  let heights = [];
  for (const seg of segments) {
    // Try multiple patterns
    const patterns = [
      /height:\s*([0-9.]+)/g,
      /height:\\?\s*([0-9.]+)/g,
      /height\\?":\s*\\?"?([0-9.]+)/g,
    ];
    for (const p of patterns) {
      let m;
      while ((m = p.exec(seg)) !== null) heights.push(m[1]);
    }
  }
  if (heights.length > 0) {
    let data;
    try { data = JSON.parse(line); } catch(e) { data = {}; }
    hits.push({
      line: lineNo,
      kind: data.type || data.role || data.kind || 'unknown',
      heights: [...new Set(heights)].join(','),
      ts: data.timestamp || data.time || data.created_at || '',
      size: line.length
    });
  }
});

rl.on('close', () => {
  console.log('Lines with thai_qr_payment_2 + height: ' + hits.length + '\n');
  for (const h of hits) {
    console.log('  line=' + h.line + '  kind=' + h.kind + '  heights=[' + h.heights + ']  size=' + h.size + '  ts=' + h.ts);
  }
});
