#!/bin/sh
# @desc Push only tags
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
test -f "$rootPath/config-check.sh" && . "$rootPath/config-check.sh"

# Make build if absent
sh "$scriptsPath/publish-update.sh" || exit 1

TIMESTAMP=`cat $rootPath/build-timestamp.txt`
TIMETAG=`cat $rootPath/build-timetag.txt`
VERSION=`cat $rootPath/build-version.txt`

echo "Publishing build ($VERSION, $TIMESTAMP)..."

# TODO: Compare actual and previously published versions? (The git is checking for changes itself anyway.)

TAG_VALUE=$PUBLISH_TAG_ID.$VERSION
COMMIT_TEXT="Build $TAG_VALUE, $TIMESTAMP ($TIMETAG)"
# echo "Fetch..." && git fetch && git pull && \
cd "$PUBLISH_FOLDER" && \
  echo "Create/update tag $TAG_VALUE..." && git tag -f -am "$COMMIT_TEXT" "$TAG_VALUE" && \
  echo "Push tagged branch with tags..." && git push -f --tags && git pull && \
  echo "Done" && cd ..
  # echo "Don't forget to update version for target project dependency (package.json, WebUiCore entry)"

  # ( ( ( git tag | grep -q "v$VERSION" ) && echo "Tag exist: update" && git tag -d "v$VERSION" ) || echo "Tag absent: create" ) &&
  # ( git tag "v$VERSION" || echo "Tag already exists" ) && \

