const fs = require('fs');
const readline = require('readline');

const logPath = 'C:\\Users\\Jittr\\.gemini\\antigravity-ide\\brain\\5e8690a7-a260-40dd-86f4-865ae51068b8\\.system_generated\\logs\\transcript.jsonl';

const wanted = parseInt(process.argv[2]);
const rl = readline.createInterface({
  input: fs.createReadStream(logPath, { encoding: 'utf8' }),
  crlfDelay: Infinity
});

let lineNo = 0;
rl.on('line', (line) => {
  lineNo++;
  if (lineNo === wanted) {
    let data;
    try { data = JSON.parse(line); } catch(e) { console.log(line); rl.close(); return; }
    // pretty print
    console.log(JSON.stringify(data, null, 2).substring(0, 8000));
    rl.close();
  }
});
