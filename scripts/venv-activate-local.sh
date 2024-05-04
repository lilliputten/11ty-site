#!/bin/sh
# @changed 2024.03.07, 21:06

scriptsPath=$(dirname "$(echo "$0" | sed -e 's,\\,/,g')")
rootPath=`dirname "$scriptsPath"`
prjPath=`pwd`

# if uname | grep -q "CYGWIN"; then
#   # NOTE: Must be called directly: otherwise initalizing venv for current execution only.
#   # Use `call .venv/Scripts/activate.bat`
#   cmd /C "utils\\venv-activate-local.cmd"
#   # cmd /C ".\\.venv\\Scripts\\activate.bat"
# else
  source "./.venv/Scripts/activate"
# fi
