#!/bin/sh
# @desc Update build date/time tag file with current timestamp
# @changed 2024.03.07, 21:06
# NOTE: This script updates only .txt files not properties in `package.json`.
# Use `update-build-variables.sh` script before build.

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

node "$scriptsPath/update-build-time.js" --tz=$TIMEZONE
