#!/bin/sh
# @desc Update version number & build timestamps
# @changed 2024.06.12, 02:28

scriptsPath=$(dirname "$(echo "$0" | sed -e 's,\\,/,g')")
rootPath=`dirname "$scriptsPath"`
prjPath=`pwd`

# Import config variables (expected variables `$DIST_REPO` and `$PUBLISH_FOLDER`)...
test -f "$rootPath/config.sh" && . "$rootPath/config.sh"
test -f "$rootPath/config-local.sh" && . "$rootPath/config-local.sh"
test -f "$prjPath/config.sh" && . "$prjPath/config.sh"
test -f "$prjPath/config-local.sh" && . "$prjPath/config-local.sh"

# # Check basic required variables...
# test -f "$rootPath/config-check.sh" && . "$rootPath/config-check.sh" --omit-publish-folder-check

# Run js updater (make changes in `build-*` files; see list below)...
# TODO: To check exit status?
if ! node "$scriptsPath/update-build-time.js"; then
  echo "Failed execution of 'update-build-time.js'!"
  exit 1
fi

# Read variables from changed files...
TIMESTAMP=`cat $rootPath/build-timestamp.txt`
TIMETAG=`cat $rootPath/build-timetag.txt`
VERSION=`cat $rootPath/build-version.txt`

echo "Version/time: $VERSION / $TIMESTAMP"

UPDATE_FILE() {
  FILE=$1
  if [ ! -f $FILE ]; then
    # echo "File $FILE doesn't exists"
    return
  fi
  NAME="${FILE##*/}" # Exract extension
  EXT="${NAME##*.}" # Exract extension
  echo "Processing file $NAME..."
  mv $FILE $FILE.bak || exit 1
  # # TODO: Replace only first occurence of `version`
  if [ "$NAME" = "package-lock.json" ]; then # package-lock
    # NOTE: Update only first occurenece of verion parameter in package-lock...
    echo "package-lock.json"
    cat $FILE.bak \
      | sed "0,/\(\"version\":\) \".*\"/{s//\1 \"$VERSION\"/}" \
    > $FILE || exit 1
  elif [ "$EXT" = "json" ]; then # JSON
    cat $FILE.bak \
      | sed "s/\(\"version\":\) \".*\"/\1 \"$VERSION\"/" \
      | sed "s/\(\"timestamp\":\) \".*\"/\1 \"$TIMESTAMP\"/" \
      | sed "s/\(\"timetag\":\) \".*\"/\1 \"$TIMETAG\"/" \
    > $FILE || exit 1
  elif [ "$EXT" = "local" ]; then # env.local files
    cat $FILE.bak \
      | sed "s/\(version=\)\s*\".*\"/\1\"$VERSION\"/" \
      | sed "s/\(timestamp=\)\s*\".*\"/\1\"$TIMESTAMP\"/" \
      | sed "s/\(timetag=\)\s*\".*\"/\1\"$TIMETAG\"/" \
    > $FILE || exit 1
  elif [ "$EXT" = "py" ]; then # Python
    cat $FILE.bak \
      | sed "s/\(__version__ =\) \([\"']\).*\2/\1 \2$VERSION\2/" \
      | sed "s/\(__timestamp__ =\) \([\"']\).*\2/\1 \2$TIMESTAMP\2/" \
      | sed "s/\(__timetag__ =\) \([\"']\).*\2/\1 \2$TIMETAG\2/" \
    > $FILE || exit 1
  else # MD
    cat $FILE.bak \
      | sed "s/^\(-* *Version:\) .*$/\1 $VERSION/" \
      | sed "s/^\(-* *Last changes timestamp:\) .*$/\1 $TIMESTAMP/" \
      | sed "s/^\(-* *Last changes timetag:\) .*$/\1 $TIMETAG/" \
    > $FILE || exit 1
  fi
  rm $FILE.bak || exit 1
}

UPDATE_FILE "$prjPath/.env.local"
UPDATE_FILE "$prjPath/package.json"
UPDATE_FILE "$prjPath/package-lock.json"
UPDATE_FILE "$prjPath/README.md"
UPDATE_FILE "$prjPath/src/layouts/base.njk"
