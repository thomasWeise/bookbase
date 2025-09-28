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
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Building multiple '$title' slides for '$baseUrl', got slides request '${@:3}'."

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

lasttexgit=""
for dirName in "${@:3}"; do
    dirName="$(basename "$dirName")"
    theDir="$slidesDir/$dirName"
    if [ -d "$theDir" ]; then
        docName="$dirName.tex"
        if [ -f "$theDir/$docName" ]; then
            echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Found directory '$theDir' with document '$docName'."

            curDirGit="$theDir/__git__"
            rm -rf "$curDirGit"
            if [ -n "$lasttexgit" ]; then
                mv "$lasttexgit" "$theDir"
                lasttexgit=""
            fi

            cd "$theDir"
            "$scriptDir/pdflatex.sh" "$docName"
            if [[ $(declare -p NO_PDF_OPT 2>/dev/null) != declare\ ?x* ]]; then
              echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Minifying slide '$dirName.pdf'."
              "$scriptDir/pdfsizeopt.sh" "$dirName.pdf" "$websiteDir/$dirName.pdf"
              rm "$dirName.pdf"
              echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Done minifying slide '$dirName.pdf'."
            else
              echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Not slide '$dirName.pdf', because NO_PDF_OPT is specified."
              mv "$dirName.pdf" "$websiteDir/$dirName.pdf"
            fi

            if [ -d "$curDirGit" ]; then
                echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Git directory is $curDirGit."
                lasttexgit="$(realpath "$curDirGit")"
                echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Canonicalized git directory is $lasttexgit."
            fi
            cd "$currentDir"
        else
            echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Found directory '$theDir', but it does not contain a corresponding LaTeX document. So we skip it."
        fi
    fi
done

if [ -d "$lasttexgit" ]; then
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Cleaning up '$lasttexgit'."
    rm -rf "$lasttexgit"
fi

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Rendering default html pages."
"$scriptDir/renderStandardPages.sh" "$currentDir" "$websiteDir" "$title" "$baseUrl"

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Setting access mode for files in '$websiteDir'."
chmod -R 777 "$websiteDir"

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Finished the multiple slides building script."
