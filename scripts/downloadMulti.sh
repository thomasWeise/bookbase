#!/bin/bash -

# Download one or multiple files using wget.

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): The script directory is '$scriptDir'."

baseUrl="$1"
if [[ $baseUrl == node* ]]; then
  echo "$(date +'%0Y-%0m-%0d %0R:%0S'): The base URL is '$baseUrl'."
else
  baseUrl="https://thomasweise.github.io/${baseUrl}"
  echo "The URL suffix is '$1' and the base URL is '$baseUrl'."
fi

for file in "${@:2}"; do
  "$scriptDir/download.sh" "$baseUrl/$file"
done

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Finished downloading all files."
