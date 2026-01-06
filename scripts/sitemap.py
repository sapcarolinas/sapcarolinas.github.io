#!/usr/bin/env python3

import fnmatch
import os
import subprocess
import sys
from datetime import datetime

from relpath import relpath

baseurl = sys.argv[1]
source_dir = sys.argv[2]
exclude_patterns = sys.argv[2:]

indexable_paths = {}

for root, dirs, files in os.walk(source_dir):
    for file in files:
        path = os.path.join(root, file)
        if path.endswith('.md') or path.endswith('.html'):
            rpath = relpath(source_dir, path)
            exclude = False
            for pattern in exclude_patterns:
                if fnmatch.fnmatch(rpath, pattern):
                    exclude = True
                    break
            if not exclude:
                indexable_paths[path] = rpath

print('<?xml version="1.0" encoding="UTF-8"?>')
print('<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">')
for path, rpath in indexable_paths.items():
    lastmod = subprocess.run(['git', 'log', '-1', '--format=%cI', path],
                        stdout=subprocess.PIPE,
                        universal_newlines=True).stdout.strip()
    print('  <url>')
    print(f'    <loc>{baseurl}/{rpath}</loc>')
    print(f'    <lastmod>{lastmod}</lastmod>')
    print('  </url>')
print('</urlset>')
