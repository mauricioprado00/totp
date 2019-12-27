#!/usr/bin/env bash
__autocomplete_app="$0"
function cmd-autocomplete
{
    handle-command 'cmd-autocomplete' 'help' 'invalid-command' "$@"
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
    >&2 echo Use following script to generate autocomplete $0
    cat <<OUT 

function topt_complete () {
    local words=("\${COMP_WORDS[@]}");
    unset words[0];
    unset words[\$COMP_CWORD];
    local completions=\$(./topt autocomplete list "\${COMP_WORDS[*]}" "\${COMP_CWORD}");
    COMPREPLY=(\$(compgen -W "\$completions" -- "\$word"));
}

complete -F topt_complete $0

OUT
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

    # convert string to array
    IFS=' ' read -r -a COMP_WORDS <<< "${COMP_WORDS}"

    # reverse walk the array to find a handling function name
    for (( ; COMP_CWORD >= 1 ; COMP_CWORD-=1 )); do
    #for idx in `eval echo $(echo -n {${COMP_CWORD}..1})`; do
        func_name=autocomplete_`echo ${COMP_WORDS[@]:1:$COMP_CWORD} | sed 's# #_#g'`

        declare -p ${func_name} 1>/dev/null 2>&1
        if [ $? -eq 0 ]; then
            # found variable containing function name
            eval 'func_name=$'$func_name
        fi

        if [[ `type -t "$func_name" 2>/dev/null` == "function" && $? -eq 0 ]]; then
            # call found function to obtain list of words
            compgen -W "$($func_name)" "${COMP_WORDS[@]:(( $COMP_CWORD + 1 ))}"
            break
        fi
    done

    # find a command name just like what is being typed
    COMP_CWORD=${#COMP_WORDS[@]}
    COMP_CWORD=$(($2 > COMP_CWORD ? COMP_CWORD : $2 ))
    func_name=${COMP_WORDS[@]:1:$COMP_CWORD}
    func_name=cmd-`echo ${COMP_WORDS[@]:1:$COMP_CWORD} | sed 's# #-#g'`
    if [[ $func_name =~ ^[a-z-]+$ ]]; then
        if [[ ${#COMP_WORDS[@]} -le $COMP_CWORD && $COMP_CWORD -gt 1 ]]; then
            func_name=${func_name}'-'
        fi
        IFS=" " read -r -a func_name <<< $(declare -F | \
            awk '{print $NF}' | \
            sort | uniq | \
            grep '^'$func_name | \
            awk -F '-' $COMP_CWORD' == NF-1 {print $NF }' | tr '\n' ' ')
        echo ${func_name[@]}
    fi
}