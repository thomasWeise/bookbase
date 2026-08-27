#!/bin/bash -

## Print the contents of a file to the stdout.
## $1 the file to print

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

fullDocumentPath="$(realpath "$1")"
if [ -f "$fullDocumentPath" ]; then
  fullDocumentPath="$(readlink -f "$fullDocumentPath")"
  echo "===================== Start of '$fullDocumentPath' =====================."
  cat "$fullDocumentPath"
  echo "===================== End of '$fullDocumentPath' =====================."
else
  echo "===================== Path '$1' = '$fullDocumentPath' does not identify a file =====================."
fi
