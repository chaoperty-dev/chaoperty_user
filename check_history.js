const fs = require('fs');
const path = require('path');

const historyDir = path.join(process.env.APPDATA, 'Code/User/History');
const targetFile = 'lib/screen_Intents_V3/payment_mainV3_InvAll.dart'.replace(/\//g, '\\\\');

function findHistory() {
    const dirs = fs.readdirSync(historyDir);
    let candidates = [];

    for (const dir of dirs) {
        const entriesPath = path.join(historyDir, dir, 'entries.json');
        if (fs.existsSync(entriesPath)) {
            try {
                const data = JSON.parse(fs.readFileSync(entriesPath, 'utf8'));
                const res = decodeURIComponent(data.resource || '');
                if (res.includes(targetFile.replace(/\\\\/g, '/'))) {
                    candidates.push({ dir, entries: data.entries });
                }
            } catch(e) {}
        }
    }
    
    return candidates;
}

const history = findHistory();
console.log(JSON.stringify(history, null, 2));
