#!/bin/bash -

## Make a book draft

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): The script directory is '$scriptDir'."
currentDir="$(pwd)"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): We are working in directory: '$currentDir'."

rm -rf "$currentDir/book.pdf" || true

websiteDir="$currentDir/website"
rm -rf "$websiteDir" || true

bookTex="$currentDir/book.tex"
if [ -f "$bookTex" ]; then
  echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Compiling '$bookTex'."
  "$scriptDir/pdflatex.sh" "$currentDir/book.tex" draft
else
  echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Did not find '$bookTex', quitting."
fi

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Finished the inner book draft building script."
