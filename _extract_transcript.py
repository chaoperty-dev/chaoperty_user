import json
import os
import re

log_path = r'C:\Users\Jittr\.gemini\antigravity-ide\brain\5e8690a7-a260-40dd-86f4-865ae51068b8\.system_generated\logs\transcript.jsonl'

# Target file names to search
targets = ['payment_subV3_InvAll', 'payment_subV4_InvAll', 'payment_mainV3_InvAll']

# Collect all entries that reference these files
hits = []
line_no = 0
with open(log_path, 'r', encoding='utf-8') as f:
    for line in f:
        line_no += 1
        try:
            data = json.loads(line)
        except:
            continue
        s = json.dumps(data, ensure_ascii=False)
        for t in targets:
            if t in s:
                # Get timestamp if present
                ts = data.get('timestamp') or data.get('time') or data.get('created_at') or ''
                # Try to find content snippets that include thai_qr_payment_2 with height
                content_str = s
                # Look for thai_qr_payment_2 nearby height
                m = re.search(r"thai_qr_payment_2[\s\S]{0,500}?height:\s*([0-9.]+)", content_str)
                height = m.group(1) if m else None
                # Type of entry
                ekind = data.get('type') or data.get('role') or data.get('kind') or 'unknown'
                hits.append({
                    'line': line_no,
                    'target': t,
                    'ts': ts,
                    'height': height,
                    'kind': ekind,
                    'size': len(line)
                })
                break

print(f'Total hits: {len(hits)}\n')
# Sort by line (chronological)
for h in hits[-40:]:  # last 40 hits
    print(f"  line={h['line']:5d}  size={h['size']:7d}  kind={h['kind']:15s}  target={h['target']:30s}  thai_height={h['height']}  ts={h['ts']}")
