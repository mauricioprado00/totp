

function cmd-generate
{
    local account_name="$1"
    local res
    local key

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

    key=$(gpg-get-account-key "${account_name}")
    res=$?
    if [ $res -ne 0 ]; then
        >&2 echo "Could not successfully decrypt key"
        let 'res = res + 20'
        return $res;
    fi

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
    echo "  topt generate <account_name>"
    echo
    echo "  <account_name>  A string identifying the account. one of: ${accounts}"
    echo
    handle-help-commands ${FUNCNAME}
}


function helpdesc-cmd-generate
{
    echo -n "Generates a one-time password"
}