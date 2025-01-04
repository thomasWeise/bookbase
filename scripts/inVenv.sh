#!/bin/bash

# Execute a script inside a virtual environment-

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Welcome to the virtual environment script."
script="$(readlink -f "$1")"  # the script to execute
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): We will execute '$script' with arguments '${@:2}'."

scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): The script directory is '$scriptDir'."

if [[ $(declare -p PYTHON_INTERPRETER 2>/dev/null) != declare\ ?x* ]]; then
  echo "$(date +'%0Y-%0m-%0d %0R:%0S'): No virtual environment found."
  venvDir="$(mktemp -d)"
  echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Got temp dir '$venvDir', now creating environment in it."
  python3 -m venv --upgrade-deps --copies "$venvDir"
  echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Activating virtual environment in '$venvDir'."
  source "$venvDir/bin/activate"
  export PYTHON_INTERPRETER="$venvDir/bin/python3"
  echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Setting python interpreter to '$PYTHON_INTERPRETER'."
  "$scriptDir/pipInstall.sh" "$scriptDir/../requirements.txt"
  needCleanup=true
else
  echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Virtual environment with interpreter '$PYTHON_INTERPRETER' detected. Using that one."
  needCleanup=false
fi

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Now running '$script'."
"$script" "${@:2}"

if [ "$needCleanup" = true ]; then
  echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Deactivating virtual environment."
  deactivate
  if [ -d "$venvDir" ]; then
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Deleting virtual environment '$venvDir'."
    rm -rf "$venvDir"
  else
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): '$venvDir' is not a directory?."
  fi
fi

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): We have finished the virtual environment wrapper."
