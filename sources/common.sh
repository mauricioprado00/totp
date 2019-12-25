#!/usr/bin/env bash

function common-basepath() {
    echo $__common_bindir
}

# obtain complete path of a directory
# directory must exist
# lookbehind: allows you to resolve path of an 
#   unexistent path, you must specify the 
#   amount of directories to look behind for a
#   real path
function common-rpath() { 
    local target=$1
    local lookbehind=$2
    local suffix=''
    local result;
    
    if [ -f $target ] && [ -z "$lookbehind" ]; then
        lookbehind=1
    fi
    
    if [ ! -z "$lookbehind" ]; then
        for idx in $(seq 1 $lookbehind); do
            suffix='/'$(basename $target)$suffix
            target=$(dirname $target)
        done
    fi

    pushd $target > /dev/null; 
    result=$(pwd); 
    popd > /dev/null; 
    
    echo $result$suffix; 
}

function common-alias() {
    eval "function $1() { $2 \$@; }"
}

__common_bindir=$(common-rpath $(dirname $0))

function depends () {
    pushd $__common_bindir > /dev/null
    for filename in $@
    do
        source $filename.sh 
    done
    popd > /dev/null
}

__common_trap_list=()
function common-trap-exit-add() {
    __common_trap_list+=("$@")
}
function common-trap-exit() {
    local trap_command
    for trap_command in "${__common_trap_list[@]}"; do
        eval $trap_command
    done
}

trap common-trap-exit EXIT
