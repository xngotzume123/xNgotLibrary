#!/usr/bin/env python3
"""Build the self-contained bilingual docs. Requires mistune 3.x."""
from pathlib import Path
import json
import re
import mistune
from content import sections

SITE = Path(__file__).resolve().parent
markdown = mistune.create_markdown(plugins=['table', 'strikethrough'])
pages = []
for ident, group_en, group_vi, title_en, title_vi, number, en, vi in sections:
    pages.append({
        'id': ident, 'num': number,
        'group': {'en': group_en, 'vi': group_vi},
        'title': {'en': title_en, 'vi': title_vi},
        'html': {'en': markdown(en), 'vi': markdown(vi)},
        'plain': {'en': re.sub(r'[#`*]', '', en), 'vi': re.sub(r'[#`*]', '', vi)},
    })
payload = json.dumps(pages, ensure_ascii=False, separators=(',', ':')).replace('</', '<\\/')
template = (SITE / 'template.html').read_text(encoding='utf-8')
assert template.count('__PAGES__') == 1
(SITE.parent / 'index.html').write_text(template.replace('__PAGES__', payload), encoding='utf-8')
for lang in ('en', 'vi'):
    parts = []
    for item in sections:
        parts.append(item[6 if lang == 'en' else 7].strip())
    title = '# xNgot Library — User Manual\n' if lang == 'en' else '# xNgot Library — Hướng dẫn sử dụng\n'
    (SITE.parent / ('LIBRARY.' + lang + '.md')).write_text(title + '\n\n---\n\n' + '\n\n---\n\n'.join(parts) + '\n', encoding='utf-8')
print('Built docs/index.html and bilingual Markdown with', len(pages), 'sections.')
