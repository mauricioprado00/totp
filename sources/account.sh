#!/usr/bin/env bash

function cmd-account
{
    handle-command 'cmd-account' 'help' 'invalid-command' "$@"
}

function cmd-account-help
{
    handle-help ${FUNCNAME} "$@"
    echo
    echo "USAGE:"
    echo "  topt account <command>"
    echo
    handle-help-commands ${FUNCNAME}
}

function helpdesc-cmd-account
{
    echo -n "Manage accounts/services"
}

function cmd-account-list
{
    local dir=$(base-account-dir)
    local accounts=$(ls $dir 2>/dev/null)

    if [ -t 1 ]; then
        echo
        if [ ! -z "$accounts" ]; then
            echo Accounts:
            echo ${accounts} | sed 's#\( \)#\n  - #g'
        else 
            echo No accounts found
        fi
        echo
    else 
        echo $accounts
    fi
}

function helpdesc-cmd-account-list
{
    echo -n "List all accounts"
}

function cmd-account-create
{
    local dir=$(base-account-dir)
    local account_name="$1"
    local account_info="$2"
    local account_topt
    local choice

    if [ -z "$account_name" ]; then
        echo 'Please provide account name (use only leters, numbers and hyphens):'

        read account_name

        echo 'the acccount name $account_name'
    fi

    if [ -z "$account_info" ]; then
        echo "Please choose option to provide topt key:"
        echo "a) the topt key"
        echo "b) an image filename with the QR code"
        echo "c) take a screenshot (default action)"

        read -p "Your choice (a/b/c)?" choice
        case "$choice" in 
          a )
            echo 'Please provide the topt key:'
            read account_info;;
          b )
            echo 'Please provide filename of the QR code:'
            read account_info;;
          c|"") 
            account_info=$(screenshot-take)
            if [ $? -ne 0 ]; then
                echo 'Error while taking screenshot'
                return 7
            fi
            ;;
          * ) 
            echo "Invalid option, aborting"
            return 6
            ;;
        esac
        # make sure screenshot image is deleted afterwards
        common-trap-exit-add "safe-rm $account_info"

    fi

    if [[ ${account_name} =~ [^a-zA-Z0-9\.@_-] ]]; then
        >&2 echo "Invalid account name provided"
        return 1
    fi

    if [ -z "$account_name" ]; then
        >&2 echo "Wrong account name ($account_name)"
        exit 2
    fi

    if [ -z "$account_info" ]; then
        >&2 echo "Wrong account topt key ($account_info)"
        exit 3
    fi

    if [ -f "$account_info" ] ; then
        account_info=$(zbarimg "$account_info" 2>/dev/null)
    fi

    account_topt=$(echo "$account_info" | sed 's#.*secret=##g;s#[^a-z0-9].*##gi')

    if [ -z "$account_topt" ]; then
        >&2 echo "Wrong topt key for account ($account_topt)"
        return 4
    fi

    if [ -d ${dir}/${account_name} ]; then
        >&2 echo "Account directory already exists."
        >&2 printf "\t ${dir}/${account_name}\n"
        return 5
    fi

    echo 'Creating new account:'
    echo 'Account Name: '$account_name
    echo 'Topt Key: '$account_topt
    echo 'Location: '${dir}/${account_name}
    mkdir -p ${dir}/${account_name}
    chmod 700 ${dir}
    chmod 700 ${dir}/${account_name}
    # ensure key is shredded in any case
    common-trap-exit-add "safe-rm ${dir}/${account_name}/.key"
    echo -n "${account_topt}" > ${dir}/${account_name}/.key
    chmod 400 ${dir}/${account_name}/.key

    common-trap-exit-add "rmdir ${dir}/${account_name} > /dev/null"
    ggp-encrypt-account-key ${account_name}

    if [ $? -ne 0 ]; then
        echo 'Could not encrypt topt key, aborting and removing account'
        safe-rm ${dir}/${account_name}/.key
        rm -Rf ${dir}/${account_name} > /dev/null
    fi
}

