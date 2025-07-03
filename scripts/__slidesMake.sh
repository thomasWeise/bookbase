#!/bin/bash -

## Make a set of slides
# $1 book title
# $2 book base URL

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

title="$1"
baseUrl="$2"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Building all '$title' slides for '$baseUrl'."

scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): The script directory is '$scriptDir'."
currentDir="$(pwd)"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): We are working in directory '$currentDir'."
slidesDir="$currentDir/slides"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): The slides directory is '$slidesDir'."

"$scriptDir/__slidesMulti.sh" "$title" "$baseUrl" "$slidesDir/"[0-9]*

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Finished the inner all slides building script."
