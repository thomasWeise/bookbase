#!/bin/bash -

## Render a README.md file
## $1 input file
## $2 output file
## $3 title
## $4 base URL
## $5 formatIn (optional)

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Welcome to the markdown rendering script."

scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): The script directory is '$scriptDir'."

inFile="$(readlink -f "$1")"
outFile="$(realpath "$2")"
title="$3"
baseUrl="$4"
formatIn="${5:-}"

if [ -z "$formatIn" ]; then
  formatIn="markdown"
  echo "$(date +'%0Y-%0m-%0d %0R:%0S'): No format specified, using 'formatIn'."
fi

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): We will render the file '$inFile' to '$outFile' using format '$formatIn', title '$title', and base url '$baseUrl'."

partA="$(<$scriptDir/htmlHeader1.html)"
partB="$(<$scriptDir/htmlHeader2.html)"
partC="$(<$scriptDir/htmlFooter1.html)"
partD="$(<$scriptDir/htmlFooter2.html)"
if [ "$formatIn" = "markdown" ]; then
  rendered="$("$PYTHON_INTERPRETER" -m markdown -o html "$inFile")"
else
  rendered="$(pygmentize -f html -l "$formatIn" "$inFile")"
fi
websiteText="${partA}$title${partB}$rendered$partC$(date +'%0Y-%0m-%0d&nbsp;%0R:%0S&nbsp;%z')$partD"
websiteText="${websiteText//"\"$baseUrl/"/"\"./"}"
websiteText="${websiteText//"=$baseUrl"/"=."}"
echo "$websiteText" > "$outFile"

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Now rendering table of contents."
"$PYTHON_INTERPRETER" "$scriptDir/createHtmlToc.py" "$outFile"

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Done rendering '$inFile' to '$outFile'."
