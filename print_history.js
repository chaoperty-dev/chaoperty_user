const fs = require('fs');
const path = require('path');
const historyDir = path.join(process.env.APPDATA, 'Code/User/History');
const dirs = fs.readdirSync(historyDir);

for (const dir of dirs) {
    const entriesPath = path.join(historyDir, dir, 'entries.json');
    if (fs.existsSync(entriesPath)) {
        try {
            const data = JSON.parse(fs.readFileSync(entriesPath, 'utf8'));
            const res = decodeURIComponent(data.resource || '');
            if (res.includes('payment_subV3_InvAll.dart')) {
                console.log(dir + ': ' + res);
                console.log(JSON.stringify(data.entries.map(e => ({id: e.id, ts: e.timestamp}))));
            }
        } catch(e) {}
    }
}
