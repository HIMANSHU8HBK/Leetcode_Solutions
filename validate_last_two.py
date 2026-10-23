import re
import requests
from pathlib import Path

base = Path(r"C:\Users\kautk\Desktop\Leetcode Solutions\Deep-ML")
files = [base / "0026_0050.md", base / "0051_0100.md"]
pattern = re.compile(r"^#\s+Deep-ML\s+Problem\s+(\d+):\s*(.+)$", re.M)
expected = {}

for file_path in files:
    text = file_path.read_text(encoding="utf-8")
    for num, title in pattern.findall(text):
        expected[int(num)] = title.strip()

mismatches = []
for num in sorted(expected):
    url = f"https://www.deep-ml.com/problems/{num}"
    try:
        html = requests.get(url, timeout=20).text
        title_match = re.search(r"<title>(.*?)</title>", html, re.S | re.I)
        site_title = re.sub(r"\s+", " ", title_match.group(1)).strip() if title_match else "TITLE_NOT_FOUND"
        if site_title != expected[num]:
            mismatches.append((num, expected[num], site_title))
    except Exception as exc:  # pragma: no cover
        mismatches.append((num, expected[num], f"ERROR: {exc}"))

print(f"COUNT_EXPECTED={len(expected)}")
print(f"COUNT_MISMATCHES={len(mismatches)}")
for num, file_title, site_title in mismatches[:25]:
    print(f"{num}: FILE='{file_title}' | SITE='{site_title}'")
if len(mismatches) > 25:
    print("... more mismatches beyond first 25")
