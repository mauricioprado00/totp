#!/usr/bin/env bash
function screenshot-tool-list
{
    declare -A list
    list['import']="%s %s"
    list['gnome-screenshot']="%s -f %s -a"
    list['scrot']='%s %s'
    list['spectacle']='%s -b -o %s -r'
    list['maim']='%s %s'

    if [ ! -z "$2" ]; then
        # the orders
        eval $2'=(import gnome-screenshot scrot spectacle maim)'
    fi
    # the items
    eval $1$(declare -p list | sed 's#declare -[aA] list##g')
}
function screenshot-take
{
    local binary_file
    local wait=1
    local toolname
    local tools_names

    declare -A tools
    declare -a tools_names
    screenshot-tool-list tools tools_names

    >&2 echo Waiting $wait seconds before taking screenshot
    sleep $wait
    for toolname in "${tools_names[@]}"; do
        binary_file=$(which ${toolname})
        if [ $? -eq 0 ]; then
            screenshot-take-generic "$binary_file" "${tools[$toolname]}"
            return
        fi
    done

    >&2 "Missing tool to take screenshot. Please install either imagemagik, scrot, gnome-screenshot, spectacle or malm"
    return 1
}

function screenshot-take-generic
{
    local file=$(mktemp /tmp/XXXXXXX.png)
    local cmd=$(printf "$2" "$1" "$file")
    >&2 echo creating screenshot with $1 in $file
    $cmd
    if [ $? -ne 0 ]; then
        return 1
    fi

    echo ${file}    
}