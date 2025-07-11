#!/bin/bash -

## Make a single slide
## $1 the slide to make

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Welcome to the slides building script."

scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): The script directory is '$scriptDir'."

"$scriptDir/inVenv.sh" "$scriptDir/__slidesSingle.sh" "$1"

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Finished the slides building script."
evince "slides/$1/$1.pdf" &
