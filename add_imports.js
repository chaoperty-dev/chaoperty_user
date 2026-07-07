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

files.forEach(file => {
    let content = fs.readFileSync(file, 'utf8');
    if (content.includes('MyConstant')) {
        if (!content.includes('Myconstant.dart')) {
            const importStr = "import 'package:chaoperty_user/Constant/Myconstant.dart';\n";
            // Insert after the first import or at the top
            let lines = content.split('\n');
            let lastImportIdx = -1;
            for (let i = 0; i < lines.length; i++) {
                if (lines[i].trim().startsWith('import ')) {
                    lastImportIdx = i;
                }
            }
            if (lastImportIdx !== -1) {
                lines.splice(lastImportIdx + 1, 0, importStr);
            } else {
                lines.unshift(importStr);
            }
            fs.writeFileSync(file, lines.join('\n'), 'utf8');
            console.log('Added import to: ' + file);
        }
    }
});
