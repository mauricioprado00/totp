#!/usr/bin/env bash

source $(basepath)/.env

function base-account-dir()
{
    # variable defined in .env
    echo $dir
}

function base-gpg-key-id()
{
    # variable defined in .env
    echo $kid
}

function base-gpg-user-id()
{
    # variable defined in .env
    echo $uid
}

function safe-rm()
{
    local file="$1"

    which shred > /dev/null
    if [ $? -eq 0 ]; then
        # if available, use shred to safelly delete the key file
        shred -f "$file"
    else
        rm -f "$file"
    fi
}