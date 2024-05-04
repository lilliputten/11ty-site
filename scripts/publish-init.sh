#!/bin/sh
# @desc Initialize publish syncing repository
# @changed 2024.03.07, 21:06

scriptsPath=$(dirname "$(echo "$0" | sed -e 's,\\,/,g')")
rootPath=`dirname "$scriptsPath"`
prjPath=`pwd`

# Import config variables (expected variables `$DIST_REPO` and `$PUBLISH_FOLDER`)...
test -f "$rootPath/config.sh" && . "$rootPath/config.sh"
test -f "$rootPath/config-local.sh" && . "$rootPath/config-local.sh"
test -f "$prjPath/config.sh" && . "$prjPath/config.sh"
test -f "$prjPath/config-local.sh" && . "$prjPath/config-local.sh"

# # Check basic required variables...
test -f "$rootPath/config-check.sh" && . "$rootPath/config-check.sh" --omit-publish-folder-check

# Publish folder should be absent...
# NOTE: For uninstall/reinitialize publish submodule, use:
if [ -d "$PUBLISH_FOLDER" ]; then
  echo "Publish folder already exists!"
  echo "Remove it first for re-initializing using command:"
  echo "'rm -Rf "$PUBLISH_FOLDER" ".gitmodules" ".git/modules/$PUBLISH_FOLDER"'"
  echo "or"
  echo "'sh utils/publish-uninit.sh'."
  exit # Successfull exit
  # # Alterative behaviors...
  # exit 1 # Exit with error code
  # echo "Uninstalling submodule..."
  # . "$scriptsPath/publish-uninit.sh"
fi

echo "Initializing publish folder & submodule for '$PUBLISH_FOLDER'..."

echo "Init publish submodule with $DIST_REPO ..."
touch ".gitmodules" && \
  git submodule add -f "$DIST_REPO" "$PUBLISH_FOLDER" && \
  git rm --cached -f "$PUBLISH_FOLDER" ".gitmodules" && \
  test ! -z "$DIST_BRANCH" && ( \
    echo "Switch to branch '$DIST_BRANCH' ..." && \
    cd "$PUBLISH_FOLDER" && \
    git checkout "$DIST_BRANCH" && \
    cd .. \
  ) && \
  echo OK
