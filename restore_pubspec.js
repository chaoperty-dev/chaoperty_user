const fs = require('fs');
const path = require('path');
const execSync = require('child_process').execSync;

const historyDir = path.join(process.env.APPDATA, 'Code/User/History');

const targetFiles = [
    'pubspec.yaml'
];

function getGitVersion(filePath) {
    try {
        return execSync('git show HEAD:' + filePath).toString('utf8');
    } catch(e) { return ''; }
}

const dirs = fs.readdirSync(historyDir);

for (const target of targetFiles) {
    let bestEntry = null;
    let bestDir = null;

    for (const dir of dirs) {
        const entriesPath = path.join(historyDir, dir, 'entries.json');
        if (fs.existsSync(entriesPath)) {
            try {
                const data = JSON.parse(fs.readFileSync(entriesPath, 'utf8'));
                const res = decodeURIComponent(data.resource || '');
                if (res.includes(target) && !res.includes('.history')) {
                    for (const entry of data.entries) {
                        if (entry.timestamp < 1779514000000) {
                            if (!bestEntry || entry.timestamp > bestEntry.timestamp) {
                                bestEntry = entry;
                                bestDir = dir;
                            }
                        }
                    }
                }
            } catch(e) {}
        }
    }

    if (bestEntry && bestDir) {
        const historyFilePath = path.join(historyDir, bestDir, bestEntry.id);
        const historyContent = fs.readFileSync(historyFilePath, 'utf8');
        console.log('Restoring: ' + target);
        fs.writeFileSync(target, historyContent, 'utf8');
        console.log('Done!');
    } else {
        console.log('No history found for: ' + target);
    }
}
