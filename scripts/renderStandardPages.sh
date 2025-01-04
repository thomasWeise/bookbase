#!/bin/bash -

## Render the standard pages
## $1 input directory
## $2 output directory
## $3 main title
## $4 base url

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Welcome to the standard page rendering script."

scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): The script directory is '$scriptDir'."

inDir="$(realpath "$1")"
outDir="$(realpath "$2")"
title="$3"
baseUrl="$4"

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): We will render the files from '$inDir' to '$outDir' using title '$title' and base url '$baseUrl'."

file="$inDir/README.md"
if [ -f "$file" ]; then
  echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Found README.md as '$file'."
  cp "$file" "$outDir/README.md"
  "$scriptDir/renderToHtml.sh" "$file" "$outDir/index.html" "$title" "$baseUrl"
fi

file="$inDir/LICENSE.md"
if [ -f "$file" ]; then
  echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Found LICENSE.md as '$file'."
  cp "$file" "$outDir/LICENSE.md"
  "$scriptDir/renderToHtml.sh" "$file" "$outDir/LICENSE.html" "$title: License" "$baseUrl"
fi

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Rendering dependencies and packages."
file="$outDir/DEPENDENCIES.md"
echo "## $title Dependencies

<pre>" > "$file"
"$scriptDir/dependencyVersions.sh" >> "$file"
echo "</pre>

python3 -m pip freeze

<pre>" >> "$file"
"$PYTHON_INTERPRETER" -m pip freeze >> "$file"
echo "</pre>" >> "$file"
"$scriptDir/renderToHtml.sh" "$file" "$outDir/DEPENDENCIES.html" "$title: Dependencies" "$baseUrl"
sed -i "s/<pre>/\`\`\`/g" "$file"
sed -i "s/<\/pre>/\`\`\`/g" "$file"

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Now compressing HTML files."
cd "$outDir"
find -type f -name "*.html" -exec "$PYTHON_INTERPRETER" "$scriptDir/minifyHtml.py" "{}" \;

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Creating .nojekyll file."
touch "$outDir/.nojekyll"

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Done with rendering the standard web page files."
