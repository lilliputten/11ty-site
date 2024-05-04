#!/bin/sh
# @desc Update publish folder (prepare remote update)
# @since 2023.01.26, 16:43
# @changed 2024.03.07, 21:06

scriptsPath=$(dirname "$(echo "$0" | sed -e 's,\\,/,g')")
rootPath=`dirname "$scriptsPath"`
prjPath=`pwd`

# Import config variables (expected variables `$DIST_REPO` and `$PUBLISH_FOLDER`)...
test -f "$rootPath/config.sh" && . "$rootPath/config.sh"
test -f "$rootPath/config-local.sh" && . "$rootPath/config-local.sh"
test -f "$prjPath/config.sh" && . "$prjPath/config.sh"
test -f "$prjPath/config-local.sh" && . "$prjPath/config-local.sh"

# Check basic required variables...
test -f "$rootPath/config-check.sh" && . "$rootPath/config-check.sh" # --omit-publish-folder-check

BUILD_FOLDER="build"

# Make build if absent
test -d "$BUILD_FOLDER" || npm run -s build || exit 1

TIMESTAMP=`cat $rootPath/build-timestamp.txt`
TIMETAG=`cat $rootPath/build-timetag.txt`
VERSION=`cat $rootPath/build-version.txt`

echo "Updating ($VERSION, $TIMESTAMP) publish folder '$PUBLISH_FOLDER' from build folder '$BUILD_FOLDER'..."

cd "$PUBLISH_FOLDER" && \
  pwd && \
  rm -Rf * && \
  cp -Rfu ../$BUILD_FOLDER/* . && \
  cp -Rfu ../$BUILD_FOLDER/.[^.]* . && \
  cd .. && \
  echo OK
  # If we have dot (`.*`, hidden) files in build:
  # cp -Rfu ../$BUILD_FOLDER/.[^.]* . && \
