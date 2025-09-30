#!/bin/bash -

## Make a book
# $1 book document name
# $2 book title
# $3 book base URL

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

document="$1"
title="$2"
baseUrl="$3"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Building '$title' document '$document' for '$baseUrl'."

scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): The script directory is '$scriptDir'."
currentDir="$(pwd)"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): We are working in directory '$currentDir'."

rm -rf "$currentDir/book.pdf" || true

websiteDir="$currentDir/website"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): The website directory is '$websiteDir'."
rm -rf "$websiteDir" || true

bookTex="$currentDir/book.tex"
if [ -f "$bookTex" ]; then
  echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Compiling '$bookTex'."
  "$scriptDir/pdflatex.sh" "$currentDir/book.tex"

  echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Creating website directory '$websiteDir'."
  mkdir -p "$websiteDir"

  if [[ $(declare -p NO_PDF_OPT 2>/dev/null) != declare\ ?x* ]]; then
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Minifying book 'book.pdf' to '$document.pdf'."
    "$scriptDir/pdfsizeopt.sh" "$currentDir/book.pdf" "$websiteDir/$document.pdf"
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Done minifying book 'book.pdf' to '$document.pdf'."
  else
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Not minifying book, because NO_PDF_OPT was specified."
    mv "$currentDir/book.pdf" "$websiteDir/$document.pdf"
  fi

  echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Rendering default html pages."
  "$scriptDir/renderStandardPages.sh" "$currentDir" "$websiteDir" "$title" "$baseUrl"

  echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Setting access mode for files in '$websiteDir'."
  chmod -R 777 "$websiteDir"

else
  echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Did not find '$bookTex', quitting."
fi

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Finished the inner book building script."
