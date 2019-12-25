
function ggp-encrypt-account-key
{
    local account_name="$1"
    local key_file=$(account-key-file "${account_name}")
    local key_file_encrypted=$(account-key-file-encrypted "${account_name}")

    [ "$account_name" == "" ] && \
        { echo "Usage: $0 service"; return 1; }
    [ ! -f "$key_file" ] && \
        { echo "$0 - Error: $key_file file not found."; return 2; }
    [ -f "$key_file_encrypted" ] && \
        { echo "$0 - Error: Encrypted file "$key_file_encrypted" exists."; return 3; }

    gpg2 --encrypt "$key_file"
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