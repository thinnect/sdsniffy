#!/usr/bin/env bash

script_is_sourced()
{
  if [ "${FUNCNAME[1]}" = source ]; then
    return 0
  fi
  return 1
}

if script_is_sourced; then
    echo "Setting up the environment"
else
    echo "$(tput setaf 1)ERROR: This file needs to be sourced and not executed: source ${0}"
    exit 1
fi

# -----------------------------------------------------------------------------
# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-in/179231#179231
SCRIPT_PATH="${BASH_SOURCE[0]}";
if([ -h "${SCRIPT_PATH}" ]) then
  while([ -h "${SCRIPT_PATH}" ]) do SCRIPT_PATH=`readlink "${SCRIPT_PATH}"`; done
fi
pushd . > /dev/null
cd `dirname ${SCRIPT_PATH}` > /dev/null
SCRIPT_PATH=`pwd`;
popd  > /dev/null
# -----------------------------------------------------------------------------

export TINYOS_ROOT_DIR=$SCRIPT_PATH/tinyos-main

TINYOS_ROOT_DIR_ADDITIONAL=$SCRIPT_PATH/thinnect.tos-groundlib
TINYOS_ROOT_DIR_ADDITIONAL=$TINYOS_ROOT_DIR_ADDITIONAL:$SCRIPT_PATH/thinnect.tos-platforms
TINYOS_ROOT_DIR_ADDITIONAL=$TINYOS_ROOT_DIR_ADDITIONAL:$SCRIPT_PATH/thinnect.tos-watchdogs

export TINYOS_ROOT_DIR_ADDITIONAL=$TINYOS_ROOT_DIR_ADDITIONAL
echo $TINYOS_ROOT_DIR_ADDITIONAL

export WORKSPACE_ROOT=$SCRIPT_PATH
