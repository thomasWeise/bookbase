#!/bin/bash -

# This script downloads git hub release.

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Welcome to using the git download script for '$@'."

repo="$1"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): repository is '$repo'."

user="${2:-}"
if [[ -n "$user" ]]; then
	echo "$(date +'%0Y-%0m-%0d %0R:%0S'): User '$user' specified."
else
  user="thomasWeise"
	echo "$(date +'%0Y-%0m-%0d %0R:%0S'): No user specified, using '$user'."
fi

scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): The script directory is '$scriptDir'."

download="$(realpath "$scriptDir/download.sh")"

while [ 1 ]; do
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Getting files to download."
    set +o errexit
    files="$(curl -s https://api.github.com/repos/$user/$repo/releases/latest | grep browser_download_url | sed -re 's/.*: "([^"]+)".*/\1/')"
    retcode="$?"
    set -o errexit
      echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Get retcor=$retcode and files '$files'."
    if [ "$retcode" -eq 0 ]; then
      for file in $files; do
        set +o errexit
        "$download" "$file"
        retcode="$?"
        set -o errexit
        if [ "$retcode" -ne 0 ]; then continue 2; fi; # check return value, break if successful (0)
      done
      echo "$(date +'%0Y-%0m-%0d %0R:%0S'): We are done."
      exit 0
    fi; # check return value, break if successful (0)
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Error when trying to download releases '$@', trying again after 1 second."
    sleep 1s;
done;
