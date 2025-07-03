#!/bin/bash -

## Make a set of slides
# $1 book title
# $2 book base URL
# $3... the single slides

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Welcome to the slides multi-building script."

scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): The script directory is '$scriptDir'."

"$scriptDir/inVenv.sh" "$scriptDir/__slidesMulti.sh" "$@"

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Finished the slides multi-building script, now opening slides."

currentDir="$(pwd)"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): We are working in directory '$currentDir'."
websiteDir="$currentDir/website"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): The website directory is '$websiteDir'."

# Now let's open the slides.
for dirName in "${@:3}"; do
    slide="$websiteDir/$(basename "$dirName").pdf"
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Now opening '$slide'."
    evince "$slide" &
done
