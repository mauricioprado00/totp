#!/usr/bin/env bash

function handle-help() {
    local current="$1"
    local sub="$2"
    local name=${1%%help}$sub'-help'
    local what=$(type -t "${name}")

    if [ "$what" == 'function' ]; then
        $name "${@:3}"
        exit
    fi
}

function handle-command() {
    local prefix="$1"
    local help="$2"
    local invalid="$3"
    local action=${4}
    local cmd=${action:-${help}}

    cmd=${prefix}-${cmd}

    if [ "$action" == '--help' ]; then
        cmd=${prefix}-help
    fi

    what=$(type -t "${cmd}")

    if [[ -z $what || "$what" != 'function' ]]; then
        ${invalid} $4 "${@:5}"
        ${prefix}-${help}
    else
        # execute the action
        $cmd "${@:5}"
    fi

}