const fs = require('fs');
const path = require('path');

const directory = 'lib';

function walk(dir) {
    let results = [];
    const list = fs.readdirSync(dir);
    list.forEach(file => {
        file = path.join(dir, file);
        const stat = fs.statSync(file);
        if (stat && stat.isDirectory()) {
            results = results.concat(walk(file));
        } else {
            if (file.endsWith('.dart')) results.push(file);
        }
    });
    return results;
}

const files = walk(directory);
let changedFiles = 0;

files.forEach(file => {
    let content = fs.readFileSync(file, 'utf8');
    if (content.includes('MyConstant.chaoPrimary')) {
        let newContent = content.replace(/MyConstant\.chaoPrimary/g, 'Colors.indigo');
        fs.writeFileSync(file, newContent, 'utf8');
        console.log('Updated: ' + file);
        changedFiles++;
    }
});

console.log('Total files restored: ' + changedFiles);
