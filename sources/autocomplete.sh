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
    local func_name
    local idx

    # convert string to array
    IFS=' ' read -r -a COMP_WORDS <<< "${COMP_WORDS}"

    # reverse walk the array to find a handling function name
    for (( idx=COMP_CWORD; idx >= 1 ; idx-=1 )); do
    #for idx in `eval echo $(echo -n {${COMP_CWORD}..1})`; do
        func_name=autocomplete-`echo ${COMP_WORDS[@]:1:$idx} | sed 's# #-#g'`

        if [[ `type -t "$func_name" 2>/dev/null` == "function" && $? -eq 0 ]]; then
            # call found function to obtain list of words
            compgen -W "$($func_name)" "${COMP_WORDS[@]:(( $idx + 1 ))}"
            break
        fi
    done
}