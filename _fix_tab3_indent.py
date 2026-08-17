#!/usr/bin/env python3
"""Fix Tab 3 indent (off by 4 spaces) and add missing Container close."""
fp = 'lib/screen_Intents_V4/payment_subV4_InvAll.dart'
with open(fp, 'r', encoding='utf-8') as f:
    lines = f.read().split('\n')

# Tab 3 block: lines 5567 (1-indexed) to 5686 (1-indexed) - off by 4 spaces
# Closing chain: 5687 (],), 5688 (), 5689 () - off by 4 spaces
# Need to insert Container close before line 5690 (const SizedBox)

# 0-indexed:
TAB3_START = 5566  # L5567
TAB3_END = 5685    # L5686 (last line of Tab 3 - Expanded close)
CHAIN_END = 5688   # L5689 (last `),` of chain)
INSERT_BEFORE = 5689  # L5690 (const SizedBox)

# Add 4 spaces to all lines from TAB3_START to CHAIN_END (inclusive)
for i in range(TAB3_START, CHAIN_END + 1):
    lines[i] = '    ' + lines[i]

# Insert Container close before INSERT_BEFORE
# Original indent for const SizedBox was 30, so Container close should also be at 30
container_close = '                              ),'  # 30 spaces + '),'
lines.insert(INSERT_BEFORE, container_close)

with open(fp, 'w', encoding='utf-8') as f:
    f.write('\n'.join(lines))

print('Fixed Tab 3 indent')
print(f'Added 4 spaces to lines {TAB3_START+1} to {CHAIN_END+1}')
print(f'Inserted Container close at line {INSERT_BEFORE+1}')
