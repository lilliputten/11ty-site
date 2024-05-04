#!/bin/sh
# @desc Initialize python venv
# @changed 2024.03.07, 21:06

scriptsPath=$(dirname "$(echo "$0" | sed -e 's,\\,/,g')")
rootPath=`dirname "$scriptsPath"`
prjPath=`pwd`

test -f "$rootPath/config.sh" && . "$rootPath/config.sh"
test -f "$rootPath/config-local.sh" && . "$rootPath/config-local.sh"
test -f "$prjPath/config.sh" && . "$prjPath/config.sh"
test -f "$prjPath/config-local.sh" && . "$prjPath/config-local.sh"

# Global system requirements...
pip install setuptools virtualenv
# Create venv...
python -m virtualenv -p "$PYTHON_RUNTIME" .venv
# Or with default settings: python -m virtualenv .venv
# Activate venv (use `call .venv/Scripts/activate` for windows)
. ./.venv/Scripts/activate
# Install project dependencies...
pip install -r requirements-general.txt -r requirements-dev-only.txt
# User info...
echo "Use next command to activate venv: '. ./.venv/Scripts/activate'"
echo "Or for windows: 'call .venv/Scripts/activate'"

