#!/usr/bin/env bash

function screenshot-take
{
    local binary_file
    local wait=1
    local tools=("import" "gnome-screenshot" "scrot" "spectacle")

    >&2 echo Waiting $wait seconds before taking screenshot
    sleep 1

    for (( ctool=0; ctool < ${#tools[@]}; ctool++ )); do        
        binary_file=$(which ${tools[ctool]})
        if [ $? -eq 0 ]; then
            screenshot-take-${tools[ctool]} $binary_file
            return
        fi
    done

    >&2 "Missing tool to take screenshot. Please install either imagemagik, scrot, gnome-screenshot or spectacle"
    return 1
}

# try use spectacle
function screenshot-take-spectacle
{
    local file=$(mktemp /tmp/XXXXXXX.png)
    >&2 echo creating screenshot with $1 in $file
    $1 -b -o ${file} -r
    if [ $? -ne 0 ]; then
        return 1
    fi

    echo ${file}    
}

# try use gnome-screenshot
function screenshot-take-gnome-screenshot
{
    local file=$(mktemp /tmp/XXXXXXX.png)
    >&2 echo creating screenshot with $1 in $file
    $1 -f ${file} -a
    if [ $? -ne 0 ]; then
        return 1
    fi

    echo ${file}    
}

# try use scrot
function screenshot-take-scrot
{
    local file=$(mktemp /tmp/XXXXXXX.png)
    >&2 echo creating screenshot with $1 in $file
    $1 ${file}
    if [ $? -ne 0 ]; then
        return 1
    fi

    echo ${file}    
}

# try use import (imagemagik)
function screenshot-take-import
{
    local file=$(mktemp /tmp/XXXXXXX.png)
    >&2 echo creating screenshot with $1 in $file
    $1 ${file}
    if [ $? -ne 0 ]; then
        return 1
    fi

    echo ${file}
}