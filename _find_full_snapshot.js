// Find largest transcript entries referencing subV3 — likely full file snapshots
const fs = require('fs');
const readline = require('readline');

const logPath = 'C:\\Users\\Jittr\\.gemini\\antigravity-ide\\brain\\5e8690a7-a260-40dd-86f4-865ae51068b8\\.system_generated\\logs\\transcript.jsonl';

const target = process.argv[2] || 'payment_subV3_InvAll';

const rl = readline.createInterface({
  input: fs.createReadStream(logPath, { encoding: 'utf8' }),
  crlfDelay: Infinity
});

let lineNo = 0;
const hits = [];

rl.on('line', (line) => {
  lineNo++;
  if (!line.includes(target)) return;
  let data;
  try { data = JSON.parse(line); } catch(e) { return; }
  // Check if there's full file content - look for ReplacementContent or run_command WriteFile or similar
  let hasFullFile = false;
  let chaoPrimary = line.includes('chaoPrimary');
  let thaiQr = line.includes('thai_qr_payment_2');
  let s = JSON.stringify(data);
  // Look for patterns suggesting full file content
  if (s.length > 50000) hasFullFile = true;
  // Common indicators
  const fullFileIndicators = [
    'write_to_file',
    'WriteToFile',
    'write_file_content',
    'RESTORE',
    'restore',
    'CHECKPOINT',
    'full_content'
  ];
  let indicator = fullFileIndicators.find(i => s.includes(i));

  hits.push({
    line: lineNo,
    size: line.length,
    kind: data.type || 'unknown',
    chaoPrimary,
    thaiQr,
    indicator: indicator || '',
    ts: data.created_at || data.timestamp || ''
  });
});

rl.on('close', () => {
  // Sort by size descending
  hits.sort((a,b) => b.size - a.size);
  console.log('Top 30 largest lines referencing ' + target + ':\n');
  for (const h of hits.slice(0, 30)) {
    const local = h.ts ? new Date(new Date(h.ts).getTime() + 7*3600*1000).toISOString().slice(0,19) : '';
    console.log('  line=' + h.line + '  size=' + h.size + '  kind=' + h.kind + '  thai_qr=' + h.thaiQr + '  indicator=' + h.indicator + '  ts=' + local);
  }
});
