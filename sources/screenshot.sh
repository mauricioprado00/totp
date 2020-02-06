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

function suggest-screenshot-tools
{
    declare -A tools
    declare -a tools_names
    declare -- found=0
    screenshot-tool-list tools tools_names

    for toolname in "${tools_names[@]}"; do
        binary_file=$(which ${toolname})
        if [ $? -eq 0 ]; then
            found=1
            break
        fi
    done

    if [ $found -ne 1 ]; then
        echo -e "\n * You are missing a tool to take screenshots.\n   Please install any of these: \n   ${tools_names[@]}"
    fi
}