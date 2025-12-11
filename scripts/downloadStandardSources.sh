#!/bin/bash -

# This script downloads all the sources shared by all book projects.

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Welcome to the standard sources download script."

scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): The script directory is '$scriptDir'."

gitDownload="$(realpath "$scriptDir/gitDownload.sh")"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): The git download script is '$gitDownload'."

gitReleaseDownload="$(realpath "$scriptDir/githubReleaseDownload.sh")"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): The git release download script is '$gitDownload'."

"$gitDownload" "pycommons"
"$gitDownload" "texgit_py"
"$gitDownload" "texgit_tex"
"$gitDownload" "bookbase"

mkdir -p _package_releases_
cd _package_releases_
"$gitReleaseDownload" "pycommons"
"$gitReleaseDownload" "texgit_py"
"$gitReleaseDownload" "texgit_tex"
"$gitReleaseDownload" "bookbase"

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Done with the standard sources download script."
