#!/usr/bin/env bash

function screenshot-take
{
    local binary_file
    local wait=1
    local tools=(
        "maim"
        "import"
        "gnome-screenshot"
        "scrot"
        "spectacle"
    )
    local tools_format=(
        # maim
        '%s %s'
        # import
        '%s %s'
        # gnome-screenshot
        '%s -f %s -a'
        # scrot
        '%s %s'
        # spectacle
        '%s -b -o %s -r'
    )

    >&2 echo Waiting $wait seconds before taking screenshot
    sleep 1

    for (( ctool=0; ctool < ${#tools[@]}; ctool++ )); do        
        binary_file=$(which ${tools[ctool]})
        if [ $? -eq 0 ]; then
            screenshot-take-generic "$binary_file" "${tools_format[ctool]}"
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