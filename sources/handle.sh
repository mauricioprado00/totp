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

function handle-help-commands() {
    local current="$1"
    local name=${1%%-help}
    local commands=$(declare -F | \
        sed 's#^declare -f ##g' | \
        grep '^helpdesc' | \
        grep -F "$name" | \
        sed 's#^helpdesc\-'${name}'-##g' | \
        grep -v '[^a-zA-Z0-9]' | sort)
    local command
    local long_desc

    if [[ $(type -t "helpdesc-${name}") = "function" ]]; then
        printf '%s\n\n' "$(helpdesc-${name})"
    fi

    if [ -z "$commands" ]; then
        return
    fi
    echo "  <command>:"
    for command in $commands; do
        printf '%*s%*s' 15 "${command}" 5 ' '
        helpdesc-${name}-${command}
        printf '\n'
    done
    echo
}

function handle-command() {
    local prefix="$1"
    local help="$2"
    local invalid="$3"
    local action=${4}
    local action2=${5}
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
        if [[ ${action2} =~ ^(--)?help$  ]]; then
            what=$(type -t "${cmd}-help")
            if [ "$what" = "function" ]; then
                ${cmd}-help ${@:6}
                return
            fi
        fi

        # execute the action
        $cmd "${@:5}"
    fi

}