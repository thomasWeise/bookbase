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

mkdir -p "$repo"
cd "$repo"
while [ 1 ]; do
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Getting files to download."
    set +o errexit
    data="$(curl -s https://api.github.com/repos/$user/$repo/releases/latest)"
    retcode="$?"
    set -o errexit
    if [ "$retcode" -ne 0 ]; then
      echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Get retcode='$retcode'."
      sleep 1s
      continue
    fi

    set +o errexit
    files="$(grep browser_download_url <<< "$data" | sed -re 's/.*: "([^"]+)".*/\1/')"
    retcode="$?"
    set -o errexit
    if [ "$retcode" -eq 0 ]; then
      for file in $files; do
        set +o errexit
        "$download" "$file"
        retcode="$?"
        set -o errexit
        if [ "$retcode" -ne 0 ]; then continue 2; fi; # check return value, break if successful (0)
      done
      echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Done downloading attached files."
    else
      echo "$(date +'%0Y-%0m-%0d %0R:%0S'): No attached files."
    fi

    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Now getting zip ball."
    set +o errexit
    file="$(grep zipball_url <<< "$data" | sed -re 's/.*: "([^"]+)".*/\1/')"
    retcode="$?"
    set -o errexit
    if [ "$retcode" -eq 0 ]; then
      echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Got zip ball '$file'."
      set +o errexit
      "$download" "$file"
      retcode="$?"
      set -o errexit
      if [ "$retcode" -ne 0 ]; then continue 2; fi; # check return value, break if successful (0)
      echo "$(date +'%0Y-%0m-%0d %0R:%0S'): File donwloaded, now renaming it."
      file="${file##*/}"
      mv "$file" "${repo}_zipball_${file}.zip"
      echo "$(date +'%0Y-%0m-%0d %0R:%0S'): We are done."
      exit 0
    fi
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Error when trying to download releases '$@', trying again after 1 second."
    sleep 1s;
done;
