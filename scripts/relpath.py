#!/usr/bin/env python3

import os
import sys
import urllib.parse
from pathlib import Path

root_dir = Path(sys.argv[1])
path     = Path(sys.argv[2])
relpath  = path.relative_to(root_dir)

if path == root_dir:
    raise ValueError("path and root_dir are the same!")

if relpath.name == "index.html":
    parent = relpath.parent.as_posix()
    if parent == ".":
        url = ""
    else:
        url = parent + os.sep
else:
    url = relpath.as_posix()

print(urllib.parse.quote(url))
