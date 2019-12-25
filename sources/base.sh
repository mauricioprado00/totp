#!/usr/bin/env bash

function base-account-dir()
{
    echo ~/.topt-2fa/accounts
}

function safe-rm()
{
    local file="$1"

    if [ -f $file ]; then
        which shred > /dev/null
        if [ $? -eq 0 ]; then
            # if available, use shred to safelly delete the key file
            shred -fu "$file"
        else
            rm -f "$file"
        fi
    fi
}