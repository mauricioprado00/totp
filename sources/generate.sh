

function cmd-generate
{
    local account_name="$1"
    local res
    local key

    if [[ -z ${account_name} || \
        ${account_name} =~ ^(--)?help$  ]]; then
        cmd-generate-help
    fi

    account-exists "${account_name}"
    res=$?
    if [ $res -ne 0 ]; then
        echo "Account does not exists or key is missing"
        return $res
    fi

    key=$(gpg-get-account-key "${account_name}")
    res=$?
    if [ $res -ne 0 ]; then
        echo "Could not successfully decrypt key"
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
    echo
    echo "USAGE:"
    echo "  topt generate <account_name>"
    echo
    echo "  <account_name>:"
    echo "          Can be listed with \`topt account list\`"
    cmd-account-list
}
