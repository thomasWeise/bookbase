#!/bin/bash

# Install Python requirements with pip.

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Welcome to requirements installation script."

requirements="$(readlink -f "$1")"  # the script to execute
cycle=1
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Installing requirements from file '$requirements'."
while ! timeout --kill-after=60m 58m "$PYTHON_INTERPRETER" -m pip install --no-input --default-timeout=300 --timeout=300 --retries=100 -r "$requirements" ; do
    cycle=$((cycle+1))
    if (("$cycle" > 100)) ; then
        echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Something odd is happening: We have performed $cycle cycles of pip install and all failed. That's too many. Let's quit."
        exit 2  # A non-zero exit code indicates failure.
    fi
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): pip install failed, we will try again."
done

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Printing the list of all installed packages."
"$PYTHON_INTERPRETER" -m pip freeze

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): We have finished installing the requirements from '$requirements'."
