#!/usr/bin/env bash
__autocomplete_app="$0"
function cmd-autocomplete
{
    handle-command 'cmd-autocomplete' 'help' 'cmd-autocomplete-invalid' "$@"
}

function cmd-autocomplete-invalid
{
    cmd-invalid "${@:2}"
#    cmd-account-help
}

function cmd-autocomplete-help
{
    handle-help ${FUNCNAME} "$@"
    echo
    echo "USAGE:"
    echo "  topt aucotomplete <command>"
    echo
    handle-help-commands ${FUNCNAME}
}

function helpdesc-cmd-autocomplete
{
    echo -n "Manage tool autocompletion"
}


function cmd-autocomplete-register
{
    echo registering "$__autocomplete_app"
    complete -W "about account autocomplete generate" './topt'

}

function helpdesc-cmd-autocomplete-register
{
    echo -n "Register autocompletion in current bash session"
}

function helpdesc-cmd-autocomplete-list
{
    echo -n "List autocompletion options"
}

function cmd-autocomplete-list-help
{
    handle-help ${FUNCNAME} "$@"
    echo
    echo "USAGE:"
    echo "  topt aucotomplete list <comp_words> <comp_cword>"
    echo
    echo "  <comp_words>    list of words typed"
    echo '  <comp_cword>    current typed word number from list'
    echo
    echo "e.g."
    echo '    declare -A COMP_WORDS=([0]="topt" [1]="account" [2]="show" [3]="m" )'
    echo '    declare -- COMP_CWORD="3"'
    echo '   ./topt autocomplete list "${COMP_WORDS[*]}" "${COMP_CWORD}"'
    echo
    echo
    handle-help-commands ${FUNCNAME}
}


function cmd-autocomplete-list
{
    local COMP_WORDS="$1"
    local COMP_CWORD="$2"
    local word
    local cword=0
    local prev_words
    local func_name
    local filter=""

    >&2 declare -p COMP_WORDS
    >&2 declare -p COMP_CWORD

    for word in $COMP_WORDS; do
        if [[ $cword -lt $COMP_CWORD && $cword -gt 0 ]]; then
            if [ -z "$prev_words" ]; then
                prev_words="$word"
            else
                prev_words="${prev_words} $word"
            fi
        elif [ $cword -eq $COMP_CWORD ]; then
            filter="$word"
            break
        fi
        let 'cword++'
    done

    func_name=autocomplete-$(echo "$prev_words" | sed 's# \+#-#g')

    >&2 declare -p prev_words
    >&2 declare -p func_name
    >&2 declare -p word

    type -t "$func_name" > /dev/null
    if [ $? -eq 0 ]; then
        >&2 echo calling $func_name with $filter
        compgen -W "$($func_name)" "$filter"
    fi
}