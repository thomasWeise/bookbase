#!/bin/bash -

# Download one or multiple files using wget.

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value


echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Welcome to using the download script for downloading '$@'."
for i in {1..10}; do
    set +o errexit
    wget --user-agent="Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:83.0) Gecko/20100101 Firefox/83.0" --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 -t 0 --continue --random-wait --no-check-certificate "$@"
    retcode="$?"
    set -o errexit
    if [ "$retcode" -eq 0 ]; then exit; fi; # check return value, break if successful (0)
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Error when trying to download '$@', trying again after 1 second."
    sleep 1s;
done;

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Now trying with limited rate."
while [ 1 ]; do
    set +o errexit
    wget --user-agent="Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:83.0) Gecko/20100101 Firefox/83.0" --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 -t 0 --continue --limit-rate=200k --random-wait --no-check-certificate "$@"
    retcode="$?"
    set -o errexit
    if [ "$retcode" -eq 0 ]; then exit; fi; # check return value, break if successful (0)
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Error when trying to download '$@', trying again after 1 second."
    sleep 1s;
done;

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Finished downloading '$@'."
