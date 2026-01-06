#!/usr/bin/env python3

import os
import sys
import urllib.parse
from pathlib import Path

def relpath(root_dir, path):
    root_dir = Path(root_dir)
    path     = Path(path)
    relpath  = path.relative_to(root_dir)

    if path == root_dir:
        raise ValueError("path and root_dir are the same!")

    if relpath.name in ["index.html", "index.md"]:
        parent = relpath.parent.as_posix()
        if parent == ".":
            url = ""
        else:
            url = parent + os.sep
    else:
        url = relpath.as_posix()

    return urllib.parse.quote(url)


if __name__ == "__main__":
    print(relpath(sys.argv[1], sys.argv[2]))
