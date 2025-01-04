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
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Building '$title' slides for '$baseUrl'."

scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): The script directory is '$scriptDir'."
currentDir="$(pwd)"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): We are working in directory '$currentDir'."

websiteDir="$currentDir/website"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): The website directory is '$websiteDir'."
rm -rf "$websiteDir" || true

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Creating website directory '$websiteDir'."
mkdir -p "$websiteDir"

slidesDir="$currentDir/slides"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): The slides directory is '$slidesDir'."

lastLatexGit=""
for dirName in "$slidesDir/"*; do
    dirName="$(basename "$dirName")"
    theDir="$slidesDir/$dirName"
    if [ -d "$theDir" ]; then
        docName="$dirName.tex"
        if [ -f "$theDir/$docName" ]; then
            echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Found directory '$theDir' with document '$docName'."

            curDirGit="$theDir/__git__"
            rm -rf "$curDirGit"
            if [ -n "$lastLatexGit" ]; then
                mv "$lastLatexGit" "$theDir"
                lastLatexGit=""
            fi

            cd "$theDir"
            "$scriptDir/pdflatex.sh" "$docName"
            "$scriptDir/pdfsizeopt.sh" "$dirName.pdf" "$websiteDir/$dirName.pdf"
            rm "$dirName.pdf"

            if [ -d "$curDirGit" ]; then
                echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Git directory is $curDirGit."
                lastLatexGit="$(realpath "$curDirGit")"
                echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Canonicalized git directory is $lastLatexGit."
            fi
            cd "$currentDir"
        else
            echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Found directory '$theDir', but it does not contain a corresponding LaTeX document."
        fi
    fi
done

if [ -d "$lastLatexGit" ]; then
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Cleaning up '$lastLatexGit'."
    rm -rf "$lastLatexGit"
fi

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Rendering default html pages."
"$scriptDir/renderStandardPages.sh" "$currentDir" "$websiteDir" "$title" "$baseUrl"

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Setting access mode for files in '$websiteDir'."
chmod -R 777 "$websiteDir"

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Finished the inner slides building script."
