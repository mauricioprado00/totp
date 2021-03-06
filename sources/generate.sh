

function cmd-generate
{
    local account_name="$1"
    local res
    local key
    local info

    if [[ -z ${account_name} ]]; then
        >&2 echo "Missing account name"
        cmd-generate-help
        return 1
    fi

    account-exists "${account_name}"
    res=$?
    if [ $res -ne 0 ]; then
        >&2 echo "Account does not exists or key is missing"
        let 'res = res + 10'
        return $res
    fi

    info=$(gpg-get-account-key "${account_name}")
    res=$?
    if [ $res -ne 0 ]; then
        >&2 echo "Could not successfully decrypt key"
        let 'res = res + 20'
        return $res;
    fi

    key=$(account-totp "$info")

    if [ -t 1 ]; then
        echo 
        echo "Your code for ${account_name} is ..."
        oathtool -b --totp "$key"
        echo
    else
        oathtool -b --totp "$key"
    fi
}

function cmd-generate-help
{
    local accounts=$(cmd-account-list | sed 's# \|^#\n                     - #g')
    echo
    echo "USAGE:"
    echo "  totp generate <account_name>"
    echo
    echo "  <account_name>  A string identifying the account. one of: ${accounts}"
    echo
    handle-help-commands ${FUNCNAME}
}


function helpdesc-cmd-generate
{
    echo -n "Generates a one-time password"
}

function suggest-generate-tools
{
    local toolname=oathtool

    which ${toolname} > /dev/null
    if [ $? -ne 0 ]; then
        echo -e "\n * You are missing a tool to generate totp keys.\n   Please install oathtool"
    fi

}

autocomplete_generate=cmd-account-list