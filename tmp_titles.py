import os
import re
import requests
base = r'C:\Users\kautk\Desktop\Leetcode Solutions\Deep-ML'
out = []
for n in range(26, 101):
    url = f'https://www.deep-ml.com/problems/{n}'
    html = requests.get(url, timeout=20).text
    m = re.search(r'<title>(.*?)</title>', html, re.S | re.I)
    title = re.sub(r'\s+', ' ', m.group(1)).strip() if m else 'TITLE_NOT_FOUND'
    out.append(f'{n}\t{title}')
path = os.path.join(base, 'actual_titles_26_100.txt')
with open(path, 'w', encoding='utf-8') as f:
    f.write('\n'.join(out))
print(path)
