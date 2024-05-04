#!/bin/sh
# @desc Create/update version tag (from build folder)
# @since 2023.01.26, 16:43
# @changed 2024.03.25, 19:18

scriptsPath=$(dirname "$(echo "$0" | sed -e 's,\\,/,g')")
rootPath=`dirname "$scriptsPath"`
prjPath=`pwd`

# Import config variables (expected variables `$DIST_REPO` and `$PUBLISH_FOLDER`)...
test -f "$rootPath/config.sh" && . "$rootPath/config.sh"
test -f "$rootPath/config-local.sh" && . "$rootPath/config-local.sh"
test -f "$prjPath/config.sh" && . "$prjPath/config.sh"
test -f "$prjPath/config-local.sh" && . "$prjPath/config-local.sh"

if [ -z "$SRC_TAG_PREFIX" ]; then
  echo "No tag prefix is specified. Add 'SRC_TAG_PREFIX' parameter in 'config.sh'."
  exit 1
fi

VERSIONFILE="$rootPath/build-version.txt"
if [ ! -f "$VERSIONFILE" ]; then
  echo "No version file ($VERSIONFILE) exist!"
  exit 1
fi

VERSION=`cat "$VERSIONFILE"`

echo "Create/update tag $SRC_TAG_PREFIX.$VERSION..." \
  && git tag -f "$SRC_TAG_PREFIX.$VERSION" \
  && git push origin -f --tags \
  && git pull origin \
  && git push lilliputten -f --tags \
  && echo "OK"

  # && git pull lilliputten \
