#!/bin/sh
# @desc Initialize python venv
# @changed 2024.03.07, 21:06

scriptsPath=$(dirname "$(echo "$0" | sed -e 's,\\,/,g')")
rootPath=`dirname "$scriptsPath"`
prjPath=`pwd`

TARGET_SERVER_BRANCH="server"
TARGET_SERVER_ORIGIN="lilliputten"

test -f "$rootPath/config.sh" && . "$rootPath/config.sh"
test -f "$rootPath/config-local.sh" && . "$rootPath/config-local.sh"
test -f "$prjPath/config.sh" && . "$prjPath/config.sh"
test -f "$prjPath/config-local.sh" && . "$prjPath/config-local.sh"

git update-index --refresh

GIT_CHANGES=`git diff-index HEAD --`

if [ "$GIT_CHANGES" != "" ] && [[ ! "$*" =~ .*--allow-uncommited-changes.* ]]; then
  echo "The project has uncommited changes. Please commit them before merging."
  exit 1
fi

CURRENT_BRANCH=`git rev-parse --abbrev-ref HEAD`

echo "Current branch: $CURRENT_BRANCH"
echo "Target branch: '$TARGET_SERVER_BRANCH"
echo "Trying to merge current branch into the target..."

git checkout $TARGET_SERVER_BRANCH \
  && git pull && \
  git merge -X theirs $CURRENT_BRANCH && \
  git push $TARGET_SERVER_ORIGIN && \
  git checkout $CURRENT_BRANCH && \
  echo Ok

# Alternate approach (for the case of conflicts):
# git rebase -X theirs $CURRENT_BRANCH && \
# git push --force-with-lease && \