function cmd-account-create-help
{
    echo
    echo "USAGE:"
    echo "  topt account create <account_name> <topt_key>"
    echo
    echo "  <account_name>  A string identifying the account."
    echo "  <topt_key>      A string of the topt code provided by the service or"
    echo "                  A filename of a QR code containing the topt key"
    echo     
}

function helpdesc-cmd-account-create
{
    echo -n "Creates an account"
}

function account-exists
{
    local account_name="$1"

    if [ -z "${account_name}" ]; then
        return 1
    fi
    if [ ! -d "$(account-directory "$account_name")" ]; then
        return 2
    fi

    if [ ! -f "$(account-key-file-encrypted "$account_name")" ]; then
        return 3
    fi

    return 0
}

function account-directory
{
    local dir=$(base-account-dir)
    local account_name="$1"
    echo ${dir}/${account_name}
}

function account-key-file
{
    local account_name="$1"
    local key_file=$(account-directory "$account_name")/.key
    echo ${key_file}
}

function account-key-file-encrypted
{
    local account_name="$1"
    local key_file=$(account-key-file ${account_name})    
    local key_file_encrypted="${key_file}.gpg"
    echo ${key_file_encrypted}
}

function cmd-account-show
{
    local account_name="$1"
    local res
    local key

    if [[ -z ${account_name} || \
        ${account_name} =~ ^(--)?help$  ]]; then
        cmd-account-show-help
    fi

    account-exists "${account_name}"
    res=$?
    if [ $res -ne 0 ]; then
        >&2 echo "Account does not exists or key is missing"
        let 'res = res + 10'
        return $res
    fi

    key=$(gpg-get-account-key "${account_name}")
    res=$?
    if [ $res -ne 0 ]; then
        >&2 echo "Could not successfully decrypt key"
        let 'res = res + 20'
        return $res;
    fi

    if [ -t 1 ]; then
        echo 
    fi

    echo "Account Name: ${account_name}"
    echo "GnuPG Encrypted topt key file: "$(account-key-file-encrypted $account_name)
    echo "Key: ${key}"
    if [ -t 1 ]; then
        echo 
    fi
}

function cmd-account-show-help
{
    local accounts=$(cmd-account-list | sed 's# \|^#\n                     - #g')
    echo
    echo "USAGE:"
    echo "  topt account show <account_name>"
    echo
    echo "  <account_name>  A string identifying the account. one of: ${accounts}"
    echo
}

function helpdesc-cmd-account-show
{
    echo -n "Display account information"
}

autocomplete_account_show=cmd-account-list

function cmd-account-rm
{
    local account_name="$1"
    local res
    local key

    if [[ -z ${account_name} ]]; then
        >&2 echo "Missing account name"
        cmd-account-rm-help
        return 1
    fi

    account-exists "${account_name}"
    res=$?
    if [ $res -ne 0 ]; then
        >&2 echo "Account does not exists or key is missing"
        let 'res = res + 10'
        return $res
    fi

    if [ -t 1 ]; then
        echo 
    fi

    echo "Deleting account"
    echo "Account Name: ${account_name}"
    echo "GnuPG Encrypted topt key file: "$(account-key-file-encrypted $account_name)
    read -p "Continue (y/n)?" choice
    case "$choice" in 
      y|Y|yes )
        rm -Rf $(account-directory "$account_name");;
      n|N ) 
        echo "Cancelled";;
      * ) echo "Invalid option, aborting";;
    esac
    if [ -t 1 ]; then
        echo 
    fi
}

function cmd-account-rm-help
{
    local accounts=$(cmd-account-list | sed 's# \|^#\n                     - #g')
    echo
    echo "USAGE:"
    echo "  topt account rm <account_name>"
    echo
    echo "  <account_name>  A string identifying the account. one of: ${accounts}"
    echo
}

function helpdesc-cmd-account-rm
{
    echo -n "Removes an account"
}

autocomplete_account_rm=cmd-account-list
