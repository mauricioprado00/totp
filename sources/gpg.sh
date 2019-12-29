function gpg-check-keys
{
    local keys=$(gpg2 --list-secret-keys --keyid-format long)
    local choice
    if [ -z "$keys" ]; then
        echo "You dont have private keys. Do you wish to create one now?"
        read -p "Your choice (y/n)?" choice
        case $choice in
            y|Y|yes) 
                gpg-generate-key
            ;;
            *)
                echo "Please retry after creating a key with:"
                echo "gpg --full-gen-key"
                return 1
            ;;
        esac
    fi
}

function gpg-generate-key
{
    gpg --full-gen-key 2>/dev/null
}
function ggp-encrypt-account-key
{
    local account_name="$1"
    local key_file=$(account-key-file "${account_name}")
    local key_file_encrypted=$(account-key-file-encrypted "${account_name}")
    local keys
    local uid

    gpg-check-keys

    if [ $? -ne 0 ]; then
        echo "Abort missing encrypting key"
        return 4
    fi

    # if only one key, use that
    if [ $(gpg --list-secret-keys --keyid-format LONG |  grep ssb | wc -l) == 1 ]; then
        uid=$(gpg --list-secret-keys --keyid-format LONG | grep uid | sed 's#.*<##g;s#>.*##g')
        uid='-r '$uid
    fi

    [ "$account_name" == "" ] && \
        { echo "Usage: $0 service"; return 1; }
    [ ! -f "$key_file" ] && \
        { echo "$0 - Error: $key_file file not found."; return 2; }
    [ -f "$key_file_encrypted" ] && \
        { echo "$0 - Error: Encrypted file "$key_file_encrypted" exists."; return 3; }

    gpg2 $uid --encrypt "$key_file"
}

function gpg-get-account-key
{
    local account_name="$1"
    local key_file_encrypted=$(account-key-file-encrypted "${account_name}")

    # failsafe stuff
    [ "$account_name" == "" ] && \
        { echo "Usage: $0 service"; return 1; }
    [ ! -f "$key_file_encrypted" ] && \
        { echo "Error: Encrypted file "$key_file_encrypted" not found."; return 2; }

    gpg2 --quiet --decrypt "$key_file_encrypted"
}