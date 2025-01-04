"""A small script for minifying HTML pages."""
import sys
from typing import Final

import minify_html
from pycommons.io.console import logger
from pycommons.io.path import Path

file: Final[Path] = Path(sys.argv[1])
logger(f"Now minifying {file!r}.")
text: str = file.read_all_str()
orig_len: Final[int] = str.__len__(text)
logger(f"Read {orig_len} characters from {file!r}.")

text = minify_html.minify(
    text, do_not_minify_doctype=True,
    ensure_spec_compliant_unquoted_attribute_values=True,
    keep_html_and_head_opening_tags=False,
    minify_css=True,minify_js=True,
    remove_bangs=True,
    remove_processing_instructions=True)

if "<pre" not in text:
    text = " ".join(map(str.strip, text.splitlines()))

new_len: Final[int] = str.__len__(text)

if new_len < orig_len:
    logger(f"Writing {new_len} characters to {file!r}.")
    file.write_all_str(str.strip(text))
else:
    logger("Now length improvement found.")
