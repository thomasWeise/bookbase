#!/bin/bash -

# This script downloads git repositories.

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

baseUrl="github.com/$user/$repo"

while [ 1 ]; do
    rm -rf "./$repo" || true
    set +o errexit
    git clone --recurse-submodules --depth 1  "ssh://git@$baseUrl" || git clone --recurse-submodules --depth 1  "https://$baseUrl"
    retcode="$?"
    set -o errexit
    if [ "$retcode" -eq 0 ]; then break; fi; # check return value, break if successful (0)
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Error when trying to download '$@', trying again after 1 second."
    sleep 1s;
done;

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Downloaded repository '$repo', now cleaning up git data."
cd "$repo"
find "." -name ".git" -type d -prune -exec rm -rf "{}" \;
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Now pruning empty directories."
find "." -name "*" -type d -empty -delete

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Finished with the git download script for downloading '$@'."
