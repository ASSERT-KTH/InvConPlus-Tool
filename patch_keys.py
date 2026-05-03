#!/usr/bin/env python3
"""Patch hardcoded QuickNode URL to use environment variable."""
import re

path = "invconplus/plugin/quickNode.py"
content = open(path).read()
content = re.sub(
    r"url = 'https://[^']+quiknode\.pro/[^']*/'",
    "url = os.environ.get('QUICKNODE_URL', '')",
    content
)
if "import os" not in content:
    content = "import os\n" + content
open(path, "w").write(content)
print("quickNode.py patched OK")
