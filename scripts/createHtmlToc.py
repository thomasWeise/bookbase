"""A small script for minifying HTML pages."""

import sys
from io import StringIO
from typing import Final

from pycommons.io.console import logger
from pycommons.io.path import Path

file: Final[Path] = Path(sys.argv[1])
logger(f"Now creating TOC for {file!r}.")
text: str = file.read_all_str()
orig_len: Final[int] = str.__len__(text)
logger(f"Read {orig_len} characters from {file!r}.")

# A list with start, depth, key, and title
toc: Final[list[tuple[int, int, str, str]]] = []
key_counter: int = 0

write_back: bool = True

for depth in range(1, 8):
    if not write_back:
        break
    start_tag: str = f"<h{depth}"
    end_tag: str = f"</h{depth}>"
    i1: int = 0
    while True:
        i2: int = text.find(start_tag, i1)
        if i2 < i1:
            break
        i1 = i2
        i2 = text.find(">", i1)
        if i2 < i1:
            write_back = False
            break
        i3: int = text.find(end_tag, i2)
        if i3 < i2:
            write_back = False
            break
        id_i1: int = text.find("id=", i1, i2)
        the_id: str | None = None
        if i1 < id_i1 < i2:
            id_i1 += 3
            id_quote = text[id_i1]
            if id_quote not in {"'", '"'}:
                write_back = False
                break
            id_i1 += 1
            id_end = text.find(id_quote, id_i1, i2)
            if id_i1 < id_end < i2:
                the_id = text[id_i1:id_end]
                if (str.__len__(the_id) <= 0) or (str.strip(the_id) != the_id):
                    write_back = False
                    break
            else:
                write_back = False
                break
        else:
            while True:
                the_id = f"k{key_counter:x}"
                key_counter += 1
                if the_id not in text:
                    break
            ins = f" id={the_id!r}"
            text = f"{text[:i2]}{ins}{text[i2:]}"
            i2 += str.__len__(ins)
            i3 += str.__len__(ins)
        toc.append((i1, depth, the_id, text[i2 + 1:i3]))
        i1 = i3

if not write_back:
    logger("Invalid toc, quitting.")
    sys.exit(0)

# remove single top-level entries, if any
while toc:
    min_depth = min(x[1] for x in toc)
    n_min_depth = sum(1 if x[1] <= min_depth else 0 for x in toc)
    if n_min_depth > 1:
        break
    if n_min_depth <= 1:
        logger("Only single element at minimal depth, raising elements.")
        for i in range(list.__len__(toc) - 1, -1, -1):
            x = toc[i]
            depth = x[1]
            if depth <= min_depth:
                del toc[i]
            else:
                toc[i] = (x[0], depth - 1, x[2], x[3])

if list.__len__(toc) <= 0:
    logger("Toc is empty, we quit.")
    sys.exit(0)

if toc[0][1] != 1:
    logger(f"First toc element {toc[0]!r} is not of minimal depth, quitting.")
    sys.exit(0)

toc.sort()
last_depth: int = 0
with StringIO() as sio:
    sio.write("<div class='toc'>")
    for _, td, key, txt in toc:
        while last_depth > td:
            sio.write("</li></ul>")
            last_depth -= 1
        if last_depth >= td:
            sio.write("</li>")
        while last_depth < td:
            sio.write("<ul class='toc'>")
            last_depth += 1
        sio.write(f"<li class='toc'><a href='#{key}'>{txt}</a>")
    while last_depth > 1:
        sio.write("</li></ul>")
        last_depth -= 1
    sio.write("</li><li class='toc'><a href='/'>Home</a></li></ul></div>")
    sio.seek(0)
    toc_text = sio.read()

if str.__len__(toc_text) <= 0:
    logger("toc is empty?")
    sys.exit(0)

new_text = text.replace("${toc}", toc_text)
if new_text == text:
    logger("text did not change?")
    sys.exit(0)

logger(f"Writing {str.__len__(new_text)} characters to {file!r}.")
file.write_all_str(str.strip(new_text))
