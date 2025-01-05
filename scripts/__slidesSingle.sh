#!/bin/bash -

## Make a set of slides
# $1 the slide set to make

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

dirName="$1"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Building slide '$dirName'."

scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): The script directory is '$scriptDir'."
currentDir="$(pwd)"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): We are working in directory '$currentDir'."

slidesDir="$currentDir/slides"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): The slides directory is '$slidesDir'."

theDir="$slidesDir/$dirName"
if [ -d "$theDir" ]; then
    docName="$dirName.tex"
    if [ -f "$theDir/$docName" ]; then
        echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Found directory '$theDir' with document '$docName'."

        curDirGit="$theDir/__git__"
        rm -rf "$curDirGit" || true

        cd "$theDir"
        "$scriptDir/pdflatex.sh" "$docName" draft

        rm -rf "$curDirGit" || true
        cd "$currentDir"
    else
        echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Error! Found directory '$theDir', but it does not contain a corresponding LaTeX document."
        exit 2
    fi
else
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Error! Directory '$dirName' does not exist!"
    exit 1
fi

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Finished the inner single slide building script."
